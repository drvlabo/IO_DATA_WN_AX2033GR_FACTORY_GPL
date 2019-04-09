
--[[
]]--

module("luci.controller.iodata.lan_settings", package.seeall)

function index()
	entry({"menu", "lan_settings"}, alias("content", "lan_settings"), _("LAN Settings"), 4).leaf = true
	entry({"content", "lan_settings"}, firstchild(), _("LAN Settings"), 4)
end