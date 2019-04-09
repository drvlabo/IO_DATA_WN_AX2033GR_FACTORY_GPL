--[[
LuCI - Lua Configuration Interface

Copyright 2011 Manuel Munz <freifunk somakoma de>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

]]--

module "luci.controller.iodata.vpn_status"

function index()
	entry({"content", "vpn", "vpn_status"}, template("iodata/vpn_status"), _("Status"), 1).leaf = true
end
