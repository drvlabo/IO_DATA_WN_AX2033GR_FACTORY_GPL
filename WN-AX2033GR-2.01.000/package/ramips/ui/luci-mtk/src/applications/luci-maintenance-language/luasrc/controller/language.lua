module("luci.controller.language", package.seeall)
local uci = require("luci.model.uci").cursor()
local sys = require("luci.sys")

function index()
	local i18n = require("luci.i18n")
	local libuci = require("luci.model.uci").cursor()
	local lang = libuci:get("luci","main","lang") 
	i18n.load("language",lang)
	i18n.setlanguage(lang)
	
	local page  = node("expert", "maintenance", "language")
	page.target = call("act_lang")
	page.title  = i18n.translate("Language")  
	page.order  = 90
end

function act_lang()
	local apply = luci.http.formvalue("apply")
	
	if apply then
		local lang = luci.http.formvalue("language")
		if lang then
			uci:set("luci","main","lang",lang)
			uci:commit("luci")
		end

		luci.template.render("language",{reload_page=1})
		return
	end
	
	luci.template.render("language",{reload_page=0})
end
