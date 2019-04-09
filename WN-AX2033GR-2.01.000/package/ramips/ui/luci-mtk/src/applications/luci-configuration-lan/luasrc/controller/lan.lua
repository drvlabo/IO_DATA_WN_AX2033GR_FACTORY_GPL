module("luci.controller.lan", package.seeall)
local uci = require("luci.model.uci").cursor()
local sys = require("luci.sys")

function index()
	local i18n = require("luci.i18n")
	local libuci = require("luci.model.uci").cursor()
	local lang = libuci:get("luci","main","lang") 
	i18n.load("lan",lang)
	i18n.setlanguage(lang)
	
	local page  = node("expert", "configuration", "network", "lan")
	page.target = call("action_lan")
	page.title  = i18n.translate("LAN")  
	page.order  = 65
	
	local page  = node("expert", "configuration", "network", "lan", "ipv6")
	page.target = call("action_lan_ipv6")
	page.title  = i18n.translate("lan_ipv6")  
	page.order  = 66  
end

function action_lan()
	local apply = luci.http.formvalue("apply")
	
	if apply then	
		local ipaddr  = luci.http.formvalue("ipaddr")
		local netmask = luci.http.formvalue("netmask")
		local lan_ip = uci:get("network", "lan", "ipaddr")
		local lan_mask = uci:get("network", "lan", "netmask")
		local dhcp_disable = uci:get("dhcp", "lan", "ignore")
		local dhcp_start = uci:get("dhcp", "lan", "start")
		local dhcp_pool = uci:get("dhcp", "lan", "limit")
		
		--marco
		local ignore = luci.http.formvalue("ssid_state")
		local startAddress = luci.http.formvalue("startAdd")
		local poolSize = luci.http.formvalue("poolSize")
		local start=string.match(startAddress,"%d+.%d+.%d+.(%d+)")
		
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
		
		if not (ignore == dhcp_disable) then
			uci:set("dhcp","lan",'ignore',ignore)
			changed = true
		end
		
		
		if not (start == dhcp_start) then
			uci:set("dhcp","lan",'start',start)
			changed = true
		end
		
		if not (poolSize == dhcp_pool) then
			uci:set("dhcp","lan",'limit',poolSize)
			changed = true
		end

		if changed then		
            uci:commit("dhcp")
			uci:commit("network")
			uci:apply("network")
			uci:apply("dhcp")
			sys.exec("/etc/init.d/network reload")
			--marco
			sys.exec("/etc/init.d/dnsmasq stop 2>/dev/null")
			sys.exec("/etc/init.d/dnsmasq start 2>/dev/null")					

			local _sessionpath = luci.config.sauth.sessionpath
			luci.sys.exec("rm ".._sessionpath.."/*")
		end		
	end

	luci.template.render("lan")
end

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



	luci.template.render("lan_ipv6")
end