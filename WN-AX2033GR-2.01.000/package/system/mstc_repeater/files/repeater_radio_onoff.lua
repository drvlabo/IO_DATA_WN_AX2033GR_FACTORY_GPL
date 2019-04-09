uci = require("luci.model.uci").cursor()
sys = require("luci.sys")

local ap_2g={};
local ap_5g={};

function scanWirelssIfceList()
	uci.foreach("wireless", "wifi-iface", 
	function(s)
		if (s.device == "mt7620" or s.device == "mt7602e" or s.device == "mt7603e" or s.device == "mt7628" or s.device == "mt7688" or s.device == "mt7615e2") then
			if s.mode == "ap" then
				ap_2g[#ap_2g+1] = s[".name"]
			end
		end
		if ( s.device == "mt7615e5" or s.device == "mt7610e" or s.device == "mt7612e" ) then
			if s.mode == "ap" then
				ap_5g[#ap_5g+1] = s[".name"]
			end
		end
	end)
end

function ifce_down_up(ifce_id, operation)
	local device = uci: get("wireless", ifce_id, "device");
	local radio = uci:get("wireless", device, "device_on"); -- don't use 'radio'. it only works on client mode, and wps and site survey will use apcli. use 'device_on' to save status
	if not radio then
		radio = "1"
	end
	
	local ifcename = uci:get("wireless", ifce_id, "ifname");
	local cmd;
	if radio == "1" then
		if operation == "on" then
			cmd = "/sbin/ifconfig " .. ifcename .. " up";
		else
			cmd = "/sbin/ifconfig " .. ifcename .. " down";
		end
	else
		cmd = "/sbin/ifconfig " .. ifcename .. " down";
	end
	print(cmd);
	sys.call(cmd);
end

-- main flow --
local onoff = arg[1];

-- find all wireless interfaces name first
scanWirelssIfceList();

--[[
if onoff == "on" then
	uci:set("wireless", ap_2g[1], "disabled", "0");
	uci:set("wireless", ap_5g[1], "disabled", "0");
else
	uci:set("wireless", ap_2g[1], "disabled", "1");
	uci:set("wireless", ap_5g[1], "disabled", "1");
end
uci:commit("wireless");
]]
ifce_down_up(ap_2g[1], onoff);
ifce_down_up(ap_5g[1], onoff);
