module("luci.controller.dmz", package.seeall)
local uci = require("luci.model.uci").cursor()
local sys = require("luci.sys")

function index()
	local i18n = require("luci.i18n")
	local libuci = require("luci.model.uci").cursor()
	local lang = libuci:get("luci","main","lang") 
	i18n.load("dmz",lang)
	i18n.setlanguage(lang)
	
	local page  = node("expert", "configuration", "network", "nat")
	page.target = call("action_dmz")
	page.title  = i18n.translate("DMZ")
	page.order  = 71  
end

function action_dmz()
	local apply = luci.http.formvalue("apply")
	
	if apply then
		local serChange = luci.http.formvalue("serChange")
		local changeToSerIP = luci.http.formvalue("changeToSerIP")
		local last_changeToSerIP
		local changeToSer = 0		
		if (serChange=="change") then
			if not (changeToSerIP=="") then
				local changeToSer = 1
				uci:set("nat","general","changeToSer",changeToSer)
				uci:set("nat","general","changeToSerIP",changeToSerIP)
			end	
		else
			last_changeToSerIP = uci:get("nat","general","changeToSerIP")
			if last_changeToSerIP then
				uci:delete("nat","general","changeToSerIP")
				--uci:set("nat","general","last_changeToSerIP",last_changeToSerIP)
			end
			uci:set("nat","general","changeToSer",changeToSer)			
			
		end	
		
		uci:commit("nat")
		uci:apply("nat")
		sys.exec("/usr/sbin/nat reload")
	end	
	
	luci.template.render("dmz")
end