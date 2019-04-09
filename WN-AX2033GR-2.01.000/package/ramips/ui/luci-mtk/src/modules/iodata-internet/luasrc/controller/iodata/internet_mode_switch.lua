
--[[
]]--
module("luci.controller.iodata.internet_mode_switch", package.seeall)
local uci = require("luci.model.uci").cursor()
local sys = require("luci.sys")
local datatypes  = require("luci.cbi.datatypes")

function index()
		
end

local ap_2g={};
local ap_5g={};
local client_2g={};
local client_5g={};
local device_2g;
local device_5g;
function scanWifiDev()
	uci.foreach("wireless", "wifi-iface", 
	function(s)
		if (s.device == "mt7620" or s.device == "mt7602e" or s.device == "mt7603e" or s.device == "mt7628" or s.device == "mt7688" or s.device == "mt7615e2") then
			if s.mode == "ap" then
				ap_2g[#ap_2g+1] = s[".name"]
			elseif s.mode == "client" then
				client_2g[#client_2g+1] = s[".name"]
			end
			device_2g = s.device;
		end
		if ( s.device == "mt7615e5" or s.device == "mt7610e" or s.device == "mt7612e" ) then
			if s.mode == "ap" then
				ap_5g[#ap_5g+1] = s[".name"]
			elseif s.mode == "client" then
				client_5g[#client_5g+1] = s[".name"]
			end
			device_5g = s.device;
		end
	end)
end

function config_repeater_wireless_ifce()
	scanWifiDev();

	-- disable guest ssid and copy ssid interface, but keep 'copy_ssid_disabled' value, so we can restore it when changing to other mode
	uci:set("wireless", ap_2g[2], "disabled", "1"); -- guest
	uci:set("wireless", ap_2g[3], "disabled", "1"); -- copy
	uci:set("wireless", ap_5g[2], "disabled", "1"); -- copy
	
	-- enable repeater interface
	local radio_2g = uci:get("wireless", device_2g, "device_on"); -- don't use 'radio'. it only works on client mode, and wps and site survey will use apcli. use 'device_on' to save status
	if not radio_2g then
		radio_2g = "1"
	end
	if radio_2g == "1" then
		uci:set("wireless", client_2g[1], "disabled", "0");
	end
	
	local radio_5g = uci:get("wireless", device_5g, "device_on"); -- don't use 'radio'. it only works on client mode, and wps and site survey will use apcli. use 'device_on' to save status
	if not radio_5g then
		radio_5g = "1"
	end
	if radio_5g == "1" then
		uci:set("wireless", client_5g[1], "disabled", "0");
	end
	
	--MSTC MBA, Sean, disable wps in repeater mode
	if device_2g then
		uci:set("wireless", device_2g, "wsc_confmode", "0");
	end
	if device_5g then
		uci:set("wireless", device_5g, "wsc_confmode", "0");
	end
end

-- before changing wan mode from repeater to others, restore original copy ssid and guest ssid status
function config_non_repeater_wireless_ifce()
	scanWifiDev();
	-- if device_on is on, restore copy ssid and guest ssid status
	local radio_2g = uci:get("wireless", device_2g, "device_on");  -- don't use 'radio'. it's only works on client mode, and wps and site survey will use apcli
	if not radio_2g then
		radio_2g = "1"
	end
	if radio_2g == "1" then
		uci:set("wireless", ap_2g[2], "disabled", "0"); -- guest
		local copy_ssid_2g_disabled = uci:get("wireless", device_2g, "copy_ssid_disabled"); -- 2.4g copy ssid
		if copy_ssid_2g_disabled then
			uci:set("wireless", ap_2g[3], "disabled", copy_ssid_2g_disabled); -- copy
		end
	end

	local radio_5g = uci:get("wireless", device_5g, "device_on");  -- don't use 'radio'. it's only works on client mode, and wps and site survey will use apcli
	if not radio_5g then
		radio_5g = "1"
	end
	if radio_5g == "1" then
		local copy_ssid_5g_disabled = uci:get("wireless", device_5g, "copy_ssid_disabled"); -- 5g copy ssid
		if copy_ssid_5g_disabled then
			uci:set("wireless", ap_5g[2], "disabled", copy_ssid_5g_disabled); -- copy
		end
	end

	-- disable repeater interface
	uci:set("wireless", client_2g[1], "disabled", "1");
	uci:set("wireless", client_5g[1], "disabled", "1");
	
	--MSTC MBA Sean, enable wps if wps is enable in none-repeater mode
	if uci:get("wireless", device_2g, "wps_enable") == "1" then 
		if device_2g then
			uci:set("wireless", device_2g, "wsc_confmode", "7");
		end
		if device_5g then
			uci:set("wireless", device_5g, "wsc_confmode", "7");
		end	
	end
end

--MSTC, Smith, change lan config to target mode
function change_lan_setting(target_mode)
	local mode = uci:get("network", "lan_"..target_mode, "mode")

	if mode == target_mode then
		uci:delete("network","lan")
		local tmp_name = uci:add("network", "interface")
		uci:rename("network", tmp_name, "lan")

		--get target mode setting first
		local lan_ifname = uci:get("network", "lan_"..target_mode, "ifname")
		local lan_force_link = uci:get("network", "lan_"..target_mode, "force_link")
		local lan_type = uci:get("network", "lan_"..target_mode, "type")
		local lan_proto = uci:get("network", "lan_"..target_mode, "proto")
		local lan_ipaddr = uci:get("network", "lan_"..target_mode, "ipaddr")
		local lan_netmask = uci:get("network", "lan_"..target_mode, "netmask")
		local lan_autoip = uci:get("network", "lan_"..target_mode, "autoip")

		--set to lan
		uci:set("network", "lan", 'ifname', lan_ifname)
		uci:set("network", "lan", 'force_link', lan_force_link)
		uci:set("network", "lan", 'type', lan_type)
		uci:set("network", "lan", 'proto', lan_proto)
		uci:set("network", "lan", 'ipaddr', lan_ipaddr)
		uci:set("network", "lan", 'netmask', lan_netmask)
		uci:set("network", "lan", 'autoip', lan_autoip)

		--MSTC, Terence, Append hostname for dhcp protocol
		if lan_proto == "dhcp" then
			local file = io.open("/etc/openwrt_release", "r")
			local product_name = ""
			if file then
				for line in file:lines() do
					local name, value = line:match("(.+)=%p(.+)%p")
					if name == "DISTRIB_PRODUCT" then
						product_name = value
						break
					end
				end
				io.close(file)
			end
			uci:set("network", "lan", "hostname", product_name)
		end
	end
end

--__MSTC__, Vincent: Concatenate all command arguments to local string buffer
	local options=""
	for i, v in ipairs(arg) do
	  --print (i, arg[i])
	  options = options .. tostring(v) .." "
	end
	
	local wan_mode = string.match(options, '--wan_mode=(%S+)')
	--We still need to check the value in teh lua program, because user may disable javascript
	local wrong_value = false
	
	--MBA Sean, get current mode to check cpe need reboot or not.
	local current_mode = uci:get("network","wan",'mode')
	local set_mode = "router"
	
		--MBA Sean, router mode
		if wan_mode == "static" then 
  			local ipaddr = string.match(options, '--ipaddr=(%S+)')
  			local netmask = string.match(options, '--netmask=(%S+)')
  			local gateway = string.match(options, '--gateway=(%S+)')
  			local dns1 = string.match(options, '--dns1=(%S+)')
  			local dns2 = string.match(options, '--dns2=(%S+)')
			local dns = ""
  			local ipv6pass = string.match(options, '--ipv6pass=(%S+)')
			
			if not datatypes.ipaddr(ipaddr) then
				wrong_value = true
			end
			
			if not datatypes.ipaddr(gateway) then
				wrong_value = true
			end
			
			if dns2 == nil or string.len(dns2) == 0 then
				if not datatypes.ipaddr(dns1) then
					wrong_value = true
				else
				--MBA Sean, need to concat the dns1 & dns2 (openwrt format)
					dns = dns1
				end
			else
				if not datatypes.ipaddr(dns1) or not datatypes.ipaddr(dns2) then
					wrong_value = true
				else
				--MBA Sean, need to concat the dns1 & dns2 (openwrt format)
					dns = dns1 .. " " .. dns2
				end
			end

			--MBA Sean, set the value only if the value is right.
			if not wrong_value then
					--MSTC, Terence, re-build wan config area
					uci:delete("network","wan")
					local tmp_name = uci:add("network", "interface")
					uci:rename("network", tmp_name, "wan")

					uci:set("network","wan",'mode',"router")
					uci:set("network","wan",'ifname',"eth1")
					uci:set("network","wan",'proto',"static")
					uci:set("network","wan",'ipaddr', ipaddr)
					uci:set("network","wan",'netmask', netmask)
					uci:set("network","wan",'gateway', gateway)
					uci:set("network","wan",'dns',dns)
					uci:set("network","wan",'ipv6', "0")	-- MSTC, Terence, Should not send RS and DHCPv6 Solicited

					--MSTC, Terence, backup current wan setting
					local static_bak_exist = uci:get("network","static","mode")
					if not static_bak_exist then
						local tmp_static_bak_name = uci:add("network", "wan_mode")
						uci:rename("network", tmp_static_bak_name, "static")
					end

					uci:set("network","static",'mode',"router")
					uci:set("network","static",'ifname',"eth1")
					uci:set("network","static",'proto',"static")
					uci:set("network","static",'ipaddr', ipaddr)
					uci:set("network","static",'netmask', netmask)
					uci:set("network","static",'gateway', gateway)
					uci:set("network","static",'dns',dns)
					set_mode = "router"
					change_lan_setting("router")

					--MSTC Bing, ipv6 passthrough
					uci:set("network", "static", "ipv6passthrough", ipv6pass)
					uci:set("network", "dhcp", "ipv6passthrough", ipv6pass)
					uci:set("network","wan",'ipv6passthrough', ipv6pass)

					if current_mode == "repeater" then
						config_non_repeater_wireless_ifce();
						uci:commit("wireless");
					end
			end
		elseif wan_mode == "dhcp" then
			local hostname = string.match(options, '--hostname=(%S+)')
			local ipv6pass = string.match(options, '--ipv6pass=(%S+)')
			
			--MBA Sean, IO-DATA don't need to check available hostname
			--if not datatypes.hostname(hostname) then
			--	wrong_value = true
			--end
			
			if not wrong_value then
					--MBA Sean, need to get the .Name of System, dirty work...
					local ifce={}
					uci:foreach("system", "system", function(s) ifce[s[".index"]]=s end)
					
					uci:set("system",ifce[0][".name"],'hostname',hostname)

					--MSTC, Terence, re-build wan config area
					uci:delete("network","wan")
					local tmp_name = uci:add("network", "interface")
					uci:rename("network", tmp_name, "wan")

					uci:set("network","wan",'mode',"router")
					uci:set("network","wan",'ifname',"eth1")
					uci:set("network","wan",'proto',"dhcp")
					-- MSTC, Terence, append hostname into dhcp client request
					uci:set("network","wan",'hostname',hostname)
					uci:set("network","wan",'ipv6', "0")	-- MSTC, Terence, Should not send RS and DHCPv6 Solicited

					--MSTC, Terence, backup current wan setting
					local backup_dhcp_exist = uci:get("network","dhcp","mode")
					if not backup_dhcp_exist then
						local tmp_dhcp_bak_name = uci:add("network", "wan_mode")
						uci:rename("network", tmp_dhcp_bak_name, "dhcp")
					end

					uci:set("network","dhcp",'mode',"router")
					uci:set("network","dhcp",'ifname',"eth1")
					uci:set("network","dhcp",'proto',"dhcp")
					set_mode = "router"
					change_lan_setting("router")

					--MSTC Bing, ipv6 passthrough
					uci:set("network", "static", "ipv6passthrough", ipv6pass)
					uci:set("network", "dhcp", "ipv6passthrough", ipv6pass)
					uci:set("network","wan",'ipv6passthrough', ipv6pass)

					if current_mode == "repeater" then
						config_non_repeater_wireless_ifce();
						uci:commit("wireless");
					end
			end
		--MBA Sean, pppoe mode
		elseif wan_mode == "pppoe" then
			local pppoe_id_type = string.match(options, '--pppoe_id_type=(%S+)')
			local pppoe_userid = ""
			local pppoe_pass = string.match(options, '--pppoe_pass=(%S+)')
			local pppoe_MTU = string.match(options, '--pppoe_mtu=(%S+)')
			local pppoe_ipv6pass = string.match(options, '--pppoe_ipv6pass=(%S+)')
			
			if pppoe_id_type == "pppoe_flets" then
				local flets_front = string.match(options, '--pppoe_flets_front=(%S+)')
				local flets_back = string.match(options, '--pppoe_flets_back=(%S+)')
				pppoe_userid = flets_front .. "@" .. flets_back
			elseif pppoe_id_type == "pppoe_others" then
				pppoe_userid = string.match(options, '--pppoe_userid=(%S+)')
			else
				wrong_value = true
			end
			
			if not datatypes.range( pppoe_MTU, 576, 1492 ) then
				wrong_value = true
			end

			if not wrong_value then
					--MSTC, Terence, re-build wan config area
					uci:delete("network","wan")
					local tmp_name = uci:add("network", "interface")
					uci:rename("network", tmp_name, "wan")

					uci:set("network","wan",'mode',"router")
					uci:set("network","wan",'ifname',"eth1")
					uci:set("network","wan",'proto',"pppoe")
					uci:set("network","wan",'pppoe_id_type', pppoe_id_type)
					uci:set("network","wan",'username', pppoe_userid)
					uci:set("network","wan",'password', pppoe_pass)
					uci:set("network","wan",'pppd_mtu', pppoe_MTU)
					uci:set("network","wan",'keepalive', "5,60")		-- MSTC Terence, Modify LCP Echo Interval as 60 seconds.  format : <lcp-echo-failure>,<lcp-echo-interval>
					uci:set("network","wan",'ipv6', "0")	-- MSTC, Terence, Should not send IPV6CP

					--MSTC, Terence, backup current wan setting
					local backup_pppoe_exist = uci:get("network","pppoe","mode")
					if not backup_pppoe_exist then
						local tmp_pppoe_bak_name = uci:add("network", "wan_mode")
						uci:rename("network", tmp_pppoe_bak_name, "pppoe")
					end

					uci:set("network","pppoe",'mode',"router")
					uci:set("network","pppoe",'ifname',"eth1")
					uci:set("network","pppoe",'proto',"pppoe")
					uci:set("network","pppoe",'pppoe_id_type', pppoe_id_type)
					uci:set("network","pppoe",'username', pppoe_userid)
					uci:set("network","pppoe",'password', pppoe_pass)
					uci:set("network","pppoe",'mtu', pppoe_MTU)
					uci:set("network","pppoe",'keepalive', "5,60")		-- MSTC Terence, Modify LCP Echo Interval as 60 seconds.  format : <lcp-echo-failure>,<lcp-echo-interval>
					set_mode = "router"
					change_lan_setting("router")

					--MSTC Bing, ipv6 passthrough
					uci:set("network", "pppoe", "ipv6passthrough", pppoe_ipv6pass)
					uci:set("network","wan",'ipv6passthrough', pppoe_ipv6pass)

					if current_mode == "repeater" then
						config_non_repeater_wireless_ifce();
						uci:commit("wireless");
					end
			end

		--MBA Sean, ap mode 
		elseif wan_mode == "ap" then
			--MSTC, Terence, re-build wan config area
			uci:delete("network","wan")
			local tmp_name = uci:add("network", "interface")
			uci:rename("network", tmp_name, "wan")

			uci:set("network","wan","mode","ap")
			uci:set("network","wan",'ifname',"eth1")

			--MSTC, Terence, backup current wan setting
			local backup_ap_exist = uci:get("network","ap","mode")
			if not backup_ap_exist then
				local tmp_ap_bak_name = uci:add("network", "wan_mode")
				uci:rename("network", tmp_ap_bak_name, "ap")
			end

			uci:set("network","ap","mode","ap")
			uci:set("network","ap",'ifname',"eth1")
			--MSTC Bing, ipv6 passthrough
			uci:set("network","wan",'ipv6passthrough', "0")
			set_mode = "ap"
			change_lan_setting("ap")

			if current_mode == "repeater" then
				config_non_repeater_wireless_ifce();
				uci:commit("wireless");
			end
		--MBA Sean, repeater mode 
		elseif wan_mode == "repeater" then
			--MSTC, Terence, re-build wan config area
			uci:delete("network","wan")
			local tmp_name = uci:add("network", "interface")
			uci:rename("network", tmp_name, "wan")

			uci:set("network","wan",'mode',"repeater")
			uci:set("network","wan",'ifname',"eth1")

			--MSTC, Terence, backup current wan setting
			local backup_repeater_exist = uci:get("network","repeater","mode")
			if not backup_repeater_exist then
				local tmp_repeater_bak_name = uci:add("network", "wan_mode")
				uci:rename("network", tmp_repeater_bak_name, "repeater")
			end

			uci:set("network","repeater",'mode',"repeater")
			uci:set("network","repeater",'ifname',"eth1")
			--MSTC Bing, ipv6 passthrough
			uci:set("network","wan",'ipv6passthrough', "0")
			set_mode = "repeater"
			change_lan_setting("repeater")

			if current_mode ~= "repeater" then
				config_repeater_wireless_ifce();
				uci:commit("wireless");
			end
		--MBA Sean, not included, error
		else
			wrong_value = true;
		end
	
		--MBA Sean, The customer doesn't need check input changed, apply anyway.
		if not wrong_value then
		
			if current_mode == "router" and set_mode ~= "router" then
				uci:set("upnpd", "config", "enable_natpmp", "0")
				uci:set("upnpd", "config", "enable_upnp", "0")
				uci:foreach("dhcp", "dnsmasq", function(s)
					uci:set("dhcp", s[".name"], "enabled", "0")
				end)
				uci:set("dhcp","lan","ignore","1")
			end
			if current_mode ~= "router" and set_mode == "router" then
				uci:foreach("dhcp", "dnsmasq", function(s)
					uci:set("dhcp", s[".name"], "enabled", "1")
				end)

				local  dhcp_lan_router = uci:get("dhcp", "lan_router", "ignore")
				if dhcp_lan_router then
					uci:set("dhcp","lan","ignore",dhcp_lan_router)
				else
					uci:set("dhcp","lan","ignore","0")
				end
			end
		
			uci:commit("dhcp")
			uci:commit("network")
			uci:commit("system")
			uci:commit("upnpd")
		
			--MSTC, Olivia, if only mode switch, it should be rebooted anyway.
			--MBA Sean Only reboot if mode actually change (cuurent mode not equal to set mode )
			if ( current_mode ~= set_mode ) then
				sys.exec("sync")
				sys.exec("reboot")--end
			else	
				sys.exec("/etc/init.d/network restart")
				sys.exec("/etc/init.d/system restart")
				sys.exec("/usr/sbin/httpredirect.sh update")
				sys.exec("/etc/init.d/mstcIpv6Pass restart")
			end
		end

	
