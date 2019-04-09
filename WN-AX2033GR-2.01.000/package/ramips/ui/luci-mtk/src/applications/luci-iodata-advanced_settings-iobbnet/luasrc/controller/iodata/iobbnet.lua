--[[
LuCI - Lua Configuration Interface

Copyright 2011 Manuel Munz <freifunk somakoma de>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

]]--


module ("luci.controller.iodata.iobbnet", package.seeall)
local uci = require("luci.model.uci").cursor()
local sys = require("luci.sys")
local csrf = require("luci.csrf")
local datatypes  = require("luci.cbi.datatypes")

function index()
	local uci2 = require("luci.model.uci").cursor()
	
	local mode_check = uci2:get("network","wan","mode")
	if not (mode_check == "repeater" or mode_check == "v6plus" or mode_check == "transix") then
		entry({"content", "advanced_settings", "iobbnet"}, call("action_iobbnet"), _("iobb.net"), 4).leaf = true		
	end	
	
	
end

--MSTC MBA Sean, we need to add firewall rule to let upnp response pass the firewall
function add_upnp_firewall_rule()

	local rule = uci:add("firewall", "rule")
	uci:set("firewall", rule, "name", "Allow-upnp-response")
	uci:set("firewall", rule, "src", "wan")
	uci:set("firewall", rule, "proto", "udp")
	uci:set("firewall", rule, "src_port", "1900")
	uci:set("firewall", rule, "target", "ACCEPT")
	uci:set("firewall", rule, "family", "ipv4")
	
	uci:commit("firewall")
	sys.exec("/etc/init.d/firewall restart")
	-- fw3 restart willl flush miniupnp rule
	sys.exec("/etc/init.d/miniupnpd restart 2>/dev/null")
end

function delete_upnp_firewall_rule()
	local rule_name
	
	uci.foreach("firewall", "rule",
	function(s)
		if( s.name == "Allow-upnp-response" ) then
			rule_name = s[".name"]
		end
	end)
	
	if rule_name ~= nil then
		uci:delete("firewall", rule_name);
	end
	
	uci:commit("firewall")
	sys.exec("/etc/init.d/firewall restart")
	-- fw3 restart willl flush miniupnp rule
	sys.exec("/etc/init.d/miniupnpd restart 2>/dev/null")
end

function action_iobbnet()

	local apply = luci.http.formvalue("isApply")
	local address_update = luci.http.formvalue("isAddressUpdate")
	local wrong_value = false
	-- get current mode before set
	local current_mode = uci:get("ddns", "global", "mode")
	-- action: nop: do nothing/ run: run daemon/ sginal: send signal
	local action = "nop"
	-- error protection for pgrap command => use grep if pgrep not available
	local cmd_get_pid = "/usr/bin/pgrep /usr/sbin/ddns"

	-- test pgrep is available
	sys.exec("/usr/bin/pgrep > /tmp/check_pgrep_cmd 2>&1")
	local pgrep_cmd_not_found = sys.exec("/bin/cat /tmp/check_pgrep_cmd")
	
	if (string.find(pgrep_cmd_not_found,"not found")) == nil then	
		cmd_get_pid = "/usr/bin/pgrep /usr/sbin/ddns"
	else		
		cmd_get_pid = "ps | grep /usr/sbin/ddns | awk \'{print $1}\' | tr \"\n\" \" \" | awk \'{print $1}\'"
	end
	
	local cmd_send_sig_usr1 = "/bin/kill -SIGUSR1 " .. "`" .. cmd_get_pid .. "`"
	local cmd_send_sig_alrm = "/bin/kill -SIGALRM " .. "`" .. cmd_get_pid .. "`"	
	
	if apply == "1" then		
		
		--[[=========CSRF check Start=========--]]
		local csrf_token_web = csrf.get_csrf_token_in_web()
		--if csrf token is wrong or can't get it from web, return 403
		if ( not csrf.verify(csrf_token_web) ) then
			wrong_value = true
			csrf.http_return_403()
			return
		end
		--[[=========CSRF check End=========--]]		
		
		-- Do it
		local request_ddns_mode = luci.http.formvalue("ddnsMode")
		local username = luci.http.formvalue("iobbSerialNumber")
		local password = luci.http.formvalue("iobbPassword")
		local domain = luci.http.formvalue("iobbHostname")

		--[[
        DDNS mode: 0/disable, 1/preset, 2/enable
		current mode        request mode
		0                   0    => do nothing
				            1    => run ddns
			                2    => run ddns

		1                   0    => All send signal
				            1
			                2

		2                   0    => All send signal
				            1
			                2

		--]]

		if current_mode == "0" then      -- current is disable
			uci:set("ddns", "global", "mode", request_ddns_mode)
			
			if request_ddns_mode == "0" then						
				action = "nop"
			elseif request_ddns_mode == "1" then	
				add_upnp_firewall_rule()
				action = "run"
			elseif request_ddns_mode == "2" then	
				add_upnp_firewall_rule()
				uci:set("ddns", "iobbnet", "username", username)
				uci:set("ddns", "iobbnet", "password", password)
				uci:set("ddns", "iobbnet", "domain", domain)
				action = "run"
			else
				wrong_value = true
			end						
			
		elseif (current_mode == "1") or (current_mode == "2") then  -- current is preset or enable mode
			uci:set("ddns", "global", "mode", request_ddns_mode)
			action = "signal"
			
			--MSTC MBA Sean, when ddns change from enable to disable, remove the firewall fule
			if( request_ddns_mode == "0") then
				delete_upnp_firewall_rule()
			end
			
			if request_ddns_mode == "2" then  -- only when enable mode needs set uci config			
				uci:set("ddns", "iobbnet", "username", username)
				uci:set("ddns", "iobbnet", "password", password)
				uci:set("ddns", "iobbnet", "domain", domain)		
			end				
			
		else
			wrong_value = true
		end
		
		
		if not wrong_value then
			uci:commit("ddns")				
			if action == "run" then
				sys.exec("/etc/init.d/ddns restart")
			elseif action == "signal" then
				sys.exec(cmd_send_sig_usr1)
			end				
		end
	end

	
	
	if address_update == "1" then		
		if current_mode == "1" or current_mode == "2" then 		
			sys.exec(cmd_send_sig_alrm)
		end
	end

	
	luci.template.render("iodata/iobbnet")

end
