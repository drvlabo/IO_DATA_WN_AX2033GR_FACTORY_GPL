local uci = require("luci.model.uci").cursor()	
local sys = require("luci.sys")
	
local ap_2g={}
local ap_5g={}
local client_2g={}
local client_5g={}

local device_5g
local device_2g

--MBA Sean Get all SSID 
uci.foreach("wireless", "wifi-iface", 
function(s)
	if (s.device == "mt7620" or s.device == "mt7602e" or s.device == "mt7603e" or s.device == "mt7628" or s.device == "mt7688" or s.device == "mt7615e2") then 
		if s.mode == "client" then
			client_2g[#client_2g+1] = s[".name"]
		elseif s.mode == "ap" then
			ap_2g[#ap_2g+1] = s[".name"]
		end
		device_2g = s.device
	end
	if ( s.device == "mt7615e5" or s.device == "mt7610e" or s.device == "mt7612e" ) then 
		if s.mode == "client" then
			client_5g[#client_5g+1] = s[".name"]
		elseif s.mode == "ap" then
			ap_5g[#ap_5g+1] = s[".name"]
		end
		device_5g = s.device
    end
end)

local ssid = arg[1];

local encryption = arg[2];

local key = arg[3];

local frequency = arg[4];

local auth_mode = arg[5];

local enc_type = arg[6];

local keyindex = arg[7]; 

local ap_mac_addr = arg[8];

local encryption_repeater = arg[9];


--MSTC MBA Sean, set the 2.4g ssid, encryption, key info no matter it is connect to 2.4g or not
--the gui will read this config if SSID changable is disable, if there is not value, gui may crash
uci:set("wireless", client_2g[1], "ssid", ssid)
uci:set("wireless", client_2g[1], "encryption", encryption_repeater)
uci:set("wireless", client_2g[1], "apcli_bssid", ap_mac_addr)
if encryption == "wep-auto" then
	uci:set("wireless", client_2g[1], "key", keyindex)
	uci:set("wireless", client_2g[1], "key"..keyindex, key)
else
	uci:set("wireless", client_2g[1], "key", key)
end

if frequency == "2.4g" then
	uci:set("wireless", client_2g[1], "apcli_enable", "1")
	local client_2g_ifname = uci:get("wireless", client_2g[1], "ifname");
	sys.exec("iwpriv " .. client_2g_ifname .. " set ApCliBssid=" .. ap_mac_addr)

	--MSTC MBA Sean, disable other part of ssid, to avoid link 2.4g & 5g at same time
	local client_5g_ifname = uci:get("wireless", client_5g[1], "ifname");
	sys.exec("iwpriv " .. client_5g_ifname .. " set WscStop=1")
	sys.exec("iwpriv " .. client_5g_ifname .. " set ApCliEnable=0")
	uci:set("wireless", client_5g[1], "apcli_enable", "0")
end
	
	
--MSTC MBA Sean, set the 5g ssid, encryption, key info no matter it is connect to 5g or not
--the gui will read this config if SSID changable is disable, if there is not value, gui may crash
uci:set("wireless", client_5g[1], "ssid", ssid)
uci:set("wireless", client_5g[1], "encryption", encryption_repeater)
uci:set("wireless", client_5g[1], "apcli_bssid", ap_mac_addr)
if encryption == "wep-auto" then
	uci:set("wireless", client_5g[1], "key", keyindex)
	uci:set("wireless", client_5g[1], "key"..keyindex, key)
else
	uci:set("wireless", client_5g[1], "key", key)
end

if frequency == "5g" then 
	uci:set("wireless", client_5g[1], "apcli_enable", "1")
	local client_5g_ifname = uci:get("wireless", client_5g[1], "ifname");
	sys.exec("iwpriv " .. client_5g_ifname .. " set ApCliBssid=" .. ap_mac_addr)

	--MSTC MBA Sean, disable other part of ssid, to avoid link 2.4g & 5g at same time
	local client_2g_ifname = uci:get("wireless", client_2g[1], "ifname");
	sys.exec("iwpriv " .. client_2g_ifname .. " set WscStop=1")
	sys.exec("iwpriv " .. client_2g_ifname .. " set ApCliEnable=0")
	uci:set("wireless", client_2g[1], "apcli_enable", "0")
end

uci:commit("wireless")

--MSTC MBA Sean, dump uci back to dat 
if device_2g then
	changeable_2g = uci:get("wireless", "repeater", "changeable_2g")
	if changeable_2g == "0" then
		uci:set("wireless", ap_2g[1], "ssid", ssid)
		uci:set("wireless", ap_2g[1], "encryption", encryption)
		if encryption == "wep-auto" then
			uci:set("wireless", ap_2g[1], "key", keyindex)
			uci:set("wireless", ap_2g[1], "key"..keyindex, key)
		else
			uci:set("wireless", ap_2g[1], "key", key)
		end
		
		--MBA Sean, restart the interface to make config apply
		local ap_2g_ifname = uci:get("wireless", ap_2g[1], "ifname");
		sys.exec("ifconfig " .. ap_2g_ifname .. " up")
		sys.exec("iwpriv " .. ap_2g_ifname .. " set AuthMode=".. auth_mode)
		sys.exec("iwpriv " .. ap_2g_ifname .. " set EncrypType=".. enc_type)
		sys.exec("iwpriv " .. ap_2g_ifname .. " set SSID=".. ssid)
		--MBA Sean, for some reason 2.4g need to set key after set ssid, i don't know why
		if encryption == "wep-auto" then
			sys.exec("iwpriv " .. ap_2g_ifname .. " set DefaultKeyID=".. keyindex)
			sys.exec("iwpriv " .. ap_2g_ifname .. " set Key" .. keyindex .. "=" .. key)
		else
			sys.exec("iwpriv " .. ap_2g_ifname .. " set WPAPSK="..key)
		end
	end
	uci:commit("wireless")
	
	sys.exec("uci2dat -d "..device_2g.." -f /etc/wireless/"..device_2g.."/"..device_2g..".dat")
end 

if device_5g then
	changeable_5g = uci:get("wireless", "repeater", "changeable_5g")
	if changeable_5g == "0" then
		uci:set("wireless", ap_5g[1], "ssid", ssid)
		uci:set("wireless", ap_5g[1], "encryption", encryption)
		if encryption == "wep-auto" then
			uci:set("wireless", ap_5g[1], "key", keyindex)
			uci:set("wireless", ap_5g[1], "key"..keyindex, key)
		else
			uci:set("wireless", ap_5g[1], "key", key)
		end
		
		--MBA Sean, restart the interface to make config apply
		local ap_5g_ifname = uci:get("wireless", ap_5g[1], "ifname");
		sys.exec("ifconfig " .. ap_5g_ifname .. " up")
		sys.exec("iwpriv " .. ap_5g_ifname .. " set AuthMode="..auth_mode)
		sys.exec("iwpriv " .. ap_5g_ifname .. " set EncrypType="..enc_type)
		--MBA Sean, for some reason 5g need to set key before set ssid, i don't know why
		if encryption == "wep-auto" then
			sys.exec("iwpriv " .. ap_5g_ifname .. " set DefaultKeyID="..keyindex)
			sys.exec("iwpriv " .. ap_5g_ifname .. " set Key"..keyindex.."="..key)
		else
			sys.exec("iwpriv " .. ap_5g_ifname .. " set WPAPSK="..key)
		end
		sys.exec("iwpriv " .. ap_5g_ifname .. " set SSID="..ssid)	
	end

	uci:commit("wireless")
	
	sys.exec("uci2dat -d "..device_5g.." -f /etc/wireless/"..device_5g.."/"..device_5g..".dat")
end

sys.call("/usr/bin/lua /usr/sbin/repeater_autoreconnect.lua &");
