--[[
LuCI - Lua Configuration Interface

Copyright 2008 Steven Barth <steven@midlink.org>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

$Id: index.lua 4040 2009-01-16 12:35:25Z Cyrus $
]]--
module("luci.controller.monitor", package.seeall)
local uci = require("luci.model.uci").cursor()
local sys = require("luci.sys")

function index()
	
	local i18n = require("luci.i18n")
	local libuci = require("luci.model.uci").cursor()
	local lang = libuci:get("luci","main","lang") 
	i18n.load("common",lang)
	i18n.setlanguage(lang)
	
	local page  = node("expert", "monitor")
	page.target = template("../../../../../tmp/web/monitor")
	page.title  = i18n.translate("Monitor")  
	page.order  = 40
end
