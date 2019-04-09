--[[
LuCI - Lua Configuration Interface

Copyright 2011 Manuel Munz <freifunk somakoma de>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

]]--

module ("luci.controller.iodata.passthrough", package.seeall)
local uci = require("luci.model.uci").cursor()
local sys = require("luci.sys")
local csrf = require("luci.csrf")

function index()
	local uci2 = require("luci.model.uci").cursor()
	local exanime_mode = uci2:get("network","wan","mode")
	if exanime_mode == "router" then
		entry({"content", "security", "passthrough"}, call("action_passthrough"), _("PASSTHROUGH"), 1).leaf = true
	end
end

function action_passthrough()
	local isApply = luci.http.formvalue("isApply")
	if isApply then
	
		--[[=========CSRF check Start=========--]]
		local csrf_token_web = csrf.get_csrf_token_in_web()
		--if csrf token is wrong or can't get it from web, return 403
		if ( not csrf.verify(csrf_token_web) ) then 
			wrong_value = true;
			csrf.http_return_403()
			return
		end
		--[[=========CSRF check End=========--]]
	
		local pptpEnableStr = luci.http.formvalue("pptpDataStr")
		local ipsecEnableStr = luci.http.formvalue("ipsecDataStr")
		local ipsec_conntrac_del = "0"
		local pptp_conntrac_del = "0"
		local def_node={}
		local cnt=0
		uci:foreach("firewall", "defaults", function(s) 
			def_node[cnt]=s[".name"]  
			cnt = cnt + 1
		end)

		uci:set("firewall", def_node[0], "pptp_rule_enable", pptpEnableStr)
		uci:set("firewall", def_node[0], "ipsec_rule_enable", ipsecEnableStr)
		if pptpEnableStr == "1" then
			uci:delete("firewall", "pptp_rule_name")
		else
			local test = uci:get("firewall", "pptp_rule_name")
			if test ~= nil then
				uci:delete("firewall", "pptp_rule_name")
			end

			local pptp_rule_name = uci:add("firewall", "rule")
			uci:rename("firewall", pptp_rule_name,"pptp_rule_name")
			uci:set("firewall", "pptp_rule_name", "src", "*")
			uci:set("firewall", "pptp_rule_name", "dest", "*")
			uci:set("firewall", "pptp_rule_name", "proto", "tcp")
			uci:set("firewall", "pptp_rule_name", "dest_port", "1723")
			uci:set("firewall", "pptp_rule_name", "target", "DROP")
			pptp_conntrac_del = "1"
		end
		-- set IPsec DROP rule to the firewall
		if ipsecEnableStr == "1" then
			uci:delete("firewall", "ipsec_rule_conn")
			uci:delete("firewall", "ipsec_rule_data")
		else
			local test = uci:get("firewall", "ipsec_rule_conn")
			if test ~= nil then
				uci:delete("firewall", "ipsec_rule_conn")
			end

			local ipsec_rule_conn = uci:add("firewall", "rule")
			uci:rename("firewall", ipsec_rule_conn,"ipsec_rule_conn")
			uci:set("firewall", "ipsec_rule_conn", "src", "*")
			uci:set("firewall", "ipsec_rule_conn", "dest", "*")
			uci:set("firewall", "ipsec_rule_conn", "proto", "udp")
			uci:set("firewall", "ipsec_rule_conn", "dest_port", "500")
			uci:set("firewall", "ipsec_rule_conn", "target", "DROP")
		
			local test2 = uci:get("firewall", "ipsec_rule_data")
			if test2 ~= nil then
				uci:delete("firewall", "ipsec_rule_data")
			end
			local ipsec_rule_data = uci:add("firewall", "rule")
			uci:rename("firewall", ipsec_rule_data,"ipsec_rule_data")
			uci:set("firewall", "ipsec_rule_data", "src", "*")
			uci:set("firewall", "ipsec_rule_data", "dest", "*")
			uci:set("firewall", "ipsec_rule_data", "proto", "udp")
			uci:set("firewall", "ipsec_rule_data", "dest_port", "4500")
			uci:set("firewall", "ipsec_rule_data", "target", "DROP")
			ipsec_conntrac_del = "1"
		end
	
		uci:commit("firewall")

		sys.exec("/etc/init.d/firewall restart 2>/dev/null")
		-- fw3 restart willl flush miniupnp rule
		sys.exec("/etc/init.d/miniupnpd restart 2>/dev/null")

		--after set IPsec/PPTP DROP rule to the firewall, it is necessary to delete relatived conntrack to stop re-establish.
		if (ipsec_conntrac_del == "1") and (pptp_conntrac_del =="1") then --delete both ipsec and pptp conntrack
			sys.exec("conntrack -D -p udp --dport 500 2>/dev/null")
			sys.exec("conntrack -D -p udp --dport 4500 2>/dev/null")
			sys.exec("conntrack -D -p tcp --dport 1723 2>/dev/null")
		elseif (pptp_conntrac_del == "1") then --delete pptp contrack only
			sys.exec("conntrack -D -p tcp --dport 1723 2>/dev/null")
		elseif (ipsec_conntrac_del == "1") then -- delete ipsec conntrack only
			sys.exec("conntrack -D -p udp --dport 500 2>/dev/null")
			sys.exec("conntrack -D -p udp --dport 4500 2>/dev/null")
		end
	end

	luci.template.render("iodata/passthrough")
end
