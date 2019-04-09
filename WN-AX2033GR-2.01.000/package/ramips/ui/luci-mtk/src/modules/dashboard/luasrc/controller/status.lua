--[[
LuCI - Lua Configuration Interface

Copyright 2008 Steven Barth <steven@midlink.org>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

$Id: index.lua 4040 2009-01-16 12:35:25Z Cyrus $
]]--
module("luci.controller.status", package.seeall)
local uci = require("luci.model.uci").cursor()
local sys = require("luci.sys")

function index()
	
	local root = node()
	if not root.target then
		root.target = alias("expert")
		root.index = true
	end

	local page   = node("session_check")
	page.target  = call("action_session_check")
	page.title   = "session_check"
	page.ignoreindex = true
	page.order   = 10
	
	local page   = node("expert")
	page.target  = alias("expert", "passWarning")
	page.title   = "Expert Mode"
	
	--page.sysauth = "admin"
	-- MSTC MBA SW, 20160113 Sean, the original openwrt is using root as sysauth
	page.sysauth = "root"
	page.sysauth_authenticator = "htmlauth"
	page.order   = 10
	page.index   = true
	
	local page   = node("expert","passWarning")
	page.target  = call("action_passWarning")
	page.title   = "passWarning"
	page.ignoreindex = true
	page.order   = 10
	
	local page   = node("expert", "status")
	page.target  = call("action_status")
	page.title   = "Status"
	page.ignoreindex = true
	page.order   = 10
		
	entry({"expert", "logout"}, call("action_logout"), "Logout", 20)
	entry({"expert", "top"}, template("../../../../../tmp/web/top"))
	entry({"expert", "under"}, template("../../../../../tmp/web/under"))
	entry({"expert", "path"}, template("../../../../../tmp/web/path"))
	
	entry({"expert", "leftmonitor"}, template("../../../../../tmp/web/leftmonitor"))
	entry({"expert", "leftconfig"}, template("../../../../../tmp/web/leftconfig"))
	entry({"expert", "leftmaintenance"}, template("../../../../../tmp/web/leftmaintenance"))
end

function action_session_check()
	luci.template.render("../../../../../tmp/web/session_check")
end

function action_passWarning()
	local login_count_file = "/tmp/login_count"
	local file,err = io.open(login_count_file,"r")	
	if(err == nil) then
		file:close()
		sys.exec("rm " .. login_count_file)
	end
	
	local pwwarning_disable = uci:get("account_info","info","pwwarning_disable")
	if pwwarning_disable == "1" then
		action_status()
	else
		local apply = luci.http.formvalue("apply")
		local skip = luci.http.formvalue("skip")
		if apply then
			local new_password  = luci.http.formvalue("new_password")
			
			local set_pw = luci.sys.user.setpasswd("admin", new_password)
			if set_pw == 0 then
				local pw_encrypt = sys.exec("cat /etc/shadow | grep admin | cut -d ':' -f 2")
				uci:set("account_info", "info", "password1", pw_encrypt)
				uci:set("account_info", "info", "pwwarning_disable", "1")
				uci:commit("account_info")
				action_status()
			else
				luci.template.render("../../../../../tmp/web/passWarning",{pw_confirm = -1})
			end
		elseif skip then
			action_status()
		else
			luci.template.render("../../../../../tmp/web/passWarning")
		end	
	end
end

function action_logout()
        local dsp = require "luci.dispatcher"
        local sauth = require "luci.sauth"
        if dsp.context.authsession then
                sauth.kill(dsp.context.authsession)
                dsp.context.urltoken.stok = nil
        end
		
		local _sessionpath = luci.config.sauth.sessionpath
		sys.exec("rm ".._sessionpath.."/*")

        luci.http.header("Set-Cookie", "sysauth=; path=" .. dsp.build_url())
        luci.http.redirect(luci.dispatcher.build_url())
end

function action_status()

	local refreshInteval  = luci.http.formvalue("refreshInteval")
	
	if refreshInteval then
		local file2 = io.open( "/tmp/refresh", "w" )
        	file2:write(refreshInteval)
        	file2:close()
        	local url = luci.dispatcher.build_url("expert","status")
        	luci.http.redirect(url)
        	return
   	end

	-- Modify by YaoTien.001 on 20121114, for unnecessary task
	-- local file3 = io.open( "/tmp/firmware_version", "r" )
	-- local fw_ver = file3:read("*line")
	-- file3:close()
	-- End of Modify by YaoTien.001 on 20121114, for unnecessary task

	local security_24G
	local security_5G
	local security24G = uci.get("wireless.ath0.encryption")
	local security5G = uci.get("wireless5G","general","auth")
      --read WPA-PSK Compatible value
        local WPAPSKCompatible_24G = uci.get("wireless", "general", "WPAPSKCompatible")
        local WPAPSKCompatible_5G = uci.get("wireless5G", "general", "WPAPSKCompatible")
      --read WPA Compatible value
        local WPACompatible_24G = uci.get("wireless", "general", "WPACompatible")
        local WPACompatible_5G = uci.get("wireless5G", "general", "WPACompatible")


	if security24G == "WPAPSK" then
		security_24G="WPA-PSK"
	elseif security24G == "WPA2PSK" then
      -- add by darren 2012.03.07
                if WPAPSKCompatible_24G == "0" then
                        security_24G="WPA2-PSK"
                elseif WPAPSKCompatible_24G == "1" then
                        security_24G="WPA-PSK / WPA2-PSK"
                end
      --
	elseif security24G == "WEPAUTO" or security24G == "SHARED" then
		security_24G="WEP"
	elseif security24G == "OPEN" then
		security_24G="No Security"
      -- add by darren 2012.03.07
        elseif security24G == "WPA2" then
                if WPACompatible_24G == "0" then
                        security_24G=security24G
                elseif WPACompatible_24G == "1" then
                        security_24G="WPA / WPA2"
                end
      --
	else
		security_24G=security24G
	end

        if security5G == "WPAPSK" then
                security_5G="WPA-PSK"
        elseif security5G == "WPA2PSK" then
      -- add by darren 2012.03.07
                if WPAPSKCompatible_5G == "0" then
                        security_5G="WPA2-PSK"
                elseif WPAPSKCompatible_5G == "1" then
                        security_5G="WPA-PSK / WPA2-PSK"
                end
      -- 
        elseif security5G == "WEPAUTO" or security5G == "SHARED" then
                security_5G="WEP"
        elseif security5G == "OPEN" then
                security_5G="No Security"
      -- add by darren 2012.03.07
	elseif security5G == "WPA2" then
		if WPACompatible_5G == "0" then
			security_5G=security5G
		elseif WPACompatible_5G == "1" then
			security_5G="WPA / WPA2"
		end
      --
	else
                security_5G=security5G
        end

	local mode_24G
	local mode_5G
	local bitRate_24G
	local bitRate_5G
	local width_24G
	local width_5G

	mode_24G = uci.get("wireless", "general", "hwmode")
	mode_5G = uci.get("wireless5G", "general", "mode")
	width_24G = uci.get("wireless", "general", "htmode")
	width_5G = uci.get("wireless5G", "general", "channel_width")

	if mode_24G == "11b" then
		bitRate_24G = "11M"
	elseif  mode_24G == "11g" or mode_24G == "11bg" then
		bitRate_24G = "54M"
	else
		if width_24G == "HT20" then
			bitRate_24G = "216.7M"
		else
			bitRate_24G = "450M"
		end
	end

        if mode_5G == "11a" then
                bitRate_5G = "54M"
        else
                if width_5G == "20" then
                        bitRate_5G = "216.7M"
                else
                        bitRate_5G = "450M"
                end
        end

	--IPv6
	local wan_mode = uci:get("network6","wan","type")
	local wan_ipv6_iface
	local wan_ipv6_addr=""
	local lan_ipv6_addr=""
	if wan_mode == "tunnel" then
		wan_ipv6_iface = sys.exec("ifconfig tun")
		if wan_ipv6_iface ~= "" then
			wan_ipv6_addr = sys.exec("ifconfig tun | awk '/Global/{print $3}'")
		else
			wan_ipv6_iface = sys.exec("ifconfig sit1")
			if wan_ipv6_iface ~= "" then
				wan_ipv6_addr = sys.exec("ifconfig sit1 | awk '/Global/{print $3}'")
			end
		end

		lan_ipv6_addr = sys.exec("ifconfig lan | awk '/Global/{print $3}'")
	end
	
	--Leo, this will update WAN information to UCI before we try to load dashboard page
	sys.exec("/usr/sbin/update_wan_to_uci.sh")

 	luci.template.render("../../../../../tmp/web/dashboard",{firmware_version = fw_ver,
							security_24g = security_24G,
							security_5g = security_5G,
							rate24G = bitRate_24G,
							rate5G = bitRate_5G,
							wan_addr_v6 = wan_ipv6_addr,
							lan_addr_v6 = lan_ipv6_addr})
end
