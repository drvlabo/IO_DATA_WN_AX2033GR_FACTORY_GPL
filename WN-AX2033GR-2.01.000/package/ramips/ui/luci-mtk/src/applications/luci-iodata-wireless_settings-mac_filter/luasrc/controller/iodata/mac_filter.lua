--[[
LuCI - Lua Configuration Interface

Copyright 2011 Manuel Munz <freifunk somakoma de>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

]]--

module ("luci.controller.iodata.mac_filter", package.seeall)
local http = require "luci.http"
local uci = require("luci.model.uci").cursor()
local sys = require("luci.sys")
local csrf = require("luci.csrf")

function index()
	entry({"content", "wireless_settings", "mac_filter"}, call("mac_filter"), _("MAC Filter"), 4).leaf = true
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

local ifce={}
local device_2g = "";
local device_5g = "";

function AddDelMAC()
		local RuleDataStr = luci.http.formvalue("RuleDataStr");
		local enableACL = luci.http.formvalue("enableACL");
		
		local ruleTab = {}
		local tmpStr = RuleDataStr
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
		
		if #ruleTab <= 32 then
			local tmpAclDesc = ""
			local tmpAclMac = ""
			for i=1,#ruleTab do
				if tmpAclDesc == "" then
					tmpAclDesc = ruleTab[i][1];
				else
					tmpAclDesc = tmpAclDesc .. "," .. ruleTab[i][1];
				end
				if tmpAclMac == "" then
					tmpAclMac = ruleTab[i][2];
				else
					tmpAclMac = tmpAclMac .. ";" .. ruleTab[i][2];
				end
			end
			for i=1,#ifce do
				uci:set("wireless", ifce[i], "acl_description", tmpAclDesc);
				uci:set("wireless", ifce[i], "acl_mac", tmpAclMac);
				uci:set("wireless", ifce[i], "accesspolicy", enableACL);
			end
		end
end


function mac_filter()
	local submitFormNum = luci.http.formvalue("submitFormNum");

	uci.foreach("wireless", "wifi-iface", 
	function(s)
		if s.mode == "ap" then
			ifce[#ifce+1] = s[".name"]
			if s.device == "mt7620" or s.device == "mt7602e" or s.device == "mt7603e" or s.device == "mt7628" or s.device == "mt7688" or s.device == "mt7615e2" then 
				device_2g = s.device
			end
			if s.device == "mt7610e"  or s.device == "mt7612e" or s.device == "mt7615e5" then 
				device_5g = s.device
			end
		end
	end)
	
	if submitFormNum then -- apply button
	
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
		local enableACL = luci.http.formvalue("enableACL");
		for i=1,#ifce do
			uci:set("wireless", ifce[i], "accesspolicy", enableACL);
		end
		if enableACL == '1' then
			-- disable wps
			uci:set("wireless", device_2g, "wsc_confmode", "0");
			uci:set("wireless", device_5g, "wsc_confmode", "0");
			uci:set("wireless", device_5g, "wps_enable", "0");
			uci:set("wireless", device_2g, "wps_enable", "0");
		end
		uci:commit("wireless");
		sys.exec("wifi reload_legacy");
	end

	luci.template.render("iodata/mac_filter")
end
