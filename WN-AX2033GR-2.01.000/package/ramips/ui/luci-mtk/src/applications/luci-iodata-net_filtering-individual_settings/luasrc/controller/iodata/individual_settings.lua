--[[
LuCI - Lua Configuration Interface

Copyright 2011 Manuel Munz <freifunk somakoma de>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

]]--

module ("luci.controller.iodata.individual_settings",package.seeall)
local http = require "luci.http"
local uci = require("luci.model.uci").cursor()
local sys = require("luci.sys")
local csrf = require("luci.csrf")

function index()
	entry({"content", "net_filtering", "individual_settings"}, call("action_individual_settings"), _("Individual Settings"), 2).leaf = true
end

function string:split(delimiter)
  local result = { }
  local from = 1
  local delim_from, delim_to = string.find( self, delimiter, from )
  while delim_from do
    table.insert( result, string.sub( self, from , delim_from-1 ) )
    from = delim_to + 1
    delim_from, delim_to = string.find( self, delimiter, from )
  end
  table.insert( result, string.sub( self, from ) )
  return result
end

function AddDelMAC()
		local idv_RuleDataStr = luci.http.formvalue("idv_RuleDataStr");
		
		local ruleTab = {}
		local tmpStr = idv_RuleDataStr
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
				local s2,e2 = string.find(curStr, ";")
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
		
		if #ruleTab <= 10 then
			uci:foreach( "siteblock","single_limit", function(s)
				uci:delete("siteblock", s[".name"])
			end)
			
			for i = 1,#ruleTab do
				new_name = uci:add("siteblock", "single_limit")
				uci:set("siteblock", new_name, "enabled", "1")
				uci:set("siteblock", new_name, "mac", ruleTab[i][1])
				uci:set("siteblock", new_name, "limit_rule", ruleTab[i][2])
			end
		end
end


function action_individual_settings()
	local isApply = luci.http.formvalue("isApply");

	
	if isApply then -- apply button
	
		--[[=========CSRF check Start=========--]]
		local csrf_token_web = csrf.get_csrf_token_in_web()
		--if csrf token is wrong or can't get it from web, return 403
		if ( not csrf.verify(csrf_token_web) ) then
			wrong_value = true;
			csrf.http_return_403()
			return
		end
		--[[=========CSRF check End=========--]]
	
		AddDelMAC();
		
		uci:commit("siteblock");
		sys.exec("/etc/init.d/mstc_sbd stop 1>/dev/null 2>&1")
		sys.exec("/etc/init.d/firewall restart 1>/dev/null 2>&1")
		-- fw3 restart willl flush miniupnp rule
		sys.exec("/etc/init.d/miniupnpd restart 2>/dev/null")
		sys.exec("/etc/init.d/mstc_sbd start 1>/dev/null 2>&1")
	end

	luci.template.render("iodata/individual_settings", {src_url="/content/net_filtering/individual_settings"})
end
