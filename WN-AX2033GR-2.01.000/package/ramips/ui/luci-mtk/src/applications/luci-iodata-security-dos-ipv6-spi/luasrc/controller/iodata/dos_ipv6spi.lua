--[[
LuCI - Lua Configuration Interface

Copyright 2011 Manuel Munz <freifunk somakoma de>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

]]--

module ("luci.controller.iodata.dos_ipv6spi", package.seeall)
local uci = require("luci.model.uci").cursor()
local sys = require("luci.sys")
local csrf = require("luci.csrf")

function index()
	local uci2 = require("luci.model.uci").cursor()
	local exanime_mode = uci2:get("network","wan","mode")
	if (exanime_mode == "v6plus" or exanime_mode == "transix") then
		entry({"content", "security", "dos_ipv6spi"}, call("action_dos_ipv6spi"), _("DoS/IPv6 SPI"), 1).leaf = true
	end
end

function action_dos_ipv6spi()
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
	
		local dosEnableStr = luci.http.formvalue("dosDataStr")
		local def={}
		local cnt=0
		
		local spiEnableStr = luci.http.formvalue("spiDataStr")
		
		uci:foreach("firewall", "defaults", function(s) 
			def[cnt]=s[".name"]  
			cnt = cnt + 1
		end)
		
		local wan_node={}
		cnt=0
		uci:foreach("firewall", "zone", function(s) 
			if s.name == "wan" then
				wan_node[cnt] = s[".name"]
				cnt = cnt+1
			end
		end)

		--set dos
		uci:set("firewall", def[0], "syn_flood", dosEnableStr)
		
		--set spi
		uci:set("firewall", def[0], "spi_rule_enable", spiEnableStr)

		if spiEnableStr == "1" then
			uci:set("firewall", def[0], "forward", "REJECT")
			uci:set("firewall", wan_node[0], "forward", "REJECT")
		else
			uci:set("firewall", def[0], "forward", "ACCEPT")
			uci:set("firewall", wan_node[0], "forward", "ACCEPT")
		end
		
		uci:commit("firewall")
		
		--sys.exec("ip4ov6jp_stop")
		
		sys.exec("mii_mgr -p 0 -l down")
		sys.exec("sleep 3")
		sys.exec("mii_mgr -p 0 -l up")
		
		--sys.exec("/etc/init.d/network restart")
	end

	luci.template.render("iodata/dos_ipv6spi")
end
