--[[
LuCI - Lua Configuration Interface

Copyright 2011 Manuel Munz <freifunk somakoma de>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

]]--

module ("luci.controller.iodata.ipaddress_settings", package.seeall)
local uci = require("luci.model.uci").cursor()
local sys = require("luci.sys")
local datatypes  = require("luci.cbi.datatypes")
local csrf = require("luci.csrf")

function index()

	entry({"content", "lan_settings", "ipaddress_settings"}, call("action_ipaddress_settings"), _("IP Address Settings"), 1).leaf = true
	
end


function action_ipaddress_settings()
	local apply = luci.http.formvalue("apply")
	local mode = uci:get("network", "wan", "mode")
	--We still need to check the value in teh lua program, because user may close javascript
	local wrong_value = false
	
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
	
		local ipaddr  = luci.http.formvalue("ipaddr")
		local lan_ip = uci:get("network", "lan", "ipaddr")
		
		if not datatypes.ipaddr(ipaddr) then
			wrong_value = true
		end
		
		--MBA Sean, Only the router mode need to deal with dhcp
		local leasetime = luci.http.formvalue("leasetime")
		local dhcp_disable = uci:get("dhcp", "lan", "ignore")
		local dhcp_start = uci:get("dhcp", "lan", "start")
		local dhcp_pool = uci:get("dhcp", "lan", "limit")
		local dhcp_lease = uci:get("dhcp", "lan", "leasetime")
			
		--marco
		local ignore = luci.http.formvalue("dhcp_enable")
		local startAddress = luci.http.formvalue("startAdd")
		local endAddress = luci.http.formvalue("endAdd")
		local poolSize = 150 --MBA Sean, Openwrt default
		local startAd = 100 --MBA Sean, Openwrt default
		if (mode == "router") or (mode == "v6plus") or (mode == "transix") then
			if not ignore == 1 and not ignore ==0 then
				wrong_value = true
			end
			if not datatypes.ipaddr(startAddress) then
				wrong_value = true
			end
			if not datatypes.ipaddr(endAddress) then
				wrong_value = true
			end
			--if not datatypes.uinteger(leasetime) and leasetime < 168 then
			--	wrong_value = true
			--else
			--	leasetime = leasetime .. "h" --MBA Sean, put the "h" back to the lease time
			--end
		
			startAd=string.match(startAddress,"%d+.%d+.%d+.(%d+)")
			local endAd=string.match(endAddress,"%d+.%d+.%d+.(%d+)")
		
			--MBA Sw Sean, calculate poolsize (end ip - start ip) 
			if tonumber(endAd) >= tonumber(startAd) then
				poolSize = tonumber(endAd) - tonumber(startAd) +1
			else
				wrong_value = true
			end
			
			if not wrong_value then
				--MSTC, Terence, backup dhcp setting with router mode
				local backup_dhcp_exist = uci:get("dhcp","lan_router","ignore")
				if not backup_dhcp_exist then
					local tmp_dhcp_bak_name = uci:add("dhcp", "lan_router")
					uci:rename("dhcp", tmp_dhcp_bak_name, "lan_router")
				end

				uci:set("network", "lan", "ipaddr", ipaddr)
				uci:set("dhcp","lan",'ignore',ignore)
				uci:set("dhcp","lan",'leasetime',leasetime)
				uci:set("dhcp","lan",'start',startAd)

				--MSTC, Smith, backup current lan setting
				uci:set("network", "lan_router", "ipaddr", ipaddr)

				--MSTC, Terence, backup current dhcp setting
				uci:set("dhcp", "lan_router", "ignore", ignore)

				--MBA Sean, transfer the dhcp_pool & poolSize to the same type
				--If you compare 100 == "100" in Lua, it will not reutrn true
				--you must compare the same type 
				uci:set("dhcp","lan",'limit',poolSize)
			end
			--MSTC,Olivia Hu, it should stop v6 and then restart the process again while there has any network changing as customer request.
			if (mode == "v6plus") or (mode == "transix") then
				sys.exec("ip4ov6jp_stop")
			end --end
			
		end
		
		--MBA Sean, only the ap & repeater need to set dns and default gw and lan ip mode
		local lanproto = luci.http.formvalue("lanproto")
		local default_gw = luci.http.formvalue("default_gw")
		local dns_server = luci.http.formvalue("dns_server")	
		if mode == "ap" or mode == "repeater" then
			
			if not lanproto == "static" and not lanproto == "dhcp" then
				wrong_value = true
			end

			if lanproto == "static" then
				if not datatypes.ipaddr(default_gw) then
					wrong_value = true
				end
				if not datatypes.ipaddr(dns_server) then
					wrong_value = true
				end
			end

			if not wrong_value then
				uci:set("network", "lan", "proto", lanproto)

				if lanproto == "static" then
					uci:set("network", "lan", "autoip", "no")
					uci:set("network", "lan", "ipaddr", ipaddr)
					uci:set("network", "lan", "gateway", default_gw)
					uci:set("network", "lan", "dns", dns_server)
				else
					uci:set("network", "lan", "autoip", "yes")
				end

				--__MSTC__ Smith, backup current lan setting
				uci:set("network", "lan_"..mode, "proto", lanproto)

				if lanproto == "static" then
					uci:set("network", "lan_"..mode, "ipaddr", ipaddr)
					uci:set("network", "lan_"..mode, "gateway", default_gw)
					uci:set("network", "lan_"..mode, "dns", dns_server)
					uci:set("network", "lan_"..mode, "lan_autoip", "no")
				else
					uci:set("network", "lan_"..mode, "lan_autoip", "yes")
				end

			end
		end

		--MBA Sean, The customer doesn't need check input changed, apply anyway.
		if not wrong_value then
            uci:commit("dhcp")
			uci:commit("network")
			sys.exec("/etc/init.d/network restart")
			sys.exec("/etc/init.d/avahi-autoipd restart")
			sys.exec("/usr/sbin/httpredirect.sh update")
		end		
	end

	luci.template.render("iodata/ipaddress_settings")
end
