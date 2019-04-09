--[[
LuCI - Lua Configuration Interface

Copyright 2011 Manuel Munz <freifunk somakoma de>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

]]--

module ("luci.controller.iodata.countdown", package.seeall)
local uci = require("luci.model.uci").cursor()
local sys = require("luci.sys")

function index()
	entry({"content", "system_settings", "firmware", "countdown"}, call("action_countdown"), _("Countdown"), 0).leaf = true
end

function action_countdown()
	luci.template.render("iodata/countdown")
end