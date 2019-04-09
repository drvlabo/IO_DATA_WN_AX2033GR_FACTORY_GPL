
--[[
]]--

module("luci.controller.iodata.net_filtering", package.seeall)

function index()
	local uci2 = require("luci.model.uci").cursor()
	local exanime_mode = uci2:get("network","wan","mode")
	if exanime_mode ~= "repeater" then
		entry({"menu", "net_filtering"}, alias("content", "net_filtering"), _("Net Filtering"), 9).leaf = true
		entry({"content", "net_filtering"}, firstchild(), _("Net Filtering"), 9)
		entry({"unauth", "net_filtering"}, firstchild(), _("Net Filtering"), 1)
	end
end
