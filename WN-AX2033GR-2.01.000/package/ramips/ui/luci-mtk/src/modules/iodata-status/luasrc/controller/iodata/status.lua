
--[[
]]--

module("luci.controller.iodata.status", package.seeall)

function index()
	entry({"menu", "status"}, alias("content", "status"), _("Status"), 1).leaf = true
	entry({"content", "status"}, template("iodata/status"), _("Status"), 1)
end