--[[
LuCI - Lua Configuration Interface

Copyright 2011 Manuel Munz <freifunk somakoma de>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

]]--

module ("luci.controller.iodata.dos", package.seeall)
local uci = require("luci.model.uci").cursor()
local sys = require("luci.sys")
local csrf = require("luci.csrf")

function index()
	local uci2 = require("luci.model.uci").cursor()
	local exanime_mode = uci2:get("network","wan","mode")
	if exanime_mode == "router" then
		entry({"content", "security", "dos"}, call("action_dos"), _("DoS"), 3).leaf = true
	end
end

function action_dos()
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
		uci:foreach("firewall", "defaults", function(s) 
			def[cnt]=s[".name"]  
			cnt = cnt + 1
		end)
		
		uci:set("firewall", def[0], "syn_flood", dosEnableStr)
		uci:commit("firewall")

		sys.exec("/etc/init.d/firewall reload 2>/dev/null")
	end

	luci.template.render("iodata/dos")
end
