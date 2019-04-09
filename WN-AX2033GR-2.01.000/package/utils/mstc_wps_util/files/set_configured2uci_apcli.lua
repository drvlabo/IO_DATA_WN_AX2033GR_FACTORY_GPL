local uci = require("luci.model.uci").cursor()	
local sys = require("luci.sys")
	
local ifce_2g={}
local ifce_5g={}

local device_5g
local device_2g

--MBA Sean Get all SSID 
uci.foreach("wireless", "wifi-iface", 
function(s)
	if s.mode == "ap" then
		if (s.device == "mt7620" or s.device == "mt7602e" or s.device == "mt7603e" or s.device == "mt7628" or s.device == "mt7688" or s.device == "mt7615e2") then 
			ifce_2g[#ifce_2g+1] = s[".name"]
			device_2g = s.device
		end
		if ( s.device == "mt7615e5" or s.device == "mt7610e" or s.device == "mt7612e" ) then 
        	ifce_5g[#ifce_5g+1] = s[".name"]
			device_5g = s.device
    	end
	end
end)

local ssid = arg[1];

local encryption = arg[2];

local key = arg[3];

local frequency = arg[4];

--MBA Sean, the ssid number of copy ssid (start from 1)
local copy_ssid_index = tonumber(arg[5]); 

local keyindex = arg[6]; 

--MSTC MBA Sean, set enctype

if frequency == "2.4g" then 
	uci:set("wireless", ifce_2g[copy_ssid_index], "ssid", ssid)
	uci:set("wireless", ifce_2g[copy_ssid_index], "encryption", encryption)
	if encryption == "wep-auto" then
		uci:set("wireless", ifce_2g[copy_ssid_index], "key", keyindex)
		uci:set("wireless", ifce_2g[copy_ssid_index], "key"..keyindex, key)
	else
		uci:set("wireless", ifce_2g[copy_ssid_index], "key", key)
	end
	
	-- don't use 'radio'. it only works on client mode, and wps and site survey will use apcli. use 'device_on' to save status
	local radio_2g = uci:get("wireless", device_2g, "device_on");
	if not radio_2g then
		radio_2g = "1"
	end
	if radio_2g == "1" then
		uci:set("wireless", ifce_2g[copy_ssid_index], "disabled", "0")
		uci:set("wireless", device_2g, "copy_ssid_disabled", "0")
	else
		uci:set("wireless", device_2g, "copy_ssid_disabled", "1")
	end
	sys.exec("ifconfig apcli0 down")
end
	
if frequency == "5g" then 
	uci:set("wireless", ifce_5g[copy_ssid_index], "ssid", ssid)
	uci:set("wireless", ifce_5g[copy_ssid_index], "encryption", encryption)
	if encryption == "wep-auto" then
		uci:set("wireless", ifce_5g[copy_ssid_index], "key", keyindex)
		uci:set("wireless", ifce_5g[copy_ssid_index], "key"..keyindex, key)
	else
		uci:set("wireless", ifce_5g[copy_ssid_index], "key", key)
	end
	
	-- don't use 'radio'. it only works on client mode, and wps and site survey will use apcli. use 'device_on' to save status
	local radio_5g = uci:get("wireless", device_5g, "device_on");
	if not radio_5g then
		radio_5g = "1"
	end
	if radio_5g == "1" then
		uci:set("wireless", ifce_5g[copy_ssid_index], "disabled", "0")
		uci:set("wireless", device_5g, "copy_ssid_disabled", "0")
	else
		uci:set("wireless", ifce_5g[copy_ssid_index], "disabled", "1")
		uci:set("wireless", device_5g, "copy_ssid_disabled", "1")
	end
	sys.exec("ifconfig apclii0 down")
end

uci:commit("wireless")

--MSTC MBA Sean, dump uci back to dat 
if device_2g then
	sys.exec("uci2dat -d "..device_2g.." -f /etc/wireless/"..device_2g.."/"..device_2g..".dat")
end 
if device_5g then
	sys.exec("uci2dat -d "..device_5g.." -f /etc/wireless/"..device_5g.."/"..device_5g..".dat")
end
