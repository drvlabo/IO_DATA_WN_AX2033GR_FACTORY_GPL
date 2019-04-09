--[[
LuCI - Lua Configuration Interface

Copyright 2008 Steven Barth <steven@midlink.org>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

$Id: index.lua 4040 2009-01-16 12:35:25Z Cyrus $
]]--
module("luci.controller.expert.monitor", package.seeall)
local uci = require("luci.model.uci").cursor()
local sys = require("luci.sys")

function index()
	
	local i18n = require("luci.i18n")
	local libuci = require("luci.model.uci").cursor()
	local lang = libuci:get("luci","main","lang") 
	i18n.load("admin-core",lang)
	i18n.setlanguage(lang)
	
	local page  = node("expert", "monitor")
	page.target = template("expert_monitor/monitor")
	page.title  = i18n.translate("Monitor")  
	page.order  = 40
	
	local page  = node("expert", "monitor", "log")
	page.target = call("action_viewlog")
	page.title  = i18n.translate("Log")  
	page.order  = 40

-- MSTC, Sharon mark monitor->log->logsettings
--[[
	local page  = node("expert", "monitor", "log", "logsettings")
	page.target = call("action_log_setting")
	page.title  = "Log Settings"  
	page.order  = 40
--]]
	
	local page  = node("expert", "monitor", "dhcptable")
	page.target = call("action_monitorClientList")
	page.title  = i18n.translate("DHCP_Table")  
	page.order  = 50

-- MSTC, Sharon mark monitor->Packet_Statistics
--[[	
	local page  = node("expert", "monitor", "pktstats")
	page.target = call("action_monitorSum_SysStatus")
	page.title  = i18n.translate("Packet_Statistics")  
	page.order  = 60
--]]
	
-- jeffary Add monitor->wanstats, 2012.08.07
	local page  = node("expert", "monitor", "wanstats")
	page.target = call("action_wanstatus")
	page.title  = i18n.translate("WAN_Status") 
	page.order  = 65

-- jeffary mark monitor->vpnmonitor, 2012.08.01
--[[
	local page  = node("expert", "monitor", "vpnmonitor")
	--page.target = template("expert_monitor/Sum_VPNMonitor0")
	page.target = call("action_vpnmonitor")
	page.title  = i18n.translate("VPN_Monitor")  
	page.order  = 70
]]--

-- MSTC, Sharon, add monitor->sms 	
	local page  = node("expert", "monitor", "sms")
	page.target = call("action_sms")
	page.title  = "SMS"  
	page.order  = 75
	
	local page  = node("expert", "monitor", "sms", "sms_send")
	page.target = call("action_sms_send")
	page.title  = "SMS"  
	page.order  = 75
-- end		

-- MSTC, Sharon mark monitor->wlanstats_24g
--[[
	local page  = node("expert", "monitor", "wlanstats_24g")
	page.target = template("expert_monitor/Sum_AssocList_24g")
	page.title  = i18n.translate("WLAN_2_dot_4_G_Station_Status")  
	page.order  = 80
--]]
	
	-- jeffary mark monitor->wlanstats_5g, 2012.08.01
--[[
	local page  = node("expert", "monitor", "wlanstats_5g")
	page.target = template("expert_monitor/Sum_AssocList_5g")
	page.title  = i18n.translate("WLAN_5_G_Station_Status")  
	page.order  = 81
]]--
end

-- Eten : view log & log setting
function viewlog_getLogType(lvName, procName, str) -- wen-hsiang 2011/09/16 --
--	if "kernel" == procName:lower() then
--		if string.find(lvName, "err") then
--			return "SysErrs"
--		else
--			return "SysMaintenance"
--		end

--	else
--		if string.find(str,"Firmware") then  -- wen-hsiang 2011/09/16 --
--			return "Firmware"
--		else
--		        return "AccessCtrl"
--		end
--	end
	if string.find(lvName, "emerg") then
		return "SysEmergency"
	elseif string.find(lvName, "alert") then
		return "SysAlert"
	elseif string.find(lvName, "crit") then
		return "SysCritical"
	elseif string.find(lvName, "err") then
		return "SysError"
	elseif string.find(lvName, "warn") then
		return "SysWarning"
	elseif string.find(lvName, "notice") then
		return "SysNotice"
	elseif string.find(lvName, "info") then
		return "SysInfo"
	elseif string.find(lvName, "debug") then
		return "SysDebug"
	else
		return "AccessCtrl"	
	end
	
end

function viewlog_parsePrefix(inputStrPre,inputStrAll) -- wen-hsiang 2011/09/16 --
	local result = {}; idx = 1

	while not (nil == idx) do
		local tail = inputStrPre:find("%s", idx)

		if nil == tail then
			table.insert(result, inputStrPre:sub(idx, inputStrPre:len()))
			break
		else
			table.insert(result, inputStrPre:sub(idx, tail - 1))
		end
		idx = tail + 1
	end

	if #result >= 3 then
		result["OSName"]   = result[1]
		result["LvName"]   = result[2]
		result["ProcName"] = result[3]
		result["LvType"]   = viewlog_getLogType(result.LvName, result.ProcName, inputStrAll)  -- wen-hsiang 2011/09/16 --
		return result
	end

	return nil
end

function action_viewlog()
	local srcMsgFileName = "/var/log/messages"
	local dstMsgFileName = "/tmp/logMsgs"
	local submitType = luci.http.formvalue("ViewLogSubmitType")

	if submitType and "Clear Log" == submitType then
		uci:apply("syslogd")
	else
		local logMsgs = {}; logList = {}

		--logList["SysMaintenance"] = { ["name"] = "System Maintenance" }
		--logList["SysErrs"]        = { ["name"] = "System Errors" }
		--logList["Firmware"]       = { ["name"] = "On-line Firmware upgrade" }  -- wen-hsiang 2011/09/16 --
		logList["SysEmergency"]        = { ["name"] = "System Emergency" }
		logList["SysAlert"]        = { ["name"] = "System Alert" }
		logList["SysCritical"]        = { ["name"] = "System Critical" }
		logList["SysError"]        = { ["name"] = "System Error" }
		logList["SysWarning"]        = { ["name"] = "System Warning" }
		logList["SysNotice"]        = { ["name"] = "System Notice" }
		logList["SysInfo"]        = { ["name"] = "System Info" }
		logList["SysDebug"]        = { ["name"] = "System Debug" }
		logList["AccessCtrl"]     = { ["name"] = "Access Control" }

		for name, item in pairs(logList) do
                        -- for hide message, NBG5715, wen-hsiang, 2011/11/03
                        if name == "SysMaintenance" then
                           local value = nil -- for hide message, NBG5715, wen-hsiang, 2011/11/03
                        else
			   value = uci:get("syslogd", "setting", "log" .. name)
                        end

			if not ( nil == value ) and tonumber(value) > 0 then
				uci:set("syslogd", "setting", "log" .. name, "1")
				uci:commit("syslogd")
				item["enabled"] = true
			else
				item["enabled"] = false
			end
		end

		local viewType = luci.http.formvalue("ViewLogType")

		if nil == viewType then
			viewType = "AllLogs"
		end

		if "AllLogs" == viewType then
			for name, item in pairs(logList) do
				if item.enabled then
					item["display"] = "1"
				end
			end
		else
			uci:set("syslogd", "setting", "log" .. viewType, "2")
			uci:commit("syslogd")
			logList[viewType]["display"] = "1"
		end

		sys.exec("logread > " .. srcMsgFileName)

		local srcFile = io.open(srcMsgFileName, "r")
		local dstFile = io.open(dstMsgFileName, "w")

		if not (nil == srcFile) then
			for msgLine in srcFile:lines() do
				local prefixIdx = msgLine:find(":", 16)
				if not (nil ==  prefixIdx) then
					local prefix = viewlog_parsePrefix(string.gsub(msgLine:sub(16, prefixIdx - 1), "^%s*(.-)%s*$", "%1"),msgLine)  -- wen-hsiang 2011.9.16. --
					if not (nil == prefix) and "1" == logList[prefix.LvType].display then
						dstFile:write(msgLine:gsub(prefix.OSName, "", 1) .. "\n")
--						dstFile:write(string.format("%s %s %s%s\n", msgLine:sub(1, 15), prefix.LvName, prefix.ProcName, msgLine:sub(prefixIdx, msgLine:len())))
					end
				end
			end
		end

		dstFile:close()
		srcFile:close()

		os.remove(srcMsgFileName)
	end

	luci.template.render("expert_monitor/viewlog")

	os.remove(dstMsgFileName)
end

function logsetting_setLogCategory(prefix, cateTable)
	for i, item in ipairs(cateTable) do
		local formValue = luci.http.formvalue(prefix .. item)
		local token = string.lower(prefix:sub(1, 1)) .. prefix:sub(2, prefix:len()) .. item

		if not (nil == formValue) and "on" == formValue then
			uci:set("syslogd", "setting", token, 1)
		else
			uci:set("syslogd", "setting", token, 0)
		end
	end
end

function action_log_setting()
	local apply = luci.http.formvalue("apply")
	
	if apply then
		logsetting_setLogCategory("Log", {
			"SysEmergency",
			"SysAlert",
			"SysCritical",
			"SysError",
			"SysWarning",
			"SysNotice",
			"SysInfo",
			"SysDebug",
			"AccessCtrl"
		})

--		logsetting_setLogCategory("Alert", {
--			"SysErrs",
--			"AccessCtrl",
--			"BlkedWebSites",
--			"BlkedJavaEtc",
--			"Attacks",
--			"IPSec",
--			"IKE"
--		})

		uci:save("syslogd")
		uci:commit("syslogd")
	end

	luci.template.render("expert_monitor/log_settings")
end
-- Eten : END

function action_monitorClientList()
        local apply = luci.http.formvalue("sysSubmit")
        if apply then
                local staticIp= luci.http.formvalue("macIp")
                local onlyOne=luci.http.formvalue("onlyOne")
                uci:set("dhcp","lan",'staticIP',staticIp)
                uci:commit("dhcp")
                uci:apply("dhcp")

		local staticInfo=uci.get("dhcp","lan","staticIP")


		if not staticInfo then
			local file = io.open( "/etc/ethers", "w" )
			file:write("")
			file:close()
		else
			local have=string.split(staticInfo,";")

			if onlyOne=="1" then
				local file = io.open( "/etc/ethers", "w" )
				file:write(staticInfo .. "\n")
				file:close()
			else
				local file = io.open( "/etc/ethers", "w" )
				for index,info in pairs(have) do
					file:write(info .. "\n")
				end
				file:close()
			end

		end
		sys.exec("/etc/init.d/dnsmasq stop 2>/dev/null")
		sys.exec("/etc/init.d/dnsmasq start 2>/dev/null")
        end

	luci.template.render("expert_monitor/Sum_DHCP")
end

function action_monitorSum_SysStatus()
	local SetIntvl = luci.http.formvalue("SetIntvl")
	local url = luci.dispatcher.build_url("expert", "monitor", "pktstats")

	if SetIntvl then
		local interval = luci.http.formvalue("interval")
		local SysStatusFile = io.open("/tmp/SysStatus_interval", "w")

		if interval=="00000000" then
			SysStatusFile:write("0")		
		elseif interval=="00000001" then
			SysStatusFile:write("60")
		elseif interval=="00000002" then
			SysStatusFile:write("120")
		elseif interval=="00000003" then
			SysStatusFile:write("180")
		elseif interval=="00000004" then
			SysStatusFile:write("240")
		elseif interval=="00000005" then
			SysStatusFile:write("300")
		end
		SysStatusFile:close()	
	
		luci.http.redirect(url)
		return	
	end

	local wlan5G

	wlan5G = luci.sys.exec("iwpriv rai0 stat")
	if wlan5G ~= ""  then
	        RX_PKT=luci.sys.exec("iwpriv rai0 stat | grep \"Rx success\" | awk '{print $4}'")
	        TX_PKT=luci.sys.exec("iwpriv rai0 stat | grep \"Tx success\" | awk '{print $4}'")
	else
        	RX_PKT = 0
		TX_PKT = 0
	end

	luci.template.render("expert_monitor/Sum_SysStatusFrame",{rai0_rx_pks = RX_PKT, rai0_tx_pks = TX_PKT})
end


function action_wanstatus()
	local SetIntvl = luci.http.formvalue("SetIntvl")
	local url = luci.dispatcher.build_url("expert", "monitor", "wanstats")
	
	local lte_connect = luci.http.formvalue("lte_connect")
	local lte_disconnect = luci.http.formvalue("lte_disconnect")
	local set_auto_connect_boot = luci.http.formvalue("set_auto_connect_boot")
	
	if SetIntvl then
		local interval = luci.http.formvalue("interval")
		local SysStatusFile = io.open("/tmp/WanStatus_interval", "w")

		if interval=="00000000" then
			SysStatusFile:write("0")		
		elseif interval=="00000001" then
			SysStatusFile:write("60")
		elseif interval=="00000002" then
			SysStatusFile:write("120")
		elseif interval=="00000003" then
			SysStatusFile:write("180")
		elseif interval=="00000004" then
			SysStatusFile:write("240")
		elseif interval=="00000005" then
			SysStatusFile:write("300")
		end
		SysStatusFile:close()	
	
		luci.http.redirect(url)
		return	
	end
	
	if lte_connect then	
		sys.exec("echo -e 'mode_pref service 3' >> /usr/bin/commandpipe")
		uci:set("wanconfig","wanconfig","manual_connect_ctrl","1")	
		uci:commit("wanconfig")		
		luci.http.redirect(url)
		return	
	end
	
	if lte_disconnect then
		sys.exec("echo -e 'mode_pref service 4' >> /usr/bin/commandpipe")	
		uci:set("wanconfig","wanconfig","manual_connect_ctrl","2")		
		uci:commit("wanconfig")		
		luci.http.redirect(url)
		return	
	end
	
	if set_auto_connect_boot then
		local auto_connect_boot = luci.http.formvalue("auto_connect_boot")			
		
		if auto_connect_boot=="1" then
			uci:set("wanconfig","wanconfig","boot_autoconnect","1")		
		elseif auto_connect_boot=="0" then
			uci:set("wanconfig","wanconfig","boot_autoconnect","0")			
		end
		
		uci:commit("wanconfig")	
		uci:apply("wanconfig")
		luci.http.redirect(url)		
		return	
	end
	
	luci.template.render("expert_monitor/Sum_WanStatusFrame")
end

function action_vpnmonitor()
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
                remote_gw_ip = uci:get("ipsec",rules,"remote_gw_ip")
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

        luci.template.render("expert_monitor/Sum_VPNMonitor0", {status_r1 = rule_status[1],
								status_r2 = rule_status[2],
								status_r3 = rule_status[3],
								status_r4 = rule_status[4],
								status_r5 = rule_status[5]})	
end

-- MSTC, Sharon add sms 
function action_sms()
	luci.template.render("expert_monitor/sms")
end
--end

-- MSTC, Sharon add sms send
function action_sms_send()
	luci.template.render("expert_monitor/sms_send")
end
--end