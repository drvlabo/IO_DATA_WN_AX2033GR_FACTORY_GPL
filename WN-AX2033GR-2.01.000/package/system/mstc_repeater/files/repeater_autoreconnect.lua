
uci = require("luci.model.uci").cursor()
sys = require("luci.sys")

BAND_AUTO = 0;
BAND_2G = 1;
BAND_5G = 2;


local client_2g={};
local client_5g={};

function scanWirelssIfceList()
	uci.foreach("wireless", "wifi-iface", 
	function(s)
		if (s.device == "mt7620" or s.device == "mt7602e" or s.device == "mt7603e" or s.device == "mt7628" or s.device == "mt7688" or s.device == "mt7615e2") then
			if s.mode == "client" then
				client_2g[#client_2g+1] = s[".name"]
			end
		end
		if ( s.device == "mt7615e5" or s.device == "mt7610e" or s.device == "mt7612e" ) then
			if s.mode == "client" then
				client_5g[#client_5g+1] = s[".name"]
			end
		end
	end)
end

-- main flow --

-- find all wireless interfaces name first
scanWirelssIfceList();

local preferBand = uci:get("wireless","repeater","band");
local connectCheckInterval = uci:get("wireless","repeater","connect_check_interval");
if not connectCheckInterval then
	connectCheckInterval = "5";
end
local reconnectTriggerInterval = uci:get("wireless","repeater","reconnect_trigger_interval");
if not reconnectTriggerInterval then
	reconnectTriggerInterval = "20";
end
local configured = 0;

sys.call("killall repeater_radio_ctrl");
if tonumber(preferBand) == BAND_2G or tonumber(preferBand) == BAND_AUTO then
	local enable = uci:get("wireless", client_2g[1], "apcli_enable", "1");
	if enable and enable == "1" then
		local apcli_if = uci:get("wireless", client_2g[1], "ifname", "apcli0");
		sys.call("/usr/sbin/iwpriv "..apcli_if.." set ApCliEnable=1"); -- don't do this after ApCliAutoConnect
		sys.call("/usr/sbin/iwpriv "..apcli_if.." set ApCliAutoConnect=1");
		sys.call("/usr/sbin/repeater_radio_ctrl " .. apcli_if .. " " .. connectCheckInterval .. " " .. reconnectTriggerInterval .. " &");
		configured = 1;
	end
end
if tonumber(preferBand) == BAND_5G or tonumber(preferBand) == BAND_AUTO then
	local enable = uci:get("wireless", client_5g[1], "apcli_enable", "1");
	if enable and enable == "1" then
		local apclii_if = uci:get("wireless", client_5g[1], "ifname", "apclii0");
		sys.call("/usr/sbin/iwpriv "..apclii_if.." set ApCliEnable=1"); -- don't do this after ApCliAutoConnect
		sys.call("/usr/sbin/iwpriv "..apclii_if.." set ApCliAutoConnect=1");
		sys.call("/usr/sbin/repeater_radio_ctrl " .. apclii_if .. " " .. connectCheckInterval .. " " .. reconnectTriggerInterval .. " &");
		configured = 1;
	end
end

if configured == 0 then
	-- even root AP info is not configured, we still run repeater_radio_ctrl to turn off radio
	local apcli_if = uci:get("wireless", client_2g[1], "ifname", "apcli0");
	sys.call("/usr/sbin/repeater_radio_ctrl " .. apcli_if .. " " .. connectCheckInterval .. " " .. reconnectTriggerInterval .. " &");
end
