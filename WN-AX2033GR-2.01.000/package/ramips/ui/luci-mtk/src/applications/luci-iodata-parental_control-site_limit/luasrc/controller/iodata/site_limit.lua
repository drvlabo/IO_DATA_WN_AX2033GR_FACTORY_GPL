--[[
LuCI - Lua Configuration Interface

Copyright 2011 Manuel Munz <freifunk somakoma de>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

]]--

module ("luci.controller.iodata.site_limit",package.seeall)

function index()
	entry({"content", "parental_control", "site_limit"}, call("action_site_limit"), _("Site Limit"), 2).leaf = true
end

function action_site_limit()
	luci.template.render("iodata/individual_settings", {src_url="/content/parental_control/site_limit"})
end