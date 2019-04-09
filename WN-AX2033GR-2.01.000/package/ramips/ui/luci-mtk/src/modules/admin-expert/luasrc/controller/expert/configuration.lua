--[[
LuCI - Lua Configuration Interface

Copyright 2008 Steven Barth <steven@midlink.org>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

$Id: index.lua 4040 2009-01-16 12:35:25Z Cyrus $
]]--
module("luci.controller.expert.configuration", package.seeall)
local uci = require("luci.model.uci").cursor()
local sys = require("luci.sys")

country_code_table = {
	FF={"reg0", "reg10"},				 -- USA           //DEBUG   old:{"reg0", "reg7"}
	FE={"reg1", "reg7"},				 -- S.Africa     
	FD={"reg1", "reg1"},				 -- Netherland   
	FC={"reg1", "reg1"},				 -- Denmark      
	FA={"reg1", "reg1"},				 -- Sweden       
	F9={"reg1", "reg1"},				 -- UK           
	F8={"reg1", "reg1"},				 -- Belgium      
	F7={"reg1", "reg1"},				 -- Greece       
	F6={"reg1", "reg2"},				 -- Czech        
	F5={"reg1", "reg1"},				 -- Norway       
	F4={"reg1", "reg9"},				 -- Australia    
	F3={"reg1", "reg9"},				 -- New Zealand   //without 165
	F2={"reg1", "reg7"},				 -- Hong Kong    
	F1={"reg1", "reg0"},				 -- Singapore    
	F0={"reg1", "reg1"},				 -- Finland      
	EF={"reg1", "reg6"},				 -- Morocco	     
	EE={"reg0", "reg3"},				 -- Taiwan       // old: {"reg0", "reg13"} 
	ED={"reg1", "reg1"},				 -- German       
	EC={"reg1", "reg1"},				 -- Italy        
	EB={"reg1", "reg1"},				 -- Ireland      
	EA={"reg1", "reg1"},				 -- Japan         //without 184 188 192 196
	E9={"reg1", "reg1"},				 -- Austria      
	E8={"reg1", "reg0"},				 -- Malaysia     
	E7={"reg1", "reg1"},				 -- Poland       
	E6={"reg1", "reg0"},				 -- Russia       
	E5={"reg1", "reg1"},				 -- Hungary      
	E4={"reg1", "reg1"},				 -- Slovak 	     
	E3={"reg1", "reg7"},				 -- Thailand     
	E2={"reg1", "reg2"},				 -- Israel       
	E1={"reg1", "reg1"},				 -- Switzerland  
	E0={"reg1", "reg1"},				 -- UAE          
	DE={"reg1", "reg4"},				 -- China        
	DD={"reg1", "reg0"},				 -- Ukraine      
	DC={"reg1", "reg1"},				 -- Portugal     
	DB={"reg1", "reg1"},				 -- France       
	DA={"reg1", "reg11"},				 -- Korea        
	D9={"reg1", "reg7"},				 -- Korea        
	D8={"reg1", "reg7"},				 -- Philippine   
	D7={"reg1", "reg1"},				 -- Slovenia	 
	D6={"reg1", "reg7"},				 -- India        
	D5={"reg1", "reg1"},				 -- Spain        
	D3={"reg1", "reg1"},				 -- Turkey       
	D1={"reg1", "reg7"},				 -- Peru         
	D0={"reg0", "reg7"},				 -- Brazil       
	CB={"reg1", "reg1"},				 -- Bulgaria     
	CC={"reg1", "reg1"},				 -- Luxembourg   
	CE={"reg0", "reg9"},				 -- Canada 	     
	CD={"reg1", "reg1"},				 -- Iceland	     
	CF={"reg1", "reg1"}				 -- Romania                             	                                           
}

channelRange = {
	reg0="1-11",    --region 0
	reg1="1-13",    --region 1
	reg2="10-11",   --region 2
	reg3="10-13",   --region 3
	reg4="14",      --region 4
	reg5="1-14",    --region 5
	reg6="3-9",     --region 6
	reg7="5-13"    --region 7
}
                                    
function index()                     
	
	local i18n = require("luci.i18n")
	local libuci = require("luci.model.uci").cursor()
	local lang = libuci:get("luci","main","lang") 
	i18n.load("admin-core",lang)
	i18n.setlanguage(lang)
                                 
	local page  = node("expert", "configuration")
	page.target = template("expert_configuration/configuration")
	page.title  = i18n.translate("Configuration")    
	page.order  = 40                 

-- jeffary mark network->WAN, 2012.08.03
--[[  
	local page  = node("expert", "configuration", "network")
	page.target = alias("expert", "configuration", "network", "wan")
	page.title  = i18n.translate("Network")         
	page.index = true                
	page.order  = 41                 
	                                 
	local page  = node("expert", "configuration", "network", "wan")
	page.target = call("action_wan_internet_connection")
	page.title  = i18n.translate("WAN")
	page.order  = 42        

	local page  = node("expert", "configuration", "network", "wan","ipv6")
	page.target = call("action_wan_ipv6")
	--page.target = template("expert_configuration/ipv6")
	--page.title  = i18n.translate("IPv6")
	page.title  = "IPv6"
	page.order  = 420	

    	local page  = node("expert", "configuration", "network", "wan","advanced")
    	page.target = call("action_wan_advanced")
    	page.title  = "Advanced"
    	page.order  = 421
]]--

	local page  = node("expert", "configuration", "lte")
	page.target = alias("expert", "configuration", "lte", "sim")
	page.title  = i18n.translate("LTE")
	page.index = true  
	page.order  = 40

	local page  = node("expert", "configuration", "lte", "sim")
	page.target = call("action_lte_sim")
	page.title  = i18n.translate("SIM")
	page.order  = 42        

	local page  = node("expert", "configuration", "lte", "APN")
	page.target = call("action_lte_apn")
	page.title  = i18n.translate("APN")
	page.order  = 42
	
	local page  = node("expert", "configuration", "lte", "APN","apn_edit")
	page.target = call("action_apn_edit")
	page.title  = "APN Edit"
	page.order  = 42
	
	local page  = node("expert", "configuration", "lte", "network_settings")
	page.target = call("action_lte_network_settings")
	page.title  = i18n.translate("Network Settings")
	page.order  = 43
	
	local page  = node("expert", "configuration", "lte", "network_settings", "network_select")
	page.target = call("action_lte_network_select")
	page.title  = i18n.translate("Network Select")
	page.order  = 43
	
--[[wireless2.4G]]--
-- jeffary add network->wlan, 2012.08.03
	local page  = node("expert", "configuration", "network")
	page.target = alias("expert", "configuration", "network", "wlan")
	page.title  = i18n.translate("Network")         
	page.index = true                
	page.order  = 51    

	local page  = node("expert", "configuration", "network", "wlan")
--	page.target = template("expert_configuration/wlan")
	page.target = call("wlan_general")
	page.title  = i18n.translate("wireless_lan")  
	page.order  = 53


	local page  = node("expert", "configuration", "network", "wlan", "wlanmacfilter")
--	page.target = template("expert_configuration/wlanmacfilter")
	page.target = call("wlanmacfilter")
	page.title  = "MAC Filter"  
	page.order  = 44

--[[
	local page  = node("expert", "configuration", "network", "wlan", "wlanadvanced")
--	page.target = template("expert_configuration/wlanadvanced")
	page.target = call("wlan_advanced")	
	page.title  = "Advanced"  
	page.order  = 45
	
	local page  = node("expert", "configuration", "network", "wlan", "wlanqos")
--	page.target = template("expert_configuration/wlanqos")
	page.target = call("wlan_qos")		
	page.title  = "QoS"  
	page.order  = 46
		
	local page  = node("expert", "configuration", "network", "wlan", "wlanscheduling")
--	page.target = template("expert_configuration/wlanscheduling")
	page.target = call("wlanscheduling")
	page.title  = "Scheduling"  
	page.order  = 48
]]--

--[[end2.4G]]--	

	local page  = node("expert", "configuration", "network", "lan")
	page.target = call("action_lan")
	page.title  = i18n.translate("LAN")  
	page.order  = 65

-- MSTC, Sharon add configuration->lan ipv6	
	local page  = node("expert", "configuration", "network", "lan", "ipv6")
	page.target = call("action_lan_ipv6")
	page.title  = i18n.translate("lan_ipv6")  
	page.order  = 66
-- end

-- jeffary mark lan->ipalias, 2012.08.08
--[[
	local page  = node("expert", "configuration", "network", "lan", "ipalias")
	page.target = call("action_ipalias")
	page.title  = "IP Alias"  
	page.order  = 57
]]--
	
	--[[
	local page  = node("expert", "configuration", "network", "lan", "ipadv")
	page.target = template("expert_configuration/ip_advance")
	page.title  = "IP Advance"  
	page.order  = 44
	]]--
	
	local page  = node("expert", "configuration", "network", "dhcpserver")
	page.target = call("action_dhcpSetup")
	page.title  = i18n.translate("DHCP_Server")
	page.order  = 68

	local page  = node("expert", "configuration", "network", "dhcpserver", "ipstatic")
	page.target = call("action_dhcpStatic")
	page.title  = "LAN_IPStatic"
	page.order  = 69

	local page  = node("expert", "configuration", "network", "dhcpserver", "dhcptbl")
	page.target = call("action_clientList")
	page.title  = "LAN_DHCPTbl_1"
	page.order  = 70
	
	local page  = node("expert", "configuration", "network", "nat")
	page.target = call("action_dmz")
	page.title  = i18n.translate("DMZ")
	page.order  = 71
	
	local page  = node("expert", "configuration", "network", "nat", "portfw")
	page.target = call("action_portfw")
	page.title  = "Port Forwarding"
	page.order  = 72

	local page  = node("expert", "configuration", "network", "nat", "portfw","portfw_edit")
	page.target = call("action_portfw_edit")
	page.title  = "Port Forwarding Edit"
	page.order  = 73
	
-- jeffary mark network->Static Route, 2012.08.03
--[[	
	local page  = node("expert", "configuration", "network", "nat","nat_advance")
	page.target = call("port_trigger")
	page.title  = "NAT Advance"
	page.order  = 64
]]--

-- MSTC, Sharon mark configuration->ddns
--[[
	local page  = node("expert", "configuration", "network", "ddns")
	page.target = call("action_ddns")
	page.title  = i18n.translate("Dynamic_DNS")
	page.order  = 75
--]]

-- MSTC, Sharon mark configuration->vpn_passthrough
--[[
	local page  = node("expert", "configuration", "network", "vpn_passthrough")
	page.target = call("action_vpn_passthrough")
	page.title  = i18n.translate("VPN_Passthrough")  
	page.order  = 76
--]]

-- jeffary mark network->Static Route, 2012.08.03
--[[
	local page  = node("expert", "configuration", "network", "static_route")
	page.target = call("action_static_route")
	page.title  = i18n.translate("Static_Route")
	page.order  = 66
]]--

-- jeffary mark network->security, 2012.08.03
--[[
	local page  = node("expert", "configuration", "security")
	page.target = alias("expert", "configuration", "security", "firewall")
	page.title  = i18n.translate("Security")
	page.index = true 
	page.order  = 67
	
	local page  = node("expert", "configuration", "security", "firewall")
	page.target = call("firewall")
	page.title  = i18n.translate("Firewall") 
	page.ignoreindex = true	
	page.order  = 68
	
	local page  = node("expert", "configuration", "security", "firewall", "fwsrv")
	page.target = call("fw_services")
	page.title  = "Firewall Service"  
	page.order  = 69
	
	local page  = node("expert", "configuration", "security", "vpn")
	--page.target = template("expert_configuration/vpn")
	page.target = call("action_vpn")
	page.title  = i18n.translate("IPSec_VPN")  
	page.order  = 70
	
	local page  = node("expert", "configuration", "security", "vpn", "vpn_edit")
	page.target = call("action_vpnEdit")
	page.title  = "IPSec VPN Edit"  
	page.order  = 71
	
	local page  = node("expert", "configuration", "security", "vpn", "samonitor")
	--page.target = template("expert_configuration/samonitor")
	page.target = call("action_samonitor")
	page.title  = "SA Monitor"  
	page.order  = 72
	
	local page  = node("expert", "configuration", "security", "ContentFilter")
	page.target = call("action_CF")
	page.title  = i18n.translate("Content_filter")  
	page.order  = 73
]]--
	
--[[	
	local page  = node("expert", "configuration", "usb")
	page.target = template("expert_configuration/3g_connection")
	page.title  = "USB Service"  
	page.order  = 73
	
	local page  = node("expert", "configuration", "powersave")
	page.target = template("expert_configuration/powersaving")
	page.title  = "Power Saving"  
	page.order  = 74
]]--

-- jeffary mark configuration->Bandwidth_MGMT, 2012.08.07
--[[
	local page  = node("expert", "configuration", "management")
	page.target = alias("expert", "configuration", "management", "qos")
	page.title  = i18n.translate("Management")
	page.index = true  
	page.order  = 75

	local page  = node("expert", "configuration", "management", "qos")
	page.target = alias("expert", "configuration", "management", "qos", "general")
	page.title  = i18n.translate("Bandwidth_MGMT")  
	page.order  = 76
	
	local page  = node("expert", "configuration", "management", "qos", "general")
	page.target = call("action_qos")
	page.title  = "QoS General"  
	page.order  = 77
	
	local page  = node("expert", "configuration", "management", "qos", "advance")
	page.target = call("action_qos_adv")
	page.title  = "QoS Advance"  
	page.order  = 78
	
	local page  = node("expert", "configuration", "management", "qos", "monitor")
	page.target = template("expert_configuration/qos_monitor")
	page.title  = "QoS Monitor"  
	page.order  = 79
]]--

-- MSTC, Sharon mark configuration->remote MGMT
--[[
	local page  = node("expert", "configuration", "management")
	page.target = alias("expert", "configuration", "management", "remote")
	page.title  = i18n.translate("Management")
	page.index = true  
	page.order  = 85

	local page  = node("expert", "configuration", "management", "remote")
	page.target = call("action_remote_www")
	page.title  = i18n.translate("Remote_MGMT")
	page.ignoreindex = true  
	page.order  = 90
	
	local page  = node("expert", "configuration", "management", "remote", "telnet")
	page.target = call("action_remote_telnet")
	page.title  = "Remote MGMT Telnet"
	page.order  = 91
	
	local page  = node("expert", "configuration", "management", "remote", "wol")
	page.target = call("action_wol")
	page.title  = "Wake On LAN"
	page.order  = 82
]]--

-- MSTC, Sharon mark configuration->upnp
--[[
	local page  = node("expert", "configuration", "management", "upnp")
	page.target = call("action_upnp")
	page.title  = i18n.translate("UPnP")  
	page.order  = 93
--]]	
end

function action_wan_internet_connection()
    local apply = luci.http.formvalue("apply")

    if apply then
		-- lock dns check, and it will be unlock after updating dns in update_sys_dns
		sys.exec("echo 1 > /var/update_dns_lock")
		local wan_proto = uci:get("network","wan","proto")
		sys.exec("echo "..wan_proto.." > /tmp/old_wan_proto")
	
        local connection_type = luci.http.formvalue("connectionType")                
        local Server_dns1Type       = luci.http.formvalue("dns1Type")
        local Server_staticPriDns   = luci.http.formvalue("staticPriDns")
        local Server_dns2Type       = luci.http.formvalue("dns2Type")
        local Server_staticSecDns   = luci.http.formvalue("staticSecDns")
        local Server_dns3Type       = luci.http.formvalue("dns3Type")
        local Server_staticThiDns   = luci.http.formvalue("staticThiDns")
				
		if Server_dns1Type~="USER" or Server_staticPriDns == "0.0.0.0" or not Server_staticPriDns then
			Server_staticPriDns=""
		end
				
		if Server_dns2Type~="USER" or Server_staticSecDns == "0.0.0.0" or not Server_staticSecDns then
			Server_staticSecDns=""
		end
				
		if Server_dns3Type~="USER" or Server_staticThiDns == "0.0.0.0" or not Server_staticThiDns then
			Server_staticThiDns=""
		end
				
		uci:set("network","wan","dns1",Server_dns1Type ..",".. Server_staticPriDns)
		uci:set("network","wan","dns2",Server_dns2Type ..",".. Server_staticSecDns)
		uci:set("network","wan","dns3",Server_dns3Type ..",".. Server_staticThiDns)

        if connection_type == "PPPOE" then

			local pppoeUser = luci.http.formvalue("pppoeUser")
			local pppoePass = luci.http.formvalue("pppoePass")
			local pppoeMTU = luci.http.formvalue("pppoeMTU")
			local pppoeNailedup = luci.http.formvalue("pppoeNailedup")
			local pppoeIdleTime = luci.http.formvalue("pppoeIdleTime")
			local pppoeServiceName = luci.http.formvalue("pppoeServiceName")
			--local pppoePassthrough = luci.http.formvalue("pppoePassthrough")
			local pppoeWanIpAddr = luci.http.formvalue("pppoeWanIpAddr")

			if pppoeNailedup~="1" then
				pppoeNailedup=0
			end
					
			if not pppoeIdleTime then
				pppoeIdleTime=""
			end
			--[[
			if pppoePassthrough~="1" then
				pppoePassthrough=0
			end
			]]--
					
			if not pppoeWanIpAddr then
				pppoeWanIpAddr=""
			end
					
            uci:set("network","wan","proto","pppoe")
            uci:set("network","wan","username",pppoeUser)
            uci:set("network","wan","password",pppoePass)
	    uci:set("network","wan","mtu",pppoeMTU)	
			uci:set("network","wan","pppoeNailedup",pppoeNailedup)
			uci:set("network","wan","demand",pppoeIdleTime)
			uci:set("network","wan","pppoeServiceName",pppoeServiceName)
			--uci:set("network","wan","pppoePassthrough",pppoePassthrough)
			uci:set("network","wan","pppoeWanIpAddr",pppoeWanIpAddr)
			--[[
			uci:delete("network","wan","ipaddr")
			uci:delete("network","wan","netmask")
			uci:delete("network","wan","gateway")
			]]--
		elseif connection_type == "PPTP" then
		
			local pptpUser = luci.http.formvalue("pptpUser")
			local pptpPass = luci.http.formvalue("pptpPass")
			local pptpMTU = luci.http.formvalue("pptpMTU")
			local pptpNailedup = luci.http.formvalue("pptpNailedup")
			local pptpIdleTime = luci.http.formvalue("pptpIdleTime")
			local pptp_serverIp = luci.http.formvalue("pptp_serverIp")
			local pptpWanIpAddr = luci.http.formvalue("pptpWanIpAddr")
			local pptp_config_ip = luci.http.formvalue("pptp_config_ip")
			local pptp_staticIp = luci.http.formvalue("pptp_staticIp")
			local pptp_staticNetmask = luci.http.formvalue("pptp_staticNetmask")
			local pptp_staticGateway = luci.http.formvalue("pptp_staticGateway")
			local pptpWanIPMode = luci.http.formvalue("pptpWanIPMode")

			if pptpNailedup~="1" then
				pptpNailedup=0
			end
					
			if not pptpIdleTime then
				pptpIdleTime=""
			end
					
			if not pptpWanIpAddr then
				pptpWanIpAddr=""
			end					
            uci:set("network","wan","proto","pptp")
			uci:set("network","vpn","interface")
			
			if pptp_config_ip == "1" then
				uci:set("network","vpn","proto","dhcp")
            else
				uci:set("network","vpn","proto","static")
				uci:set("network","wan","ipaddr",pptp_staticIp)
				uci:set("network","wan","netmask",pptp_staticNetmask)
				uci:set("network","wan","gateway",pptp_staticGateway)
            end
			
            uci:set("network","vpn","pptp_username",pptpUser)
            uci:set("network","vpn","pptp_password",pptpPass)
	    uci:set("network","wan","pptp_mtu",pptpMTU)
			uci:set("network","vpn","pptp_Nailedup",pptpNailedup)
			uci:set("network","vpn","pptp_demand",pptpIdleTime)
			uci:set("network","vpn","pptp_serverip",pptp_serverIp)
			uci:set("network","vpn","pptpWanIPMode",pptpWanIPMode)
			uci:set("network","vpn","pptpWanIpAddr",pptpWanIpAddr)	

		else	
				
			local WAN_IP_Auto = luci.http.formvalue("WAN_IP_Auto")
			local Fixed_staticIp = luci.http.formvalue("staticIp")
			local Fixed_staticNetmask = luci.http.formvalue("staticNetmask")
			local Fixed_staticGateway = luci.http.formvalue("staticGateway")
			local ethMTU = luci.http.formvalue("ethMTU")
					
			if WAN_IP_Auto == "1" then
				uci:set("network","wan","proto","dhcp")
            else
				uci:set("network","wan","proto","static")
				uci:set("network","wan","ipaddr",Fixed_staticIp)
				uci:set("network","wan","netmask",Fixed_staticNetmask)
				uci:set("network","wan","gateway",Fixed_staticGateway)
            end
			uci:set("network","wan","eth_mtu",ethMTU)
			--[[
			uci:delete("network","wan","username")
			uci:delete("network","wan","password")
			uci:delete("network","wan","pppoeNailedup")
			uci:delete("network","wan","pppoeIdleTime")
			uci:delete("network","wan","pppoeServiceName")
			uci:delete("network","wan","pppoePassthrough")
			]]--
		end
			
					
		local WAN_MAC_Clone = luci.http.formvalue("WAN_MAC_Clone")
		local spoofIPAddr = luci.http.formvalue("spoofIPAddr")
		local macCloneMac = luci.http.formvalue("macCloneMac")
		--[[
		local old_WAN_MAC_Clone = uci:get("network", "wan", "wan_mac_status")
		if not old_WAN_MAC_Clone then 
			old_WAN_MAC_Clone = "0"
			uci:set("network","wan","wan_mac_status",old_WAN_MAC_Clone)
		end
		]]--
		--if WAN_MAC_Clone ~= old_WAN_MAC_Clone then
			if WAN_MAC_Clone == "0" then
				uci:set("network","wan","wan_mac_status",WAN_MAC_Clone)
			elseif WAN_MAC_Clone == "1" then
				local sw = 0
				local t={}
				t=luci.sys.net.arptable()
				for i,v in ipairs(t) do
					if t[i]["IP address"]==spoofIPAddr then 
						uci:set("network","wan","wan_clone_ip",t[i]["IP address"])
						uci:set("network","wan","wan_clone_ip_mac",t[i]["HW address"])
						sw = 1
					end
				end
			
				if sw==1 then
					uci:set("network","wan","wan_mac_status","1")
				else
					local url = luci.dispatcher.build_url("expert","configuration","network","wan")		
					luci.http.redirect(url .. "?" .. "arp_error=1" .. "&error_addr=" .. spoofIPAddr)
				end

			elseif WAN_MAC_Clone == "2" then
				uci:set("network","wan","wan_mac_status",WAN_MAC_Clone)
				uci:set("network","wan","wan_set_mac",macCloneMac)
			end

		--end
			
		uci:set("network","general","config_section","wan")	
		uci:commit("network")	
        uci:apply("network")    
	end

    luci.template.render("expert_configuration/broadband_add")

end

function action_wan_ipv6()
	local apply = luci.http.formvalue("apply")

	if apply then
		local connect_type = luci.http.formvalue("connectionType")

		if ( connect_type == "None" ) then
			--IPoE
			--PPPoE
			--Tunnel
			sys.exec("/etc/init.d/gw6c stop 2>/dev/null")
			uci:set("gw6c", "basic", "disabled", "1")
			uci:commit("gw6c")
			uci:set("network6","wan","type", "none")
			uci:commit("network6")
		elseif ( connect_type == "Tunnelv6" ) then
			local broker = luci.http.formvalue("tunnel_broker")
			--freenet6
			if (broker == "freenet6") then
				local user_name = luci.http.formvalue("gogo6_user_name")
				local password = luci.http.formvalue("gogo6_pwd")
				local tunnel_type = luci.http.formvalue("tunnel_mode")
				local server = luci.http.formvalue("gogo6_server")

				uci:set("network6","wan","type", "tunnel")
				uci:commit("network6")

				uci:set("gw6c", "basic", "disabled", 0)
				uci:set("gw6c", "basic", "userid", user_name)
				uci:set("gw6c", "basic", "passwd", password)
				uci:set("gw6c", "advanced", "if_tunnel_mode", tunnel_type)

				if (server == "best_server") then
					uci:set("gw6c", "basic", "server", "anon.freenet6.net")
				else
					uci:set("gw6c", "basic", "server", server)
				end

				uci:commit("gw6c")
				uci:apply("gw6c")
			end
		end
	end

	luci.template.render("expert_configuration/ipv6")
end

function action_wan_advanced()
	local apply = luci.http.formvalue("apply")
		
	if apply then
		local apply_igmp = luci.http.formvalue("apply_igmp")
		local apply_ip_change = luci.http.formvalue("apply_ip_change")
			
	        if apply_igmp then
	                local igmpEnabled   = luci.http.formvalue("igmpEnabled")
	
	                uci:set("igmpproxy","general","igmpEnabled",igmpEnabled)
	                uci:commit("igmpproxy")
			uci:apply("igmpproxy")
	        end
	        
	        if apply_ip_change then
	        	local ipChangeEnabled  = luci.http.formvalue("ipChangeEnabled")
	        	
	        	uci:set("network", "general", "auto_ip_change", ipChangeEnabled)
	        	uci:set("network", "general", "config_section", "advance")
	        	
	        	uci:commit("network")
	        	uci:apply("network")
	        end
	end
        luci.template.render("expert_configuration/broadband_advance")
end

function subnet(ip, mask)
	local ip_byte1, ip_byte2, ip_byte3, ip_byte4 = ip:match("(%d+).(%d+).(%d+).(%d+)")
	local mask_byte1, mask_byte2, mask_byte3, mask_byte4 = mask:match("(%d+).(%d+).(%d+).(%d+)")
	
	return bit.band(tonumber(ip_byte1), tonumber(mask_byte1)) .. "." .. bit.band(tonumber(ip_byte2), tonumber(mask_byte2)) .. "." .. bit.band(tonumber(ip_byte3), tonumber(mask_byte3)) .. "." .. bit.band(tonumber(ip_byte4), tonumber(mask_byte4))
end

function action_lan()
	local apply = luci.http.formvalue("apply")

	if apply then
		local ipaddr  = luci.http.formvalue("ipaddr")
		local netmask = luci.http.formvalue("netmask")
		local dhcpstart = luci.http.formvalue("dhcpstart")
		local dhcpend = luci.http.formvalue("dhcpend")
		local lan_ip = uci:get("network", "lan", "ipaddr")
		local lan_mask = uci:get("network", "lan", "netmask")
		local changed = false
		local subnet_changed = false
		local hostname = uci:get("system", "main", "hostname")

		if not (ipaddr == lan_ip) then
			uci:set("network", "lan", "ipaddr", ipaddr)
	
			local file = io.open( "/etc/hosts", "w" )
                        file:write("127.0.0.1" .. " " .. "localhost" .. " " .. hostname .. "\n")
                        file:write(ipaddr .. " " .. "myrouter" .. "\n")
                        file:close()

			changed = true
		end

		if not (netmask == lan_mask) then
			uci:set("network", "lan", "netmask", netmask)
			changed = true
			subnet_changed = true
		end

		if not ("static" == uci:get("network", "lan", "proto")) then
			uci:set("network", "lan", "proto", "static")
			changed = true
		end

		if changed then
			
			local lan_subnet = subnet(lan_ip, lan_mask)
			local cfg_subnet = subnet(ipaddr, netmask)
			
			local _start=string.match(dhcpstart,"%d+.%d+.%d+.(%d+)")
			local _pool=tonumber(string.match(dhcpend,"%d+.%d+.%d+.(%d+)"))-tonumber(_start)+1
            uci:set("dhcp","lan",'start',_start)
            uci:set("dhcp","lan",'limit',_pool)

            uci:commit("dhcp")
			uci:commit("network")
			uci:apply("network")
			uci:apply("dhcp")
			sys.exec("/etc/init.d/network reload")
			
			if lan_subnet ~= cfg_subnet or subnet_changed then
				sys.exec("/etc/init.d/dnsmasq restart")
			end
			local _sessionpath = luci.config.sauth.sessionpath
			luci.sys.exec("rm ".._sessionpath.."/*")
		end
	end

	luci.template.render("expert_configuration/lan")
end

function action_ipalias()
	local apply = luci.http.formvalue("apply")
	
	if apply then
		local i = 1

		uci:delete_all("network", "alias")
		while not (nil == luci.http.formvalue("alias" .. i .. "_ip")) do
			local aliasEntry = "alias"..i
			uci:set("network",aliasEntry,"alias")
			
			local aliasIP = luci.http.formvalue("alias" .. i .. "_ip")
			local aliasNetmask = luci.http.formvalue("alias" .. i .. "_netmask")
			local lan_ifname
			if uci:get("network","lan","type") == "bridge" then
				lan_ifname = "lan"
			else
				lan_ifname = uci:get("network","lan","ifname")
			end 

			--local lan_ifname = "br0"--#change eth2 to br0#
			local enabled = luci.http.formvalue("alias" .. i .. "_enabled")
			
			if not (enabled == "enabled") then 
				enabled = "disabled" 
			end			
				
			uci:set("network", aliasEntry, "interface", lan_ifname)
			uci:set("network", aliasEntry, "enabled", enabled)
			uci:set("network", aliasEntry, "proto", "static")
			uci:set("network", aliasEntry, "ipaddr", aliasIP)
			uci:set("network", aliasEntry, "netmask", aliasNetmask)

			i = i + 1
		end
		uci:set("network","general","config_section","ipalias")
		uci:commit("network")
		uci:apply("network")
	end

	luci.template.render("expert_configuration/ip_alias")
end



--dipper firewall
function firewall()

	local apply = luci.http.formvalue("apply")
	
	if apply then
		local enabled = luci.http.formvalue("DoSEnabled")
		local fw_level
		local flag = 1
		
		if enabled == nil then
			enabled = "0"
		end
		uci:set("firewall","general","dos_enable",enabled)	
		uci:commit("firewall")
		uci:apply("firewall")
		
	end
	
	luci.template.render("expert_configuration/firewall")
end

function fw_services()

	local icmp_apply = luci.http.formvalue("icmp_apply")
	local enable_apply = luci.http.formvalue("enable_apply")
	local add_rule = luci.http.formvalue("add_rule")
	local remove = luci.http.formvalue("remove")
	
	if icmp_apply then				
		
		local pingEnabled = luci.http.formvalue("pingFrmWANFilterEnabled")
		local ori_pingEnabled = uci:get("firewall","general","pingEnabled")
		
		
		if not (ori_pingEnabled==pingEnabled) then
			uci:set("firewall","general","pingEnabled",pingEnabled)
			uci:commit("firewall")
			uci:apply("firewall")
		end
	end
	
	if enable_apply then
	
		local filterEnabled = luci.http.formvalue("portFilterEnabled")
		local ori_filterEnabled = uci:get("firewall","general","filterEnabled")
		
		if filterEnabled then 
			filterEnabled = "1"
		else
			filterEnabled = "0"
		end
		
		if not (ori_filterEnabled==filterEnabled) then
			uci:set("firewall","general","filterEnabled",filterEnabled)
			uci:commit("firewall")
			uci:apply("firewall")
		end	
	
	end
	
	if add_rule then
	
		local srvName = luci.http.formvalue("srvName")
		local mac_address = luci.http.formvalue("mac_address")
		local dip_address = luci.http.formvalue("dip_address")
		local sip_address = luci.http.formvalue("sip_address")
		local protocol = luci.http.formvalue("protocol")
		local dFromPort = luci.http.formvalue("dFromPort")
		local dToPort = luci.http.formvalue("dToPort")
		local sFromPort = luci.http.formvalue("sFromPort")
		local sToPort = luci.http.formvalue("sToPort")
			
		-----firewall-----
		local enabled = 1
		if mac_address=="" then
			mac_address="00:00:00:00:00:00"
		end
		if dip_address=="" then
			dip_address="0.0.0.0"
		end
		if sip_address=="" then
			sip_address="0.0.0.0"
		end
		
		if protocol == "ICMP" then
			dFromPort = ""
			dToPort = ""
			sFromPort = ""
			sToPort = ""
		end
		
		if dFromPort=="" then
			if not dToPort=="" then
				dFromPort=dToPort
			end
		end
		
		if sFromPort=="" then
			if not sToPort=="" then
				sFromPort=sToPort
			end
		end
		
		local fw_type = "in"
		local wan = 0
		local lan = 0
		local fw_time = "always"
		local target = "DROP"
		--local target =	uci:get("firewall","general","filterEnabled")
		
		local rules_count = uci:get("firewall","general","rules_count")
		local NextRulePos = uci:get("firewall","general","NextRulePos")
		--local service_count = uci:get("firewall","general","service_count")
		rules_count = rules_count+1
		NextRulePos = NextRulePos+1
		--service_count = service_count+1
		local rules = "rule"..rules_count
		local services = "service"..rules_count
		--[[
		uci:set("firewall",services,"service")
		uci:set("firewall",services,"name",srvName)
		uci:set("firewall",services,"protocol",protocol)
		uci:set("firewall",services,"dFromPort",dFromPort)
		uci:set("firewall",services,"dToPort",dToPort)
		uci:set("firewall",services,"sFromPort",sFromPort)
		uci:set("firewall",services,"sToPort",sToPort)		
		]]--
		
		uci:set("firewall",rules,"firewall")
		uci:set("firewall",rules,"StatusEnable",enabled)
		uci:set("firewall",rules,"CurPos",rules_count)
		uci:set("firewall",rules,"type",fw_type)
		uci:set("firewall",rules,"service",services)
		uci:set("firewall",rules,"name",srvName)
		uci:set("firewall",rules,"protocol",protocol)
		uci:set("firewall",rules,"dFromPort",dFromPort)
		uci:set("firewall",rules,"dToPort",dToPort)
		uci:set("firewall",rules,"sFromPort",sFromPort)
		uci:set("firewall",rules,"sToPort",sToPort)
		uci:set("firewall",rules,"mac_address",mac_address)
		uci:set("firewall",rules,"wan",wan)
		uci:set("firewall",rules,"src_ip",sip_address)
		uci:set("firewall",rules,"local",lan)
		uci:set("firewall",rules,"dst_ip",dip_address)
		uci:set("firewall",rules,"time",fw_time)
		uci:set("firewall",rules,"target",target)	
	
		uci:set("firewall","general","rules_count",rules_count)
		uci:set("firewall","general","NextRulePos",NextRulePos)
		--uci:set("firewall","general","service_count",service_count)
		
		uci:commit("firewall")
		uci:apply("firewall")
			
	end
	
	
	if remove then
	
		local cur_num = remove
		local del_rule ="rule"..cur_num
		uci:delete("firewall",del_rule)
		
		-----firewall-----
		local rules_count = uci:get("firewall","general","rules_count")
		local NextRulePos = uci:get("firewall","general","NextRulePos")
		local num = rules_count-cur_num
		
		for i=num,1,-1 do
			local rules = "rule"..cur_num+1
			local new_rule = "rule"..cur_num
			local old_data = {}
			old_data=uci:get_all("firewall",rules)
			
			if old_data then
				uci:set("firewall",new_rule,"firewall")
				uci:tset("firewall",new_rule,old_data)
				uci:set("firewall",new_rule,"CurPos",cur_num)
				uci:commit("firewall")
				uci:delete("firewall",rules)
				uci:commit("firewall")
				cur_num =cur_num+1				
			end
		end	
		
		uci:set("firewall","general","rules_count",rules_count-1)
		uci:set("firewall","general","NextRulePos",NextRulePos-1)
		
		uci:commit("firewall")
		uci:apply("firewall")
	
	end

	luci.template.render("expert_configuration/fw_services")
end
--dipper firewall

--dipper nat
function nat()
	
	local apply = luci.http.formvalue("apply")
	
	if apply then
	
		local enabled = luci.http.formvalue("enabled")
		--local sessions_user = luci.http.formvalue("sessions_user")
		
		if not max_user then
			max_user=""
		end
			
		uci:set("nat","general","nat")
		uci:set("nat","general","nat",enabled)
		--uci:set("nat","general","sessions_user",sessions_user)
		uci:commit("nat")
		uci:apply("nat")
		
		--uci:set("nat_new","general_new","nat")
		--uci:set("nat_new","general_new","nat",enabled)
		--uci:set("nat_new","general_new","max_user",max_user)
		--uci:commit("nat_new")
		--uci:apply("nat_new")
		
	end

	luci.template.render("expert_configuration/nat")
end

--dipper content filter
function action_CF()

	local apply = luci.http.formvalue("apply")
	
	if apply then
	
		local IPAddress = luci.http.formvalue("websTrustedIPAddress")
		
		uci:set("parental","trust_ip","ipaddr",IPAddress)

		local Activex = luci.http.formvalue("websFilterActivex")
		local Java = luci.http.formvalue("websFilterJava")
		local Cookies = luci.http.formvalue("websFilterCookies")		
		local Proxy = luci.http.formvalue("websFilterProxy")
		
		if not Activex then Activex=0 end
		if not Java then Java=0 end 
		if not Cookies then Cookies=0 end 
		if not Proxy then Proxy=0 end 
		
		
		uci:set("parental","restrict_web","activeX",Activex)
		uci:set("parental","restrict_web","java",Java)
		uci:set("parental","restrict_web","cookies",Cookies)
		uci:set("parental","restrict_web","web_proxy",Proxy)
		
		local KeyWord_Enable = luci.http.formvalue("cfKeyWord_Enable")
		local url_str = luci.http.formvalue("url_str")
		
		if not KeyWord_Enable then KeyWord_Enable=0 end
		if not url_str  then url_str="" end 
		
		uci:set("parental","keyword","enable",KeyWord_Enable)
		uci:set("parental","keyword","keywords",url_str)		
		
		uci:commit("parental")
		uci:apply("parental")
		
	end

	luci.template.render("expert_configuration/ContentFilter")

end

-- MSTC, Sharon mark configuration->ddns
--[[
--Eten dynamic DNS
function action_ddns()
	local apply = luci.http.formvalue("apply")

	if apply then
		local provider = luci.http.formvalue("DDNSProvider")
		local update   = luci.http.formvalue("DDNSUpdate")
		local host     = luci.http.formvalue("DDNSHost")
		local user     = luci.http.formvalue("DDNSUser")
		local passwd   = luci.http.formvalue("DDNSPasswd")
		local wan_ip   = luci.http.formvalue("DDNSWANIP")
		local entry = nil

		uci:foreach("updatedd", "updatedd", function( section )
				entry = section[".name"]
				uci:set("updatedd", entry, "service", provider)
		end)

		if nil == entry then
			entry = uci:add("updatedd", "updatedd")
			uci:set("updatedd", entry, "service", provider)
		end

		if "enable" == update then
			uci:set("updatedd", entry, "update", "1")
		else
			uci:set("updatedd", entry, "update", "0")
		end

		uci:set("updatedd", entry, "host", host)
		uci:set("updatedd", entry, "username", user)
		uci:set("updatedd", entry, "password", passwd)

		if "wan_ip" == wan_ip then
			uci:set("updatedd", entry, "ip_source", "interface")
			local wan_interface = uci:get("network","wan","ifname")
			if wan_interface ~= nil then
				uci:set("updatedd", entry, "ip_network", wan_interface)
			end
			
		else
			uci:set("updatedd", entry, "ip_source", "network")
			uci:set("updatedd", entry, "ip_network", "wan")		
		end
		uci:save("updatedd")
		uci:commit("updatedd")
		uci:apply("updatedd")
	end

	luci.template.render("expert_configuration/ddns")
end
--Eten END
--]]
--
--Eten Static Route
function action_static_route()
	local apply = luci.http.formvalue("apply")
	local delete = luci.http.formvalue("delete")
	local submitType = luci.http.formvalue("SRSubmitType")

	if apply then
		if "edit" == submitType then
			local editID = luci.http.formvalue("SREditID")
			local enable = luci.http.formvalue("SREditRadio")
			local name   = luci.http.formvalue("SREditName")
			local dest   = luci.http.formvalue("SREditDest")
			local mask   = luci.http.formvalue("SREditMask")
			local gw     = luci.http.formvalue("SREditGW")
			local entryName = nil

			if "New" == editID then
				editID = uci:get("route", "general", "routes_count") + 1
				uci:set("route", "general", "routes_count", editID)
				entryName = "route" .. editID
				uci:set("route", entryName, "route")
				uci:set("route", entryName, "new", "1")
			else
				entryName = editID
				uci:set("route", entryName, "edit", "1")
				uci:set("route", entryName, "dest_ip_old", uci:get("route", entryName, "dest_ip"))
				uci:set("route", entryName, "netmask_old", uci:get("route", entryName, "netmask"))
				uci:set("route", entryName, "gateway_old", uci:get("route", entryName, "gateway"))
				uci:set("route", entryName, "enable_old", uci:get("route", entryName, "enable"))
			end

			uci:set("route", entryName, "name", name)
			uci:set("route", entryName, "dest_ip", dest)
			uci:set("route", entryName, "netmask", mask)
			uci:set("route", entryName, "gateway", gw)
		
			if not ("enable" == enable) then
				uci:set("route", entryName, "enable", 0)
			else
				uci:set("route", entryName, "enable", 1)
			end

			uci:save("route")
			uci:commit("route")
			uci:apply("route")
		elseif "table" == submitType then

			local list = luci.http.formvalue("SRDeleteIDs")

			if not ( "" == list ) then
				local i, j = 0, 0

				while true do
				        j = string.find(list, ",", i + 1)
		        		if j == nil then break end
					uci:set("route", string.sub(list, i + 1, j - 1 ), "delete", "1")
				        i = j
				end

				uci:save("route")
				uci:commit("route")
				uci:apply("route")
			end

		end
	end
	
	if delete then
		uci:set("route", "route" .. delete, "delete", "1")
		uci:commit("route")
		uci:apply("route")
	end

	luci.template.render("expert_configuration/static_route")
end
--Eten Static Route END

function action_portfw()
	local new = luci.http.formvalue("new")
	local apply = luci.http.formvalue("apply")
	local add = luci.http.formvalue("add")
	local remove = luci.http.formvalue("remove")
	
	if new then	
		uci:revert("nat")
		--uci:revert("nat_new")
	end
	
	if apply then
		local serChange = luci.http.formvalue("serChange")
		local changeToSerIP = luci.http.formvalue("changeToSerIP")
		local last_changeToSerIP
		local changeToSer = 0		
		if (serChange=="change") then
			if not (changeToSerIP=="") then
				local changeToSer = 1
				uci:set("nat","general","changeToSer",changeToSer)
				uci:set("nat","general","changeToSerIP",changeToSerIP)

				--uci:set("nat_new","general_new","changeToSer",changeToSer)
				--uci:set("nat_new","general_new","changeToSerIP",changeToSerIP)
			end	
		else
			last_changeToSerIP = uci:get("nat","general","changeToSerIP")
			if last_changeToSerIP then
				uci:delete("nat","general","changeToSerIP")
				uci:set("nat","general","last_changeToSerIP",last_changeToSerIP)
				--uci:set("nat_new","general_new","last_changeToSerIP",last_changeToSerIP)
			end
			uci:set("nat","general","changeToSer",changeToSer)			
			--uci:set("nat_new","general_new","changeToSer",changeToSer)
			
		end	
		
		uci:commit("nat")
		uci:apply("nat")
		--uci:commit("nat_new")
		--uci:apply("nat_new")
	end	
	
	if add then
		local enabled = 1
		local srvIndex = luci.http.formvalue("srvIndex")
		local srvName,extPort,protocol = fetchProtocolInfo(srvIndex)
		
		if (protocol=="") then
			protocol = luci.http.formvalue("protocol")
		end
		
		local srvIp = luci.http.formvalue("srvIp")
		local wake_up = 1
		local wan = 1
		local wan_ip = "0.0.0.0"
		local rules_count = uci:get("nat","general","rules_count")
		local NextRulePos = uci:get("nat","general","NextRulePos")		
		rules_count = rules_count+1
		local rules = "rule"..rules_count	
		uci:set("nat",rules,"nat")		
		uci:set("nat",rules,"StatusEnable",enabled)
		uci:set("nat",rules,"CurPos",NextRulePos)
		uci:set("nat",rules,"service",srvName)
		uci:set("nat",rules,"service_idx",srvIndex)
		uci:set("nat",rules,"protocol",protocol)
		uci:set("nat",rules,"port",extPort)
		uci:set("nat",rules,"wan",wan)
		uci:set("nat",rules,"wan_ip",wan_ip)
		uci:set("nat",rules,"local_ip",srvIp)
		uci:set("nat",rules,"wake_up",wake_up)
		uci:set("nat","general","rules_count",rules_count)
		
		uci:save("nat")
		uci:commit("nat")
		uci:apply("nat")
		
		-- must reset remote management of WWW from port 80 to 8080 
		if srvIndex=="0" then
			local infIdx = uci:get("firewall", "remote_www", "interface")
			local cfgCheck = uci:get("firewall", "remote_www", "client_check")
			local remote_www_port = uci:get("firewall", "remote_www", "port")
			
			if remote_www_port=="80" then
				local infCmd  = ""
				local infDCmd = ""
				local addrCmd = ""
				
				if "2" == infIdx then
					-- LAN
					infCmd=" -i lan "
					if cfgCheck ~= "1" then
						infDCmd=" ! -i lan "
					end
				elseif "3" == infIdx then
					-- WAN LAN
					infCmd=" ! -i lan "
					if cfgCheck ~= "1" then
						infDCmd=" -i lan "
					end
				end
		
				if not ("0" == uci:get("firewall", "remote_www", "client_check")) then
					addrCmd=" -s " .. uci:get("firewall", "remote_www", "client_addr") .. " "
				end
		
				sys.exec("/usr/sbin/iptables -t filter -D INPUT " .. infCmd .. addrCmd .. " -p tcp --dport " .. uci:get("firewall", "remote_www", "port") .. " -j ACCEPT 2> /dev/null")
				sys.exec("/usr/sbin/iptables -t filter -D INPUT " .. infDCmd .. " -p tcp --dport " .. uci:get("firewall", "remote_www", "port") .. " -j DROP 2> /dev/null")
				
				uci:set("firewall", "remote_www", "port", 8080)
				uci:save("firewall")
				uci:commit("firewall")
				sys.exec("/etc/init.d/uhttpd restart 2>/dev/null")
			end
		end
		-- must reset remote management of Telnet from port 23 to 2323
		if srvIndex=="5" then 
			local remote_telnet_port = uci:get("firewall", "remote_telnet", "port")
			if remote_telnet_port=="23" then
				sys.exec("/etc/init.d/telnet stop 2>/dev/null")
				uci:set("firewall", "remote_telnet", "port", 2323)
				uci:save("firewall")
				uci:commit("firewall")
				sys.exec("/etc/init.d/telnet start 2>/dev/null")
			end
		end
		--[[
		-----nat_new-----
		local new_rule = 1
		local new_rules_count = uci:get("nat_new","general_new","rules_count")
		new_rules_count = new_rules_count+1
		local new_rules = "rule_new"..new_rules_count		
		
		uci:set("nat_new",new_rules,"nat")
		uci:set("nat_new",new_rules,"new_rule",new_rule)		
		uci:set("nat_new",new_rules,"CurPos",NextRulePos)
		uci:set("nat_new",new_rules,"service",srvName)
		uci:set("nat_new",new_rules,"port",extPort)
		uci:set("nat_new",new_rules,"wan",wan)
		uci:set("nat_new",new_rules,"wan_ip",wan_ip)
		uci:set("nat_new",new_rules,"local_ip",srvIp)
		uci:set("nat_new",new_rules,"StatusEnable",enabled)	
		uci:set("nat_new","general_new","rules_count",new_rules_count)
		uci:save("nat_new")
		uci:commit("nat_new")
		uci:apply("nat_new")		
				
		NextRulePos = NextRulePos+1
		uci:set("nat","general","NextRulePos",NextRulePos)
		uci:commit("nat")
		uci:apply("nat")
		]]--
	end		
	
	if remove then
		local del_rule = remove
		local rul_num = tonumber(string.match(del_rule,"%d+"))
		local cur_num = rul_num
		local rm_curpos = uci:get("nat",del_rule,"CurPos")
		local extPort = uci:get("nat",del_rule,"port")
		uci:delete("nat",del_rule)
		
		local rules_count = uci:get("nat","general","rules_count")
		local NextRulePos = uci:get("nat","general","NextRulePos")		
		local num = rules_count-cur_num
		
		for i=num,1,-1 do
			local rules = "rule"..cur_num+1
			local new_rule = "rule"..cur_num
			local old_data = {}
			old_data=uci:get_all("nat",rules)
			
			if old_data then				
				uci:set("nat",new_rule,"nat")
				uci:tset("nat",new_rule,old_data)
				
				local edit_CurPos=uci:get("nat",new_rule,"CurPos")				
				uci:set("nat",new_rule,"CurPos",edit_CurPos-1)

				uci:delete("nat",rules)
				uci:commit("nat")
				cur_num =cur_num+1				
			end
		end		
		uci:set("nat","general","rules_count",rules_count-1)
		uci:set("nat","general","NextRulePos",NextRulePos-1)
		uci:commit("nat")
		uci:apply("nat")
		
		-- must reset remote management of WWW from port 8080 to 80 
		if extPort=="80" then
			local infIdx = uci:get("firewall", "remote_www", "interface")
			local cfgCheck = uci:get("firewall", "remote_www", "client_check")
			local remote_www_port = uci:get("firewall", "remote_www", "port")
			
			if remote_www_port=="8080" then
				local infCmd  = ""
				local infDCmd = ""
				local addrCmd = ""
				
				if "2" == infIdx then
					-- LAN
					infCmd=" -i lan "
					if cfgCheck ~= "1" then
						infDCmd=" ! -i lan "
					end
				elseif "3" == infIdx then
					-- WAN LAN
					infCmd=" ! -i lan "
					if cfgCheck ~= "1" then
						infDCmd=" -i lan "
					end
				end
		
				if not ("0" == uci:get("firewall", "remote_www", "client_check")) then
					addrCmd=" -s " .. uci:get("firewall", "remote_www", "client_addr") .. " "
				end
		
				sys.exec("/usr/sbin/iptables -t filter -D INPUT " .. infCmd .. addrCmd .. " -p tcp --dport " .. uci:get("firewall", "remote_www", "port") .. " -j ACCEPT 2> /dev/null")
				sys.exec("/usr/sbin/iptables -t filter -D INPUT " .. infDCmd .. " -p tcp --dport " .. uci:get("firewall", "remote_www", "port") .. " -j DROP 2> /dev/null")
				
				uci:set("firewall", "remote_www", "port", 80)
				uci:save("firewall")
				uci:commit("firewall")
				sys.exec("/etc/init.d/uhttpd restart 2>/dev/null")
			end
		end
		-- must reset remote management of Telnet from port 2323 to 23
		if extPort=="23" then 
			local remote_telnet_port = uci:get("firewall", "remote_telnet", "port")
			if remote_telnet_port=="2323" then
				sys.exec("/etc/init.d/telnet stop 2>/dev/null")
				uci:set("firewall", "remote_telnet", "port", 23)
				uci:save("firewall")
				uci:commit("firewall")
				sys.exec("/etc/init.d/telnet start 2>/dev/null")
			end
		end
		
		--[[
		-----nat_new-----
		local delete_rule=1
		local new_rules_count = uci:get("nat_new","general_new","rules_count")
		new_rules_count = new_rules_count+1
		local new_rules = "rule_new"..new_rules_count
		
		uci:set("nat_new",new_rules,"nat")
		uci:set("nat_new",new_rules,"delete_rule",delete_rule)
		uci:set("nat_new",new_rules,"CurPos",rm_curpos)
		uci:set("nat_new","general_new","rules_count",new_rules_count)
		
		uci:commit("nat_new")
		uci:apply("nat_new")
		]]--
	end
	
	luci.template.render("expert_configuration/nat_application")
end

function action_portfw_edit()

	local apply = luci.http.formvalue("apply")
	local edit = luci.http.formvalue("edit")	
	
	if apply then
		local rules = luci.http.formvalue("rules")
		local enabled = luci.http.formvalue("enabled")		
		local srvIndex = luci.http.formvalue("srvIndex")
		local srvName,extPort,protocol = fetchServerInfo(srvIndex)
		local cfgPort = uci:get("nat",rules,"port")
		
		local srvIp = luci.http.formvalue("srvIp")
		local wake_up = luci.http.formvalue("wake_up")
		local url = luci.dispatcher.build_url("expert","configuration","network","nat","portfw")		
		local wan = 1
		local wan_ip = "0.0.0.0"
		local CurPos =uci:get("nat",rules,"CurPos")
		local NextRulePos = uci:get("nat","general","NextRulePos")
		local ori_StatusEnable=uci:get("nat",rules,"StatusEnable")
						
		if not wake_up then
			wake_up = 0
		end
		
		uci:set("nat",rules,"service",srvName)
		uci:set("nat",rules,"service_idx",srvIndex)
		uci:set("nat",rules,"port",extPort)
		uci:set("nat",rules,"protocol",protocol)
		uci:set("nat",rules,"wan",wan)
		uci:set("nat",rules,"wan_ip",wan_ip)
		uci:set("nat",rules,"local_ip",srvIp)
		uci:set("nat",rules,"wake_up",wake_up)

		local rules_count = uci:get("nat","general","rules_count")
		local rul_num = tonumber(string.match(rules,"%d+"))
		local cur_num = rul_num
		local edit_rules
		local edit_rules_curpos
		if enabled=="0" then
			uci:set("nat",rules,"StatusEnable",enabled)
			if not (ori_StatusEnable==enabled) then							
				for i=rules_count,1,-1 do
					cur_num = cur_num+1
					edit_rules="rule"..cur_num
					edit_rules_curpos = uci:get("nat",edit_rules,"CurPos")
					if edit_rules_curpos then					
						uci:set("nat",edit_rules,"CurPos",edit_rules_curpos-1)
					end
				end
				uci:set("nat","general","NextRulePos",NextRulePos-1)
			end
		elseif enabled=="1" then
			uci:set("nat",rules,"StatusEnable",enabled)
			if not (ori_StatusEnable==enabled) then
				for i=rules_count,1,-1 do
					cur_num = cur_num+1
					edit_rules="rule"..cur_num
					edit_rules_curpos = uci:get("nat",edit_rules,"CurPos")
					if edit_rules_curpos then					
						uci:set("nat",edit_rules,"CurPos",edit_rules_curpos+1)
					end
				end
				uci:set("nat","general","NextRulePos",NextRulePos+1)				
			end
			
		end
		
		uci:commit("nat")		
		uci:apply("nat")
		
		-- must reset remote management of WWW from port 80 to 8080 
		if extPort==80 and cfgPort~="80" then
			local infIdx = uci:get("firewall", "remote_www", "interface")
			local cfgCheck = uci:get("firewall", "remote_www", "client_check")
			local remote_www_port = uci:get("firewall", "remote_www", "port")
			
			if remote_www_port=="80" then
				local infCmd  = ""
				local infDCmd = ""
				local addrCmd = ""
				
				if "2" == infIdx then
					-- LAN
					infCmd=" -i lan "
					if cfgCheck ~= "1" then
						infDCmd=" ! -i lan "
					end
				elseif "3" == infIdx then
					-- WAN LAN
					infCmd=" ! -i lan "
					if cfgCheck ~= "1" then
						infDCmd=" -i lan "
					end
				end
		
				if not ("0" == uci:get("firewall", "remote_www", "client_check")) then
					addrCmd=" -s " .. uci:get("firewall", "remote_www", "client_addr") .. " "
				end
		
				sys.exec("/usr/sbin/iptables -t filter -D INPUT " .. infCmd .. addrCmd .. " -p tcp --dport " .. uci:get("firewall", "remote_www", "port") .. " -j ACCEPT 2> /dev/null")
				sys.exec("/usr/sbin/iptables -t filter -D INPUT " .. infDCmd .. " -p tcp --dport " .. uci:get("firewall", "remote_www", "port") .. " -j DROP 2> /dev/null")
				
				uci:set("firewall", "remote_www", "port", 8080)
				uci:save("firewall")
				uci:commit("firewall")
				sys.exec("/etc/init.d/uhttpd restart 2>/dev/null")
			end
		end
		-- must reset remote management of Telnet from port 23 to 2323
		if extPort==23 and cfgPort~="23" then 
			local remote_telnet_port = uci:get("firewall", "remote_telnet", "port")
			if remote_telnet_port=="23" then
				sys.exec("/etc/init.d/telnet stop 2>/dev/null")
				uci:set("firewall", "remote_telnet", "port", 2323)
				uci:save("firewall")
				uci:commit("firewall")
				sys.exec("/etc/init.d/telnet start 2>/dev/null")
			end
		end
		
		-- must reset remote management of WWW from port 8080 to 80
		if cfgPort=="80" and extPort~=80 then
			local infIdx = uci:get("firewall", "remote_www", "interface")
			local cfgCheck = uci:get("firewall", "remote_www", "client_check")
			local remote_www_port = uci:get("firewall", "remote_www", "port")
			
			if remote_www_port=="8080" then
				local infCmd  = ""
				local infDCmd = ""
				local addrCmd = ""
				
				if "2" == infIdx then
					-- LAN
					infCmd=" -i lan "
					if cfgCheck ~= "1" then
						infDCmd=" ! -i lan "
					end
				elseif "3" == infIdx then
					-- WAN LAN
					infCmd=" ! -i lan "
					if cfgCheck ~= "1" then
						infDCmd=" -i lan "
					end
				end
		
				if not ("0" == uci:get("firewall", "remote_www", "client_check")) then
					addrCmd=" -s " .. uci:get("firewall", "remote_www", "client_addr") .. " "
				end
		
				sys.exec("/usr/sbin/iptables -t filter -D INPUT " .. infCmd .. addrCmd .. " -p tcp --dport " .. uci:get("firewall", "remote_www", "port") .. " -j ACCEPT 2> /dev/null")
				sys.exec("/usr/sbin/iptables -t filter -D INPUT " .. infDCmd .. " -p tcp --dport " .. uci:get("firewall", "remote_www", "port") .. " -j DROP 2> /dev/null")
				
				uci:set("firewall", "remote_www", "port", 80)
				uci:save("firewall")
				uci:commit("firewall")
				sys.exec("/etc/init.d/uhttpd restart 2>/dev/null")
			end
		end
		-- must reset remote management of Telnet from port 2323 to 23
		if cfgPort=="23" and extPort~=23 then 
			local remote_telnet_port = uci:get("firewall", "remote_telnet", "port")
			if remote_telnet_port=="2323" then
				sys.exec("/etc/init.d/telnet stop 2>/dev/null")
				uci:set("firewall", "remote_telnet", "port", 23)
				uci:save("firewall")
				uci:commit("firewall")
				sys.exec("/etc/init.d/telnet start 2>/dev/null")
			end
		end

		--[[
		-----nat_new-----		
		local new_rules_count = uci:get("nat_new","general_new","rules_count")
		new_rules_count = new_rules_count+1
		local new_rules = "rule_new"..new_rules_count
		if enabled=="0" then
			if not (ori_StatusEnable==enabled) then
				local delete_rule = 1								
				uci:set("nat_new",new_rules,"nat")
				uci:set("nat_new",new_rules,"delete_rule",delete_rule)
				uci:set("nat_new",new_rules,"CurPos",CurPos)
				uci:set("nat_new","general_new","rules_count",new_rules_count)
			end
		else
			if not (ori_StatusEnable==enabled) then
				local insert_rule = 1
				uci:set("nat_new",new_rules,"nat")
				uci:set("nat_new",new_rules,"insert_rule",insert_rule)
				uci:set("nat_new",new_rules,"service",srvName)
				uci:set("nat_new",new_rules,"port",extPort)
				uci:set("nat_new",new_rules,"wan",wan)
				uci:set("nat_new",new_rules,"wan_ip",wan_ip)
				uci:set("nat_new",new_rules,"local_ip",srvIp)			
				uci:set("nat_new",new_rules,"CurPos",CurPos)
				uci:set("nat_new","general_new","rules_count",new_rules_count)
			else
				local edit_rule = 1
				uci:set("nat_new",new_rules,"nat")
				uci:set("nat_new",new_rules,"edit_rule",edit_rule)
				uci:set("nat_new",new_rules,"service",srvName)
				uci:set("nat_new",new_rules,"port",extPort)
				uci:set("nat_new",new_rules,"wan",wan)
				uci:set("nat_new",new_rules,"wan_ip",wan_ip)
				uci:set("nat_new",new_rules,"local_ip",srvIp)
				uci:set("nat_new",new_rules,"CurPos",CurPos)
				uci:set("nat_new","general_new","rules_count",new_rules_count)		
			end
		end
		
		uci:commit("nat_new")		
		uci:apply("nat_new")
		]]--
		luci.http.redirect(url)		
	end	
	
	if edit then
		local rules = edit
		local enabled = uci:get("nat",rules,"StatusEnable")
		local protocol = uci:get("nat",rules,"protocol")
		local extPort = uci:get("nat",rules,"port")		
		local srvName = uci:get("nat",rules,"service")
		local srvIdx = uci:get("nat",rules,"service_idx")
		local srvIp = uci:get("nat",rules,"local_ip")
		local wake_up = uci:get("nat",rules,"wake_up")		
		local url = luci.dispatcher.build_url("expert","configuration","network","nat","portfw","portfw_edit")
		
		luci.http.redirect(url .. "?" .. "service_name=" .. srvName .. "&rules=" .. rules .. "&enabled=" .. enabled .. "&protocol=" .. protocol .. "&srvIdx=" .. srvIdx .. "&external_port=" .. extPort .. "&server_ip=" .. srvIp .. "&wake_up=" .. wake_up .. "&rt=" .. 1 .. "&errmsg=test!!")
		return
	end

	luci.template.render("expert_configuration/nat_application_edit")
end


function port_trigger()

	local apply = luci.http.formvalue("apply")
	
	if apply then		
	
		local trigger_named
		local inComing_port_start
		local inComing_port_end
		local trigger_port_start
		local trigger_port_end		
		local preInfo

		
			--if not (luci.http.formvalue("trigger_name1") == "") then
			trigger_named = luci.http.formvalue("trigger_name1")
			inComing_port_start = luci.http.formvalue("inComing_port_start1")
			inComing_port_end = luci.http.formvalue("inComing_port_end1")
			trigger_port_start = luci.http.formvalue("trigger_port_start1")
			trigger_port_end = luci.http.formvalue("trigger_port_end1")	
			preName = luci.http.formvalue("preData1")
			if preName=="" then
				if not (trigger_named == "") then
					port_trigger_add(trigger_named,inComing_port_start,inComing_port_end,trigger_port_start,trigger_port_end,preName)
				end
			else
				if (trigger_named == "") then trigger_named=" " end
					port_trigger_add(trigger_named,inComing_port_start,inComing_port_end,trigger_port_start,trigger_port_end,preName)
			end
			-- ------------------------------------------------------------------------------------------------------
			--if not (luci.http.formvalue("trigger_name2") == "") then
			trigger_named = luci.http.formvalue("trigger_name2")
			inComing_port_start = luci.http.formvalue("inComing_port_start2")
			inComing_port_end = luci.http.formvalue("inComing_port_end2")
			trigger_port_start = luci.http.formvalue("trigger_port_start2")
			trigger_port_end = luci.http.formvalue("trigger_port_end2")	
			preName = luci.http.formvalue("preData2")
			if preName=="" then
				if not (trigger_named == "") then
					port_trigger_add(trigger_named,inComing_port_start,inComing_port_end,trigger_port_start,trigger_port_end,preName)
				end
			else
				if (trigger_named == "") then trigger_named=" " end
					port_trigger_add(trigger_named,inComing_port_start,inComing_port_end,trigger_port_start,trigger_port_end,preName)
			end
			-- ------------------------------------------------------------------------------------------------------
			--if not (luci.http.formvalue("trigger_name3") == "") then
			trigger_named = luci.http.formvalue("trigger_name3")
			inComing_port_start = luci.http.formvalue("inComing_port_start3")
			inComing_port_end = luci.http.formvalue("inComing_port_end3")
			trigger_port_start = luci.http.formvalue("trigger_port_start3")
			trigger_port_end = luci.http.formvalue("trigger_port_end3")
			preName = luci.http.formvalue("preData3")
			if preName=="" then
				if not (trigger_named == "") then
					port_trigger_add(trigger_named,inComing_port_start,inComing_port_end,trigger_port_start,trigger_port_end,preName)
				end
			else
				if (trigger_named == "") then trigger_named=" " end
					port_trigger_add(trigger_named,inComing_port_start,inComing_port_end,trigger_port_start,trigger_port_end,preName)
			end
			-- ------------------------------------------------------------------------------------------------------
			--if not (luci.http.formvalue("trigger_name4") == "") then
			trigger_named = luci.http.formvalue("trigger_name4")
			inComing_port_start = luci.http.formvalue("inComing_port_start4")
			inComing_port_end = luci.http.formvalue("inComing_port_end4")
			trigger_port_start = luci.http.formvalue("trigger_port_start4")
			trigger_port_end = luci.http.formvalue("trigger_port_end4")
			preName = luci.http.formvalue("preData4")
			if preName=="" then
				if not (trigger_named == "") then
					port_trigger_add(trigger_named,inComing_port_start,inComing_port_end,trigger_port_start,trigger_port_end,preName)
				end
			else
				if (trigger_named == "") then trigger_named=" " end
					port_trigger_add(trigger_named,inComing_port_start,inComing_port_end,trigger_port_start,trigger_port_end,preName)
			end
			-- ------------------------------------------------------------------------------------------------------
			--if not (luci.http.formvalue("trigger_name5") == "") then
			trigger_named = luci.http.formvalue("trigger_name5")
			inComing_port_start = luci.http.formvalue("inComing_port_start5")
			inComing_port_end = luci.http.formvalue("inComing_port_end5")
			trigger_port_start = luci.http.formvalue("trigger_port_start5")
			trigger_port_end = luci.http.formvalue("trigger_port_end5")
			preName = luci.http.formvalue("preData5")
			if preName=="" then
				if not (trigger_named == "") then
					port_trigger_add(trigger_named,inComing_port_start,inComing_port_end,trigger_port_start,trigger_port_end,preName)
				end
			else
				if (trigger_named == "") then trigger_named=" " end
					port_trigger_add(trigger_named,inComing_port_start,inComing_port_end,trigger_port_start,trigger_port_end,preName)
			end
			-- ------------------------------------------------------------------------------------------------------
			--if not (luci.http.formvalue("trigger_name6") == "") then
			trigger_named = luci.http.formvalue("trigger_name6")
			inComing_port_start = luci.http.formvalue("inComing_port_start6")
			inComing_port_end = luci.http.formvalue("inComing_port_end6")
			trigger_port_start = luci.http.formvalue("trigger_port_start6")
			trigger_port_end = luci.http.formvalue("trigger_port_end6")
			preName = luci.http.formvalue("preData6")
			if preName=="" then
				if not (trigger_named == "") then
					port_trigger_add(trigger_named,inComing_port_start,inComing_port_end,trigger_port_start,trigger_port_end,preName)
				end
			else
				if (trigger_named == "") then trigger_named=" " end
					port_trigger_add(trigger_named,inComing_port_start,inComing_port_end,trigger_port_start,trigger_port_end,preName)
			end
			-- ------------------------------------------------------------------------------------------------------
			--if not (luci.http.formvalue("trigger_name7") == "") then
			trigger_named = luci.http.formvalue("trigger_name7")
			inComing_port_start = luci.http.formvalue("inComing_port_start7")
			inComing_port_end = luci.http.formvalue("inComing_port_end7")
			trigger_port_start = luci.http.formvalue("trigger_port_start7")
			trigger_port_end = luci.http.formvalue("trigger_port_end7")
			preName = luci.http.formvalue("preData7")
			if preName=="" then
				if not (trigger_named == "") then
					port_trigger_add(trigger_named,inComing_port_start,inComing_port_end,trigger_port_start,trigger_port_end,preName)
				end
			else
				if (trigger_named == "") then trigger_named=" " end
					port_trigger_add(trigger_named,inComing_port_start,inComing_port_end,trigger_port_start,trigger_port_end,preName)
			end
			-- ------------------------------------------------------------------------------------------------------
			--if not (luci.http.formvalue("trigger_name8") == "") then
			trigger_named = luci.http.formvalue("trigger_name8")
			inComing_port_start = luci.http.formvalue("inComing_port_start8")
			inComing_port_end = luci.http.formvalue("inComing_port_end8")
			trigger_port_start = luci.http.formvalue("trigger_port_start8")
			trigger_port_end = luci.http.formvalue("trigger_port_end8")
			preName = luci.http.formvalue("preData8")
			if preName=="" then
				if not (trigger_named == "") then
					port_trigger_add(trigger_named,inComing_port_start,inComing_port_end,trigger_port_start,trigger_port_end,preName)
				end
			else
				if (trigger_named == "") then trigger_named=" " end
					port_trigger_add(trigger_named,inComing_port_start,inComing_port_end,trigger_port_start,trigger_port_end,preName)
			end
			-- ------------------------------------------------------------------------------------------------------
			--if not (luci.http.formvalue("trigger_name9") == "") then
			trigger_named = luci.http.formvalue("trigger_name9")
			inComing_port_start = luci.http.formvalue("inComing_port_start9")
			inComing_port_end = luci.http.formvalue("inComing_port_end9")
			trigger_port_start = luci.http.formvalue("trigger_port_start9")
			trigger_port_end = luci.http.formvalue("trigger_port_end9")
			preName = luci.http.formvalue("preData9")			
			if preName=="" then
				if not (trigger_named == "") then
					port_trigger_add(trigger_named,inComing_port_start,inComing_port_end,trigger_port_start,trigger_port_end,preName)
				end
			else
				if (trigger_named == "") then trigger_named=" " end
					port_trigger_add(trigger_named,inComing_port_start,inComing_port_end,trigger_port_start,trigger_port_end,preName)
			end
			-- ------------------------------------------------------------------------------------------------------
			--if not (luci.http.formvalue("trigger_name10") == "") then
			trigger_named = luci.http.formvalue("trigger_name10")
			inComing_port_start = luci.http.formvalue("inComing_port_start10")
			inComing_port_end = luci.http.formvalue("inComing_port_end10")
			trigger_port_start = luci.http.formvalue("trigger_port_start10")
			trigger_port_end = luci.http.formvalue("trigger_port_end10")
			preName = luci.http.formvalue("preData10")			
			if preName=="" then
				if not (trigger_named == "") then
					port_trigger_add(trigger_named,inComing_port_start,inComing_port_end,trigger_port_start,trigger_port_end,preName)
				end
			else
				if (trigger_named == "") then trigger_named=" " end
					port_trigger_add(trigger_named,inComing_port_start,inComing_port_end,trigger_port_start,trigger_port_end,preName)
			end
			-- ------------------------------------------------------------------------------------------------------
			--if not (luci.http.formvalue("trigger_name11") == "") then
			trigger_named = luci.http.formvalue("trigger_name11")
			inComing_port_start = luci.http.formvalue("inComing_port_start11")
			inComing_port_end = luci.http.formvalue("inComing_port_end11")
			trigger_port_start = luci.http.formvalue("trigger_port_start11")
			trigger_port_end = luci.http.formvalue("trigger_port_end11")
			preName = luci.http.formvalue("preData11")			
			if preName=="" then
				if not (trigger_named == "") then
					port_trigger_add(trigger_named,inComing_port_start,inComing_port_end,trigger_port_start,trigger_port_end,preName)
				end
			else
				if (trigger_named == "") then trigger_named=" " end
					port_trigger_add(trigger_named,inComing_port_start,inComing_port_end,trigger_port_start,trigger_port_end,preName)
			end
			-- ------------------------------------------------------------------------------------------------------
			--if not (luci.http.formvalue("trigger_name12") == "") then
			trigger_named = luci.http.formvalue("trigger_name12")
			inComing_port_start = luci.http.formvalue("inComing_port_start12")
			inComing_port_end = luci.http.formvalue("inComing_port_end12")
			trigger_port_start = luci.http.formvalue("trigger_port_start12")
			trigger_port_end = luci.http.formvalue("trigger_port_end12")
			preName = luci.http.formvalue("preData12")
			if preName=="" then
				if not (trigger_named == "") then
					port_trigger_add(trigger_named,inComing_port_start,inComing_port_end,trigger_port_start,trigger_port_end,preName)
				end
			else
				if (trigger_named == "") then trigger_named=" " end
					port_trigger_add(trigger_named,inComing_port_start,inComing_port_end,trigger_port_start,trigger_port_end,preName)
			end
			-- ------------------------------------------------------------------------------------------------------	
			
	end

	luci.template.render("expert_configuration/nat_advance")
end

function port_trigger_add(trigger_named,inComing_port_start,inComing_port_end,trigger_port_start,trigger_port_end,preName)
		
		if not (preName=="") then 
			if not (trigger_named==preName) then
				uci:delete("portTrigger",preName)
				uci:commit("portTrigger")
			end
		end
		
		local section = uci:get("portTrigger",trigger_named)
		
		if not section then
			uci:set("portTrigger",trigger_named,"trigger")
		end			
		
		uci:set("portTrigger",trigger_named,"inComing_port_start",inComing_port_start)
		uci:set("portTrigger",trigger_named,"inComing_port_end",inComing_port_end)
		uci:set("portTrigger",trigger_named,"trigger_port_start",trigger_port_start)
		uci:set("portTrigger",trigger_named,"trigger_port_end",trigger_port_end)
		uci:commit("portTrigger")
		uci:apply("portTrigger")
end


function fetchProtocolInfo(num)

local protNam
local portNumb
local protocol

	if num=="0" then
		protNam="WWW"
		portNumb=80
		protocol="tcpandudp"
	elseif num=="1" then
		protNam="HTTPS"
		portNumb=443
		protocol="tcp"
	elseif num=="2" then
		protNam="FTP"
		portNumb=21
		protocol="tcp"
	elseif num=="3" then
		protNam="SMTP"
		portNumb=25
		protocol="tcp"
	elseif num=="4" then
		protNam="POP3"
		portNumb=110
		protocol="tcp"
	elseif num=="5" then
		protNam="Telnet"
		portNumb=23
		protocol="tcp"
	elseif num=="6" then
		protNam="NetMeeting"
		portNumb=1720
		protocol="tcp"
	elseif num=="7" then
		protNam="PPTP"
		portNumb=1723
		protocol="tcpandudp"
	elseif num=="8" then
		protNam="IPSec"
		portNumb=500
		protocol="udp"
	elseif num=="9" then
		protNam="SIP"
		portNumb=5060
		protocol="tcpandudp"
	elseif num=="10" then
		protNam="TFTP"
		portNumb=69
		protocol="udp"
	elseif num=="11" then
		protNam="Real-Audio"
		portNumb=554
		protocol="tcpandudp"
	elseif num=="12" then
		protNam=luci.http.formvalue("srvName")
		portNumb=luci.http.formvalue("srvPort")
		protocol=luci.http.formvalue("protocol")
	else 
		protNam=""
		portNumb=0
		protocol=""
	end
	
	return protNam,portNumb,protocol
end

function fetchServerInfo(srvidx)

local protNam
local portNumb
local protocol

	if srvidx=="0" then
		protNam="WWW"
		portNumb=80
		protocol="tcpandudp"
	elseif srvidx=="1" then
		protNam="HTTPS"
		portNumb=443
		protocol="tcp"
	elseif srvidx=="2" then
		protNam="FTP"
		portNumb=21
		protocol="tcp"
	elseif srvidx=="3" then
		protNam="SMTP"
		portNumb=25
		protocol="tcp"
	elseif srvidx=="4" then
		protNam="POP3"
		portNumb=110
		protocol="tcp"
	elseif srvidx=="5" then
		protNam="Telnet"
		portNumb=23
		protocol="tcp"
	elseif srvidx=="6" then
		protNam="NetMeeting"
		portNumb=1720
		protocol="tcp"
	elseif srvidx=="7" then
		protNam="PPTP"
		portNumb=1723
		protocol="tcpandudp"
	elseif srvidx=="8" then
		protNam="IPSec"
		portNumb=500
		protocol="udp"
	elseif srvidx=="9" then
		protNam="SIP"
		portNumb=5060
		protocol="tcpandudp"
	elseif srvidx=="10" then
		protNam="TFTP"
		portNumb=69
		protocol="udp"
	elseif srvidx=="11" then
		protNam="Real-Audio"
		portNumb=554
		protocol="tcpandudp"
	elseif srvidx=="12" then
		protNam=luci.http.formvalue("srvName")
		portNumb=luci.http.formvalue("extPort")
		protocol=luci.http.formvalue("protocol")
	else 
		portNumb=0
		protocol=""
	end
	
	return protNam,portNumb,protocol
end
--dipper nat

--benson dhcp
function action_dhcpSetup()
        --local apply = luci.http.formvalue("sysSubmit")
		local apply = luci.http.formvalue("DHCPSubmit")
        if apply then
                local ignore = luci.http.formvalue("ssid_state")
                local startAddress = luci.http.formvalue("startAdd")
                local poolSize = luci.http.formvalue("poolSize")
                local start=string.match(startAddress,"%d+.%d+.%d+.(%d+)")
                uci:set("dhcp","lan","dhcp")
                uci:set("dhcp","lan",'ignore',ignore)
                uci:set("dhcp","lan",'start',start)
                uci:set("dhcp","lan",'limit',poolSize)

                uci:commit("dhcp")
                uci:apply("dhcp")
				
		-- marco, add for reload dnsmasq
		sys.exec("/etc/init.d/dnsmasq stop 2>/dev/null")
                sys.exec("/etc/init.d/dnsmasq start 2>/dev/null")
        end

        luci.template.render("expert_configuration/lan_dhcp_setup")
end

function action_dhcpStatic()
        local apply = luci.http.formvalue("sysSubmit")
        if apply then
				local staticipMAX = uci:get("dhcp","lan","staticipMAX")
				if staticipMAX == nil then
					staticipMAX=8
				end
				local dhcp_static_mac={}
				local dhcp_static_ip={}
				for i = 1,staticipMAX do
					local mac_formvalue="dhcp_static_mac"..i
					local ip_formvalue="dhcp_static_ip"..i
					dhcp_static_mac[i]=luci.http.formvalue(mac_formvalue)
					dhcp_static_ip[i]=luci.http.formvalue(ip_formvalue)

						local entry=nil
						local mac_name="Static_DHCP_IP"..i
						uci:foreach("dhcp", "host", function( section )	

							if section.name == mac_name then
								entry = section[".name"]				
							end
						end)
						
						if dhcp_static_ip[i] ~= "0.0.0.0" and dhcp_static_mac[i]~= "00:00:00:00:00:00" then
							if nil == entry then
								entry = uci:add("dhcp", "host")
								uci:set("dhcp", entry, "name", mac_name)
							end
							uci:set("dhcp", entry, "mac", dhcp_static_mac[i])
							uci:set("dhcp", entry, "ip", dhcp_static_ip[i])
						else
							if entry ~= nil then
								uci:delete("dhcp", entry)
							end
						end						
			
				end
				uci:save("dhcp")

                local sysFirstDNSAddr = luci.http.formvalue("sysFirDNSAddr")
                local sysSecondDNSAddr = luci.http.formvalue("sysSecDNSAddr")
                local sysThirdDNSAddr = luci.http.formvalue("sysThirdDNSAddr")

		local lan_domainName = uci.get("system","main","domain_name")

                local file2 = io.open( "/etc/dnsmasq.conf", "w" )
                file2:write("# filter what we send upstream\n")
                file2:write("# domain-needed\n")
                file2:write("# bogus-priv\n")
                file2:write("filterwin2k\n")
                file2:write("localise-queries\n")
                file2:write("\n")
                file2:write("# allow /etc/hosts and dhcp lookups via *.lan\n")
                file2:write("local=/lan/\n")
                file2:write("domain=" .. lan_domainName .. "\n")
                file2:write("expand-hosts\n")
                file2:write("resolv-file=/tmp/resolv.conf.auto\n")
                file2:write("\n")
                file2:write("dhcp-authoritative\n")
                file2:write("dhcp-leasefile=/tmp/dhcp.leases\n")
                file2:write("\n")
                file2:write("# use /etc/ethers for static hosts; same format as --dhcp-host\n")
                file2:write("# <hwaddr> <ipaddr>\n")
                file2:write("read-ethers\n")
                file2:write("\n")
                file2:write("# other useful options:\n")
                file2:write("# default route(s): dhcp-option=3,192.168.1.1,192.168.1.2\n")
                file2:write("#    dns server(s): dhcp-option=6,192.168.1.1,192.168.1.2\n")
                file2:write("dhcp-option=6," .. sysFirstDNSAddr .. "," .. sysSecondDNSAddr .. "," .. sysThirdDNSAddr .."\n")
                file2:close()

		local lan_dns=""
		local d1= luci.http.formvalue("LAN_FirstDNS")
		if d1 == "00000000" then
			lan_dns=lan_dns .. "FromISP,"
		elseif d1 == "00000001"  then
			lan_dns=lan_dns .. sysFirstDNSAddr .. ","
		elseif d1 == "00000003"  then
			lan_dns=lan_dns .. "None,"
		else
			lan_dns=lan_dns .. "dnsRelay,"
		end

		local d2= luci.http.formvalue("LAN_SecondDNS")
		if d2 == "00000000" then
			lan_dns=lan_dns .. "FromISP,"
		elseif d2 == "00000001"  then
			lan_dns=lan_dns .. sysSecondDNSAddr .. ","
		elseif d2 == "00000003"  then
			lan_dns=lan_dns .. "None,"
		else
			lan_dns=lan_dns .. "dnsRelay,"
		end

		local d3= luci.http.formvalue("LAN_ThirdDNS")
		if d3 == "00000000" then
			lan_dns=lan_dns .. "FromISP"
		elseif d3 == "00000001"  then
			lan_dns=lan_dns .. sysThirdDNSAddr
		elseif d3 == "00000003"  then
			lan_dns=lan_dns .. "None"
		else
			lan_dns=lan_dns .. "dnsRelay"
		end

		uci:set("dhcp","lan","dhcp")
		uci:set("dhcp","lan",'lan_dns',lan_dns)
		uci:commit("dhcp")
		uci:apply("dhcp")

                sys.exec("/etc/init.d/dnsmasq stop 2>/dev/null")
                sys.exec("/etc/init.d/dnsmasq start 2>/dev/null")
        end
        luci.template.render("expert_configuration/LAN_IPStatic")
end

function action_clientList()
	local apply = luci.http.formvalue("sysSubmit")
 	if apply then
		local staticipMAX = uci:get("dhcp","lan","staticipMAX")
		if staticipMAX == nil then
			staticipMAX=8
		end
		local macList= string.split(tostring(luci.http.formvalue("mac_List")),";")
		local ipList= string.split(tostring(luci.http.formvalue("ip_List")),";")
		local checkList= string.split(tostring(luci.http.formvalue("check_List")),";")
		
		local macArray = {}
		local ipArray = {}
		local checkArray = {}
		
		for index,info in pairs(macList) do
			macArray[index]=info
		end
		for index,info in pairs(ipList) do
			ipArray[index]=info
		end	
		for index,info in pairs(checkList) do
			checkArray[index]=info
		end			
		
		for i = 1,#macList do
			local entry=nil
			uci:foreach("dhcp", "host", function( section )
				if section.mac == macArray[i] then
					entry = section[".name"]				
				end
			end)
			
			if entry ~= nil then
				if checkArray[i] == "1" then
					uci:set("dhcp", entry, "ip", ipArray[i])					
				else
					uci:delete("dhcp", entry)
				end
			else
				if checkArray[i] == "1" then
					for k = 1,staticipMAX do
						local empty_entry=nil
						local mac_name="Static_DHCP_IP"..k
						uci:foreach("dhcp", "host", function( section2 )

							if section2.name == mac_name then
								empty_entry = section2[".name"]				
							end
						end)
						if  nil== empty_entry then
							empty_entry = uci:add("dhcp", "host")
							uci:set("dhcp", empty_entry, "name", mac_name)
							uci:set("dhcp", empty_entry, "mac", macArray[i])
							uci:set("dhcp", empty_entry, "ip", ipArray[i])
							break
						end
					end
				end
			end
		end
		uci:save("dhcp")
		uci:commit("dhcp")
		uci:apply("dhcp")

	end

	luci.template.render("expert_configuration/LAN_DHCPTbl_1")
end
--benson dhcp

-- Enter lte
function action_lte_sim()
	local apply = luci.http.formvalue("sysSubmit")
	
	if apply then
		local sim_status = luci.http.formvalue("sim_status")
		local enablePIN = luci.http.formvalue("enablePIN")
		local ltePin = luci.http.formvalue("ltePin")
		local ltePuk = luci.http.formvalue("ltePuk")
		local lteModification = luci.http.formvalue("lteModification")
		local lteOldPin = luci.http.formvalue("lteOldPin")
		local lteNewPin = luci.http.formvalue("lteNewPin")
		
	-- PIN disabled
		if sim_status == "SIM_PIN_DISABLE" then 
			if enablePIN == "1" then -- Select Enable for PIN Verification
				sys.exec("sim_maintain.sh set_pin "..ltePin.." 1")
			end
	-- PIN required			
		elseif sim_status == "CELL_DEVST_SIM_PIN" then
			sys.exec("sim_maintain.sh verify_pin "..ltePin)			
	-- PIN verified		
		elseif sim_status == "CELL_DEVST_SIM_RDY" then
			if enablePIN == "1" then -- Select Enable for PIN Verification or the default for PIN Verification in the PIN verified status
				if lteModification == "1" then -- Selecte Modification
					sys.exec("sim_maintain.sh change_pin "..lteOldPin.." "..lteNewPin)
				end
			else -- Select Disable for PIN Verification
				sys.exec("sim_maintain.sh set_pin "..ltePin.." 0")
			end
	-- PIN locked		
		elseif sim_status == "CELL_DEVST_SIM_PUK" then
			sys.exec("sim_maintain.sh unblock_pin "..ltePuk.." "..lteNewPin)
		end
	end

	luci.template.render("expert_configuration/sim")
end

function action_lte_apn()
	luci.template.render("expert_configuration/apn_application")
end

function action_apn_edit()
	local edit = luci.http.formvalue("edit")
	local apply = luci.http.formvalue("APNSubmit")
	
	if apply then
		local rules = luci.http.formvalue("rules")
		local enabled = luci.http.formvalue("APNenabled")
		local cid_Name = luci.http.formvalue("cid_Name")
		local apn_type = luci.http.formvalue("_apn_type")
		local apn = luci.http.formvalue("apn")
		local auto_apn = luci.http.formvalue("_auto_apn")
		local auth = luci.http.formvalue("_auth")
		local username = luci.http.formvalue("username")
		local password = luci.http.formvalue("password")
		local url = luci.dispatcher.build_url("expert","configuration","lte","APN")
		
		uci:set("wanconfig","pdp"..rules,"name",cid_Name)
		uci:set("wanconfig","pdp"..rules,"enable",enabled)
		uci:set("wanconfig","pdp"..rules,"type",apn_type)	
		uci:set("wanconfig","pdp"..rules,"auto_apn",auto_apn)
		uci:set("wanconfig","pdp"..rules,"auth",auth)
		if username == nil or username == "" then
			uci:set("wanconfig","pdp"..rules,"username","na")
		else
			uci:set("wanconfig","pdp"..rules,"username",username)
		end
		if password == nil or password == "" then
			uci:set("wanconfig","pdp"..rules,"password","na")
		else
			uci:set("wanconfig","pdp"..rules,"password",password)
		end
		
		if auto_apn == "1" then
			uci:set("wanconfig","pdp"..rules,"apn","na")
			sys.exec("wan_profile.sh del_apn")
		else
			uci:set("wanconfig","pdp"..rules,"apn",apn)
			
			local pdp_type
			if apn_type == v4 then
				pdp_type = "0"
			elseif apn_type == "v6" then
				pdp_type = "1"
			elseif apn_type =="v4v6" then
				pdp_type = "2"
			else
				pdp_type = "2"
			end
			
			sys.exec("wan_profile.sh set_apn "..apn.." "..pdp_type)
		end
		
		if auth == "0" then
			sys.exec("wan_profile.sh del_auth")
		else
			sys.exec("wan_profile.sh set_auth "..username.." "..password)
			sys.exec("wan_profile.sh set_auth_method "..auth)
		end
		
		uci:save("wanconfig")
		uci:commit("wanconfig")
		luci.http.redirect(url)	
	end
	if edit then
		local rules = edit
		local enabled = uci:get("wanconfig","pdp"..rules,"enable")
		local cid_name = uci:get("wanconfig","pdp"..rules,"name")
		local auto_apn = uci.get("wanconfig","pdp"..rules,"auto_apn")	
		local apn_type = uci:get("wanconfig","pdp"..rules,"type")	
		local apn = uci:get("wanconfig","pdp"..rules,"apn")
		local auth = uci:get("wanconfig","pdp"..rules,"auth")
		local username = uci:get("wanconfig","pdp"..rules,"username")
		local password = uci:get("wanconfig","pdp"..rules,"password")
		
		if apn == nil then
			apn = ""
		end	
		if cid_name == nil then
			cid_name = ""
		end	
		local url = luci.dispatcher.build_url("expert","configuration","lte","APN","apn_edit")
		luci.http.redirect(url .. "?" .. "&rules=" .. rules .. "&enabled=" .. enabled .. "&cid_name=" .. cid_name .. "&auth=" .. auth .. "&username=" .. username .. "&password=" .. password .. "&auto_apn=" .. auto_apn .. "&apn_type=" .. apn_type .. "&apn=" .. apn .. "&rt=" .. 1 .. "&errmsg=test!!")
		return
	end
	luci.template.render("expert_configuration/apn_application_edit")
end

function action_lte_network_settings()
	local apply = luci.http.formvalue("sysSubmit")
	
	if apply then
	-- Network Mode
		local netmode = uci:get("wanconfig","wanconfig","netmode")
		local select_wan_mode = luci.http.formvalue("_select_wan_mode")
		
		uci:set("wanconfig","wanconfig","netmode",select_wan_mode)	
	-- MTU Size	
		local mtu_size = uci:get("wanconfig","wanconfig","mtu_size")	
		local mtu = luci.http.formvalue("mtu")
		
		uci:set("wanconfig","wanconfig","mtu_size",mtu)
		
		uci:save("wanconfig")
		uci:commit("wanconfig")
		
		if netmode ~= select_wan_mode then
			sys.exec("mode_pref.sh set_from_cfg")
		end
		
		if mtu_size ~= mtu then
			sys.exec("mtu_settings.sh set_wan_from_cfg")
		end
	end
	
	luci.template.render("expert_configuration/network_settings")
end

function sleep(n)
  os.execute("sleep " .. tonumber(n))
end

function action_lte_network_select()
	local ConfirmDisableAutoSelection = luci.http.formvalue("ConfirmDisableAutoSelection")
	local SelectSubmit = luci.http.formvalue("SelectSubmit")
	
	if ConfirmDisableAutoSelection == "1" and SelectSubmit ~= "1" then
		sys.exec("/usr/sbin/network_select.sh scan")
		luci.template.render("expert_configuration/network_select", {ScanDone = 1})
	elseif ConfirmDisableAutoSelection == "1" and SelectSubmit == "1" then
		local select_net_scan_index = luci.http.formvalue("_select_net_scan_index")
		sys.exec("/usr/sbin/network_select.sh manual_from_result "..select_net_scan_index)
		sleep(1)
		luci.template.render("expert_configuration/network_select", {SelectDone = 1})
	elseif ConfirmDisableAutoSelection == "0" and SelectSubmit == "1" then	
		sys.exec("/usr/sbin/network_select.sh auto")
		sleep(1)
		luci.template.render("expert_configuration/network_select", {SelectAuto = 1})
	else
		luci.template.render("expert_configuration/network_select")
	end	
end

-- MSTC, Sharon mark configuration->remote MGMT
--[[
--Eten remote
function action_remote_www()
	local apply = luci.http.formvalue("apply")
	
	if apply then
		local infIdx = uci:get("firewall", "remote_www", "interface")
		local cfgCheck = uci:get("firewall", "remote_www", "client_check")
		
		local infCmd  = ""
		local infDCmd = ""
		local addrCmd = ""
	
		if "2" == infIdx then
			-- LAN
			infCmd=" -i br-lan "
			if cfgCheck ~= "1" then
				infDCmd=" ! -i br-lan "
			end
		elseif "3" == infIdx then
			-- WAN LAN
			infCmd=" ! -i br-lan "
			if cfgCheck ~= "1" then
				infDCmd=" -i br-lan "
			end
		end

		if not ("0" == uci:get("firewall", "remote_www", "client_check")) then
			addrCmd=" -s " .. uci:get("firewall", "remote_www", "client_addr") .. " "
		end

		sys.exec("/usr/sbin/iptables -t filter -D INPUT " .. infCmd .. addrCmd .. " -p tcp --dport " .. uci:get("firewall", "remote_www", "port") .. " -j ACCEPT 2> /dev/null")
		sys.exec("/usr/sbin/iptables -t filter -D INPUT " .. infDCmd .. " -p tcp --dport " .. uci:get("firewall", "remote_www", "port") .. " -j DROP 2> /dev/null")


		local port = luci.http.formvalue("RemoteWWWPort")
		local interface = luci.http.formvalue("RemoteWWWInterface")
		local check = luci.http.formvalue("RemoteWWWClientCheck")
		local clientAddr = luci.http.formvalue("RemoteWWWClientAddr")

		uci:set("firewall", "remote_www", "port", port)
		uci:set("firewall", "remote_www", "interface", tonumber(interface))
		uci:set("firewall", "remote_www", "client_check", check)
		
		
		if "1" == check then
			uci:set("firewall", "remote_www", "client_addr", clientAddr);
		elseif "0" == check then
			uci:delete("firewall", "remote_www", "client_addr", clientAddr)
		end

		uci:save("firewall")
		uci:commit("firewall")
		
		sys.exec("/etc/init.d/uhttpd restart 2>/dev/null")
	end

	luci.template.render("expert_configuration/remote")
end

function action_remote_telnet()
	local apply = luci.http.formvalue("apply")
	
	if apply then
		local port = luci.http.formvalue("RemoteTelnetPort")
		local interface = luci.http.formvalue("RemoteTelnetInterface")
		local check = luci.http.formvalue("RemoteTelnetClientCheck")

		sys.exec("/etc/init.d/telnet stop 2>/dev/null")

		uci:set("firewall", "remote_telnet", "port", port)
		uci:set("firewall", "remote_telnet", "interface", tonumber(interface))
		uci:set("firewall", "remote_telnet", "client_check", check)

		if "1" == check then
			local clientAddr = luci.http.formvalue("RemoteTelnetClientAddr")
			uci:set("firewall", "remote_telnet", "client_addr", clientAddr);
		elseif "0" == check then
			uci:delete("firewall", "remote_telnet", "client_addr", clientAddr)
		end

		uci:save("firewall")
		uci:commit("firewall")
		sys.exec("/etc/init.d/telnet start 2>/dev/null")
	end

	luci.template.render("expert_configuration/remote_telnet")
end

function action_remote_icmp()
	local apply = luci.http.formvalue("apply")
	
	if apply then
		local interface = luci.http.formvalue("RemoteICMPInterface")

		uci:set("firewall", "remote_telnet", "interface", tonumber(interface))
		uci:save("firewall")
		uci:commit("firewall")
		uci:apply("firewall")
	end
	luci.template.render("expert_configuration/remote_icmp")
end
--Eten Remote END
--]]

-- MSTC, Sharon mark configuration->vpn passthrough
--[[
--Eten VPN Passthrough
function action_vpn_passthrough()
	local apply = luci.http.formvalue("apply")

	if apply then
		local enabled = luci.http.formvalue("VPNPassthroughState")

		if "enable" == enabled then
			uci:set("passthrough", "vpn", "enabled", "1")
		else
			uci:set("passthrough", "vpn", "enabled", "0")
		end

		uci:save("passthrough")
		uci:commit("passthrough")
		uci:apply("passthrough")
		sys.exec("/etc/init.d/vpn_passthrough start 2>/dev/null")
	end

	luci.template.render("expert_configuration/vpn_passthrough")
end
--Eten VPN Passthrough END
--]]

-- MSTC, Sharon mark configuration->upnp
--[[
--Eten Upnp
function action_upnp()
	local apply = luci.http.formvalue("apply")

	if apply then
		local enabled = luci.http.formvalue("UPnPState")

		if "enable" == enabled then
			uci:set("upnpd", "config", "enabled", "1")
		else
			uci:set("upnpd", "config", "enabled", "0")
		end

		uci:save("upnpd")
		uci:commit("upnpd")
		uci:apply("upnpd")
	end

	luci.template.render("expert_configuration/upnp")
end
--Eten Upnp END
--]]

--2.4G Wireless
function wlan_general()
	require("luci.model.uci")
	local apply = luci.http.formvalue("sysSubmit")
--	local tmppsk	
	local wifi_iface = "wlan0"
	local wifi_device = "general"
	
	if apply then		
	--SSID
		local SSID = luci.http.formvalue("SSID_value")
		local SSID_old = uci:get("wireless", wifi_iface,"ssid")
				
		if not (SSID == SSID_old)then
			uci:set("wireless", wifi_iface, "ssid", SSID)
		end--SSID
	--radioON
		local Wireless_enable = luci.http.formvalue("ssid_state")
		local Wireless_enable_old = uci:get("wireless", wifi_device, "disabled")
		if not(Wireless_enable == Wireless_enable_old)then
			uci:set("wireless", wifi_device, "disabled", Wireless_enable)
		end--radioON
	--HideSSID
		local wireless_hidden = luci.http.formvalue("Hide_SSID")
		local wireless_hidden_old = uci:get("wireless", wifi_iface, "hidden")
		
		if not (wireless_hidden)then
			wireless_hidden = "0"
		else
			wireless_hidden = "1"
		end

		if not(wireless_hidden == wireless_hidden_old)then			
			uci:set("wireless", wifi_iface, "hidden", wireless_hidden)
		end
	--ChannelID
		local Channel_Freq = luci.http.formvalue("Channel_Freq")
		local Channel_ID = luci.http.formvalue("Channel_ID_index")
		local Auto_Channel = luci.http.formvalue("Auto_Channel")
			
		if not (Auto_Channel == "1") then
			if (Channel_ID == "auto") then
				Channel_ID = "1"
			end
			local Channel_ID_old = uci:get("wireless", wifi_device, "ch_op", Channel_ID)
			if not(Channel_ID)then
				Channel_ID = Channel_ID_old
			end
						
			uci:set("wireless", wifi_device, "channel", Channel_ID)
			uci:set("wireless", wifi_device, "ch_op", Channel_ID)
			uci:set("wireless", wifi_device, "frequency", Channel_Freq)

		end
	--AutoChSelect
		if (Auto_Channel == "1") then
			uci:set("wireless", wifi_device, "ch_op", "auto")
		--[[	
			sys.exec("sh /usr/sbin/auto_channel_selection.sh")
			local file = io.open("/tmp/auto_channel", "r")	
			local Channel_ID_auto = file:read("*line")	
			--sys.exec("echo "..Channel_ID_auto.." > /tmp/Channel_ID_auto")
			file:close()
			uci:set("wireless", wifi_device, "channel", Channel_ID_auto)
			--uci:set("wireless", wifi_device, "channel", "auto")
		--]]	
		end
	--ChannelWidth
		--local Channel_Width = luci.http.formvalue("ChWidth_select")
		--if (Channel_Width == "HT20") then
			--uci:set("wireless", wifi_device, "htmode", Channel_Width)
		--else
			local channel_set
			--[[
			if (Auto_Channel == "1") then
				local file = io.open("/tmp/auto_channel", "r")	
				local Channel_ID_auto = file:read("*line")	
				channel_set = tonumber(Channel_ID_auto)
				file:close()
			else
				channel_set = tonumber(Channel_ID)
			end
			--]]
			
			channel_set = Channel_ID
						
			if (tonumber(channel_set) <= 4) or (tonumber(channel_set) == 149) or (tonumber(channel_set) == 157) then
				Channel_Width = "HT40+"
			elseif (tonumber(channel_set) >= 10 ) or (tonumber(channel_set) == 153) or (tonumber(channel_set) == 161) then
				Channel_Width = "HT40-"
			else
				Channel_Width = "HT40- HT40+"
			end
			
			uci:set("wireless", wifi_device, "htmode", Channel_Width)		
		--end
	--tx power
		local txPower = luci.http.formvalue("TxPower_value")
		local txPower_old = uci:get("wireless", wifi_device, "txpower")
		if not (txPower) then
			uci:set("wireless", wifi_device, "txpower","18")
		else
			if not (txPower == txPower_old) then 
				uci:set("wireless", wifi_device, "txpower",txPower)
			end
		end
	--WirelessMode
		local Wireless_Mode = luci.http.formvalue("Mode_select")
		local Wireless_Mode_5G = luci.http.formvalue("Mode_select_5G")
				
		if (Wireless_Mode) then
			uci:set("wireless", wifi_device, "hwmode", Wireless_Mode)
		elseif (Wireless_Mode_5G) then
			uci:set("wireless", wifi_device, "hwmode", Wireless_Mode_5G)
		else
			--should not enter here
		end
	--IdleMode
		local Idlemode = luci.http.formvalue("idlemode_select")
		uci:set("wireless", wifi_device, "idlemode", Idlemode)
	--SecurityMode
		local security_mode = luci.http.formvalue("security_value")
		local encryption_method = luci.http.formvalue("encryption_method")
				
		if (security_mode) then
			--No security
			if( security_mode == "NONE") then
				uci:set("wireless", wifi_iface, "auth","OPEN")
				uci:set("wireless", wifi_iface, "_encryption","NONE")
				-- encryption
				uci:set("wireless", wifi_iface, "encryption","none")
			end

			--WEP
			if( security_mode == "WEP")then
				local EncrypAuto_shared = luci.http.formvalue("auth_method")
				uci:set("wireless", wifi_iface,"_encryption","WEP")
				if (EncrypAuto_shared)	then
					if(EncrypAuto_shared == "WEPOPEN")then
						uci:set("wireless", wifi_iface,"auth",EncrypAuto_shared)
						-- encryption
						uci:set("wireless", wifi_iface, "encryption","wep+open")
					elseif(EncrypAuto_shared == "SHARED") then
						uci:set("wireless", wifi_iface,"auth",EncrypAuto_shared)
						-- encryption
						uci:set("wireless", wifi_iface, "encryption","wep+shared")
					end
				end
				--64-128bit
				local WEP64_128 = luci.http.formvalue("WEP64_128")
				if (WEP64_128)then
					if(WEP64_128 == "0")then--[[64-bit]]--
						uci:set("wireless", wifi_iface,"wepencryp128", WEP64_128)
					elseif(WEP64_128 == "1") then--[[128-bit]]--
						uci:set("wireless", wifi_iface,"wepencryp128", WEP64_128)
					end
				end
				--ASCIIHEX
				local WEPKey_Code = luci.http.formvalue("WEPKey_Code")
				if (WEPKey_Code == "1")then--[[HEx]]--
					uci:set("wireless", wifi_iface,"keytype", "1")
				elseif (WEPKey_Code == "0") then--[[ASCII]]--
					uci:set("wireless", wifi_iface,"keytype", "0")
				end
				--keyindex
				local DefWEPKey = luci.http.formvalue("DefWEPKey")
				if (DefWEPKey)then
					uci:set("wireless", wifi_iface,"key", DefWEPKey)
				end
                                	
				--WEP key value
                                local wepkey
                                local key_name
                                for i=1,4 do
                                        wepkey = luci.http.formvalue("wep_key_"..i)
                                        key_name="key"..i
                                        if ( wepkey ) then
                                                uci:set("wireless", wifi_iface, key_name, wepkey)
                               	        else
                               	                uci:set("wireless", wifi_iface, key_name, "")
                               	        end
                               	end
			end

			--WPAPSK
			if(security_mode == "WPAPSK")then
				uci:set("wireless", wifi_iface,"auth","WPAPSK")			
				
				if (encryption_method == "TKIP") then			
					uci:set("wireless", wifi_iface,"_encryption","TKIP")
					-- encryption
					uci:set("wireless", wifi_iface, "encryption","psk+tkip")
				elseif (encryption_method == "AES") then		
					uci:set("wireless", wifi_iface,"_encryption","AES")
					-- encryption
					uci:set("wireless", wifi_iface, "encryption","psk+aes")
				else			
					uci:set("wireless", wifi_iface,"_encryption","AES/TKIP")
					-- encryption
					uci:set("wireless", wifi_iface, "encryption","psk/tkip+aes")				
				end
				
				local WPAPSKkey = luci.http.formvalue("PSKey")
				if (WPAPSKkey == "") then
					uci:set("wireless", wifi_iface,"WPAPSKkey", "")
					uci:set("wireless", wifi_iface,"key", "")
				else						
					uci:set("wireless", wifi_iface,"WPAPSKkey", WPAPSKkey)
					uci:set("wireless", wifi_iface,"key", WPAPSKkey)
				end
			end

			--WPA2PSK
			if(security_mode=="WPA2PSK")then
				uci:set("wireless", wifi_iface,"auth","WPA2PSK")
				
				if (encryption_method == "TKIP") then		
					uci:set("wireless", wifi_iface,"_encryption","TKIP")
					-- encryption
					uci:set("wireless", wifi_iface, "encryption","psk2+tkip")
				elseif (encryption_method == "AES") then			
					uci:set("wireless", wifi_iface,"_encryption","AES")
					-- encryption
					uci:set("wireless", wifi_iface, "encryption","psk2+aes")
				else				
					uci:set("wireless", wifi_iface,"_encryption","AES/TKIP")
					-- encryption
					uci:set("wireless", wifi_iface, "encryption","psk2/tkip+aes")				
				end				
				
				--uci:set("wireless", wifi_iface,"_encryption","AES")
				-- encryption
				--uci:set("wireless", wifi_iface, "encryption","psk2+aes")
				local WPAPSKkey = luci.http.formvalue("PSKey")
				if (WPAPSKkey == "") then
					uci:set("wireless", wifi_iface,"WPAPSKkey", "")
					uci:set("wireless", wifi_iface,"key", "")
				else
					uci:set("wireless", wifi_iface,"WPAPSKkey", WPAPSKkey)
					uci:set("wireless", wifi_iface,"key", WPAPSKkey)
				end
			end			
			--WPAPSKWPA2PSK
			if(security_mode=="WPAPSKWPA2PSK")then
				uci:set("wireless", wifi_iface,"auth","WPAPSKWPA2PSK")
				
				if (encryption_method == "TKIP") then			
					uci:set("wireless", wifi_iface,"_encryption","TKIP")
					-- encryption
					uci:set("wireless", wifi_iface, "encryption","psk-mixed/tkip")
				elseif (encryption_method == "AES") then					
					uci:set("wireless", wifi_iface,"_encryption","AES")
					-- encryption
					uci:set("wireless", wifi_iface, "encryption","psk-mixed/aes")
				else					
					uci:set("wireless", wifi_iface,"_encryption","AES/TKIP")
					-- encryption
					uci:set("wireless", wifi_iface, "encryption","psk-mixed/tkip+aes")				
				end
				
				--uci:set("wireless", wifi_iface,"_encryption","AES")
				-- encryption
				--uci:set("wireless", wifi_iface, "encryption","psk-mixed/aes")
				local WPAPSKkey = luci.http.formvalue("PSKey")
				if (WPAPSKkey == "") then
					uci:set("wireless", wifi_iface,"WPAPSKkey", "")
					uci:set("wireless", wifi_iface,"key", "")
				else
					uci:set("wireless", wifi_iface,"WPAPSKkey", WPAPSKkey)
					uci:set("wireless", wifi_iface,"key", WPAPSKkey)
				end
			end

		end
		uci:commit("wireless")
		--uci:apply("wireless")
		sys.exec("/sbin/wifi") 
	end --end apply

--[[
	sys.exec("set_tmp_psk")
	tmppsk=sys.exec("cat /tmp/tmppsk")
	sys.exec("rm /tmp/tmppsk")

	local file = io.open("/var/countrycode", "r")	
	local temp = file:read("*all")
	file:close()
]]--
	local temp = "DE" --China
	local code = temp:match("([0-9a-fA-F]+)")
	local region = country_code_table[code:gsub("[a-fA-F]", string.upper)]


	luci.template.render("expert_configuration/wlan", {channels = channelRange[region[1]]})	
end

function wlanmacfilter()
	local apply = luci.http.formvalue("sysSubmit")
	local select_ap = luci.http.formvalue("ap_select")
	local changed = 0
	local filter

--[[	
	if not select_ap then
		select_ap="0"
	end

	filter="general"..select_ap
]]--	

	if apply then
		--filter on/of
		local MACfilter_ON = luci.http.formvalue("MACfilter_ON")
		MACfilter_ON_old = uci:get("wireless_macfilter", "filter","mac_state")
		if not (MACfilter_ON == MACfilter_ON_old) then
			changed = 1
			uci:set("wireless_macfilter", "filter","mac_state", MACfilter_ON)
		end
		--filter action
		local filter_act = luci.http.formvalue("filter_act")
		filter_act_old = uci:get("wireless_macfilter", "filter","filter_action")
		if not (filter_act == filter_act_old) then
			changed = 1
			uci:set("wireless_macfilter", "filter","filter_action", filter_act)
		end

		--mac address
		local MacAddr
		local Mac_field
		local MacAddr_old
		for i=1,10 do
			Mac_field="MacAddr"..i
			MacAddr_old = uci:get("wireless_macfilter", "filter", Mac_field)
			MacAddr = luci.http.formvalue(Mac_field)
			if not ( MacAddr == MacAddr_old ) then
				changed = 1
				uci:set("wireless_macfilter", "filter", Mac_field, MacAddr)
			end
		end

		--new value need to be saved
		if (changed == 1) then
		--[[
			local iface_reset="ra"..select_ap
			local iface
			local iface_filter
			for i=0,3 do
				iface="ra"..i
				iface_filter="general"..i
				if (iface == iface_reset) then
					uci:set("wireless_macfilter", iface_filter, "reset", "1")
				else
					uci:set("wireless_macfilter", iface_filter, "reset", "0")	
				end
			end
		]]--
			uci:set("wireless_macfilter", "filter", "reset", "1")
			uci:commit("wireless_macfilter")
			uci:apply("wireless_macfilter")
			sys.exec("/sbin/wifi")
		end
	end
	luci.template.render("expert_configuration/wlanmacfilter",{filter_iface=filter, ap=select_ap})	
end

--[[
function wlan_advanced()
	local apply = luci.http.formvalue("sysSubmit")
	local changed = 0
	local wireless_mode = uci:get("wireless", "ra0", "mode")
	local RTS_Set
	local Frag_Set

        if ( wireless_mode == "11gn" or  wireless_mode == "11n" or wireless_mode == "11bgn" ) then
                uci:set("wireless", "advance", "rts_threshold",2346)
		uci:set("wireless", "advance", "fr_threshold",2346)
                uci:commit("wireless")
                RTS_Set="disabled"
		Frag_Set="disabled"
        end

	if apply then
--rts_Threshold
		local rts_Threshold = luci.http.formvalue("rts_Threshold")
		local rts_Threshold_old = uci:get("wireless", "advance","rts_threshold")
		if not (rts_Threshold) then
			changed = 1
			uci:set("wireless", "advance","rts_threshold", "2345")
		else
			if not (rts_Threshold == rts_Threshold_old) then
			changed = 1
			uci:set("wireless", "advance","rts_threshold", rts_Threshold)
			end
		end
--fr_threshold		
		local fr_threshold = luci.http.formvalue("fr_threshold")
		local fr_threshold_old = uci:get("wireless", "advance","fr_threshold")
		if not (fr_threshold) then
			changed = 1
			uci:set("wireless", "advance","fr_threshold", "2354")
		else
			if not (fr_threshold == fr_threshold_old) then
			changed = 1
			uci:set("wireless", "advance","fr_threshold", fr_threshold)
			end
		end
--Intra-BSS Traffic
		local IntraBSS_state = luci.http.formvalue("IntraBSS_state")
		local IntraBSS_state_old = uci:get("wireless", "ra0","IntraBSS")
		if not (IntraBSS_state) then
			changed = 1
			uci:set("wireless", "ra0","IntraBSS", "0")
		else
			if not (IntraBSS_state == IntraBSS_state_old) then
			changed = 1
			uci:set("wireless", "ra0","IntraBSS", IntraBSS_state)
			end
		end		
--tx power
		local txPower = luci.http.formvalue("TxPower_value")
		local txPower_old = uci:get("wireless", "ra0", "TxPower")
		if not (txPower) then
			changed = 1
			uci:set("wireless", "ra0", "TxPower","100")
		else
			if not (txPower == txPower_old) then 
			changed = 1
			uci:set("wireless", "ra0", "TxPower",txPower)
			end
		end
		if (changed == 1) then
		uci:commit("wireless")
		uci:apply("wireless")
		end
	end
	luci.template.render("expert_configuration/wlanadvanced",{rts_set=RTS_Set, frag_set=Frag_Set})	
end
]]--

--[[
function wlan_qos()
	local apply = luci.http.formvalue("sysSubmit")
	local wireless_mode = uci:get("wireless", "ra0", "mode") 
	local WMM_Choose

	if ( wireless_mode == "11gn" or  wireless_mode == "11n" or wireless_mode == "11bgn" ) then
		uci:set("wireless", "ra0", "wmm",1)
          	uci:commit("wireless")
          	WMM_Choose="disabled"
	end	

	if apply then
		local wmm_enable = luci.http.formvalue("WMM_QoS")
		
		if (wmm_enable == "1") then
			uci:set("wireless", "ra0","wmm", wmm_enable)
		elseif (wmm_enable == "0") then
			uci:set("wireless", "ra0","wmm", wmm_enable)		
		end
		uci:commit("wireless")
		uci:apply("wireless")
	end
	luci.template.render("expert_configuration/wlanqos", {wmm_choice=WMM_Choose})	
end
]]--

--[[
function wlanscheduling()
	local apply = luci.http.formvalue("sysSubmit")

	if apply then
		uci:set("wifi_schedule", "wlan", "enabled", luci.http.formvalue("WLanSchRadio"))

		local schedulingNames = { "Everyday", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun" }

		for i, name in ipairs(schedulingNames) do
			local prefixStr = "WLanSch" .. name
			local token = string.lower(name:sub(1, 1)) .. name:sub(2, #name)

			uci:set("wifi_schedule", token, "status_onoff", luci.http.formvalue(prefixStr .. "Radio"))
			uci:set("wifi_schedule", token, "start_hour",   luci.http.formvalue(prefixStr .. "StartHour"))
			uci:set("wifi_schedule", token, "start_min",    luci.http.formvalue(prefixStr .. "StartMin"))
			uci:set("wifi_schedule", token, "end_hour",     luci.http.formvalue(prefixStr .. "EndHour"))
			uci:set("wifi_schedule", token, "end_min",      luci.http.formvalue(prefixStr .. "EndMin"))

			if "on" == luci.http.formvalue(prefixStr .. "Enabled") then
				uci:set("wifi_schedule", token, "enabled", "1")
			else
				uci:set("wifi_schedule", token, "enabled", "0")
			end
		end

		uci:commit("wifi_schedule")
		uci:apply("wifi_schedule")
	end

	luci.template.render("expert_configuration/wlanscheduling")	
end
]]--

--benson vpn
function action_vpn()
	local apply = luci.http.formvalue("sysSubmit")
	local netbios_allow = luci.http.formvalue("IPSecPassThrough")
	if apply then
		
		if not netbios_allow then
			netbios_allow="disable"
		else 
			netbios_allow="enable"
		end
		
		uci:set("ipsec_new","general",'netbiosAllow',netbios_allow)
		uci:commit("ipsec_new")
		uci:apply("ipsec_new")
	end
	luci.template.render("expert_configuration/vpn")
end

function action_samonitor()
        local remote_gw_ip
        local rule_status = {"","","","",""}
	local roadwarrior = {"0","0","0","0","0"}
	local record_number
	local rules
	local key_mode

	--for roadwarrior case
	record_number = luci.sys.exec("racoonctl show-sa isakmp | wc -l | awk '{printf $1}'")
	record_number = tonumber(record_number)
	record_number = record_number - 1

	for i=1,5 do
		rules="rule"..i
		key_mode = uci:get("ipsec", rules, "keyMode")
		remote_gw_ip = uci:get("ipsec", rules, "remote_gw_ip")
		if key_mode == "IKE" then
			if remote_gw_ip then
				if remote_gw_ip == "0.0.0.0" then
					roadwarrior[i]="1"
				else
					rule_status[i] = luci.sys.exec("racoonctl show-sa isakmp | grep -c "..remote_gw_ip)
					if ( rule_status[i] == "" ) then
						rule_status[i]="0"
					else
						--not roadwarrior case
						record_number = record_number - 1
					end
				end
			else
				rule_status[i]="0"
			end
		else
			rule_status[i]="0"
		end
	end

	--temporary method
        for i=1,5 do
                if roadwarrior[i] == "1" then
                        if record_number == 0 then
				rule_status[i]="0"
			else
                                rule_status[i]="1"
                        end
                end
        end	

	luci.template.render("expert_configuration/samonitor", {status_r1 = rule_status[1],
								status_r2 = rule_status[2],
								status_r3 = rule_status[3],
								status_r4 = rule_status[4],
								status_r5 = rule_status[5]})
end

function action_vpnEdit()
	local apply = luci.http.formvalue("sysSubmit")
	local rules = luci.http.formvalue("rules")
	local edit = luci.http.formvalue("edit")
	local delete = luci.http.formvalue("delete")

	if apply then
		local statusEnable = luci.http.formvalue("ssid_state")
		local IPSecKeepAlive = luci.http.formvalue("IPSecKeepAlive")

		if not IPSecKeepAlive then
			IPSecKeepAlive="off"
		end
		local IPSecNatTraversal = luci.http.formvalue("IPSecNatTraversal")
	
		if not IPSecNatTraversal then
			IPSecNatTraversal="off"
		end
	
		local s1 = luci.http.formvalue("keyModeSelect")
		local keyModeSelect

		if s1 == "00000000" then
			 keyModeSelect="IKE"
		else
			 keyModeSelect="manual"
		end
		
		local LocalAddrType = luci.http.formvalue("LocalAddressTypeSelect")
		local RemoteAddrType = luci.http.formvalue("RemoteAddressTypeSelect")
		local IPSecSourceAddrStart = luci.http.formvalue("IPSecSourceAddrStart")
		local IPSecSourceAddrMask = luci.http.formvalue("IPSecSourceAddrMask")
		local IPSecDestAddrStart = luci.http.formvalue("IPSecDestAddrStart")
		local IPSecDestAddrMask = luci.http.formvalue("IPSecDestAddrMask")
		local localPublicIP = luci.http.formvalue("localPublicIP")
		local s2 = luci.http.formvalue("localContentSelect")
		local localContentSelect

		if s2 == "00000000" then
			localContentSelect="address"
		elseif s2 == "00000001" then
			localContentSelect="fqdn"
		else
			localContentSelect="user_fqdn"
		end

		local localContent = luci.http.formvalue("localContent")
		local remotePublicIP = luci.http.formvalue("remotePublicIP")
		local s3 = luci.http.formvalue("remoteContentSelect")
		local remoteContentSelect

		if s3 == "00000000" then
			 remoteContentSelect="address"
		elseif s3 == "00000001" then
			 remoteContentSelect="fqdn"
		else
			 remoteContentSelect="user_fqdn"
		end

		local remoteContent = luci.http.formvalue("remoteContent")
		local IPSecPreSharedKey = luci.http.formvalue("IPSecPreSharedKey")
		local s8 = luci.http.formvalue("modeSelect")
		local modeSelect

		if s8 == "00000000" then
			modeSelect="main"
		elseif s8 == "00000001" then
			modeSelect="aggressive"
		else
			modeSelect="main, aggressive"
		end

		local authKey = luci.http.formvalue("authKey")
		local IPSecSPI = luci.http.formvalue("IPSecSPI")
		local s6 = luci.http.formvalue("encapAlgSelect")
		local encapAlgSelect

		if s6 == "00000000" then
			 encapAlgSelect="des-cbc"	
		else
			 encapAlgSelect="3des-cbc"
		end
	
		local encrypKey = luci.http.formvalue("encrypKey")
		local s7 = luci.http.formvalue("authAlgSelect")
		local authAlgSelect
		
		if s7 == "00000000" then
			 authAlgSelect="hmac-md5"
		else
			 authAlgSelect="hmac-sha1"
		end

		local authKey = luci.http.formvalue("authKey")
		local saLifeTime = luci.http.formvalue("saLifeTime")
		local s9 = luci.http.formvalue("keyGroup")
		local keyGroup
		
		if s9 == "00000000" then
			 keyGroup="modp768"
		else
			 keyGroup="modp1024"
		end
	
		local s4 = luci.http.formvalue("encapModeSelect")
		local encapModeSelect
		
		if s4 == "00000000" then
			 encapModeSelect="tunnel"
		else
			 encapModeSelect="transport"
		end
	
		local s5 = luci.http.formvalue("protocolSelect")
		local protocolSelect
		
		if s5 == "00000000" then
			 protocolSelect="esp"
		else
			 protocolSelect="ah"
		end

		local s10 = luci.http.formvalue("encapAlgSelect2")
		local encapAlgSelect2
		
		if s10 == "00000000" then
			 encapAlgSelect2="des-cbc"
		else
			 encapAlgSelect2="3des-cbc"
		end
	
		local s11 = luci.http.formvalue("authAlgSelect2")
		local authAlgSelect2
	
		if s11 == "00000000" then
			 authAlgSelect2="hmac-md5"
		else
			 authAlgSelect2="hmac-sha1"
		end

		local saLifeTime2 = luci.http.formvalue("saLifeTime2")
		local s11 = luci.http.formvalue("keyGroup2")
		local keyGroup2
		
		if s11 == "00000000" then
			keyGroup2="modp768"
		else
			keyGroup2="modp1024"
		end

	        uci:set("ipsec",rules,"ipsec")

		if LocalAddrType == "1" then
			uci:set("ipsec",rules,"LocalAddrType","1")
			uci:set("ipsec",rules,'localNetMask',IPSecSourceAddrMask)
		else
			uci:set("ipsec",rules,"LocalAddrType","0")
			uci:set("ipsec",rules,'localNetMask',"255.255.255.255")
		end

		if RemoteAddrType == "1" then
			uci:set("ipsec",rules,"RemoteAddrType","1")
			uci:set("ipsec",rules,"peerNetMask",IPSecDestAddrMask)
		else
			uci:set("ipsec",rules,"RemoteAddrType","0")
			uci:set("ipsec",rules,"peerNetMask","255.255.255.255")
		end

                uci:set("ipsec",rules,'statusEnable',statusEnable)
                uci:set("ipsec",rules,'KeepAlive',IPSecKeepAlive)
                uci:set("ipsec",rules,'NatTraversal',IPSecNatTraversal)
                uci:set("ipsec",rules,'keyMode',keyModeSelect)
                uci:set("ipsec",rules,'localIP',IPSecSourceAddrStart)
                --uci:set("ipsec",rules,'localNetMask',IPSecSourceAddrMask)
                uci:set("ipsec",rules,'peerIP',IPSecDestAddrStart)
                --uci:set("ipsec",rules,'peerNetMask',IPSecDestAddrMask)
                uci:set("ipsec",rules,'localGwIP',localPublicIP)
                uci:set("ipsec",rules,'my_identifier_type',localContentSelect)
                uci:set("ipsec",rules,'my_identifier',localContent)
                uci:set("ipsec",rules,'remoteGwIP',remotePublicIP)
                uci:set("ipsec",rules,'peers_identifier_type',remoteContentSelect)
                uci:set("ipsec",rules,'peers_identifier',remoteContent)
                uci:set("ipsec",rules,'preSharedKey',IPSecPreSharedKey)
                uci:set("ipsec",rules,'mode',modeSelect)
                uci:set("ipsec",rules,'spi',IPSecSPI)
                uci:set("ipsec",rules,'enAlgo',encapAlgSelect)
                uci:set("ipsec",rules,'enKey',encrypKey)
                uci:set("ipsec",rules,'authAlgo',authAlgSelect)
                uci:set("ipsec",rules,'authKey',authKey)
                uci:set("ipsec",rules,'lifeTime',saLifeTime)
                uci:set("ipsec",rules,'keyGroup',keyGroup)
		uci:set("ipsec",rules,'enMode',encapModeSelect)
                uci:set("ipsec",rules,'protocol',protocolSelect)
		uci:set("ipsec",rules,'enAlgo2',encapAlgSelect2)
		uci:set("ipsec",rules,'authAlgo2',authAlgSelect2)
		uci:set("ipsec",rules,'lifeTime2',saLifeTime2)
                uci:set("ipsec",rules,'keyGroup2',keyGroup2)
                uci:commit("ipsec")
                uci:apply("ipsec")

		luci.template.render("expert_configuration/vpn")
		return
	end --end apply

	if edit then
		local rules = edit
                local stEnable = uci:get("ipsec",rules,'statusEnable')
                local KeepAlive = uci:get("ipsec",rules,'KeepAlive')
                local NatTraversal = uci:get("ipsec",rules,'NatTraversal')
                local keyMode = uci:get("ipsec",rules,'keyMode')
                local localIP = uci:get("ipsec",rules,'localIP')
                local localNetMask = uci:get("ipsec",rules,'localNetMask')
                local peerIP = uci:get("ipsec",rules,'peerIP')
                local peerNetMask = uci:get("ipsec",rules,'peerNetMask')
                local localGwIP = uci:get("ipsec",rules,'localGwIP')
                local my_identifier_type = uci:get("ipsec",rules,'my_identifier_type')
                local my_identifier = uci:get("ipsec",rules,'my_identifier')
                local remoteGwIP = uci:get("ipsec",rules,'remoteGwIP')
                local peers_identifier_type = uci:get("ipsec",rules,'peers_identifier_type')
                local peers_identifier = uci:get("ipsec",rules,'peers_identifier')
                local preSharedKey = uci:get("ipsec",rules,'preSharedKey')
                local mode = uci:get("ipsec",rules,'mode')
                local spi = uci:get("ipsec",rules,'spi')
                local enAlgo = uci:get("ipsec",rules,'enAlgo')
                local enKeyy = uci:get("ipsec",rules,'enKey')
                local authAlgo = uci:get("ipsec",rules,'authAlgo')
                local authKeyy = uci:get("ipsec",rules,'authKey')
                local lifeTime = uci:get("ipsec",rules,'lifeTime')
                local keyyGroup = uci:get("ipsec",rules,'keyGroup')
		local enMode = uci:get("ipsec",rules,'enMode')
                local protocol = uci:get("ipsec",rules,'protocol')
		local enAlgo2 = uci:get("ipsec",rules,'enAlgo2')
		local authAlgo2 = uci:get("ipsec",rules,'authAlgo2')
		local lifeTime2 = uci:get("ipsec",rules,'lifeTime2')
                local keyyGroup2 = uci:get("ipsec",rules,'keyGroup2')
		local url = luci.dispatcher.build_url("expert","configuration","security","vpn","vpn_edit")
          	local paramStr = ""
          	
          	if stEnable then 	paramStr=paramStr .. "&stEnable=" .. stEnable end
          	if KeepAlive then 	paramStr=paramStr .. "&KeepAlive=" .. KeepAlive end
          	if NatTraversal then 	paramStr=paramStr .. "&NatTraversal=" .. NatTraversal end
		if keyMode then 	paramStr=paramStr .. "&keyMode=" .. keyMode end
		if localIP then 	paramStr=paramStr .. "&localIP=" .. localIP end
		if localNetMask then 	paramStr=paramStr .. "&localNetMask=" .. localNetMask end
		if peerIP then 	paramStr=paramStr .. "&peerIP=" .. peerIP end
		if peerNetMask then 	paramStr=paramStr .. "&peerNetMask=" .. peerNetMask end
		if localGwIP then 	paramStr=paramStr .. "&localGwIP=" .. localGwIP end
		if my_identifier_type then 	paramStr=paramStr .. "&my_identifier_type=" .. my_identifier_type end
		if my_identifier then 	paramStr=paramStr .. "&my_identifier=" .. my_identifier end
		if remoteGwIP then 	paramStr=paramStr .. "&remoteGwIP=" .. remoteGwIP end
		if peers_identifier_type then 	paramStr=paramStr .. "&peers_identifier_type=" .. peers_identifier_type end
		if peers_identifier then 	paramStr=paramStr .. "&peers_identifier=" .. peers_identifier end
		if preSharedKey then 	paramStr=paramStr .. "&preSharedKey=" .. preSharedKey end
		if mode then 	paramStr=paramStr .. "&mode=" .. mode end
		if spi then 	paramStr=paramStr .. "&spi=" .. spi end
		if enAlgo then 	paramStr=paramStr .. "&enAlgo=" .. enAlgo end
		if enKeyy then 	paramStr=paramStr .. "&enKeyy=" .. enKeyy end
		if authAlgo then 	paramStr=paramStr .. "&authAlgo=" .. authAlgo end
		if authKeyy then 	paramStr=paramStr .. "&authKeyy=" .. authKeyy end
		if lifeTime then 	paramStr=paramStr .. "&lifeTime=" .. lifeTime end
		if keyyGroup then 	paramStr=paramStr .. "&keyyGroup=" .. keyyGroup end
		if enMode then 	paramStr=paramStr .. "&enMode=" .. enMode end
		if protocol then 	paramStr=paramStr .. "&protocol=" .. protocol end
		if enAlgo2 then 	paramStr=paramStr .. "&enAlgo2=" .. enAlgo2 end
		if authAlgo2 then 	paramStr=paramStr .. "&authAlgo2=" .. authAlgo2 end
		if lifeTime2 then 	paramStr=paramStr .. "&lifeTime2=" .. lifeTime2 end
		if keyyGroup2 then 	paramStr=paramStr .. "&keyyGroup2=" .. keyyGroup2 end
		
		luci.http.redirect(url .. "?" .. "rules=" .. rules  .. paramStr)
		
		return
	end --end edit
	
	if delete then
		local rules2 = delete
	
		uci:delete("ipsec", rules2)
		uci:commit("ipsec")
		uci:apply("ipsec")
	
		luci.template.render("expert_configuration/vpn")
		return
	end
	luci.template.render("expert_configuration/vpn_edit")
end
--benson vpn

function action_qos()
	apply = luci.http.formvalue("apply")
	
	if apply then
		local qosEnable = luci.http.formvalue("qosEnable")
		local upShapeRate = luci.http.formvalue("UploadBandwidth")
		local downShapeRate = luci.http.formvalue("DownloadBandwidth")

		if upShapeRate ~= "" then
			uci:set("qos","shaper", "port_rate_eth0", upShapeRate)
			uci:set("qos","shaper", "port_status_eth0", uci:get("qos","general","enable"))
		else
			uci:set("qos","shaper", "port_rate_eth0", 0)
			uci:set("qos","shaper", "port_status_eth0", 0)
		end
		
		if downShapeRate ~= "" then
			uci:set("qos","shaper", "port_rate_lan", downShapeRate)
			uci:set("qos","shaper", "port_status_lan", uci:get("qos","general","enable"))
		else
			uci:set("qos","shaper", "port_rate_lan", 0)
			uci:set("qos","shaper", "port_status_lan", 0)
		end
		
		uci:set("qos","general","enable",qosEnable)
		
		-- configure shapper
		if "0" == uci:get("qos","shaper","port_rate_eth0") then
			uci:set("qos","shaper", "port_status_eth0", 0)
		else
			uci:set("qos","shaper", "port_status_eth0", qosEnable)
		end
		
		if "0" == uci:get("qos","shaper","port_rate_lan") then
			uci:set("qos","shaper", "port_status_lan", 0)
		else
			uci:set("qos","shaper", "port_status_lan", qosEnable)
		end
		
		if qosEnable == "0" then
			uci:set("qos","general","game_enable",qosEnable)
		end
		
		uci:commit("qos")
		uci:apply("qos") 
	end
	
	luci.template.render("expert_configuration/qos")
	return
end

function split(str, c)
	a = string.find(str, c)
	str = string.gsub(str, c, "", 1)
	aCount = 0
	start = 1
	array = {}
	last = 0
		
		while a do
		array[aCount] = string.sub(str, start, a - 1)
		start = a
		a = string.find(str, c)
		
		str = string.gsub(str, c, "", 1)
		aCount = aCount + 1
		end	
	return array
end

function action_qos_adv()
	apply = luci.http.formvalue("apply")
	apply_edit = luci.http.formvalue("apply_edit")
	edit = luci.http.formvalue("edit")
	delete = luci.http.formvalue("delete")
	
	if apply then
		local appPrio = split(luci.http.formvalue("app_prio"),",")
		local appEnable = split(luci.http.formvalue("app_enable"),",")
		local userCategory = split(luci.http.formvalue("user_category"),",")
		local userDir = split(luci.http.formvalue("user_dir"),",")
		local userEnable = split(luci.http.formvalue("user_enable"),",")
		local userName = split(luci.http.formvalue("user_name"),",")
		
		uci:set("qos","priority","game",appPrio[0])
		uci:set("qos","priority","voip",appPrio[1])
		uci:set("qos","priority","media",appPrio[2])
		uci:set("qos","priority","web",appPrio[3])
		uci:set("qos","priority","ftp",appPrio[4])
		uci:set("qos","priority","mail",appPrio[5])
		uci:set("qos","priority","others",appPrio[6])
		
		if appPrio[0] ~= "7" then
			uci:set("qos","general","game_enable",0)
		end
		
		uci:set("qos","XBox_Live","enable", appEnable[0])
		uci:set("qos","PlayStation","enable", appEnable[1])
		uci:set("qos","MSN_Game_Zone","enable", appEnable[2])
		uci:set("qos","Battlenet","enable", appEnable[3])
		uci:set("qos","VoIP","enable", appEnable[4])
		uci:set("qos","Instant_Messanger","enable", appEnable[5])
		uci:set("qos","Web_Surfing","enable", appEnable[6])
		uci:set("qos","FTP","enable", appEnable[7])
		uci:set("qos","E_Mail","enable", appEnable[8])
		
		for i=1,8 do
			uci:set("qos","eg_policy_" .. i,"enable",userEnable[i-1])
			uci:set("qos","eg_policy_" .. i,"name",userName[i-1])
			uci:set("qos","eg_policy_" .. i,"from_intf",userDir[i-1])
			uci:set("qos","eg_policy_" .. i,"category",userCategory[i-1])
		end
		
		uci:commit("qos")
		uci:apply("qos")
		
		luci.template.render("expert_configuration/qos_adv")
		
	elseif apply_edit then
		local src = luci.http.formvalue("srcAddr")
		local srcMask = luci.http.formvalue("srcMask")
		local srcPort = luci.http.formvalue("srcPort")
		local dst = luci.http.formvalue("dstAddr")
		local dstMask = luci.http.formvalue("dstMask")
		local dstPort = luci.http.formvalue("dstPort")
		local proto = luci.http.formvalue("proto")
		
		uci:set("qos",apply_edit,"src",src)
		uci:set("qos",apply_edit,"src_mask",srcMask)
		uci:set("qos",apply_edit,"sport",srcPort)
		uci:set("qos",apply_edit,"dst",dst)
		uci:set("qos",apply_edit,"dst_mask",dstMask)
		uci:set("qos",apply_edit,"dport",dstPort)
		uci:set("qos",apply_edit,"proto",proto)
		
		uci:commit("qos")
		uci:apply("qos")
		luci.template.render("expert_configuration/qos_adv")
		
	elseif edit then
		
		local ruleName = uci:get("qos",edit,"name")
		local ruleEnable = uci:get("qos",edit,"enable")
		local ruleSrc = uci:get("qos",edit,"src")
		local ruleSrcMask = uci:get("qos",edit,"src_mask")
		local ruleSrcPort = uci:get("qos",edit,"sport")
		local ruleDst = uci:get("qos",edit,"dst")
		local ruleDstMask = uci:get("qos",edit,"dst_mask")
		local ruleDstPort = uci:get("qos",edit,"dport")
		local ruleCategory = uci:get("qos",edit,"category")
		local ruleDir = uci:get("qos",edit,"from_intf")
		local ruleProto = uci:get("qos",edit,"proto")
		
		luci.template.render("expert_configuration/qos_cfg_edit", {
			section_name = edit,
			rule_name = ruleName,
			rule_enable = ruleEnable,
			rule_src = ruleSrc,
			rule_src_mask = ruleSrcMask,
			rule_src_port = ruleSrcPort,
			rule_dst = ruleDst,
			rule_dst_mask = ruleDstMask,
			rule_dst_port = ruleDstPort,
			rule_category = ruleCategory,
			rule_dir = ruleDir,
			rule_proto = ruleProto
		})
		
	elseif delete then
		uci:set("qos",delete,"name","")
		uci:set("qos",delete,"enable",0)
		uci:set("qos",delete,"src","")
		uci:set("qos",delete,"src_mask","")
		uci:set("qos",delete,"sport","")
		uci:set("qos",delete,"dst","")
		uci:set("qos",delete,"dst_mask","")
		uci:set("qos",delete,"dport","")
		uci:set("qos",delete,"category","")
		uci:set("qos",delete,"from_intf","")
		uci:set("qos",delete,"proto","")
		
		uci:commit("qos")
		uci:apply("qos")
		luci.template.render("expert_configuration/qos_adv")
	else
		luci.template.render("expert_configuration/qos_adv")
	end
	
end

function Dec2Hex(nValue)
	local string = require("string")
	if type(nValue) == "string" then
		nValue = tonumber(nValue)
	end
	nHexVal = string.format("%X", nValue);  -- %X returns uppercase hex, %x gives lowercase letters
	sHexVal = nHexVal..""
	return sHexVal
end

-- MSTC, Sharon mark configuration->remote MGMT
--[[
function action_wol()
	local wolApply = luci.http.formvalue("wol_apply")
	local wolStart = luci.http.formvalue("wol_start")
	local mac = luci.http.formvalue("host_mac")
	local tmp = sys.exec("ifconfig lan | awk '/Bcast/{print $3}'")
	local lanBcast = tmp:match("Bcast:(%d+.%d+.%d+.%d+)")
	if not mac then
		mac = ""
	end
			
	if wolApply then
		local wolWanEnable = luci.http.formvalue("wol_wan_enable")
		local wolPort = luci.http.formvalue("wol_port")
		if not wolPort then
			wolPort = 9
		end
		uci:set("wol", "main", "enabled", wolWanEnable)
		uci:set("wol", "main", "port", wolPort)
		uci:set("wol", "main", "broadcast", lanBcast)
		
		-- default we save mac addrerss but don't apply wol
		uci:set("wol", "wol", "enabled", "0")
		uci:set("wol", "wol", "mac", mac)
		uci:commit("wol")
		uci:apply("wol")
	end
	
	if wolStart then
		uci:set("wol", "wol", "enabled", wolStart)
		uci:set("wol", "wol", "mac", mac)
		uci:set("wol", "wol", "broadcast", lanBcast)
		uci:commit("wol")
		uci:apply("wol")
	end
	
	luci.template.render("expert_configuration/wol")
end
--]]

-- MSTC, Sharon add lan ipv6
function action_lan_ipv6()
	local apply = luci.http.formvalue("IPv6Submit")
	
	if apply then
		local address_assign = luci.http.formvalue("LAN_IPv6_Address_Assign")
		local ipv6_dns_type_1 = luci.http.formvalue("IPv6_DNS_Type_1")
		local ipv6_dns_type_2 = luci.http.formvalue("IPv6_DNS_Type_2")
		local ipv6_dns_1 = luci.http.formvalue("IPv6_DNS_1")
		local ipv6_dns_2 = luci.http.formvalue("IPv6_DNS_2")
		local ipv6_start_addr = luci.http.formvalue("IPv6_Start_Address")
		local ipv6_end_addr = luci.http.formvalue("IPv6_End_Address")

		-- If DNS type is FromISP(0), we don't need to store this value!
		if (ipv6_dns_type_1 == "0") then
			ipv6_dns_1 = ""
		end
		if (ipv6_dns_type_2 == "0") then
			ipv6_dns_2 = ""
		end		
	
		if not (address_assign=="") then
			uci:set("lan_ipv6","general","assign_type",address_assign)
		end
		if not (ipv6_dns_type_1=="") then
			uci:set("lan_ipv6","general","dns_type_1",ipv6_dns_type_1)
		end
		if not (ipv6_dns_type_2=="") then
			uci:set("lan_ipv6","general","dns_type_2",ipv6_dns_type_2)
		end
		if ipv6_dns_1 then
			if not (ipv6_dns_1=="") then
				uci:set("lan_ipv6","general","dns_server_1",ipv6_dns_1)
			else
				uci:delete("lan_ipv6","general","dns_server_1")
			end
		end
		if ipv6_dns_2 then		
			if not (ipv6_dns_2=="") then
				uci:set("lan_ipv6","general","dns_server_2",ipv6_dns_2)
			else
				uci:delete("lan_ipv6","general","dns_server_2")
			end
		end
		
		if not (ipv6_start_addr=="") then
			uci:set("lan_ipv6","general","start_addr",ipv6_start_addr)
		end
		if not (ipv6_end_addr=="") then
			uci:set("lan_ipv6","general","end_addr",ipv6_end_addr)
		end	
		
		uci:commit("lan_ipv6")
		sys.exec("/sbin/ipv6")

	end



	luci.template.render("expert_configuration/lan_ipv6")
end
-- end

-- MSTC, Sharon add dmz
function action_dmz()
	local apply = luci.http.formvalue("apply")
	
	if apply then
		local serChange = luci.http.formvalue("serChange")
		local changeToSerIP = luci.http.formvalue("changeToSerIP")
		local last_changeToSerIP
		local changeToSer = 0		
		if (serChange=="change") then
			if not (changeToSerIP=="") then
				local changeToSer = 1
				uci:set("nat","general","changeToSer",changeToSer)
				uci:set("nat","general","changeToSerIP",changeToSerIP)
			end	
		else
			last_changeToSerIP = uci:get("nat","general","changeToSerIP")
			if last_changeToSerIP then
				uci:delete("nat","general","changeToSerIP")
				--uci:set("nat","general","last_changeToSerIP",last_changeToSerIP)
			end
			uci:set("nat","general","changeToSer",changeToSer)			
			
		end	
		
		uci:commit("nat")
		uci:apply("nat")
		sys.exec("/usr/sbin/nat reload")
	end	
	
	luci.template.render("expert_configuration/dmz")
end
-- end
