
--[[
]]--

module("luci.controller.iodata.security", package.seeall)

function index()
	local uci2 = require("luci.model.uci").cursor()
	local exanime_mode = uci2:get("network","wan","mode")
	if (exanime_mode == "router" or exanime_mode == "v6plus" or exanime_mode == "transix") then
		entry({"menu", "security"}, alias("content", "security"), _("Security"), 6).leaf = true
		entry({"content", "security"}, firstchild(), _("Security"), 6)
	end
end