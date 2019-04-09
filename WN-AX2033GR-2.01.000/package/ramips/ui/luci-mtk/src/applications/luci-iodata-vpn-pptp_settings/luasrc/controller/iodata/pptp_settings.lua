--[[
LuCI - Lua Configuration Interface

Copyright 2011 Manuel Munz <freifunk somakoma de>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

]]--

module ("luci.controller.iodata.pptp_settings", package.seeall)
local uci = require("luci.model.uci").cursor()
local sys = require("luci.sys")
local datatypes  = require("luci.cbi.datatypes")
local csrf = require("luci.csrf")

function index()
	entry({"content", "vpn", "pptp_settings"}, call("action_pptp"), _("PPTP Settings"), 2).leaf = true
end

function action_pptp()
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
	
		local pptp_enable = luci.http.formvalue("pptp_enable")

		-- Set config to UCI
		if pptp_enable == "1" then
			local username = luci.http.formvalue("input_username")
			local password = luci.http.formvalue("input_password")
			local startip = luci.http.formvalue("input_remoteIP_start")
			local endip = luci.http.formvalue("input_remoteIP_end")

			if tonumber(startip) > tonumber(endip) then
				startip, endip = endip, startip
			end

			uci:set("pptpd", "pptpd", "iprange", startip .. "-" .. endip);

			local ifce={}
			uci.foreach("pptpd", "login",
				function(s)
				ifce[#ifce+1] = s[".name"]
			end)
			
			if #ifce == 0 then
				ifce[#ifce+1] = uci:add("pptpd", "login");
			end

			uci:set("pptpd", ifce[1], "username", username)
			uci:set("pptpd", ifce[1], "password", password)
		end

		if pptp_enable == "1" then
			uci:set("firewall", "pptpd", "enabled", "yes");
		else
			uci:set("firewall", "pptpd", "enabled", "no");
		end

		uci:set("pptpd", "pptpd", "enabled", pptp_enable)
		uci:commit("pptpd")
		uci:commit("firewall")
		-- End of Set config to UCI

		-- Send command to restart pptpd
		sys.exec("/etc/init.d/pptpd restart");
		sys.exec("/etc/init.d/firewall restart");
		-- fw3 restart willl flush miniupnp rule
		sys.exec("/etc/init.d/miniupnpd restart 2>/dev/null")
	end

	luci.template.render("iodata/pptp_settings")
end
