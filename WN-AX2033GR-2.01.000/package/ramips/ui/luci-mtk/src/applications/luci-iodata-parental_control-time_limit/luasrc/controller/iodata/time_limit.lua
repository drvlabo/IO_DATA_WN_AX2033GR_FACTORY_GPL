--[[
LuCI - Lua Configuration Interface

Copyright 2011 Manuel Munz <freifunk somakoma de>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

]]--

module ("luci.controller.iodata.time_limit", package.seeall)
local uci = require("luci.model.uci").cursor()
local sys = require("luci.sys")
local csrf = require("luci.csrf")

function index()
	local uci2 = require("luci.model.uci").cursor()
	local exanime_mode = uci2:get("network","wan","mode")
	if exanime_mode ~= "repeater" then
		entry({"content", "parental_control", "time_limit"}, call("action_time_limit"), _("Time limit"), 1).leaf = true
	end
end

local function file_exists(name)
   local f=io.open(name,"r")
   if f~=nil then io.close(f) return true else return false end
end

function action_time_limit()
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

		local tmpName = ""
		local tlEnableStr = luci.http.formvalue("tlEnableStr")
		local tlRuleDataStr = luci.http.formvalue("tlRuleDataStr")

		local fwIncludeName
		uci:foreach( "firewall","include", function(s)
			if s.path == "/etc/firewall.user" then
				fwIncludeName = s[".name"]
			end
		end)

		if not file_exists("/etc/config/parentalcontrol") then
			sys.exec("touch /etc/config/parentalcontrol")
		end

		local testConfigExist = uci:get("parentalcontrol", "config", "enable_time_limit")
		if not testConfigExist then
			tmpName = uci:add("parentalcontrol", "global")
			uci:rename("parentalcontrol", tmpName, "config")
		end
		uci:set("parentalcontrol", "config", "enable_time_limit", tlEnableStr)

		if tlEnableStr == "1" and fwIncludeName then
			uci:set("firewall", fwIncludeName, "reload", 1)
		end

		-- Terence, Delete all rule from config
		uci:foreach( "parentalcontrol","time_limit", function(s)
			uci:delete("parentalcontrol", s[".name"])
		end)

		-- Terence, convert data string into table
		local ruleTab = {}
		local tmpStr = tlRuleDataStr
		local curStr = ""
		while tmpStr ~= "" do
			local s1,e1 = string.find(tmpStr, ">")
			if s1 == nil then
				curStr = tmpStr
				tmpStr = ""
			else
				curStr = string.sub(tmpStr, 1, e1-1)
				tmpStr = string.sub(tmpStr, e1+1 , -1)
			end
			local curData = ""
			local dataTab = {}
			while curStr ~= "" do
				local s2,e2 = string.find(curStr, "<")
				if s2 == nil then
					curData = curStr
					curStr = ""
				else
					curData = string.sub(curStr, 1, e2-1)
					curStr = string.sub(curStr, e2+1 , -1)
				end
				table.insert(dataTab, curData)
			end
			table.insert(ruleTab, dataTab)
		end

		for i = 1,#ruleTab do
			tmpName = uci:add("parentalcontrol", "time_limit")
			uci:set("parentalcontrol", tmpName, "desc", luci.http.htmldecode(ruleTab[i][1]))
			uci:set("parentalcontrol", tmpName, "mac", ruleTab[i][2])
			uci:set("parentalcontrol", tmpName, "start_time", ruleTab[i][3])
			uci:set("parentalcontrol", tmpName, "end_time", ruleTab[i][4])
		end

		testConfigExist = uci:get("firewall", "parentalcontrol", "type")
		if not testConfigExist then
			tmpName = uci:add("firewall", "include")
			uci:rename("firewall", tmpName, "parentalcontrol")

			uci:set("firewall", "parentalcontrol", "type", "script")
			uci:set("firewall", "parentalcontrol", "path", "/etc/parentalcontrol/firewall.include")
		end
		uci:set("firewall", "parentalcontrol", "reload", 1)

		uci:commit("firewall")
		uci:commit("parentalcontrol")

		sys.exec("/etc/init.d/parentalcontrol restart")
		sys.exec("/etc/init.d/firewall restart")
		-- fw3 restart willl flush miniupnp rule
		sys.exec("/etc/init.d/miniupnpd restart 2>/dev/null")
	end

	luci.template.render("iodata/time_limit")

end
