module("luci.controller.network_settings", package.seeall)
local uci = require("luci.model.uci").cursor()
local sys = require("luci.sys")

function index()
	local i18n = require("luci.i18n")
	local libuci = require("luci.model.uci").cursor()
	local lang = libuci:get("luci","main","lang") 
	i18n.load("network_settings",lang)
	i18n.setlanguage(lang)
	
	local page  = node("expert", "configuration", "lte", "network_settings")
	page.target = call("action_lte_network_settings")
	page.title  = i18n.translate("Network Settings")
	page.order  = 43
	
	local page  = node("expert", "configuration", "lte", "network_settings", "network_select")
	page.target = call("action_lte_network_select")
	page.title  = i18n.translate("Network Select")
	page.order  = 43  
end

function action_lte_network_settings()
	local apply = luci.http.formvalue("sysSubmit")
	
	if apply then
	-- Network Mode
		local netmode = uci:get("wanconfig","wanconfig","netmode")
		local select_wan_mode = luci.http.formvalue("_select_wan_mode")
		
		uci:set("wanconfig","wanconfig","netmode",select_wan_mode)	
	-- MTU Size	
		local mtu_size = uci:get("wanconfig","wanconfig","mtu_size")	
		local mtu = luci.http.formvalue("mtu")
		
		uci:set("wanconfig","wanconfig","mtu_size",mtu)
		
		uci:save("wanconfig")
		uci:commit("wanconfig")
		
		if netmode ~= select_wan_mode then
			sys.exec("mode_pref.sh set_from_cfg")
		end
		
		if mtu_size ~= mtu then
			sys.exec("mtu_settings.sh set_wan_from_cfg")
		end
	end
	
	luci.template.render("network_settings")
end

function action_lte_network_select()
	local ConfirmDisableAutoSelection = luci.http.formvalue("ConfirmDisableAutoSelection")
	local SelectSubmit = luci.http.formvalue("SelectSubmit")
	
	if ConfirmDisableAutoSelection == "1" and SelectSubmit ~= "1" then
		sys.exec("/usr/sbin/network_select.sh scan")
		luci.template.render("network_select", {ScanDone = 1})
	elseif ConfirmDisableAutoSelection == "1" and SelectSubmit == "1" then
		local select_net_scan_index = luci.http.formvalue("_select_net_scan_index")
		sys.exec("/usr/sbin/network_select.sh manual_from_result "..select_net_scan_index)
		sleep(1)
		luci.template.render("network_select", {SelectDone = 1})
	elseif ConfirmDisableAutoSelection == "0" and SelectSubmit == "1" then	
		sys.exec("/usr/sbin/network_select.sh auto")
		sleep(1)
		luci.template.render("network_select", {SelectAuto = 1})
	else
		luci.template.render("network_select")
	end	
end

function sleep(n)
  os.execute("sleep " .. tonumber(n))
end