
--[[
]]--

module("luci.controller.iodata.advanced_settings", package.seeall)

function index()
	entry({"menu", "advanced_settings"}, alias("content", "advanced_settings"), _("Advanced Settings"), 8).leaf = true
	entry({"content", "advanced_settings"}, firstchild(), _("Advanced Settings"), 8)
end