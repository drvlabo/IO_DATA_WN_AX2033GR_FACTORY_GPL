
--[[
]]--

module("luci.controller.iodata.vpn", package.seeall)

function index()
	local uci2 = require("luci.model.uci").cursor()
	local current_wan_mode = uci2:get("network","wan",'mode')
	if current_wan_mode ~= "repeater" and current_wan_mode ~= "transix" and current_wan_mode ~= "v6plus" then
		entry({"menu", "vpn"}, alias("content", "vpn"), _("VPN"), 7).leaf = true
		entry({"content", "vpn"}, firstchild(), _("VPN"), 7)
	end		
end
