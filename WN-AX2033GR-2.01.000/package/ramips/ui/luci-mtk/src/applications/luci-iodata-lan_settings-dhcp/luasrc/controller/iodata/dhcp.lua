--[[
LuCI - Lua Configuration Interface

Copyright 2011 Manuel Munz <freifunk somakoma de>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

]]--

module ("luci.controller.iodata.dhcp", package.seeall)
local uci = require("luci.model.uci").cursor()
local sys = require("luci.sys")
local csrf = require("luci.csrf")

function index()
	local uci2 = require("luci.model.uci").cursor()
	local exanime_mode = uci2:get("network","wan","mode")
	if exanime_mode == "router" or exanime_mode == "v6plus" or exanime_mode == "transix" then
		entry({"content", "lan_settings", "dhcp"}, call("action_dhcp"), _("DHCP"), 2).leaf = true
	end
end

function action_dhcp()
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
	
		local staCltDataStr = luci.http.formvalue("strCltDataStr")
		local cnt = 0
		
		for input_ip,input_mac in string.gmatch(staCltDataStr, "(%d+.%d+.%d+.%d+),(%w+:%w+:%w+:%w+:%w+:%w+)") do
			cnt = cnt + 1
		end

		-- Terence, The maximum number of static DHCP entries is limited to 10.
		if cnt <= 10 then
			-- Terence, Delete all static client data from config
			uci:foreach( "dhcp","host", function(s)
				uci:delete("dhcp", s[".name"])
			end)

			-- Terence, Add all static client data from submit data
			-- gmatch : use pattern to find string, use () to get specific value
			for input_ip,input_mac in string.gmatch(staCltDataStr, "(%d+.%d+.%d+.%d+),(%w+:%w+:%w+:%w+:%w+:%w+)") do
				new_name = uci:add("dhcp", "host")
				uci:set("dhcp", new_name, "ip", input_ip)
				uci:set("dhcp", new_name, "mac", input_mac)
			end

			uci:commit("dhcp")

			sys.exec("/etc/init.d/dnsmasq reload 2>/dev/null")
		end
	end
	
	luci.template.render("iodata/dhcp")
end