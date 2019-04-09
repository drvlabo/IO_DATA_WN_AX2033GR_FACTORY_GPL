module("luci.controller.restart", package.seeall)
local uci = require("luci.model.uci").cursor()
local sys = require("luci.sys")

function index()
	local i18n = require("luci.i18n")
	local libuci = require("luci.model.uci").cursor()
	local lang = libuci:get("luci","main","lang") 
	i18n.load("restart",lang)
	i18n.setlanguage(lang)
	
	local page  = node("expert", "maintenance", "Systemrebooting")
	page.target = call("action_restart")
	page.title  = i18n.translate("Systemrebooting")  
	page.order  = 85
end

function action_restart()
	local restartsystem = luci.http.formvalue("restartsystem")
	
	if restartsystem then
		luci.template.render("restart",{rebootsystem=1})
		sys.exec("reboot")
	else
		luci.template.render("restart")
	end
end