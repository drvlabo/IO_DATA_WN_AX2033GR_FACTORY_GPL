uci = require("luci.model.uci").cursor()
sys = require("luci.sys")

BAND_AUTO = 0;
BAND_2G = 1;
BAND_5G = 2;
APCLIENT_2G = "apcli0";
APCLIENT_5G = "apclii0";

local client_2g={};
local client_5g={};
local passiveChannelList={};

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


function getRootAPSSID(preferBand)
	local ssid;
	
	if tonumber(preferBand) == BAND_5G then
		ssid = uci:get("wireless", client_5g[1], "ssid");
	else -- 2g or auto (in 'auto' case, we will save ssid to both bands)
		ssid = uci:get("wireless", client_2g[1], "ssid");
	end
	return ssid;
end


function getRootAPBssid(preferBand)
	local bssid;
	
	if tonumber(preferBand) == BAND_2G then
		bssid = uci:get("wireless", client_2g[1], "apcli_bssid");
	elseif tonumber(preferBand) == BAND_5G then
		bssid = uci:get("wireless", client_5g[1], "apcli_bssid");
	elseif tonumber(preferBand) == BAND_AUTO then
		bssid = uci:get("wireless", client_2g[1], "apcli_bssid");
		if not bssid then
			bssid = uci:get("wireless", client_5g[1], "apcli_bssid");
		end
	end
	
	return bssid;
end

function getRootAPSecurity(preferBand)
	local security;
	
	if tonumber(preferBand) == BAND_5G then
		security = uci:get("wireless", client_5g[1], "encryption");
	else -- 2g or auto (in 'auto' case, we will save security to both bands)
		security = uci:get("wireless", client_2g[1], "encryption");
	end
	return security;
end


function doActiveSiteSurvey(preferBand, ssid)
	if tonumber(preferBand) == BAND_2G or tonumber(preferBand) == BAND_AUTO then
		local cmd = "/usr/sbin/iwpriv ra0 set SiteSurvey=" .. ssid;
		sys.call(cmd);
	end
	
	if tonumber(preferBand) == BAND_5G or tonumber(preferBand) == BAND_AUTO then
		local cmd = "/usr/sbin/iwpriv " ..APCLIENT_5G.. " set SiteSurvey=" .. ssid;
		sys.call(cmd);
	end
end

function doPassiveSiteSurvey(preferBand)
	if tonumber(preferBand) == BAND_2G or tonumber(preferBand) == BAND_AUTO then
		local cmd = "/usr/sbin/iwpriv ra0 set SiteSurvey=";
		sys.call(cmd);
	end

	if tonumber(preferBand) == BAND_5G or tonumber(preferBand) == BAND_AUTO then
		local cmd = "/usr/sbin/iwpriv " ..APCLIENT_5G.. " set SiteSurvey=";
		sys.call(cmd);
	end
end

function checkSecurityMatch(targetSecurity, security)
	-- transform security to auth + enc
	local securities = luci.util.split(security, "/", 1, false);
	local auth;
	local enc;
	if table.getn(securities) == 2 then
		auth = securities[1];
		enc = securities[2];
	else
		enc = securities[1];
		if enc == "NONE" then
			auth = "OPEN";
		end
	end
	if enc == "WEP" then
		auth = "WEP"
	end

	local securityMatch = false;
	if targetSecurity == "psk2+ccmp" and (auth == "WPA2PSK" or auth == "WPA1PSKWPA2PSK" or auth == "WPAPSKWPA2PSK") and (enc == "AES" or enc == "TKIPAES") then
		securityMatch = true;
	elseif targetSecurity == "psk+ccmp" and (auth == "WPA1PSK" or auth == "WPAPSK" or auth == "WPA1PSKWPA2PSK" or auth == "WPAPSKWPA2PSK") and (enc == "AES" or enc == "TKIPAES") then
		securityMatch = true;
	elseif targetSecurity == "psk+tkip" and (auth == "WPA1PSK" or auth == "WPAPSK" or auth == "WPA1PSKWPA2PSK" or auth == "WPAPSKWPA2PSK") and (enc == "TKIP" or enc == "TKIPAES") then
		securityMatch = true;
	elseif targetSecurity == "wep-auto" and (auth == "WEPAUTO" or auth == "WEP") then
		securityMatch = true;
	elseif targetSecurity == "none" and auth == "OPEN" then
		securityMatch = true;
	end
	
	return securityMatch;
end

-- remove trailing whitespace
function TrimStrTrailSpace(s)
  local n = #s
  while n > 0 and s:find("^%s", n) do n = n - 1 end
  return s:sub(1, n)
end

IDX_BAND = 1;
IDX_SSID = 2;
IDX_RSSI = 3;
IDX_BSSID = 4;

local SiteList;

function getSiteListWithSpecificSSID(preferBand, targetSsid, targetSecurity)
	local file
	local cnt = 0;
	SiteList = {}; -- clean table first

	-- output of get_site_survey cmd: 
	-- Ch  Len SSID                             BSSID              Security               Siganl(%)W-Mode   ExtCH  NT WPS DPID
	-- 1   11  Unizyx_WLAN                      50:67:f0:37:a0:25  WPA1WPA2/TKIPAES       81       11b/g/n  NONE   In  NO
	if tonumber(preferBand) == BAND_2G or tonumber(preferBand) == BAND_AUTO then
		local wband = BAND_2G;
		file = io.popen("/usr/sbin/iwpriv ra0 get_site_survey", 'r');
		if file then
			while true do
				line = file:read();
				if line == nil then break end
				
				local ssid_len = tonumber(TrimStrTrailSpace(string.sub(line, 5, 8)));
				if ssid_len	and ssid_len > 0 then
					local ssid = string.sub(line, 9, 9+ssid_len-1);
					if targetSsid == ssid then -- ssid must match
						local bssid = TrimStrTrailSpace(string.sub(line, 42, 58));
						local security = TrimStrTrailSpace(string.sub(line, 61, 83));
						local signal = TrimStrTrailSpace(string.sub(line, 84, 92));
						-- if security match, add to list
						if checkSecurityMatch(targetSecurity, security) then
							cnt = cnt + 1;
							SiteList[cnt] = { wband, ssid, tonumber(signal), bssid };
						end
					end
				end -- if ssid_len
			end -- while
			io.close(file)
		end
	end

	if tonumber(preferBand) == BAND_5G or tonumber(preferBand) == BAND_AUTO then
		local wband = BAND_5G;
		file = io.popen("/usr/sbin/iwpriv " ..APCLIENT_5G.. " get_site_survey", 'r');
		if file then
			while true do
				line = file:read();
				if line == nil then break end
				
				local ssid_len = tonumber(TrimStrTrailSpace(string.sub(line, 5, 8)));
				if ssid_len	and ssid_len > 0 then
					local ssid = string.sub(line, 9, 9+ssid_len-1);
					if targetSsid == ssid then -- ssid must match
						local bssid = TrimStrTrailSpace(string.sub(line, 42, 58));
						local security = TrimStrTrailSpace(string.sub(line, 61, 83));
						local signal = TrimStrTrailSpace(string.sub(line, 84, 92));
						-- if security match, add to list
						if checkSecurityMatch(targetSecurity, security) then
							cnt = cnt + 1;
							SiteList[cnt] = { wband, ssid, tonumber(signal), bssid };
						end
					end
				end -- if ssid_len
			end -- while
			io.close(file)
		end
	end	
	
	return cnt;
end

function getSiteListAndSetPassiveScanChannel(preferBand)
	local file
	local cnt = 0;
	local i;
	local cmd = "";
	SiteList = {}; -- clean table first
	passiveChannelList = {"52","56","60","64","100","104","108","112","116","120","124","128","132","136","140"}; -- channel W52 and W56

	-- output of get_site_survey cmd:
	-- Ch  Len SSID                             BSSID              Security               Siganl(%)W-Mode   ExtCH  NT WPS DPID
	-- 1   11  Unizyx_WLAN                      50:67:f0:37:a0:25  WPA1WPA2/TKIPAES       81       11b/g/n  NONE   In  NO

	if tonumber(preferBand) == BAND_5G or tonumber(preferBand) == BAND_AUTO then
		local wband = BAND_5G;
		file = io.popen("/usr/sbin/iwpriv " ..APCLIENT_5G.. " get_site_survey", 'r');
		if file then
			while true do
				line = file:read();
				if line == nil then break end

				local ch = TrimStrTrailSpace(string.sub(line, 1, 4));
				--find other AP in this channel, remove it from passive channel list
				for i = 1, #passiveChannelList do
					if ch == passiveChannelList[i] then
						passiveChannelList[i] = "";
					end
				end
			end -- while
			io.close(file)
		end
		for i = 1, #passiveChannelList do
			if passiveChannelList[i] ~= "" then
				cmd = cmd .. passiveChannelList[i] .. ";";
			end
		end
		sys.call("iwpriv rai0 set ForcePassiveScan=\"" ..cmd.. "\"");
	end

	return cnt;
end

function saveBestSignalBssid(numAP)
	local i;
	local bestSignal = -1;
	local idx = 0;
	
	for i = 1, numAP do
		if SiteList[i][IDX_RSSI] > bestSignal then
			bestSignal = SiteList[i][IDX_RSSI];
			idx = i;
		end
	end

	if SiteList[idx][IDX_BAND] == BAND_2G then
		uci:set("wireless", client_2g[1], "apcli_bssid", SiteList[idx][IDX_BSSID]);
		uci:set("wireless", client_2g[1], "apcli_enable", "1");
	elseif SiteList[idx][IDX_BAND] == BAND_5G then
		uci:set("wireless", client_5g[1], "apcli_bssid", SiteList[idx][IDX_BSSID]);
		uci:set("wireless", client_5g[1], "apcli_enable", "1");
	end

	uci:commit("wireless");
end

function findBssid(preferBand, ssid, security)
	local cnt = 0;

	sys.call("killall repeater_radio_ctrl");
	sys.call("ifconfig ra0 down");
	sys.call("ifconfig rai0 down");
	while cnt == 0 do
		if tonumber(preferBand) == BAND_5G or tonumber(preferBand) == BAND_AUTO then
			doPassiveSiteSurvey(preferBand);
			sys.call("sleep 8");
			getSiteListAndSetPassiveScanChannel(preferBand);
		end
		doActiveSiteSurvey(preferBand, ssid);
		sys.call("sleep 8");
		cnt = getSiteListWithSpecificSSID(preferBand, ssid, security)
		if cnt > 0 then
			saveBestSignalBssid(cnt);
			-- quit loop due to cnt > 0
		else
			sys.call("sleep 5");
		end
	end
end

function writePidFile()
	local infile = io.open("/proc/self/stat", 'r');
	if infile then
		line = infile:read();
		io.close(infile);
		
		pid = line:match("%w+");
		
		local outfile = io.open("/var/run/repeater_search_bssid.lua.pid", "w");
		if outfile then
			outfile:write(pid);
			io.close(outfile);
		end
	end
end


-- main flow --
writePidFile();

-- find all wireless interfaces name first
scanWirelssIfceList();

local preferBand = uci:get("wireless","repeater","band");
local ssid = getRootAPSSID(preferBand);
if ssid then
	local bssid = getRootAPBssid(preferBand);
	if not bssid then
		local security = getRootAPSecurity(preferBand);
		findBssid(preferBand, ssid, security);
	end

	sys.call("/sbin/wifi");
else
	print("SSID of Root AP is not configured");
end

os.remove("/var/run/repeater_search_bssid.lua.pid");
