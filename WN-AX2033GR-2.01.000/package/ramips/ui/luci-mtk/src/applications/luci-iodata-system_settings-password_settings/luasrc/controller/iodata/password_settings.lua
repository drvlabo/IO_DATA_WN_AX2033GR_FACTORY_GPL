--[[
LuCI - Lua Configuration Interface

Copyright 2011 Manuel Munz <freifunk somakoma de>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

]]--

module ("luci.controller.iodata.password_settings", package.seeall)

local uci = require("luci.model.uci").cursor()
local sys = require("luci.sys")
local datatypes  = require("luci.cbi.datatypes")
local csrf = require("luci.csrf")

function index()
	entry({"content", "system_settings", "password_settings"}, call("password_settings"), _("Password Settings"), 1).leaf = true
end

function password_settings()
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
	
		local username = luci.http.formvalue("username")
		local pwdhash = luci.http.formvalue("pwdhash")

		--__MSTC__, Vincent: use ":match("^([^%s]+)")" to filter empty string
		--local sys_realm = luci.sys.exec("fw_printenv | grep product | awk -F '=' '{print $2}'"):match("^([^%s]+)")
		local sys_realm = luci.sys.exec("cat /etc/openwrt_release | grep DISTRIB_PRODUCT | awk -F '\"' '{print $2}'"):match("^([^%s]+)")
		--os.execute("echo sys_realm= "..sys_realm.." > /dev/console")	
		local emptyusrpwd_hash_cmd = string.format("echo -n :%q: | md5sum | cut -b -32", sys_realm)
		local emptyusrpwd_hash = luci.sys.exec(emptyusrpwd_hash_cmd):match("^([^%s]+)")
		--os.execute("echo emptyusrpwd_hash="..emptyusrpwd_hash.." > /dev/console")

		--os.execute("echo pwdhash= " ..pwdhash.. " > /dev/console")
		if ( emptyusrpwd_hash == pwdhash )  then
			uci:foreach( "account","http", function(s)
				uci:delete("account", s[".name"])
			end)
		else
			uci:foreach( "account","http", function(s)
				uci:delete("account", s[".name"])
			end)
			--os.execute("echo username= " ..username.. " > /dev/console")
			--os.execute("echo sys_realm= " ..sys_realm.. " > /dev/console")
			--os.execute("echo pwdhash= " ..pwdhash.. " > /dev/console")
			local tmp_name = uci:add("account","http")
			uci:rename("account", tmp_name, "http")
			uci:set("account","http","user", username)
			uci:set("account","http","realm", sys_realm)
			uci:set("account","http","password", pwdhash)
			uci:set("account","http","method", "digest")
			uci:set("account","http","debug", "0")
		end

		uci:commit("account")
		sys.exec("/bin/sleep 2 && /etc/init.d/lighttpd restart")
	end
	luci.template.render("iodata/password_settings")
end