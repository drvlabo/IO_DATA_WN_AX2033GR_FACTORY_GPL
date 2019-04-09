--[[
LuCI - Lua Configuration Interface

Copyright 2011 Manuel Munz <freifunk somakoma de>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

]]--

module ("luci.controller.iodata.ioswinf", package.seeall)

local uci = require("luci.model.uci").cursor()
local sys = require("luci.sys")
local datatypes  = require("luci.cbi.datatypes")
local csrf = require("luci.csrf")

function index()
	entry({"ioswinf"}, template("iodata/ioswinf"), _("ioswinf"), 1)
end
