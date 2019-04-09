--[[
LuCI - Lua Configuration Interface

Copyright 2011 Manuel Munz <freifunk somakoma de>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

]]--

module ("luci.controller.iodata.firmware", package.seeall)
local http = require "luci.http"
local sys = require("luci.sys")
local uci = require("luci.model.uci").cursor()
local csrf = require("luci.csrf")

function index()
	entry({"content", "system_settings", "firmware"}, call("action_firmware"), _("Firmware"), 4)
end


function setFileHandler(pathname)
	local sys = require "luci.sys"
	local fs = require "luci.fs"
	local fp

	luci.http.setfilehandler(
		function(meta, chunk, eof)
			if meta == nil then
				return
			end

			if not fp then
				fp = io.open(pathname, "w")
			end
			--actually do the uploading.
			if chunk then
				fp:write(chunk)
			end
			if eof then
				fp:close()
			end
		end
	)
end

function updateFW(pathname)
	local ret = 0;

	-- check FW integrity
	local cmd = "/sbin/mstc_fwcheck " .. pathname .. " > /dev/null 2>&1";
	ret = sys.call(cmd);
	
	--MSTC MBA Sean, check firmware id, if not the same, abort upgrade.
	if get_current_firmware_id() ~= get_uploaded_firmware_id() then
		ret = 1
	end
	
	if ret == 0 then
		-- delay 2 seconds to do flash writing in background
		cmd = "/bin/sleep 2 && /sbin/sysupgrade -n " .. pathname .. " > /dev/console 2>&1 &";
		sys.call(cmd);
		-- show countdown page
		-- http.write("<script type=\"text/javascript\">window.top.location=window.top.location+\"/content/system_settings/firmware/countdown\"</script>");
	else
		-- delete file if FW is invalid
		cmd = "/bin/rm -f " .. pathname .. " > /dev/null";
		sys.call(cmd);
	end

	return ret;
end

function saveAutoUpdateConfig()
	uci:set("system", "firmware", "firmware");

	local updateability = luci.http.formvalue("updateability");
	uci:set("system", "firmware", "updateability", updateability);

	if updateability == '2' then -- Auto Update
		local scheduleability = luci.http.formvalue("scheduleability");
		uci:set("system", "firmware", "scheduleability", scheduleability);
		if scheduleability == '0' then -- User-defined time
			local daysmask = luci.http.formvalue("hdaysmask");
			uci:set("system", "firmware", "daysmask", daysmask);

			local startTimeHour = luci.http.formvalue("startTimeHour");
			uci:set("system", "firmware", "startTimeHour", startTimeHour);

			local startTimeMin = luci.http.formvalue("startTimeMin");
			uci:set("system", "firmware", "startTimeMin", startTimeMin);
		end
	end
	uci:commit("system")

	local cmd = "/usr/sbin/auto_fwupdate_scheduler";
	sys.call(cmd);
end

function action_firmware()
	local ret = 0;
	local fwPathname = "/tmp/fw.bin";
	setFileHandler(fwPathname); -- don't add any form operation before this line

	--luci.template.render("iodata/firmware");
	local apply = luci.http.formvalue("apply");
	if apply then
	
		--[[=========CSRF check Start=========--]]
		local csrf_token_web = csrf.get_csrf_token_in_web()
		--if csrf token is wrong or can't get it from web, return 403
		if ( not csrf.verify(csrf_token_web) ) then
			wrong_value = true;
			csrf.http_return_403()
			return
		end
		--[[=========CSRF check End=========--]]
	
		local sendbutton = luci.http.formvalue("sendbutton");
		if sendbutton == "0" then -- user upload a file to update
			ret = updateFW(fwPathname);
			if ret ~= 0 then
				luci.template.render("iodata/firmware");
				http.write("<script type=\"text/javascript\">showInvalidMessage();</script>");
			else
				luci.template.render("iodata/firmware", {updateFwSuccess=1});
			end
		else -- configure auto-firmware update
			luci.template.render("iodata/firmware");
			saveAutoUpdateConfig();
		end
	else
		luci.template.render("iodata/firmware");
	end
end

function get_current_firmware_id()
	local firmware_id = "current_firmware_id"
	file = io.popen("sys atsh | grep \'Firmware Version\'", 'r')
	if file then
		local data_raw = file:read()
		if data_raw then
			firmware_id = data_raw:match(".+:%s.+%((.+)%.%d%).+")
		end
		io.close(file)
	end
	
	return firmware_id
end

function get_uploaded_firmware_id()
	local firmware_id = "uploaded_firmware_id"
	local fwPathname = "/tmp/fw.bin";
	local file = assert(io.open(fwPathname, 'rb'))
	
	if file then
		local str = file:read(64) --MBA Sean, Read all mkimage header out
		file:close()
		local frimware_version = string.sub(str, 33, 56) --MBA Sean, mkimage name part
		firmware_id = frimware_version:match(".+%((.+)%.%d%).+")
	end
	
	return firmware_id
end
