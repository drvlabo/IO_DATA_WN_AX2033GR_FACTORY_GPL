
--[[
]]--

module("luci.controller.iodata.system_settings", package.seeall)

function index()
	entry({"menu", "system_settings"}, alias("content", "system_settings"), _("System Settings"), 11).leaf = true
	entry({"content", "system_settings"}, firstchild(), _("System Settings"), 11)
end