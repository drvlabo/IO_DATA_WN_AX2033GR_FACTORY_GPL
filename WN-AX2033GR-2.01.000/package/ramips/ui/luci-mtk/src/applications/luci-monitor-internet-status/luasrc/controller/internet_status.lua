module("luci.controller.internet_status", package.seeall)
local uci = require("luci.model.uci").cursor()
local sys = require("luci.sys")

function index()
	local i18n = require("luci.i18n")
	local libuci = require("luci.model.uci").cursor()
	local lang = libuci:get("luci","main","lang") 
	i18n.load("internet_status",lang)
	i18n.setlanguage(lang)
	
	local page  = node("expert", "monitor", "wanstats")
	page.target = call("action_wanstatus")
	page.title  = i18n.translate("WAN_Status") 
	page.order  = 65
end

function action_wanstatus()
	local SetIntvl = luci.http.formvalue("SetIntvl")
	local url = luci.dispatcher.build_url("expert", "monitor", "wanstats")
	
	local lte_connect = luci.http.formvalue("lte_connect")
	local lte_disconnect = luci.http.formvalue("lte_disconnect")
	local set_auto_connect_boot = luci.http.formvalue("set_auto_connect_boot")
	
	if SetIntvl then
		local interval = luci.http.formvalue("interval")
		local SysStatusFile = io.open("/tmp/WanStatus_interval", "w")

		if interval=="00000000" then
			SysStatusFile:write("0")		
		elseif interval=="00000001" then
			SysStatusFile:write("60")
		elseif interval=="00000002" then
			SysStatusFile:write("120")
		elseif interval=="00000003" then
			SysStatusFile:write("180")
		elseif interval=="00000004" then
			SysStatusFile:write("240")
		elseif interval=="00000005" then
			SysStatusFile:write("300")
		end
		SysStatusFile:close()	
	
		luci.http.redirect(url)
		return	
	end
	
	if lte_connect then	
		sys.exec("mode_pref.sh connect")		
		luci.http.redirect(url)
		return	
	end
	
	if lte_disconnect then
		sys.exec("mode_pref.sh disconnect")			
		luci.http.redirect(url)
		return	
	end
	
	if set_auto_connect_boot then
		local auto_connect_boot = luci.http.formvalue("auto_connect_boot")			
		
		if auto_connect_boot=="1" then
			uci:set("wanconfig","wanconfig","boot_autoconnect","1")		
		elseif auto_connect_boot=="0" then
			uci:set("wanconfig","wanconfig","boot_autoconnect","0")			
		end
		
		uci:commit("wanconfig")	
		uci:apply("wanconfig")
		luci.http.redirect(url)		
		return	
	end
	
	--Marco, this will update WAN information to UCI before we try to load dashboard page
	sys.exec("/usr/sbin/update_wan_to_uci.sh")
	luci.template.render("Sum_WanStatusFrame")
end