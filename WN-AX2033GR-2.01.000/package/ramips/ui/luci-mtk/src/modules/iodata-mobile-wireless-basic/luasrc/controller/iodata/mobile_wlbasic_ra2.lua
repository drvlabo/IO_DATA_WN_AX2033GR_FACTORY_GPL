
--[[
]]--

module("luci.controller.iodata.mobile_wlbasic_ra2", package.seeall)
local uci = require("luci.model.uci").cursor()
local sys = require("luci.sys")
local datatypes  = require("luci.cbi.datatypes")
local csrf = require("luci.csrf")

function index()
	entry({"mobile", "mobile_wlbasic_ra2"}, call("action_wl_settings"), _("Wireless Settings"), 1)
end

function action_wl_settings()
	local apply = luci.http.formvalue("apply")
	local wps_function = luci.http.formvalue("wps_function")
	local wrong_value = false
	local ifce2g={}
	local ifce5g={}
	local device_2g
	local device_5g
	local wifi_2g_disable="0"
	local wifi_5g_disable="0"
	local wps_enable_uci = "0"
	--MSTC MBA Sean, get all 2.4G & 5G chip device name
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
		
	if device_2g then
		wps_enable_uci = uci:get("wireless", device_2g, "wsc_confmode")
	end
	
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
	
		local wireless_2g_channel = luci.http.formvalue("2g_channel")
		local wireless_5g_channel = luci.http.formvalue("5g_channel")
		local ssid1_ssid = luci.http.formvalue("ssid1_ssid")
		local ssid2_ssid = luci.http.formvalue("ssid2_ssid")
		local ssid1_key = luci.http.formvalue("ssid1_key")
		local ssid2_key = luci.http.formvalue("ssid2_key")

		
		-- 2.4G and 5G wifi channel setting
		local ssid1_device = uci.get("wireless", ifce2g[1], "device")
		local ssid2_device = uci.get("wireless", ifce5g[1], "device")

		if (not datatypes.range(wireless_2g_channel,1, 13)) and (not wireless_2g_channel == "auto") then
			wrong_value = true
		else
			if wireless_2g_channel == "auto" then
				uci:set("wireless", ssid1_device, "channel", "auto1")
			else
				uci:set("wireless", ssid1_device, "channel", wireless_2g_channel)
			end
		end
		
		if (not datatypes.range(wireless_5g_channel,36, 140)) and (not wireless_5g_channel == "auto") then
			wrong_value = true
		else
			if wireless_5g_channel == "auto" then
				uci:set("wireless", ssid2_device, "channel", "auto1")
			else
				uci:set("wireless", ssid2_device, "channel", wireless_5g_channel)
			end
		end
		-- end channel setting
		
		-- SSID 1 & SSID 2 display name settings
		if ssid1_ssid then
			uci:set("wireless", ifce2g[1], "ssid", ssid1_ssid)
		else
			wrong_value = true
		end
		
		if ssid2_ssid then
			uci:set("wireless", ifce5g[1], "ssid", ssid2_ssid)
		else
			wrong_value = true
		end
		--end
		
		-- SSID 1 & SSID 2 security key settings
		local ssid1_security = uci.get("wireless", ifce2g[1], "encryption")
		if ssid1_security == "wep-auto" then
			local ssid1_wep_default_key = uci:get("wireless", ifce2g[1], "key")
			uci:set("wireless", ifce2g[1], "key" .. ssid1_wep_default_key, ssid1_key)
		elseif ssid1_security == "psk2+ccmp" or ssid1_security == "psk-mixed+tkip+ccmp" then
			uci:set("wireless", ifce2g[1], "key", ssid1_key)
		elseif ssid1_security ~= "none" then
			wrong_value = true
		end
		
		local ssid2_security = uci.get("wireless", ifce5g[1], "encryption")
		if ssid2_security == "wep-auto" then
			local ssid2_wep_default_key = uci:get("wireless", ifce5g[1], "key")
			uci:set("wireless", ifce5g[1], "key" .. ssid2_wep_default_key, ssid2_key)
		elseif ssid2_security == "psk2+ccmp" or ssid2_security == "psk-mixed+tkip+ccmp" then
			uci:set("wireless", ifce5g[1], "key", ssid2_key)
		elseif ssid2_security ~= "none" then
			wrong_value = true
		end
		--end security
		if not wrong_value then
			uci:commit("wireless")
			sys.exec("wifi reload_legacy")
			sys.exec("/etc/init.d/iodata_dfs_channel_reset restart")
		end
	end
	
	--MBA, Olivia, control the WPS HW button via GUI
	if wps_function == "wps_push_button" then
		--kill the mstc_wps_util function first
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
	end
	--end
	
	luci.template.render("iodata/mobile_wlbasic_ra2")
end

