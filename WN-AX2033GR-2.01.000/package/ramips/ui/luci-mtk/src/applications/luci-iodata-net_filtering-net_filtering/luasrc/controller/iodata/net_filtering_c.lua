--[[
LuCI - Lua Configuration Interface

Copyright 2011 Manuel Munz <freifunk somakoma de>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

]]--

module("luci.controller.iodata.net_filtering_c", package.seeall)
local uci = require("luci.model.uci").cursor()
local sys = require("luci.sys")
local csrf = require("luci.csrf")

function index()
	entry({"content", "net_filtering", "net_filtering"}, call("action_net_filtering"), _("Net Filtering"), 1)
	entry({"content", "net_filtering", "net_filtering", "net_filtering_edit"}, call("action_net_filtering_edit"), _("Net Filtering Edit")).leaf = true
	entry({"content", "net_filtering", "net_filtering", "net_filtering_check"}, call("action_net_filtering_check"), _("Net Filtering Check")).leaf = true
end

function file_exists(name)
   local f=io.open(name,"r")
   if f~=nil then io.close(f) return true else return false end
end

function gen_tmp_inputdata()
	if not file_exists("/tmp/siteblock") then
		sys.exec("mkdir /tmp/siteblock 1>/dev/null 2>&1")
	end
	if not file_exists("/tmp/siteblock/inputdata") then
		sys.exec("touch /tmp/siteblock/inputdata 1>/dev/null 2>&1")
	end
end

function action_net_filtering()
	local isApply = luci.http.formvalue("isApply")
	
	if isApply then
		--[[=========CSRF check Start=========--]]
		local csrf_token_web = csrf.get_csrf_token_in_web()
		--if csrf token is wrong or can't get it from web, return 403
		if ( not csrf.verify(csrf_token_web) ) then
			wrong_value = true;
			csrf.http_return_403()
			return
		end
		--[[=========CSRF check End=========--]]
		local urlFilterEnable = uci:get("siteblock", "urlfilter", "enabled")
		local hBSEnable = luci.http.formvalue("hBSEnable")
		local License = luci.http.formvalue("License")
		local sAllLimit = luci.http.formvalue("sAllLimit")
		
		local fwIncludeName
		uci:foreach( "firewall","include", function(s)
			if s.path == "/etc/firewall.user" then
				fwIncludeName = s[".name"]
			end
		end)

		if (hBSEnable == "1") then
			gen_tmp_inputdata()

			local inputdatafile=io.open("/tmp/siteblock/inputdata", "w")
			if inputdatafile ~= nil then
				inputdatafile:write("config global 'config'\n")
				inputdatafile:write("		option enabled '1'\n")
				if ( (License ~= "") and (License:match("^[a-zA-Z0-9]+$") ~= nil) )then
					inputdatafile:write("		option license_number '" .. License .. "'\n")
				end
				if sAllLimit ~= "" then
					inputdatafile:write("		option limit_rule '" .. sAllLimit .. "'\n")
				end
				inputdatafile:close()
			end
			
			uci:set("siteblock", "config", "agreement", 1)
			uci:set("firewall", "siteblock", "enabled", 1)
			if fwIncludeName then
				uci:set("firewall", fwIncludeName, "reload", 1)
			end

			uci:commit("siteblock")
			uci:commit("firewall")
		else
			uci:set("siteblock", "config", "enabled", 0)
			uci:set("siteblock", "config", "agreement", 1)
			if urlFilterEnable == "0" then
				uci:set("firewall", "siteblock", "enabled", 0)
			end
			uci:commit("siteblock")
			uci:commit("firewall")
		end
		
		sys.exec("/etc/init.d/mstc_sbd stop 1>/dev/null 2>&1")
		sys.exec("/etc/init.d/firewall restart 1>/dev/null 2>&1")
		-- fw3 restart willl flush miniupnp rule
		sys.exec("/etc/init.d/miniupnpd restart 2>/dev/null")
		sys.exec("/etc/init.d/mstc_sbd start 1>/dev/null 2>&1")
	end
	luci.template.render("iodata/net_filtering")
end

function action_net_filtering_edit()
	local doApply = luci.http.formvalue("doApply")
	if doApply then
	
		--[[=========CSRF check Start=========--]]
		local csrf_token_web = csrf.get_csrf_token_in_web()
		--if csrf token is wrong or can't get it from web, return 403
		if ( not csrf.verify(csrf_token_web) ) then
			wrong_value = true;
			csrf.http_return_403()
			return
		end
		--[[=========CSRF check End=========--]]
		
		local CuzDataStr1 = luci.http.formvalue("CuzDataStr1");
		local CuzDataStr2 = luci.http.formvalue("CuzDataStr2");
		local CuzDataStr3 = luci.http.formvalue("CuzDataStr3");
		local CuzDataStr4 = luci.http.formvalue("CuzDataStr4");
		
		--MSTC MBA Sean, we need to check CuzDataStr format is correct and legit
		if ( (CuzDataStr1 ~= "") and (CuzDataStr1:match("^[0-9, ]+$") ~= nil) )then
			uci:delete("siteblock","custom1","cat_id")
			uci:set("siteblock","custom1","cat_id",CuzDataStr1)
		end
		
		if ( (CuzDataStr2 ~= "") and (CuzDataStr2:match("^[0-9, ]+$") ~= nil) ) then
			uci:delete("siteblock","custom2","cat_id")
			uci:set("siteblock","custom2","cat_id",CuzDataStr2)
		end
		
		if ( (CuzDataStr3 ~= "") and (CuzDataStr3:match("^[0-9, ]+$") ~= nil) ) then
			uci:delete("siteblock","custom3","cat_id")
			uci:set("siteblock","custom3","cat_id",CuzDataStr3)
		end
		
		if ( (CuzDataStr4 ~= "") and (CuzDataStr4:match("^[0-9, ]+$") ~= nil) ) then
			uci:delete("siteblock","custom4","cat_id")
			uci:set("siteblock","custom4","cat_id",CuzDataStr4)
		end
		
		uci:commit("siteblock");
		sys.exec("/etc/init.d/mstc_sbd stop 1>/dev/null 2>&1")
		sys.exec("/etc/init.d/firewall restart 1>/dev/null 2>&1")
		-- fw3 restart willl flush miniupnp rule
		sys.exec("/etc/init.d/miniupnpd restart 2>/dev/null")
		sys.exec("/etc/init.d/mstc_sbd start 1>/dev/null 2>&1")
	end

	luci.template.render("iodata/net_filtering_edit")
end

function action_net_filtering_check()
	local isApply = luci.http.formvalue("isApply")

	if isApply then
	
		--[[=========CSRF check Start=========--]]
		local csrf_token_web = csrf.get_csrf_token_in_web()
		--if csrf token is wrong or can't get it from web, return 403
		if ( not csrf.verify(csrf_token_web) ) then
			wrong_value = true;
			csrf.http_return_403()
			return
		end
		--[[=========CSRF check End=========--]]
		
		local License = luci.http.formvalue("License")

		if License then
			sys.exec("mstc_sbd -t " .. License .. " 1>/dev/null 2>&1")
		end

		local uci_t = require("luci.model.uci").cursor()
		local original_confdir = uci_t.get_confdir()
		uci_t.set_confdir("/tmp/siteblock")
		local state_available = uci_t.get("certificate_stat_check", "state", "available")
		local state_endday = uci_t.get("certificate_stat_check", "state", "endday")

		uci_t.set_confdir(original_confdir)

		luci.http.prepare_content("text/html")
		if state_available then
			luci.http.write(state_available)
		end
		luci.http.write(",")
		if state_endday then
			luci.http.write(state_endday)
		end
	end
end
