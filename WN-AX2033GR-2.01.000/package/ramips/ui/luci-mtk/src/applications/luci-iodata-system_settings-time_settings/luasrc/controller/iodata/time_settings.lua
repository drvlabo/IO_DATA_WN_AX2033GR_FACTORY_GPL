--[[
LuCI - Lua Configuration Interface

Copyright 2011 Manuel Munz <freifunk somakoma de>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

]]--

module ("luci.controller.iodata.time_settings", package.seeall)

local uci = require("luci.model.uci").cursor()
local sys = require("luci.sys")
local datatypes  = require("luci.cbi.datatypes")
local csrf = require("luci.csrf")

function index()
	entry({"content", "system_settings", "time_settings"}, call("time_settings"), _("Time Settings"), 2).leaf = true
end

function time_settings()

	local apply = luci.http.formvalue("apply")
	
	local wrong_value = false
	
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
		
		--MBA Sean, get teh ntp server from /etc/tmp_config
		local uci_t = require("luci.model.uci").cursor()
		local original_confdir = uci_t.get_confdir()
		uci_t.set_confdir("/etc/tmp_config")

		local ntp_servers = {}
		ntp_servers = uci_t.get("web", "ntp_server_list", "server")
	
		uci_t.set_confdir(original_confdir)
		
		local ntp_server  = luci.http.formvalue("ntp_server")

		--MBA Sean, check if the server is in the server list.
		wrong_value = true;
		for i=1, #ntp_servers do
			local server_name = ntp_servers[i]
			if server_name == ntp_server then
				wrong_value = false;
			end
		end
		
		if ( not wrong_value ) then
			sys.exec("uci delete system.ntp.server")
			sys.exec("uci add_list system.ntp.server=\"" .. ntp_server .. "\"")
			sys.exec("uci commit")
		end
	
		if (not wrong_value) then
			sys.exec("/etc/init.d/sysntpd restart")
		end
	end
	
	luci.template.render("iodata/time_settings")
end