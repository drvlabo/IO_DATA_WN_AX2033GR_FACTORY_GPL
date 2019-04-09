--[[
LuCI - Lua Configuration Interface

Copyright 2011 Manuel Munz <freifunk somakoma de>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

]]--

module ("luci.controller.iodata.2g_settings", package.seeall)
local uci = require("luci.model.uci").cursor()
local sys = require("luci.sys")
local datatypes  = require("luci.cbi.datatypes")
local csrf = require("luci.csrf")

function index()
	local uci2 = require("luci.model.uci").cursor()
	local current_wan_mode = uci2:get("network","wan",'mode')
	if current_wan_mode ~= "repeater" then
		entry({"content", "wireless_settings", "2g_settings"}, call("action_2g_settings"), _("2.4Ghz Settings"), 1).leaf = true
	else
		entry({"content", "wireless_settings", "repeater_2g_settings"}, call("action_repeater_2g_settings"), _("Repeater 2.4Ghz Settings"), 2).leaf = true
	end
end

local ap_ifce_2g={}
local client_ifce_2g={}
local device_2g="";
local device_5g=""
function scanWifiDev()
	--MSTC MVA Sean, get all 2.4G chip device name
	uci.foreach("wireless", "wifi-iface",
	function(s)
		if (s.device == "mt7620" or s.device == "mt7602e" or s.device == "mt7603e" or s.device == "mt7628" or s.device == "mt7688" or s.device == "mt7615e2") then
			if s.mode == "ap" then
				ap_ifce_2g[#ap_ifce_2g+1] = s[".name"]
			elseif s.mode == "client" then
				client_ifce_2g[#client_ifce_2g+1] = s[".name"]
			end
			device_2g=s.device
		end
		if ( s.device == "mt7615e5" or s.device == "mt7610e" or s.device == "mt7612e" ) then
			device_5g=s.device
		end
	end)
end

function changeNonRepeaterRadio(on)
	-- don't use 'radio'. it only works on client mode, and wps and site survey will use apcli. use 'device_on' to save status
	uci:set("wireless", device_2g, "device_on", on);

	if on == "1" then -- off to on
		uci:set("wireless", ap_ifce_2g[1], "disabled", "0"); -- main
		uci:set("wireless", ap_ifce_2g[2], "disabled", "0"); -- guest
		-- restore copy ssid 
		local copy_ssid_2g_disabled = uci:get("wireless", device_2g, "copy_ssid_disabled"); -- 2.4g copy ssid
		if not copy_ssid_2g_disabled then
			copy_ssid_2g_disabled = "1"
		end
		uci:set("wireless", ap_ifce_2g[3], "disabled", copy_ssid_2g_disabled); -- copy
	else -- on to off
		uci:set("wireless", ap_ifce_2g[1], "disabled", "1"); -- main
		uci:set("wireless", ap_ifce_2g[2], "disabled", "1"); -- guest
		uci:set("wireless", ap_ifce_2g[3], "disabled", "1"); -- copy
	end
end

function changeRepeaterRadio(on)
	-- don't use 'radio'. it only works on client mode, and wps and site survey will use apcli. use 'device_on' to save status
	uci:set("wireless", device_2g, "device_on", on);

	-- only config main ssid; guest ssid and copy ssid will handle by internet page
	if on == "1" then
		uci:set("wireless", ap_ifce_2g[1], "disabled", "0"); -- main
	else
		uci:set("wireless", ap_ifce_2g[1], "disabled", "1"); -- main
	end
end

function action_2g_settings()
	local apply = luci.http.formvalue("apply")
	
	local wrong_value = false
	
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
	
	--put your code here (uci commit, restart service ... etc)
		
		local wireless_2g_enable = luci.http.formvalue("2g_enable")
		local wireless_2g_channel = luci.http.formvalue("2g_channel")
		
		-- ssid1 part
		local ssid1_ssid = luci.http.formvalue("ssid1_ssid")
		local ssid1_broadcast_hidden = luci.http.formvalue("ssid1_broadcast_hidden")
		-- WMM always enable. local ssid1_wmm = luci.http.formvalue("ssid1_wmm")
		local ssid1_security = luci.http.formvalue("ssid1_security")
									
		-- ssid3 part
		local ssid3_ssid = luci.http.formvalue("ssid3_ssid")
		local ssid3_broadcast_hidden = luci.http.formvalue("ssid3_broadcast_hidden")
		-- WMM always enable. local ssid3_wmm = luci.http.formvalue("ssid3_wmm")
		local ssid3_security = luci.http.formvalue("ssid3_security")		
		
		local copy_ssid_2g_enable = luci.http.formvalue("copy_ssid_2g_enable")		
		
		--MSTC MBA Sean, need to get the iface id from openwrt, dirty work...
		scanWifiDev()
		
		-- ssid1 part	
		-- Add range ?
		uci:set("wireless", ap_ifce_2g[1], "ssid", ssid1_ssid)				
		
		if not datatypes.range(ssid1_broadcast_hidden,0, 1) then
			wrong_value = true
		else
			uci:set("wireless", ap_ifce_2g[1], "hidden", ssid1_broadcast_hidden)
			if ssid1_broadcast_hidden == "1" then
				--MSTC MBA Sean, disable the wps if user disable ssid broadcast
				uci:set("wireless", device_2g, "wsc_confmode", "0")
				uci:set("wireless", device_5g, "wsc_confmode", "0")
				uci:set("wireless", device_5g, "wps_enable", "0")
				uci:set("wireless", device_2g, "wps_enable", "0")
			end
		end

		-- WMM always enable
		uci:set("wireless", ap_ifce_2g[1], "wmm", "1")
		
		--MBA Sean, Only get the value from each Security mode 
		if ssid1_security == "none" then 
			wrong_value = false --do nothing
			uci:set("wireless", ap_ifce_2g[1], "encryption", ssid1_security)
			--MSTC MBA Sean, disable the wps if user select NO security
			uci:set("wireless", device_2g, "wsc_confmode", "0")
			uci:set("wireless", device_5g, "wsc_confmode", "0")
			uci:set("wireless", device_5g, "wps_enable", "0")
			uci:set("wireless", device_2g, "wps_enable", "0")
		elseif ssid1_security == "wep-auto" then
			local ssid1_wep_default_key = luci.http.formvalue("ssid1_wep_default_key")
			local ssid1_wep_key_type = luci.http.formvalue("ssid1_wep_key_type")
			local ssid1_wep_key1 = luci.http.formvalue("ssid1_wep_key1")
			local ssid1_wep_key2 = luci.http.formvalue("ssid1_wep_key2")
			local ssid1_wep_key3 = luci.http.formvalue("ssid1_wep_key3")
			local ssid1_wep_key4 = luci.http.formvalue("ssid1_wep_key4")
			
			if not (datatypes.range(ssid1_wep_default_key,1, 4)) then
				wrong_value = true
			else
				uci:set("wireless", ap_ifce_2g[1], "key", ssid1_wep_default_key)
			end
			
			if not (ssid1_wep_key1 == "") then
				if not (datatypes.wepkey(ssid1_wep_key1)) then
					wrong_value = true
				else
					uci:set("wireless", ap_ifce_2g[1], "key1", ssid1_wep_key1)
				end
			else
				uci:delete("wireless", ap_ifce_2g[1], "key1")
			end
			if not (ssid1_wep_key2 == "") then
				if not (datatypes.wepkey(ssid1_wep_key2)) then
					wrong_value = true
				else
					uci:set("wireless", ap_ifce_2g[1], "key2", ssid1_wep_key2)
				end
			else
				uci:delete("wireless", ap_ifce_2g[1], "key2")
			end
			if not (ssid1_wep_key3 == "") then
				if not (datatypes.wepkey(ssid1_wep_key3)) then
					wrong_value = true
				else
					uci:set("wireless", ap_ifce_2g[1], "key3", ssid1_wep_key3)
				end
			else
				uci:delete("wireless", ap_ifce_2g[1], "key3")
			end
			if not (ssid1_wep_key4 == "") then
				if not (datatypes.wepkey(ssid1_wep_key4)) then
					wrong_value = true
				else
					uci:set("wireless", ap_ifce_2g[1], "key4", ssid1_wep_key4)
				end
			else
				uci:delete("wireless", ap_ifce_2g[1], "key4")
			end
			uci:set("wireless", ap_ifce_2g[1], "encryption", ssid1_security)
			--MSTC MBA Sean, disable the wps if user select WEP security
			uci:set("wireless", device_2g, "wsc_confmode", "0")
			uci:set("wireless", device_5g, "wsc_confmode", "0")
			uci:set("wireless", device_5g, "wps_enable", "0")
			uci:set("wireless", device_2g, "wps_enable", "0")
		elseif ssid1_security == "psk2+ccmp" then			
			--- MBA Jay, Here ssid1_security from http will always be "psk2+ccmp", so I turn to get "ssid1_wpa_type"
			local ssid1_wpa_type = luci.http.formvalue("ssid1_wpa_type")
			local ssid1_wpa_key_type = luci.http.formvalue("ssid1_wpa_key_type")
			local ssid1_wpa_psk_key = luci.http.formvalue("ssid1_wpa_psk_key")
			local ssid1_wpa_key_interval = luci.http.formvalue("ssid1_wpa_key_interval")
			
			uci:set("wireless", ap_ifce_2g[1], "key", ssid1_wpa_psk_key)
			uci:set("wireless", ap_ifce_2g[1], "rekeymethod", "TIME")
			uci:set("wireless", ap_ifce_2g[1], "rekeyinteval", ssid1_wpa_key_interval)
			-- MBA Jay, use ssid1_wpa_type to set encryption. Either psk-mixed+tkip+ccmp or psk2+ccmp
			uci:set("wireless", ap_ifce_2g[1], "encryption", ssid1_wpa_type)	
		else
			wrong_value = true
		end
		  
		-- ssid3 part
		
		-- Add range ?
		uci:set("wireless", ap_ifce_2g[2], "ssid", ssid3_ssid)				
		
		if not datatypes.range(ssid3_broadcast_hidden,0, 1) then
			wrong_value = true
		else
			uci:set("wireless", ap_ifce_2g[2], "hidden", ssid3_broadcast_hidden)
		end
		
		-- WMM always enable
		uci:set("wireless", ap_ifce_2g[2], "wmm", "1")		
		
		--MBA Sean, Only get the value from each Security mode 
		if ssid3_security == "none" then 
			wrong_value = false --do nothing
			uci:set("wireless", ap_ifce_2g[2], "encryption", ssid3_security)
		elseif ssid3_security == "wep-auto" then
			local ssid3_wep_default_key = luci.http.formvalue("ssid3_wep_default_key")
			local ssid3_wep_key_type = luci.http.formvalue("ssid3_wep_key_type")
			local ssid3_wep_key1 = luci.http.formvalue("ssid3_wep_key1")
			local ssid3_wep_key2 = luci.http.formvalue("ssid3_wep_key2")
			local ssid3_wep_key3 = luci.http.formvalue("ssid3_wep_key3")
			local ssid3_wep_key4 = luci.http.formvalue("ssid3_wep_key4")
			
			if not (datatypes.range(ssid3_wep_default_key,1, 4)) then
				wrong_value = true
			else
				uci:set("wireless", ap_ifce_2g[2], "key", ssid3_wep_default_key)
			end
			
			if not (ssid3_wep_key1 == "") then
				if not (datatypes.wepkey(ssid3_wep_key1)) then
					wrong_value = true
				else
					uci:set("wireless", ap_ifce_2g[2], "key1", ssid3_wep_key1)
				end
			else
				uci:delete("wireless", ap_ifce_2g[2], "key1")
			end
			if not (ssid3_wep_key2 == "") then
				if not (datatypes.wepkey(ssid3_wep_key2)) then
					wrong_value = true
				else
					uci:set("wireless", ap_ifce_2g[2], "key2", ssid3_wep_key2)
				end
			else
				uci:delete("wireless", ap_ifce_2g[2], "key2")
			end
			if not (ssid3_wep_key3 == "") then
				if not (datatypes.wepkey(ssid3_wep_key3)) then
					wrong_value = true
				else
					uci:set("wireless", ap_ifce_2g[2], "key3", ssid3_wep_key3)
				end
			else
				uci:delete("wireless", ap_ifce_2g[2], "key3")
			end
			if not (ssid3_wep_key4 == "") then
				if not (datatypes.wepkey(ssid3_wep_key4)) then
					wrong_value = true
				else
					uci:set("wireless", ap_ifce_2g[2], "key4", ssid3_wep_key4)
				end
			else
				uci:delete("wireless", ap_ifce_2g[2], "key4")
			end
			uci:set("wireless", ap_ifce_2g[2], "encryption", ssid3_security)
		elseif ssid3_security == "psk2+ccmp" then			
			--- MBA Jay, Here ssid3_security from http will always be "psk2+ccmp", so I turn to get "ssid3_wpa_type"
			local ssid3_wpa_type = luci.http.formvalue("ssid3_wpa_type")
			local ssid3_wpa_key_type = luci.http.formvalue("ssid3_wpa_key_type")
			local ssid3_wpa_psk_key = luci.http.formvalue("ssid3_wpa_psk_key")
			local ssid3_wpa_key_interval = luci.http.formvalue("ssid3_wpa_key_interval")
						
			uci:set("wireless", ap_ifce_2g[2], "key", ssid3_wpa_psk_key)
			uci:set("wireless", ap_ifce_2g[2], "rekeymethod", "TIME")
			uci:set("wireless", ap_ifce_2g[2], "rekeyinteval", ssid3_wpa_key_interval)
			-- MBA Jay, use ssid3_wpa_type to set encryption. Either psk-mixed+tkip+ccmp or psk2+ccmp
			uci:set("wireless", ap_ifce_2g[2], "encryption", ssid3_wpa_type)	
		else
			wrong_value = true
		end		
		
		-- copy ssid
		if ap_ifce_2g[3] then
			if copy_ssid_2g_enable == "1" then 
				-- changeNonRepeaterRadio() will set interface disable to 1 again if radio is off
				uci:set("wireless", ap_ifce_2g[3], "disabled", "0")
				uci:set("wireless", device_2g, "copy_ssid_disabled", "0");
			elseif copy_ssid_2g_enable == "0" then 
				uci:set("wireless", ap_ifce_2g[3], "disabled", "1")
				uci:set("wireless", device_2g, "copy_ssid_disabled", "1");
			else 
				uci:set("wireless", ap_ifce_2g[3], "disabled", "1")
				uci:set("wireless", device_2g, "copy_ssid_disabled", "1");
			end 
		end 
		
		-- NOTE: config radio setting at last part to make sure no other setting (e.g., copy ssid) overwrite it; radio setting has first priority
		if not datatypes.range(wireless_2g_enable,0, 1) then
			wrong_value = true
		else
			changeNonRepeaterRadio(wireless_2g_enable);
		end
		if (not datatypes.range(wireless_2g_channel,1, 13)) and (not wireless_2g_channel == "auto") then
			wrong_value = true
		else
			if wireless_2g_channel == "auto" then
				uci:set("wireless", device_2g, "channel", "auto1")
			else
				uci:set("wireless", device_2g, "channel", wireless_2g_channel)
			end
		end
		
		-- Final
		if not wrong_value then
			--MSTC MBA Sean, when user change the wifi settings, change wps to configured
			uci:set("wireless", device_2g, "wsc_confstatus", "2")
			uci:set("wireless", device_5g, "wsc_confstatus", "2")
			
            uci:commit("wireless")
			sys.exec("wifi reload_legacy")
		end
	end
	
	luci.template.render("iodata/2g_settings")
end

function action_repeater_2g_settings()
	local apply = luci.http.formvalue("apply")

	local wrong_value = false

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
	
	--put your code here (uci commit, restart service ... etc)

		local wireless_2g_enable = luci.http.formvalue("2g_enable")
		local wireless_2g_channel = luci.http.formvalue("2g_channel")

		-- ssid1 part
		local ssid1_ssid = luci.http.formvalue("ssid1_ssid")
		local ssid1_broadcast_hidden = luci.http.formvalue("ssid1_broadcast_hidden")
		-- WMM always enable. local ssid1_wmm = luci.http.formvalue("ssid1_wmm")
		local ssid1_security = luci.http.formvalue("ssid1_security")

		--MSTC MBA Sean, need to get the iface id from openwrt, dirty work...
		scanWifiDev();

		-- ssid1 part
		local repeater_ssid = uci:get("wireless", client_ifce_2g[1], "ssid" )
		local repeater_2g_changeable = luci.http.formvalue("repeater_ssid1_change")
		uci:set("wireless", "repeater", "changeable_2g", repeater_2g_changeable)

		if repeater_2g_changeable == "1" then
			-- Add range ?
			uci:set("wireless", ap_ifce_2g[1], "ssid", ssid1_ssid)

			if not datatypes.range(ssid1_broadcast_hidden,0, 1) then
				wrong_value = true
			else
				uci:set("wireless", ap_ifce_2g[1], "hidden", ssid1_broadcast_hidden)
				if ssid1_broadcast_hidden == "1" then
					--MSTC MBA Sean, disable the wps if user disable ssid broadcast
					uci:set("wireless", device_2g, "wsc_confmode", "0")
					uci:set("wireless", device_5g, "wsc_confmode", "0")
				end
			end

			-- WMM always enable
			uci:set("wireless", ap_ifce_2g[1], "wmm", "1")

			--MBA Sean, Only get the value from each Security mode
			if ssid1_security == "none" then
				wrong_value = false --do nothing
				uci:set("wireless", ap_ifce_2g[1], "encryption", ssid1_security)
				--MSTC MBA Sean, disable the wps if user select NO security
				uci:set("wireless", device_2g, "wsc_confmode", "0")
				uci:set("wireless", device_5g, "wsc_confmode", "0")
			elseif ssid1_security == "wep-auto" then
				local ssid1_wep_default_key = luci.http.formvalue("ssid1_wep_default_key")
				local ssid1_wep_key_type = luci.http.formvalue("ssid1_wep_key_type")
				local ssid1_wep_key1 = luci.http.formvalue("ssid1_wep_key1")
				local ssid1_wep_key2 = luci.http.formvalue("ssid1_wep_key2")
				local ssid1_wep_key3 = luci.http.formvalue("ssid1_wep_key3")
				local ssid1_wep_key4 = luci.http.formvalue("ssid1_wep_key4")

				if not (datatypes.range(ssid1_wep_default_key,1, 4)) then
					wrong_value = true
				else
					uci:set("wireless", ap_ifce_2g[1], "key", ssid1_wep_default_key)
				end

				if not (ssid1_wep_key1 == "") then
					if not (datatypes.wepkey(ssid1_wep_key1)) then
						wrong_value = true
					else
						uci:set("wireless", ap_ifce_2g[1], "key1", ssid1_wep_key1)
					end
				else
					uci:delete("wireless", ap_ifce_2g[1], "key1")
				end
				if not (ssid1_wep_key2 == "") then
					if not (datatypes.wepkey(ssid1_wep_key2)) then
						wrong_value = true
					else
						uci:set("wireless", ap_ifce_2g[1], "key2", ssid1_wep_key2)
					end
				else
					uci:delete("wireless", ap_ifce_2g[1], "key2")
				end
				if not (ssid1_wep_key3 == "") then
					if not (datatypes.wepkey(ssid1_wep_key3)) then
						wrong_value = true
					else
						uci:set("wireless", ap_ifce_2g[1], "key3", ssid1_wep_key3)
					end
				else
					uci:delete("wireless", ap_ifce_2g[1], "key3")
				end
				if not (ssid1_wep_key4 == "") then
					if not (datatypes.wepkey(ssid1_wep_key4)) then
						wrong_value = true
					else
						uci:set("wireless", ap_ifce_2g[1], "key4", ssid1_wep_key4)
					end
				else
					uci:delete("wireless", ap_ifce_2g[1], "key4")
				end
				uci:set("wireless", ap_ifce_2g[1], "encryption", ssid1_security)
				--MSTC MBA Sean, disable the wps if user select WEP security
				uci:set("wireless", device_2g, "wsc_confmode", "0")
				uci:set("wireless", device_5g, "wsc_confmode", "0")
			elseif ssid1_security == "psk2+ccmp" then
				--- MBA Jay, Here ssid1_security from http will always be "psk2+ccmp", so I turn to get "ssid1_wpa_type"
				local ssid1_wpa_type = luci.http.formvalue("ssid1_wpa_type")
				local ssid1_wpa_key_type = luci.http.formvalue("ssid1_wpa_key_type")
				local ssid1_wpa_psk_key = luci.http.formvalue("ssid1_wpa_psk_key")
				local ssid1_wpa_key_interval = luci.http.formvalue("ssid1_wpa_key_interval")

				uci:set("wireless", ap_ifce_2g[1], "key", ssid1_wpa_psk_key)
				uci:set("wireless", ap_ifce_2g[1], "rekeyinteval", ssid1_wpa_key_interval)
				-- MBA Jay, use ssid1_wpa_type to set encryption. Either psk-mixed+tkip+ccmp or psk2+ccmp
				uci:set("wireless", ap_ifce_2g[1], "encryption", ssid1_wpa_type)
			else
				wrong_value = true
			end
		elseif not repeater_ssid then
			-- root AP is not configured, so keep original SSID (interface) settings, only set device settings
		else -- repeater_2g_changeable
			-- copy root AP setting to 2G AP setting
			local repeater_security = uci:get("wireless", client_ifce_2g[1], "encryption" )

			uci:set("wireless", ap_ifce_2g[1], "ssid", repeater_ssid)
			uci:set("wireless", ap_ifce_2g[1], "hidden", "0")
			uci:set("wireless", ap_ifce_2g[1], "wmm", "1")
			if repeater_security == "wep-auto" then
				local repeater_key_id = uci:get("wireless", client_ifce_2g[1], "key" )
				local uci_keyname = "key" .. repeater_key_id;
				local repeater_key = uci:get("wireless", client_ifce_2g[1], uci_keyname )
				uci:set("wireless", ap_ifce_2g[1], "encryption", "wep-auto")
				uci:set("wireless", ap_ifce_2g[1], "key", repeater_key_id)
				uci:set("wireless", ap_ifce_2g[1], "key" .. repeater_key_id, repeater_key)
			elseif repeater_security == "psk+tkip" or repeater_security == "psk+ccmp" or repeater_security == "psk2+ccmp"  then
				local repeater_key = uci:get("wireless", client_ifce_2g[1], "key")
				uci:set("wireless", ap_ifce_2g[1], "encryption", "psk-mixed+tkip+ccmp")
				uci:set("wireless", ap_ifce_2g[1], "key", repeater_key)
				uci:set("wireless", ap_ifce_2g[1], "rekeyinteval", "1800")
			elseif repeater_security == "none" then
				uci:set("wireless", ap_ifce_2g[1], "encryption", "none")
			else
				wrong_value = true
			end
		end

		-- device setting
		if not datatypes.range(wireless_2g_enable,0, 1) then
			wrong_value = true
		else
			changeRepeaterRadio(wireless_2g_enable);
		end

		if (not datatypes.range(wireless_2g_channel,1, 13)) and (not wireless_2g_channel == "auto") then
			wrong_value = true
		else
			if wireless_2g_channel == "auto" then
				uci:set("wireless", device_2g, "channel", "auto1")
			else
				uci:set("wireless", device_2g, "channel", wireless_2g_channel)
			end
		end

		local bandwidth_2g = luci.http.formvalue("2g_bandwidth")
		if ( not datatypes.range(bandwidth_2g, 0, 1) ) then
			wrong_value = true
		else
			uci:set("wireless", device_2g, "bw", bandwidth_2g)
		end

		local txpower_2g = luci.http.formvalue("2g_txpower")
		if ( not datatypes.range(txpower_2g, 10, 100) ) then
			wrong_value = true
		else
			uci:set("wireless", device_2g, "txpower", txpower_2g)
		end		
		
		-- Final
		if not wrong_value then
			--MSTC MBA Sean, when user change the wifi settings, change wps to configured
			uci:set("wireless", device_2g, "wsc_confstatus", "2")
			uci:set("wireless", device_5g, "wsc_confstatus", "2")

            uci:commit("wireless")
			sys.exec("wifi reload_legacy")
		end
	end

	luci.template.render("iodata/repeater_2g_settings")
end