--[[
LuCI - Lua Configuration Interface

Copyright 2011 Manuel Munz <freifunk somakoma de>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

]]--

--[[
page call flow:
repeater_connection_settings -> repeater_sitesurvey -> repeater_sitesurvey_result -> repeater_connection_setup -> repeater_connection_save
or
repeater_connection_settings -> repeater_connection_setup -> repeater_connection_save
]]

module ("luci.controller.iodata.repeater_sitesurvey", package.seeall)
local uci = require("luci.model.uci").cursor()
local sys = require("luci.sys")

function index()
	entry({"content", "wireless_settings", "repeater_connection_settings", "repeater_sitesurvey"}, call("action_sitesurvye"), _("Site Survey"), 0).leaf = true
end

local client_ifce_2g={}
local client_ifce_5g={}
function scanWifiDev()
	--MSTC MVA Sean, get all 2.4G chip device name
	uci.foreach("wireless", "wifi-iface",
	function(s)
		if (s.device == "mt7620" or s.device == "mt7602e" or s.device == "mt7603e" or s.device == "mt7628" or s.device == "mt7688" or s.device == "mt7615e2") then
			if s.mode == "client" then
				client_ifce_2g[#client_ifce_2g+1] = s[".name"]
			end
		end
		if ( s.device == "mt7615e5" or s.device == "mt7610e" or s.device == "mt7612e" ) then
			if s.mode == "client" then
				client_ifce_5g[#client_ifce_5g+1] = s[".name"]
			end
		end
	end)
end

function action_sitesurvye()
	local band_select = uci:get("wireless","repeater","band")
	local ifce_name;
	local cmd;
	
	if not band_select then
		band_select = "0";
	end
	
	scanWifiDev();
	-- start to wifi scan
	if band_select == "1" then
		ifce_name = uci.get("wireless", client_ifce_2g[1], "ifname");
		cmd = "/usr/sbin/iwpriv " .. ifce_name .. " set SiteSurvey=";
		sys.exec(cmd);
	elseif band_select == "2" then
		ifce_name = uci.get("wireless", client_ifce_5g[1], "ifname");
		cmd = "/usr/sbin/iwpriv " .. ifce_name .. " set SiteSurvey=";
		sys.exec(cmd);
	else
		ifce_name = uci.get("wireless", client_ifce_2g[1], "ifname");
		cmd = "/usr/sbin/iwpriv " .. ifce_name .. " set SiteSurvey=";
		sys.exec(cmd);
		ifce_name = uci.get("wireless", client_ifce_5g[1], "ifname");
		cmd = "/usr/sbin/iwpriv " .. ifce_name .. " set SiteSurvey=";
		sys.exec(cmd);
	end
	
	luci.template.render("iodata/repeater_sitesurvey")
end