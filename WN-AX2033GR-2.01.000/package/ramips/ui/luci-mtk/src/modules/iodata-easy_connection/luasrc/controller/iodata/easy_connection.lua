
--[[
]]--

module("luci.controller.iodata.easy_connection", package.seeall)
local uci = require("luci.model.uci").cursor()
local sys = require("luci.sys")
local datatypes  = require("luci.cbi.datatypes")

function index()
	local uci2 = require("luci.model.uci").cursor()
	local mode_check = uci2:get("network","wan","mode")
	if mode_check == "router" and mode_check ~= "ap" then		
		entry({"menu", "easy_connection"}, alias("content", "easy_connection"), _("Easy Connection"), 2).leaf = true
		entry({"content", "easy_connection"}, template("iodata/easy_connection"), _("Easy Connection"), 2)
	end
end