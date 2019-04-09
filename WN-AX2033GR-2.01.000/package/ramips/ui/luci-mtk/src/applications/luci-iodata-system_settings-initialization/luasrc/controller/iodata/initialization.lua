--[[
LuCI - Lua Configuration Interface

Copyright 2011 Manuel Munz <freifunk somakoma de>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

]]--

module ("luci.controller.iodata.initialization", package.seeall)
local sys = require("luci.sys")
local csrf = require("luci.csrf")

function index()
	entry({"content", "system_settings", "initialization"}, call("action_initialization"), _("Initialization"), 6).leaf = true
end

function action_initialization()
	local isApply = luci.http.formvalue("isApply")
	local functionIndex = luci.http.formvalue("functionIndex")

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
	
		--Factory setting
		luci.sys.exec("/sbin/mstc_led.sh power blink")
		if functionIndex == "0" then
			sys.exec("rm -rf /tmp/.uci >/dev/null")
			sys.exec("/usr/sbin/sys romreset 0 >/dev/null")
			sys.exec("/usr/bin/mstc_cfg_chksum chksum 1 | xargs /sbin/mstc_persist write cfg1Chksum >/dev/null")
			sys.exec("/usr/bin/mstc_cfg_chksum size 1 | xargs /sbin/mstc_persist write cfg1Size >/dev/null")
			sys.exec("/sbin/mstc_persist write cfgapply 1 >/dev/null")
			sys.exec("reboot")

		--Reboot
		elseif functionIndex == "1" then
			sys.exec("reboot")
		end
	end

	luci.template.render("iodata/initialization")
end