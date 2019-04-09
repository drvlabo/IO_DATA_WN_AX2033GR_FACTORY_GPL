module("luci.controller.help", package.seeall)
local uci = require("luci.model.uci").cursor()
local sys = require("luci.sys")

function index()
	local i18n = require("luci.i18n")
	local libuci = require("luci.model.uci").cursor()
	local lang = libuci:get("luci","main","lang") 
	i18n.load("help",lang)
	i18n.setlanguage(lang)
	
	local page  = node("expert", "help")
	page.target = call("action_help")
	page.title  = i18n.translate("HELP")  
	page.order  = 65
	
end

function action_help()
	luci.template.render("help")
end
