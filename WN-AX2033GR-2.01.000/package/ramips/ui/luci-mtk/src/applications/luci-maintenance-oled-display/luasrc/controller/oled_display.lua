module("luci.controller.oled_display", package.seeall)
local uci = require("luci.model.uci").cursor()
local sys = require("luci.sys")

function index()
	local i18n = require("luci.i18n")
	local libuci = require("luci.model.uci").cursor()
	local lang = libuci:get("luci","main","lang") 
	i18n.load("oled_display",lang)
	i18n.setlanguage(lang)
	
	local page  = node("expert", "maintenance", "oled")
	page.target = call("action_oled_config")
	page.title  = i18n.translate("oled_display")  
	page.order  = 95
end

function action_oled_config()
local set = luci.http.formvalue("sysSubmit")
local clear = luci.http.formvalue("sysClear")
	
	if set then
		local Screen_timeout = luci.http.formvalue("_screen_timeout")
		uci:set("mtoled","oled","sleeptime",Screen_timeout)
		uci:commit("mtoled")
		sys.exec("mtoled_config.sh sleeptime")	
	end

	if clear then		
		sys.exec("uci set runtime.oled.traffic=0 -c /tmp/tmp_config/")
		sys.exec("uci set runtime.oled.traffic_ipv4=0 -c /tmp/tmp_config/")
		sys.exec("uci set runtime.oled.traffic_ipv6=0 -c /tmp/tmp_config/")
		sys.exec("uci set traffic.oled.traffic=0 -c /conf")
		sys.exec("uci set traffic.oled.traffic_ipv4=0 -c /conf")
		sys.exec("uci set traffic.oled.traffic_ipv6=0 -c /conf")
		sys.exec("uci commit traffic -c /conf")
		sys.exec("mtoled_config.sh traffic")
	end	
	
	luci.template.render("oled_config")
end