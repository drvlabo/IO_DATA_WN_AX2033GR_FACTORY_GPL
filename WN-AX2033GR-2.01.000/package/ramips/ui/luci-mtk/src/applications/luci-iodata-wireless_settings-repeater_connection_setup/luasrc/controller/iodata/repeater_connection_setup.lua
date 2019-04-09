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

module ("luci.controller.iodata.repeater_connection_setup", package.seeall)
local http = require "luci.http" -- debug

function index()
		entry({"content", "wireless_settings", "repeater_connection_settings", "repeater_connection_setup"}, call("action_repeater_connection_setup"), _("Connection Settings"), 0).leaf = true
end


function action_repeater_connection_setup()
	local from_sitesurvey = luci.http.formvalue("submitFormNum")
	local TargetSSID = "";
	local TargetBSSID = "";
	local TargetEnc = "";
	local TargetAuth = "";
	local TargetChannel = "";
	
	if from_sitesurvey then -- select one AP from site survey list and start to configure it
		TargetSSID = luci.http.formvalue("TargetSSID");
		TargetBSSID = luci.http.formvalue("TargetBSSID");
		TargetEnc = luci.http.formvalue("TargetEnc");
		TargetAuth = luci.http.formvalue("TargetAuth");
		TargetChannel = luci.http.formvalue("TargetChannel");
		luci.template.render("iodata/repeater_connection_setup", {from_sitesurvey=1, TargetSSID=TargetSSID, TargetBSSID=TargetBSSID, TargetEnc=TargetEnc, TargetAuth=TargetAuth, TargetChannel=TargetChannel})
	else -- manual config root AP setting
		luci.template.render("iodata/repeater_connection_setup", {from_sitesurvey=0, TargetSSID="", TargetBSSID="", TargetEnc="AES", TargetAuth="WPA2PSK", TargetChannel="auto"})
	end

end