--[[
LuCI - Lua Configuration Interface

Copyright 2011 Manuel Munz <freifunk somakoma de>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

]]--
module ("luci.controller.iodata.lamp", package.seeall)
local uci = require("luci.model.uci").cursor()
local sys = require("luci.sys")
local csrf = require("luci.csrf")

function index()
	entry({"content", "advanced_settings", "lamp"}, call("action_lamp"), _("Lamp"), 3).leaf = true
end

function action_lamp()
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
	
		local lampEnableStr = luci.http.formvalue("lampDataStr")
		sys.exec("mii_mgr -s -p 0 -r 13 -v 0x1f")
		sys.exec("mii_mgr -s -p 0 -r 14 -v 0x24")
		sys.exec("mii_mgr -s -p 0 -r 13 -v 0x401f")
		-- MSTC,Olivia, while Enable...
		if ( lampEnableStr ~= "1" ) then
			uci:set("system", "lamp", "led_light", "0")
			sys.exec("mii_mgr -s -p 0 -r 14 -v 0x4000")--switch off
			sys.exec("/sbin/mstc_led.sh power off") -- power off
		else
			uci:set("system", "lamp", "led_light", "1")
			sys.exec("mii_mgr -s -p 0 -r 14 -v 0xC007") --switch back to the first stage
			sys.exec("/sbin/mstc_led.sh power on") -- power on
		end
		uci:commit("system")
	end

	luci.template.render("iodata/lamp")
end
