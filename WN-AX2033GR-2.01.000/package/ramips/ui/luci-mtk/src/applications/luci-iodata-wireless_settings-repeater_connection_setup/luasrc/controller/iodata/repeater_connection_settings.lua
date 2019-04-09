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

module ("luci.controller.iodata.repeater_connection_settings", package.seeall)
local uci = require("luci.model.uci").cursor()
local csrf = require("luci.csrf")

function index()
	local uci = require("luci.model.uci").cursor()
	local wan_mode = uci:get("network","wan","mode");
	if wan_mode == "repeater" then
		entry({"content", "wireless_settings", "repeater_connection_settings"}, call("action_repeater_connection_settings"), _("Connection Settings"), 1)
	end
end

function action_repeater_connection_settings()
	local apply = luci.http.formvalue("apply")
	if apply then	
	
		--[[=========CSRF check Start=========--]]
		local csrf_token_web = csrf.get_csrf_token_in_web()
		--if csrf token is wrong or can't get it from web, return 403
		if ( not csrf.verify(csrf_token_web) ) then
			wrong_value = true;
			csrf.http_return_403()
			return
		end
		--[[=========CSRF check End=========--]]
	
		local band_select = luci.http.formvalue("band_select")
		if band_select then
			uci:set("wireless", "repeater", "repeater");
			if band_select == "1" then
				uci:set("wireless", "repeater", "band", band_select);
			elseif band_select == "2" then
				uci:set("wireless", "repeater", "band", band_select);
			else
				uci:set("wireless", "repeater", "band", "0");
			end
		end
	end
	uci:commit("wireless");
	
	luci.template.render("iodata/repeater_connection_settings")
end