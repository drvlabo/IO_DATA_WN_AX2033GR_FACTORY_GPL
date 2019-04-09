--[[
LuCI - Lua Configuration Interface

Copyright 2011 Manuel Munz <freifunk somakoma de>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

]]--

module ("luci.controller.iodata.wireless_advanced_settings", package.seeall)
local uci = require("luci.model.uci").cursor()
local sys = require("luci.sys")
local datatypes  = require("luci.cbi.datatypes")
local csrf = require("luci.csrf")

function index()
	local uci2 = require("luci.model.uci").cursor()
	local current_wan_mode = uci2:get("network","wan",'mode')
	if current_wan_mode ~= "repeater" then
		entry({"content", "wireless_settings", "advanced_settings"}, call("action_advanced_settings"), _("Advanced Settings"), 3).leaf = true
	end
end

function action_advanced_settings()
	
	local apply = luci.http.formvalue("apply")
	
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
	
		--MSTC MBA Sean, need to get all wifi-device
		local device_2g;
		local device_5g;

		--MSTC MBA Sean, get all chip device, each grequence should be only one chip. 
		uci:foreach("wireless", "wifi-iface", function(s)
			if s.device == "mt7620" or s.device == "mt7602e" or s.device == "mt7603e" or s.device == "mt7628" or s.device == "mt7688" or s.device == "mt7615e2" then 
				device_2g = s.device
			end
			if s.device == "mt7610e"  or s.device == "mt7612e" or s.device == "mt7615e5" then 
				device_5g = s.device
			end
		end)
	
		local wrong_value = false
		local firewall_restart = false
					
		local beacon_interval = luci.http.formvalue("beacon_interval")
		if ( not datatypes.range(beacon_interval, 40, 1000) ) then
			wrong_value = true
		else
			uci:set("wireless", device_2g, "beacon", beacon_interval)
			uci:set("wireless", device_5g, "beacon", beacon_interval)
		end
		
		local dtim_period = luci.http.formvalue("dtim_period")
		if ( not datatypes.range(dtim_period, 1, 255) ) then
			wrong_value = true
		else
			uci:set("wireless", device_2g, "dtim", dtim_period)
			uci:set("wireless", device_5g, "dtim", dtim_period)
		end		
	
		local bandwidth_2g = luci.http.formvalue("2g_bandwidth")
		if ( not datatypes.range(bandwidth_2g, 0, 1) ) then
			wrong_value = true
		else
			uci:set("wireless", device_2g, "bw", bandwidth_2g)
		end				
		
		local bandwidth_5g = luci.http.formvalue("5g_bandwidth")
		if ( not datatypes.range(bandwidth_5g, 0, 2) ) then
			wrong_value = true
		else
			uci:set("wireless", device_5g, "bw", bandwidth_5g)
		end				
	
		local txpower_2g = luci.http.formvalue("2g_txpower")
		if ( not datatypes.range(txpower_2g, 10, 100) ) then
			wrong_value = true
		else
			uci:set("wireless", device_2g, "txpower", txpower_2g)
		end				
		
		local txpower_5g = luci.http.formvalue("5g_txpower")
		if ( not datatypes.range(txpower_5g, 10, 100) ) then
			wrong_value = true
		else
			uci:set("wireless", device_5g, "txpower", txpower_5g)
			uci:set("wireless", device_5g, "percentagectrl", "1")
		end			

		local guest_ssid_seperation = luci.http.formvalue("guest_ssid_seperation")
		if ( not datatypes.range(guest_ssid_seperation, 0, 1) ) then
			wrong_value = true
		else
			local old_guest_ssid_seperation = uci:get("wireless", device_2g, "guest_ssid_seperation")
			if ( old_guest_ssid_seperation ~= guest_ssid_seperation ) then
					firewall_restart = true
			end
			uci:set("wireless", device_2g, "guest_ssid_seperation", guest_ssid_seperation)
			uci:set("wireless", device_5g, "guest_ssid_seperation", guest_ssid_seperation)
		end		
		
		local igmpsnoop = luci.http.formvalue("igmpsnoop")
		if ( not datatypes.range(igmpsnoop, 0, 1) ) then
			wrong_value = true
		else
			uci:set("wireless", device_2g, "igmpsnoop", igmpsnoop)
			uci:set("wireless", device_5g, "igmpsnoop", igmpsnoop)
		end		
		
		local auto_disassociation = luci.http.formvalue("auto_disassociation")
		if ( not datatypes.range(auto_disassociation, 0, 1) ) then
			wrong_value = true
		else
			uci:set("wireless", device_2g, "auto_disassociation", auto_disassociation)
			uci:set("wireless", device_5g, "auto_disassociation", auto_disassociation)
		end		
		
		local beamforming = luci.http.formvalue("beamforming")
		if ( not datatypes.range(beamforming, 0, 3) ) then
			wrong_value = true
		else
			uci:set("wireless", device_2g, "txbf", beamforming)
			uci:set("wireless", device_5g, "txbf", beamforming)
		end		
		
		if ( not wrong_value ) then
			uci:commit("wireless")
			sys.exec("wifi reload_legacy")
			if ( firewall_restart ) then
				sys.exec("/etc/init.d/firewall restart")
				-- fw3 restart willl flush miniupnp rule
				sys.exec("/etc/init.d/miniupnpd restart 2>/dev/null")
			end	
		end
	end 
	
	luci.template.render("iodata/advanced_settings")
end
