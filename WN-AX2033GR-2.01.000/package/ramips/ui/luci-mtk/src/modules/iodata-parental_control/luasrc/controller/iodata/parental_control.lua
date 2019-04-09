
--[[
]]--

module("luci.controller.iodata.parental_control", package.seeall)

function index()
	local uci2 = require("luci.model.uci").cursor()
	local exanime_mode = uci2:get("network","wan","mode")
	if exanime_mode ~= "repeater" then
		entry({"menu", "parental_control"}, alias("content", "parental_control"), _("Parental Control"), 10).leaf = true
		entry({"content", "parental_control"}, firstchild(), _("Parental Control"), 10)
	end
end
