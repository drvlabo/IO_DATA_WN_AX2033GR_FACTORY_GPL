--[[
LuCI - Lua Configuration Interface

Copyright 2011 Manuel Munz <freifunk somakoma de>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

]]--

module ("luci.controller.iodata.url_filter", package.seeall)
local uci = require("luci.model.uci").cursor()
local sys = require("luci.sys")
local csrf = require("luci.csrf")

function index()
	entry({"content", "net_filtering", "url_filter"}, call("action_url_filter"), _("URL filter"), 3).leaf = true
end

function action_url_filter()
	local isApply = luci.http.formvalue("isApply")

	if isApply then
		local enableURLfilter = luci.http.formvalue("enableURLfilter");
		local urlfilter_RuleDataStr = luci.http.formvalue("urlfilter_RuleDataStr")
		
		--[[=========CSRF check Start=========--]]
		local csrf_token_web = csrf.get_csrf_token_in_web()
		--if csrf token is wrong or can't get it from web, return 403
		if ( not csrf.verify(csrf_token_web) ) then
			wrong_value = true;
			csrf.http_return_403()
			return
		end
		--[[=========CSRF check End=========--]]

		-- Terence, convert data string into table
		local ruleTab = {}
		local tmpStr = urlfilter_RuleDataStr
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
				local s2,e2 = string.find(curStr, ",")
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

		-- Terence, The maximum number of port forwarding entries is limited to 32.
		if #ruleTab <= 20 then
			local siteblockEnable = uci:get("siteblock", "config", "enabled")
			local fwIncludeName
			uci:foreach( "firewall","include", function(s)
				if s.path == "/etc/firewall.user" then
					fwIncludeName = s[".name"]
				end
			end)
			
			-- Terence, Delete all url filter data from config
			uci:foreach( "siteblock","urlfilter_rule", function(s)
				uci:delete("siteblock", s[".name"])
			end)

			for i = 1,#ruleTab do
				new_name = uci:add("siteblock", "urlfilter_rule")
				uci:set("siteblock", new_name, "enabled", "1")
				uci:set("siteblock", new_name, "url", ruleTab[i][1])
				uci:set("siteblock", new_name, "accept", ruleTab[i][2])
			end

			if enableURLfilter then
				uci:set("siteblock", "urlfilter", "enabled", enableURLfilter);
				if (enableURLfilter == "0") and (siteblockEnable == "0") then
					uci:set("firewall", "siteblock", "enabled", 0)
				else
					uci:set("firewall", "siteblock", "enabled", 1)
					if fwIncludeName then
						uci:set("firewall", fwIncludeName, "reload", 1)
					end
				end
			end
		end

		uci:commit("siteblock")
		uci:commit("firewall")
		sys.exec("/etc/init.d/mstc_sbd stop 1>/dev/null 2>&1")
		sys.exec("/etc/init.d/firewall restart 1>/dev/null 2>&1")
		-- fw3 restart willl flush miniupnp rule
		sys.exec("/etc/init.d/miniupnpd restart 2>/dev/null")
		sys.exec("/etc/init.d/mstc_sbd start 1>/dev/null 2>&1")
	end

	luci.template.render("iodata/url_filter")
end
