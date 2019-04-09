
--[[
]]--

module("luci.controller.iodata.wireless_settings", package.seeall)

function index()
	entry({"menu", "wireless_settings"}, alias("content", "wireless_settings"), _("Wireless Settings"), 5).leaf = true
	entry({"content", "wireless_settings"}, firstchild(), _("Wireless Settings"), 5)
end