--[[
LuCI - Lua Configuration Interface

Copyright 2011 Manuel Munz <freifunk somakoma de>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

]]--

module ("luci.controller.iodata.eee", package.seeall)
local uci = require("luci.model.uci").cursor()
local sys = require("luci.sys")
local csrf = require("luci.csrf")

function index()
	entry({"content", "advanced_settings", "eee"}, call("action_eee"), _("EEE"), 7).leaf = true
end

function action_eee()
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
	
		local eeeEnableStr = luci.http.formvalue("eeeDataStr")
		local oldeeeEnableStr = uci:get("system", "eee", "enable")

		if not oldEeeEnableStr then
			local tmp_eee_name = uci:add("system", "eee")
			uci:rename("system", tmp_eee_name, "eee")
			oldEeeEnableStr = "0"
		end

		uci:set("system", "eee", "enable", eeeEnableStr)
		uci:commit("system")

		if eeeEnableStr == "1" then
			luci.sys.exec("/usr/sbin/switch-eee.sh 1")
		else
			luci.sys.exec("/usr/sbin/switch-eee.sh 0")
		end
	end

	luci.template.render("iodata/eee")
end
