
--[[
]]--

module("luci.controller.mstc.csrf_token", package.seeall)

local csrf = require("luci.csrf")
local http = require "luci.http"

function index()
	entry({"csrf"}, alias("menu"), _("Status"))
	entry({"csrf", "csrf_token"}, call("action_csrf_token"), _("Wireless Settings"), 1).leaf = true
end

function action_csrf_token()
	local csrf_token = csrf.create_token()
	http.write(csrf_token)
end