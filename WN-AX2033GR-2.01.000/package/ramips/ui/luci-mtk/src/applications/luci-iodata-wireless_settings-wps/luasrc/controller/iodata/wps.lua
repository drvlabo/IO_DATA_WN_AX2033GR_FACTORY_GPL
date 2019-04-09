--[[
LuCI - Lua Configuration Interface

Copyright 2011 Manuel Munz <freifunk somakoma de>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

]]--

module ("luci.controller.iodata.wps", package.seeall)
local uci = require("luci.model.uci").cursor()
local sys = require("luci.sys")
local csrf = require("luci.csrf")

function index()
	local uci2 = require("luci.model.uci").cursor()
	local current_wan_mode = uci2:get("network","wan",'mode')
	if current_wan_mode ~= "repeater" then
		entry({"content", "wireless_settings", "wps"}, call("action_wps"), _("WPS"), 5).leaf = true
	end
end

function action_wps()

	local apply = luci.http.formvalue("apply")
	local wps_function = luci.http.formvalue("wps_function")
	--We still need to check the value in teh lua program, because user may close javascript
	
	if apply then	
	
		--[[=========CSRF check Start=========--]]
		local csrf_token_web = csrf.get_csrf_token_in_web()
		--if csrf token is wrong or can't get it from web, return 403
		if ( not csrf.verify(csrf_token_web) ) then
			wrong_value = true;
			csrf.http_return_403()
			return
		end
		--[[=========CSRF check End=========--]]
	
		--get all wireless parameter here
		--MSTC MBA Sean, need to get the iface id from openwrt, dirty work...
		local ifce2g={}
		local ifce5g={}
		local device_2g
		local device_5g
		
		local wifi_2g_disable="0"
		local wifi_5g_disable="0"
		
		--MSTC MVA Sean, get all 2.4G chip device name
		uci.foreach("wireless", "wifi-iface", 
		function(s)
			if s.mode == "ap" then
				if s.device == "mt7620" or s.device == "mt7602e" or s.device == "mt7603e" or s.device == "mt7628" or s.device == "mt7688" or s.device == "mt7615e2" then 
					device_2g = s.device
					ifce2g[#ifce2g+1] = s[".name"]
				end
				if s.device == "mt7610e"  or s.device == "mt7612e" or s.device == "mt7615e5" then 
					device_5g = s.device
					ifce5g[#ifce5g+1] = s[".name"]
				end
			end
		end)
		
		if ifce2g[1] then
			local uci_disabled = uci:get("wireless", ifce2g[1], "disabled")
			if uci_disabled then 
				wifi_2g_disable = uci_disabled
			end
		end
		
		if ifce5g[1] then
			local uci_disabled = uci:get("wireless", ifce5g[1], "disabled")
			if uci_disabled then 
				wifi_5g_disable = uci_disabled
			end
		end
		
		local wps_enable_uci = "0"
		if device_2g then
			wps_enable_uci = uci:get("wireless", device_2g, "wsc_confmode")
		end
	
		local wps_enable = luci.http.formvalue("wps_enable")
		local wps_pin_code = luci.http.formvalue("wps_pin_code")
		
		if wps_function == "wps_onoff" then
			if ( (wps_enable == "7") or (wps_enable =="0") ) then
				if device_2g then
					uci:set("wireless", device_2g, "wsc_confmode", wps_enable)
					if (wps_enable == "0") then
						uci:set("wireless", device_2g, "wps_enable", "0")
					else
						uci:set("wireless", device_2g, "wps_enable", "1")
					end
				end
				if device_5g then
					uci:set("wireless", device_5g, "wsc_confmode", wps_enable)
					if (wps_enable == "0") then
						uci:set("wireless", device_5g, "wps_enable", "0")
					else
						uci:set("wireless", device_5g, "wps_enable", "1")
					end
				end
				local command = string.format("ps | pgrep mstc_wps_util | awk '{print \"kill -9 \" $0}' | sh")
				os.execute(command)
				uci:commit("wireless")
			end
			sys.exec("wifi reload_legacy")
		elseif wps_function == "wps_configure_reset" then --TBD
			uci:set("wireless", device_2g, "wsc_confstatus", "1")
			uci:set("wireless", device_5g, "wsc_confstatus", "1")
			uci:commit("wireless")
			sys.exec("wifi reload_legacy")
		elseif wps_function == "wps_push_button" then
			if wps_enable_uci == "7" then 
				--MSTC MVA Sean, kill the mstc_wps_util function first
				local command = string.format("ps | pgrep mstc_wps_util | awk '{print \"kill -9 \" $0}' | sh")
				os.execute(command)
				if( (wifi_2g_disable == "0") or (wifi_5g_disable == "0") ) then 
					os.execute("mstc_wps_util&")
				end
				
				if( wifi_2g_disable == "0" ) then 
					os.execute("iwpriv ra0 set WscStop=1")
					os.execute("iwpriv ra0 set WscConfMode=7")
					os.execute("iwpriv ra0 set WscMode=2")
					os.execute("iwpriv ra0 set WscGetConf=1")
				end
				
				if( wifi_5g_disable == "0" ) then 
					os.execute("iwpriv rai0 set WscStop=1")
					os.execute("iwpriv rai0 set WscConfMode=7")
					os.execute("iwpriv rai0 set WscMode=2")
					os.execute("iwpriv rai0 set WscGetConf=1")
				end
			end
		elseif wps_function == "wps_pin_connect" then
			
			--MBA Sean, run wps for 2.4G & 5G
			if wps_enable_uci == "7" then 
				--MSTC MVA Sean, kill the mstc_wps_util function first
				local command = string.format("ps | pgrep mstc_wps_util | awk '{print \"kill -9 \" $0}' | sh")
				os.execute(command)
				if( (wifi_2g_disable == "0") or (wifi_5g_disable == "0") ) then 
					os.execute("mstc_wps_util&")
				end
				
				if( wifi_5g_disable == "0" ) then 
					os.execute("iwpriv rai0 set WscStop=1")
					os.execute("iwpriv rai0 set WscConfMode=7")
					os.execute("iwpriv rai0 set WscMode=1")
					os.execute("iwpriv rai0 set WscPinCode=" .. wps_pin_code)
					os.execute("iwpriv rai0 set WscGetConf=1")
					os.execute("iwpriv rai0 set WscStatus=0")
				end
				
				if( wifi_2g_disable == "0" ) then 
					os.execute("iwpriv ra0 set WscStop=1")
					os.execute("iwpriv ra0 set WscConfMode=7")
					os.execute("iwpriv ra0 set WscMode=1")
					os.execute("iwpriv ra0 set WscPinCode=" .. wps_pin_code)
					os.execute("iwpriv ra0 set WscGetConf=1")
					os.execute("iwpriv ra0 set WscStatus=0")
				end
			end
		end
		
	end
	luci.template.render("iodata/wps")
end
