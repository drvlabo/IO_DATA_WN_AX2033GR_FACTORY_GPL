--[[
LuCI - Lua Configuration Interface

Copyright 2011 Manuel Munz <freifunk somakoma de>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

]]--

module ("luci.controller.iodata.dmz", package.seeall)
local uci = require("luci.model.uci").cursor()
local sys = require("luci.sys")
local csrf = require("luci.csrf")

function index()
	local uci2 = require("luci.model.uci").cursor()
	local exanime_mode = uci2:get("network","wan","mode")
	if exanime_mode == "router" then
		entry({"content", "security", "dmz"}, call("action_dmz"), _("DMZ"), 2).leaf = true
	end
end

function action_dmz()
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
	
		local dmzRuleDataStr = luci.http.formvalue("dmzRuleDataStr")
		local pfRuleDataStr = luci.http.formvalue("pfRuleDataStr")

		-- Terence, Delete all static client data from config
		uci:foreach( "firewall","redirect", function(s)
			uci:delete("firewall", s[".name"])
		end)

		-- Terence, convert data string into table
		local ruleTab = {}
		local tmpStr = pfRuleDataStr
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
		
		for i = 1,#ruleTab do
			new_name = uci:add("firewall", "redirect")
			uci:set("firewall", new_name, "rule_type", "port_forwarding")
			uci:set("firewall", new_name, "rule_name", ruleTab[i][1])
			uci:set("firewall", new_name, "src", "wan")
			uci:set("firewall", new_name, "dest_ip", ruleTab[i][2])
			uci:set("firewall", new_name, "proto", ruleTab[i][3])
			uci:set("firewall", new_name, "dest_port", ruleTab[i][4])
			uci:set("firewall", new_name, "src_dport", ruleTab[i][5])
		end

		if dmzRuleDataStr ~= "" then
			new_name = uci:add("firewall", "redirect")
			uci:set("firewall", new_name, "rule_type", "dmz")
			uci:set("firewall", new_name, "src", "wan")
			uci:set("firewall", new_name, "proto", "all")
			uci:set("firewall", new_name, "dest_ip", dmzRuleDataStr)
		end
		uci:commit("firewall")

		sys.exec("/etc/init.d/firewall reload 2>/dev/null")
	end

	luci.template.render("iodata/dmz")
end
