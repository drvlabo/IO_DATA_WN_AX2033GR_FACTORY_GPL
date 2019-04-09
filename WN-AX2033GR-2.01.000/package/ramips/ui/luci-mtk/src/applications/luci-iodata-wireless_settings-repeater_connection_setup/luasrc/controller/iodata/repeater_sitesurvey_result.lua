--[[
LuCI - Lua Configuration Interface

Copyright 2011 Manuel Munz <freifunk somakoma de>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

]]--

--[[
page call flow:
repeater_connection_settings -> repeater_sitesurvey -> repeater_sitesurvey_result -> repeater_connection_setup -> repeater_connection_save
or
repeater_connection_settings -> repeater_connection_setup -> repeater_connection_save
]]

module ("luci.controller.iodata.repeater_sitesurvey_result", package.seeall)

function index()
	entry({"content", "wireless_settings", "repeater_connection_settings", "repeater_sitesurvey_result"}, call("action_sitesurvey"), _("Site Survey"), 0).leaf = true
end

function action_sitesurvey()
	luci.template.render("iodata/repeater_sitesurvey_result")
end