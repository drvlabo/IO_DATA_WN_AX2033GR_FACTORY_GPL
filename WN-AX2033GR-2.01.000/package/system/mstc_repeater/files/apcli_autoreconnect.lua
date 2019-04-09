
uci = require("luci.model.uci").cursor()
sys = require("luci.sys")


local client_id;

function scanWirelssIfceList(ifname)
	uci.foreach("wireless", "wifi-iface", 
	function(s)
		if (s.ifname == ifname) then
			client_id = s[".name"];
		end
	end)
end

-- main flow --
local apcli_if = arg[1];
-- find all wireless interfaces name first
scanWirelssIfceList(apcli_if);

local enable = uci:get("wireless", client_id, "apcli_enable", "1");
if enable and enable == "1" then
	print("run /usr/sbin/iwpriv "..apcli_if.." set ApCliAutoConnect=1");
	sys.call("/usr/sbin/iwpriv "..apcli_if.." set ApCliAutoConnect=1");
end

