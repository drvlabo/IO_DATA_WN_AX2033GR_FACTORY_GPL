--[[
LuCI - Lua Configuration Interface

Copyright 2011 Manuel Munz <freifunk somakoma de>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

]]--

module ("luci.controller.iodata.net_filtering_warning", package.seeall)
local uci = require("luci.model.uci").cursor()
local sys = require("luci.sys")
local csrf = require("luci.csrf")

function index()
		entry({"unauth", "net_filtering", "warning"}, call("action_warning"), _("Net Filtering Warning"), 1).leaf = true
		entry({"unauth", "net_filtering", "warning_reason"}, call("action_warning_reason"), _("Net Filtering Warning Reason"), 2).leaf = true
end

function action_warning()
	luci.template.render("iodata/net_filtering_warning")
end

function action_warning_reason()
	luci.template.render("iodata/net_filtering_warning_reason")
end