
--[[
]]--

module("luci.controller.iodata.ezinet", package.seeall)

function index()
	entry({"mobile", "ezinet"}, template("iodata/ezinet"), _("Easy connection"), 2)
end
