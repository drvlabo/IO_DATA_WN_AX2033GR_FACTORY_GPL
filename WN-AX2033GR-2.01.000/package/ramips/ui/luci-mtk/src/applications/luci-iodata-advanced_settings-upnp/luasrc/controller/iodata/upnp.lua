--[[
LuCI - Lua Configuration Interface

Copyright 2011 Manuel Munz <freifunk somakoma de>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

]]--

module ("luci.controller.iodata.upnp", package.seeall)
local uci = require("luci.model.uci").cursor()
local sys = require("luci.sys")
local csrf = require("luci.csrf")

function index()
	local uci2 = require("luci.model.uci").cursor()
	local exanime_mode = uci2:get("network","wan","mode")
	if exanime_mode == "router" then
		entry({"content", "advanced_settings", "upnp"}, call("action_upnp"), _("UPnP"), 2).leaf = true
	end
end

function action_upnp()
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
	
		local upnpEnableStr = luci.http.formvalue("upnpDataStr")

		--[[force disable natpmp for IO-DATA]]--
		uci:set("upnpd", "config", "enable_natpmp", "0")

		uci:set("upnpd", "config", "enable_upnp", upnpEnableStr)
		uci:commit("upnpd")

		sys.exec("/etc/init.d/miniupnpd reload 2>/dev/null")
	end

	luci.template.render("iodata/upnp")
end
