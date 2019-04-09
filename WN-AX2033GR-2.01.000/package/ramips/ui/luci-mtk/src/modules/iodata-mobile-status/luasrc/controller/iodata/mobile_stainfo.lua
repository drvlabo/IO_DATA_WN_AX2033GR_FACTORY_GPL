
--[[
]]--

module("luci.controller.iodata.mobile_stainfo", package.seeall)

function index()
	entry({"mobile", "mobile_stainfo"}, template("iodata/mobile_stainfo"), _("Status"), 1)
end
