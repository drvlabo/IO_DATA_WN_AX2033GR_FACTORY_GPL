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

local encryption = arg[1];

local key = arg[2];

local wsc_confstatus = arg[3];

local ssid = arg[4];

--MSTC MBA Sean, set enctype
uci:set("wireless", ifce_2g[1], "encryption", encryption)
uci:set("wireless", ifce_5g[1], "encryption", encryption)

uci:set("wireless", ifce_2g[1], "key", key)
uci:set("wireless", ifce_5g[1], "key", key)

if ssid then
	uci:set("wireless", ifce_2g[1], "ssid", ssid)
	uci:set("wireless", ifce_5g[1], "ssid", ssid)
end 

if device_2g then
	uci:set("wireless", device_2g, "wsc_confstatus", wsc_confstatus)
end 
if device_5g then
	uci:set("wireless", device_5g, "wsc_confstatus", wsc_confstatus)
end

uci:commit("wireless")

--MSTC MBA Sean, dump uci back to dat 
if device_2g then
	sys.exec("uci2dat -d "..device_2g.." -f /etc/wireless/"..device_2g.."/"..device_2g..".dat")
end 
if device_5g then
	sys.exec("uci2dat -d "..device_5g.." -f /etc/wireless/"..device_5g.."/"..device_5g..".dat")
end
