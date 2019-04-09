--[[
LuCI - Lua Configuration Interface

Copyright 2011 Manuel Munz <freifunk somakoma de>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

]]--

module ("luci.controller.iodata.log", package.seeall)
local uci = require("luci.model.uci").cursor()
local sys = require("luci.sys")
local csrf = require("luci.csrf")

function index()
	entry({"content", "system_settings", "log"}, call("action_log"), _("Log"), 3).leaf = true
end

function action_log()
	local isSave = luci.http.formvalue("isSave")
	local isClean = luci.http.formvalue("isClean")

	if isSave and isSave == "1" then
	
		--[[=========CSRF check Start=========--]]
		local csrf_token_web = csrf.get_csrf_token_in_web()
		--if csrf token is wrong or can't get it from web, return 403
		if ( not csrf.verify(csrf_token_web) ) then
			wrong_value = true;
			csrf.http_return_403()
			return
		end
		--[[=========CSRF check End=========--]]
		-- Terence, define http header for download file
		luci.http.prepare_content("application/octetstream")	--for IE & Opera
		luci.http.prepare_content("application/octet-stream")	--for the rest
		luci.http.header("Content-Disposition", "attachment; filename=sys.log");
		luci.http.header("Content-Transfer-Encoding", "binary");
		luci.http.header("Cache-Control", "cache, must-revalidate");
		-- MSTC MBA Sean, set Cookie to notify server that file has been downloaded
		luci.http.header("Set-Cookie", "file_loading=true")
		luci.http.header("Pragma", "public");
		luci.http.header("Expires", "0");
		-- MSTC MBA Sean, Read the file
		local rfile=io.open("/tmp/simple_log.log", "r")
		if rfile~=nil then
			for str in rfile:lines() do
				if string.len(str) ~= 0 then
					luci.http.write(str .. "\r\n")
				end
			end
			io.close(rfile)
		end
	elseif isClean and isClean == "1" then
	
		--[[=========CSRF check Start=========--]]
		local csrf_token_web = csrf.get_csrf_token_in_web()
		--if csrf token is wrong or can't get it from web, return 403
		if ( not csrf.verify(csrf_token_web) ) then
			wrong_value = true;
			csrf.http_return_403()
			return
		end
		--[[=========CSRF check End=========--]]
	
		sys.exec("simple_logrec.sh -c 2&>/dev/null")
	end

	if not isSave or isSave ~= "1" then
		luci.template.render("iodata/log")
	end
end
