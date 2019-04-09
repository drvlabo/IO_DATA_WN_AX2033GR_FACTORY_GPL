--[[
LuCI - Lua Configuration Interface

Copyright 2011 Manuel Munz <freifunk somakoma de>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

]]--

module ("luci.controller.iodata.easy_connection_s", package.seeall)
local uci = require("luci.model.uci").cursor()
local sys = require("luci.sys")
local csrf = require("luci.csrf")

function index()
	local uci2 = require("luci.model.uci").cursor()
	local mode_check = uci2:get("network","wan","mode")
	if mode_check == "router" then		
		entry({"content", "advanced_settings", "easy_connection_s"}, call("action_easysetup"), _("Easy Connection"), 6).leaf = true
	end
end



function action_easysetup()
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
	
		local easysetupEnableStr = luci.http.formvalue("EnableEasySetup")
			
		uci:set("system", "easysetup", "easysetup_enable", easysetupEnableStr)
		uci:set("system", "easysetup", "http_redirect_enable", easysetupEnableStr)
		uci:commit("system")
		
		if easysetupEnableStr == "1" then
			sys.exec("/usr/sbin/httpredirect.sh update")
		elseif easysetupEnableStr == "0" then
			sys.exec("/usr/sbin/httpredirect.sh disable")
		else
			sys.exec("echo parsing_easy_setup_advanced_setting_error > /dev/console")
		end
	
		
	end

	luci.template.render("iodata/easy_connection_s")
end
