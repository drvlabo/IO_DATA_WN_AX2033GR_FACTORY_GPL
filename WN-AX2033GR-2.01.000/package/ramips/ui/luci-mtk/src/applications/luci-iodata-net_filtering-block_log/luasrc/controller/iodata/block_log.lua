--[[
LuCI - Lua Configuration Interface

Copyright 2011 Manuel Munz <freifunk somakoma de>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

]]--

module ("luci.controller.iodata.block_log", package.seeall)
local http = require "luci.http"
local uci = require("luci.model.uci").cursor()
local sys = require("luci.sys")
local csrf = require("luci.csrf")

function index()
	entry({"content", "net_filtering", "block_log"}, call("action_log"), _("Block Log"), 4).leaf = true
end

function action_log()
	local isClean = luci.http.formvalue("isClean")

	if isClean and isClean == "1" then
	
		--[[=========CSRF check Start=========--]]
		local csrf_token_web = csrf.get_csrf_token_in_web()
		--if csrf token is wrong or can't get it from web, return 403
		if ( not csrf.verify(csrf_token_web) ) then
			wrong_value = true;
			csrf.http_return_403()
			return
		end
		--[[=========CSRF check End=========--]]
	
		sys.exec("killall -SIGUSR2 mstc_sbd 1>/dev/null 2>&1")
	end

	sys.exec("rm -f /tmp/siteblock/blocklog.log 1>/dev/null 2>&1")
	sys.exec("killall -SIGUSR1 mstc_sbd 1>/dev/null 2>&1")
	sys.exec("sleep 1")
	--if not isSave or isSave ~= "1" then
		luci.template.render("iodata/block_log")
	--end
end
