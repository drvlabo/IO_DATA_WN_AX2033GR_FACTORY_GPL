--[[
LuCI - Lua Configuration Interface

Copyright 2011 Manuel Munz <freifunk somakoma de>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

]]--

module("luci.controller.iodata.client_list", package.seeall)

function index()
	local uci2 = require("luci.model.uci").cursor()
	local current_wan_mode = uci2:get("network","wan",'mode')
	if current_wan_mode ~= "repeater" then
		entry({"content", "wireless_settings", "client_list"}, template("iodata/client_list"), _("Client List"), 6).leaf = true
	else
		entry({"content", "wireless_settings", "client_list"}, template("iodata/client_list"), _("Client List"), 5).leaf = true
	end
end
