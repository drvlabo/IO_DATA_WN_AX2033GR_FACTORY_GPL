--[[
LuCI - Lua Configuration Interface

Copyright 2008 Steven Barth <steven@midlink.org>
Copyright 2008 Jo-Philipp Wich <xm@leipzig.freifunk.net>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

$Id$
]]--

module("luci.controller.iodata.redirect", package.seeall)

function index()
	local root = node()
	if not root.lock then
		root.target = alias("redirect")
		root.index = true
	end
	
	local page = entry({"redirect"}, template("iodata/redirect"), _("redirect"), 1)
	page.sysauth = nil
	page.sysauth_authenticator = "htmlauth"
	page.index = true
end
