--[[
LuCI - Lua Configuration Interface

Copyright 2011 Manuel Munz <freifunk somakoma de>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

]]--

module ("luci.controller.iodata.backup", package.seeall)
local http = require "luci.http"
local sys = require("luci.sys")
local uci = require("luci.model.uci").cursor()
local csrf = require("luci.csrf")

function index()
	entry({"content", "system_settings", "backup"}, call("action_backup"), _("Backup"), 5)
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

function updateConfig(pathname)
	local ret = 0;

	-- check FW integrity

		-- delay 2 seconds to do flash writing in background
		cmd = "sys loadrom " .. pathname .. " > /dev/console 2>&1";
		ret = sys.call(cmd);
	if ret == 2 then
		luci.template.render("iodata/backup");
		http.write("<script type=\"text/javascript\">showInvalidMessage();</script>");
	elseif ret == 3 then
		luci.template.render("iodata/backup");
		http.write("<script type=\"text/javascript\">showInvalidMessage();</script>");
	end
	
	if ret == 0 then	
		-- show countdown page
		sys.call("/usr/bin/delayAndReboot.sh > /dev/null 2>&1 &")
		http.write("<script type=\"text/javascript\">window.location.href=window.top.location+\"/../content/system_settings/firmware/countdown\"</script>");
	else
		-- delete file if config file is invalid
		cmd = "/bin/rm -f " .. pathname .. " > /dev/null";
		sys.call(cmd);
	end

	return ret;
end

function ltn12_popen(command)

	local fdi, fdo = nixio.pipe()
	local pid = nixio.fork()

	if pid > 0 then
		fdo:close()
		local close
		return function()
			local buffer = fdi:read(2048)
			local wpid, stat = nixio.waitpid(pid, "nohang")
			if not close and wpid and stat == "exited" then
				close = true
			end

			if buffer and #buffer > 0 then
				return buffer
			elseif close then
				fdi:close()
				return nil
			end
		end
	elseif pid == 0 then
		nixio.dup(fdo, nixio.stdout)
		fdi:close()
		fdo:close()
		nixio.exec("/bin/sh", "-c", command)
	end
end

function action_backup()
	local ret = 0;

	local receivedfile = "/tmp/config.gpg";
	setFileHandler(receivedfile); -- don't add any form operation before this line

	-- Use the production model name as default passphrase for gpg
	local sys_realm = luci.sys.exec("cat /etc/openwrt_release | grep DISTRIB_PRODUCT | awk -F '\"' '{print $2}'"):match("^([^%s]+)")

	local applyFlag = luci.http.formvalue("applyFlag");
	local backupFlag = luci.http.formvalue("backupFlag")

	-- Retore process 
	if applyFlag == "1" then
	
		--[[=========CSRF check Start=========--]]
		local csrf_token_web = csrf.get_csrf_token_in_web()
		--if csrf token is wrong or can't get it from web, return 403
		if ( not csrf.verify(csrf_token_web) ) then
			wrong_value = true;
			csrf.http_return_403()
			return
		end
		--[[=========CSRF check End=========--]]
	
		local configPathname = "/tmp/config.tar.gz";
		local decrypt_cmd = string.format("echo %q | gpg --batch -q -o %q --passphrase-fd 0 --decrypt %q", sys_realm, configPathname, receivedfile)
		local decrypt_ret = luci.sys.call(decrypt_cmd)

		if decrypt_ret == 0 then
			ret = updateConfig(configPathname);
		else
			luci.template.render("iodata/backup");
			http.write("<script type=\"text/javascript\">showInvalidMessage();</script>");
		end
	-- Backup process
	elseif backupFlag == "1" then
	
		--[[=========CSRF check Start=========--]]
		local csrf_token_web = csrf.get_csrf_token_in_web()
		--if csrf token is wrong or can't get it from web, return 403
		if ( not csrf.verify(csrf_token_web) ) then
			wrong_value = true;
			csrf.http_return_403()
			return
		end
		--[[=========CSRF check End=========--]]
	
		local backup_file = "/tmp/_backup"
		local backup_cmd = string.format("sysupgrade --create-backup %q 2>/dev/null", backup_file)
		luci.sys.exec(backup_cmd)
		local encrypt_cmd = string.format("echo %q | gpg --batch -q --passphrase-fd 0 --cipher-algo AES256 -c %q", sys_realm, backup_file)
		luci.sys.exec(encrypt_cmd)
		local stdout_cmd = "cat "..backup_file..".gpg 2>/dev/null"

		local reader = ltn12_popen(stdout_cmd)
        luci.http.header('Content-Disposition', 'attachment; filename="backup-%s.dlf"' % {
                os.date("%Y-%m-%d-%H%M%S")})
		-- MSTC MBA Sean, set Cookie to notify server that file has been downloaded
		luci.http.header("Set-Cookie", "file_loading=true")
        luci.http.prepare_content("application/octet-stream")
        luci.ltn12.pump.all(reader, luci.http.write)
		luci.template.render("iodata/backup");

		-- Remove the unnecessary files
		luci.sys.exec("/bin/rm -f "..backup_file.."*")
	else
		luci.template.render("iodata/backup");
	end
end
