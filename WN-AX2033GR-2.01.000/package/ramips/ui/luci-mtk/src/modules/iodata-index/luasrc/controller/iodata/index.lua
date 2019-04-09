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

module("luci.controller.iodata.index", package.seeall)

function index()
	--[[
	local root = node()
	if not root.lock then
		root.target = alias("menu")
		root.index = true
	end
	]]--

	entry({"about"}, template("about"))
	entry({"content"}, alias("menu"), _("Status"))
	entry({"menu"}, template("iodata/index"), _("Status"), 1)
	entry({"mobile"}, template("iodata/smartindex"), _("Status"), 1)
	entry({"unauth"}, template("unauth"), _("Unauth"), 2)
	--[[
	local page = entry({"menu"}, template("iodata/index"), _("Status"), 1)
	page.sysauth = nil
	page.sysauth_authenticator = "htmlauth"
	page.index = true
	]]--
end
