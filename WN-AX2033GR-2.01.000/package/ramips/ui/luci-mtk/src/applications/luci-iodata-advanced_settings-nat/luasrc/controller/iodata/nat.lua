--[[
LuCI - Lua Configuration Interface

Copyright 2011 Manuel Munz <freifunk somakoma de>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

]]--

module ("luci.controller.iodata.nat", package.seeall)
local uci = require("luci.model.uci").cursor()
local sys = require("luci.sys")
local csrf = require("luci.csrf")

function index()
	local uci2 = require("luci.model.uci").cursor()
	local exanime_mode = uci2:get("network","wan","mode")
	if exanime_mode == "router" then
		entry({"content", "advanced_settings", "nat"}, call("action_nat"), _("NAT"), 5).leaf = true
	end	
end

function action_nat()
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
	
		local natEnableStr = luci.http.formvalue("natDataStr")
		local oldHwNatEnableStr = uci:get("system", "hwnat", "enable")

		if not oldHwNatEnableStr then
			local tmp_hwnat_name = uci:add("system", "hwnat")
			uci:rename("system", tmp_hwnat_name, "hwnat")
			oldHwNatEnableStr = "0"
		end

		uci:set("system", "hwnat", "enable", natEnableStr)
		uci:commit("system")

		if oldHwNatEnableStr ~= natEnableStr then
			if natEnableStr == "1" then
				sys.exec("hwnat-enable.sh")
			else
				sys.exec("hwnat-disable.sh")
			end
		end
	end

	luci.template.render("iodata/nat")
end
