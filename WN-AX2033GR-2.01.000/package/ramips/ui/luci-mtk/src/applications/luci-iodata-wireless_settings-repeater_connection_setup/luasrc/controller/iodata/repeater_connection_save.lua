--[[
LuCI - Lua Configuration Interface

Copyright 2011 Manuel Munz <freifunk somakoma de>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

]]--

--[[
page call flow:
repeater_connection_settings -> repeater_sitesurvey -> repeater_sitesurvey_result -> repeater_connection_setup -> repeater_connection_save
or
repeater_connection_settings -> repeater_connection_setup -> repeater_connection_save
]]

module ("luci.controller.iodata.repeater_connection_save", package.seeall)
local uci = require("luci.model.uci").cursor()
local sys = require("luci.sys")
local csrf = require("luci.csrf")

function index()
		entry({"content", "wireless_settings", "repeater_connection_settings", "repeater_connection_save"}, call("action_repeater_connection_save"), _("Connection Settings"), 0).leaf = true
end

function get_client_ifce_name(target_band)
	local ifce={};
    uci.foreach("wireless", "wifi-iface", 
	function(s)
        if (s.device == "mt7620" or s.device == "mt7602e" or s.device == "mt7603e" or s.device == "mt7628" or s.device == "mt7688" or s.device == "mt7615e2") then 
			if target_band == "2g" and s.mode == "client" then
				ifce[#ifce+1] = s[".name"]
        end
end
        if ( s.device == "mt7615e5" or s.device == "mt7610e" or s.device == "mt7612e" ) then 
			if target_band == "5g" and s.mode == "client" then
				ifce[#ifce+1] = s[".name"]
			end
        end
    end)

	if #ifce > 0 then
		return ifce[1]
	else
		return nil
	end
end


function clean_old_setting(ifcename)
	uci:delete("wireless", ifcename, "apcli_enable");
	uci:delete("wireless", ifcename, "key"); 
	uci:delete("wireless", ifcename, "key1");
	uci:delete("wireless", ifcename, "key2");
	uci:delete("wireless", ifcename, "key3");
	uci:delete("wireless", ifcename, "key4");
	uci:delete("wireless", ifcename, "encryption");
	uci:delete("wireless", ifcename, "apcli_bssid");
	--uci:set("wireless", ifcename, "channel", "auto");
end


function get_ap_ifce_name(target_band)
	local ifce={}

	uci.foreach("wireless", "wifi-iface", 
	function(s)
		if (s.device == "mt7620" or s.device == "mt7602e" or s.device == "mt7603e" or s.device == "mt7628" or s.device == "mt7688" or s.device == "mt7615e2") then 
			if target_band == "2g" and s.mode == "ap" then
				ifce[#ifce+1] = s[".name"]
			end
		end
		if ( s.device == "mt7615e5" or s.device == "mt7610e" or s.device == "mt7612e" ) then
			if target_band == "5g" and s.mode == "ap" then
				ifce[#ifce+1] = s[".name"]
			end
		end
	end)
	
	if #ifce > 0 then
		return ifce[1]
	else
		return nil
	end
end

-- ap interface setting
function save_repeater_ap_setting(target_band, ssid, authentication, encrypt, key)
	local ifce_name = get_ap_ifce_name(target_band);
	local opt_name = "changeable_" .. target_band;
	local changeable = uci:get("wireless", "repeater", opt_name); -- changeable_2g or changeable_5g

	if (not changeable or changeable == "0") and ifce_name then
		uci:set("wireless", ifce_name, "ssid", ssid);
		if authentication == "WEPAUTO" then
			uci:set("wireless", ifce_name, "encryption", "wep-auto");
			uci:set("wireless", ifce_name, "key", "1"); -- default key index
			uci:set("wireless", ifce_name, "key1", key);
		elseif authentication == "WPAPSK" or authentication == "WPA2PSK" then
			uci:set("wireless", ifce_name, "encryption", "psk-mixed+tkip+ccmp"); -- mixed mode (WPAPSK/WPA2PSK, TKIP+AES)
			uci:set("wireless", ifce_name, "key", key);
		else -- security none
			uci:set("wireless", ifce_name, "encryption", "none");
		end
	end
end

function map_security_to_uci_config(authentication, encrypt)
	local security;
	if authentication == "WPA2PSK" then
		if encrypt == "AES" then
			security = "psk2+ccmp";
		end
	elseif authentication == "WPAPSK" then
		if encrypt == "TKIP" then
			security = "psk+tkip";
		elseif encrypt == "AES" then
			security = "psk+ccmp";
		end
	elseif authentication == "WEPAUTO" then
		security = "wep-auto";
	else
		security = "none";
	end
	return security;
end

-- client interface setting
function save_connection_setting(target_band)
	local uci_band = uci:get("wireless","repeater","band");
	local ifce_name = get_client_ifce_name(target_band);
	clean_old_setting(ifce_name);

	
	local bssid = luci.http.formvalue("TargetBSSID");
	local ssid = luci.http.formvalue("TargetSSID");
	local channel = luci.http.formvalue("TargetChannel");
	local authentication = luci.http.formvalue("TargetAuth");
	local encrypt = luci.http.formvalue("TargetEnc");	
	local security = map_security_to_uci_config(authentication, encrypt);
	
	if authentication == "WEPAUTO" then
		local wepkeyId = luci.http.formvalue("wepkeyId");
		local wepkey = luci.http.formvalue("wepkey");
		local uci_keyname = "key" .. wepkeyId; -- key1

		uci:set("wireless", ifce_name, "key", wepkeyId); 
		uci:set("wireless", ifce_name, uci_keyname, wepkey);
		save_repeater_ap_setting(target_band, ssid, authentication, encrypt, wepkey);
	elseif authentication == "WPAPSK" or authentication == "WPA2PSK" then
		local psk = luci.http.formvalue("pskValue");
		uci:set("wireless", ifce_name, "key", psk);
		save_repeater_ap_setting(target_band, ssid, authentication, encrypt, psk);
	else -- security none
		save_repeater_ap_setting(target_band, ssid, authentication, encrypt, nil);
	end
	
	uci:set("wireless", ifce_name, "encryption", security);
	uci:set("wireless", ifce_name, "ssid", ssid);
	if bssid and string.len(bssid) == 17  then -- if we don't know bssid, then set apcli_enable after we get bssid
		uci:set("wireless", ifce_name, "apcli_bssid", bssid);
		if (tonumber(channel) <= 14 and target_band == "2g") or (tonumber(channel) > 14 and target_band == "5g") then
			uci:set("wireless", ifce_name, "apcli_enable", "1");
		end
	end
end

function kill_repeater_util()
	local file = io.open("/var/run/repeater_search_bssid.lua.pid", "r");
	if file then
		pid = file:read();
		io.close(file);
		
		if pid then
			local cmd = "kill " .. pid .. " &";
			sys.call(cmd);
		end
	end
end

function action_repeater_connection_save()

	--[[=========CSRF check Start=========--]]
	local csrf_token_web = csrf.get_csrf_token_in_web()
	--if csrf token is wrong or can't get it from web, return 403
	if ( not csrf.verify(csrf_token_web) ) then
		wrong_value = true;
		csrf.http_return_403()
		return
	end
	--[[=========CSRF check End=========--]]

	kill_repeater_util();
	save_connection_setting("2g");
	save_connection_setting("5g");
	uci:commit("wireless");
	
	luci.template.render("iodata/repeater_connection_save");
	
	-- if target SSID cannnot be found, repeater_search_bssid.lua will retry again and again, so run it in background
	sys.call("lua /usr/sbin/repeater_search_bssid.lua &");

end
