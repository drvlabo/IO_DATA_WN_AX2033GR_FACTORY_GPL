--[[
LuCI - Lua Configuration Interface

Copyright 2008 Steven Barth <steven@midlink.org>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

$Id: index.lua 4040 2009-01-16 12:35:25Z Cyrus $
]]--
module("luci.controller.expert.maintenance", package.seeall)
local sys = require("luci.sys")
local uci = require("luci.model.uci").cursor()
local nixio = require("nixio")  --wen-hsiang 2011.9.9.--
function index()
	
	local i18n = require("luci.i18n")
	local libuci = require("luci.model.uci").cursor()
	local lang = libuci:get("luci","main","lang") 
	i18n.load("admin-core",lang)
	i18n.setlanguage(lang)
	
	local page  = node("expert", "maintenance")
	page.target = template("expert_maintenance/maintenance")
	page.title  = i18n.translate("maintenance")  
	page.order  = 40

-- MSTC, Sharon mark maintenance->general
--[[
	local page  = node("expert", "maintenance", "maingeneral")
	page.target = call("action_general")
	page.title  = i18n.translate("main_general")  
	page.order  = 45
--]]

	local page  = node("expert", "maintenance", "password")
	page.target = call("action_password")
	page.title  = i18n.translate("Password")  
	page.order  = 50

-- MSTC, Sharon mark maintenance->time
--[[
	local page  = node("expert", "maintenance", "time")
	page.target = call("action_timeSetting")
	page.title  = i18n.translate("Time")  
	page.order  = 60
--]]

	local page  = node("expert", "maintenance", "fw")
	page.target = call("action_upgrade")
	page.title  = i18n.translate("Firmware_Upgrade")  
	page.order  = 70
	
	local page  = node("expert", "maintenance", "bakrestore")
	page.target = call("action_backup")
	page.title  = i18n.translate("Backup_Restore")  
	page.order  = 80
	
	local page  = node("expert", "maintenance", "Systemrebooting")
	page.target = call("action_restart")
	page.title  = i18n.translate("Systemrebooting")  
	page.order  = 85

	local page  = node("expert", "maintenance", "language")
	page.target = call("act_lang")
	page.title  = i18n.translate("Language")  
	page.order  = 90

-- MSTC, Sharon add maintenance->oled
	local page  = node("expert", "maintenance", "oled")
	page.target = call("action_oled_config")
	page.title  = i18n.translate("oled_display")  
	page.order  = 95
--end
end

-- MSTC, Sharon mark maintenance->general
--[[
function action_general()
        local apply = luci.http.formvalue("apply")

        if apply then

           local hostname    = luci.http.formvalue("hostname")
           local domain_name = luci.http.formvalue("domain_name")
           local sessiontime = luci.http.formvalue("sessiontime")

           uci:set("system","main","hostname",hostname)
           uci:set("system","main","domain_name",domain_name)
	   --Save another HostName to /etc/config/network for DHCP client use.
           uci:set("network","wan","hostname",hostname)

           sessiontime = sessiontime * 60  -- timeout(seconds)  

           uci:set("luci","sauth","sessiontime",sessiontime)

           uci:commit("system")
           uci:commit("luci")
	   uci:commit("network")
                        sys.exec("/usr/sbin/update_lan_dns")
                        sys.exec("/etc/init.d/dnsmasq stop 2>/dev/null")
                        sys.exec("/etc/init.d/dnsmasq start 2>/dev/null")

        end

        luci.template.render("expert_maintenance/maintenance_general")

end
--]]

function action_password()
        local apply = luci.http.formvalue("apply")
		
        if apply then
			local old_password = luci.http.formvalue("old_password")
			local new_password = luci.http.formvalue("new_password")
			local check_pw = luci.sys.user.checkpasswd("admin", old_password)
			
			if check_pw then
				local set_pw = luci.sys.user.setpasswd("admin", new_password)
				if set_pw == 0 then
					pw_result = 1
					local pw_encrypt = sys.exec("cat /etc/shadow | grep admin | cut -d ':' -f 2")
					uci:set("account_info", "info", "password1", pw_encrypt)
					uci:set("account_info", "info", "pwwarning_disable", "1")
					uci:commit("account_info")
				else
					pw_result = 2
				end
			else
				pw_result = 0
			end
						
        end

        luci.template.render("expert_maintenance/password",{pw_confirm = pw_result})

end

function action_backup()
        --local restore_cmd = "gunzip | tar -xC/ >/dev/null 2>&1"
		local restore_cmd = "cat >/tmp/romfile.bak "
        --local backup_cmd  = "tar -c %s | gzip 2>/dev/null"
		local backup_cmd  = "/usr/sbin/backup.sh config_backup.bak && cat config_backup.bak 2>/dev/null"
        
        local restore_fpi
        luci.http.setfilehandler(
                function(meta, chunk, eof)
                        if not restore_fpi then
                                restore_fpi = io.popen(restore_cmd, "w")
                        end
                        if chunk then
                                restore_fpi:write(chunk)
                        end
                        if eof then
                                restore_fpi:close()
                        end
                end
        )

		local upload = luci.http.formvalue("RestoreSubmit")
        local backup = luci.http.formvalue("Backup")
		local reset  = luci.http.formvalue("ResetSubmit")

	local logfile
                

        if upload=="1" then
				sys.exec("/usr/sbin/restore.sh /tmp/romfile.bak > /tmp/restore_log")
				local _result=1
                local _logfile = io.open("/tmp/restore_log", "r")
				local _msg
				
                while true do
                        _msg = _logfile:read("*line")

                        if not _msg then
							_result=1
                            break
                        end

                        if _msg == "OK" then
                            _result=0
                            break
                        end
                end
				if _result == 0 then
					luci.template.render("expert_maintenance/backup_restore",{rebootsystem=1,restore_result=_result})
					sys.exec("reboot")
				else
					luci.template.render("expert_maintenance/backup_restore",{restore_result=_result})
				end

        elseif backup then
                --luci.util.perror(backup_cmd:format(_keep_pattern()))
                local backup_fpi = io.popen(backup_cmd, "r")
                luci.http.header('Content-Disposition', 'attachment; filename="backup-%s.rom"' % {
                        os.date("%Y-%m-%d-%H%M%S")})
                luci.http.prepare_content("application/x-targz")
                luci.ltn12.pump.all(luci.ltn12.source.file(backup_fpi), luci.http.write)
				luci.template.render("expert_maintenance/backup_restore")
        elseif reset=="1" then
                luci.template.render("expert_maintenance/backup_restore",{rebootsystem=1})
				sys.exec("/usr/sbin/factoryreset.sh")

        else
                luci.template.render("expert_maintenance/backup_restore")
        end
end

function action_upgrade()
	require("luci.model.uci")

	-- Initialization
	local tmpfile = "/tmp/ras.bin"
	sys.exec("rm -rf /tmp/fwupgrade_log2 /tmp/ras.bin")
	--uci:set_t("runtime", "log", "upgrade_log", "na")

	local function upgrade_firmware()
		local fwupgrade = 0
		local ret

		filechecksum=10000
		loadfilesize=20000

		ret = sys.exec("sh /usr/sbin/fwupgrade.sh /tmp/ras.bin")
		while true do
			local message = uci:get_t("runtime", "log", "upgrade_log")
			if message == "success" then
				fwupgrade = 1
				break
			elseif message == "fail" then
				break
			end
                end
	
		if  fwupgrade == 1 then
			luci.template.render("expert_maintenance/fw", {checksum=filechecksum, filesize=loadfilesize, fileupload=1})
                else
			sys.exec("rm -rf /tmp/ras.bin")
			--sys.exec("cat /tmp/fwupgrade_log | awk '{sub(/^/, \"<p>\");print}' | \
			--	awk '{sub(/$/, \"</p>\");print}' > /tmp/fwupgrade_log2")
			ret = sys.exec("echo fail")
			luci.template.render("expert_maintenance/fw", {fileupload=2, errmsg=ret})
		end
	end

	-- Install upload handler
	local file
	local cnt = 0
	luci.http.setfilehandler(
		function(meta, chunk, eof)
			if not nixio.fs.access(tmpfile) and not file and chunk and #chunk > 0 then
				file = io.open(tmpfile, "w")
			end

			-- Remove file maxization size
			--if (cnt < 4096) then
				if file and chunk then
					file:write(chunk)
					cnt=cnt+1
				end
			--end

			if file and eof then
				file:close()
			end
		end
	)

	-- Determine state
	local keep_avail = true
	local has_image = nixio.fs.access(tmpfile)
	local has_upload = luci.http.formvalue("mtenFWUpload")
	local upload = luci.http.formvalue("sysSubmit")

	if upload == "1" then
		upgrade_firmware()
		return
	end

	luci.template.render("expert_maintenance/fw", {fileupload=0, on_line_check_fw=2,on_line_fw_dl=1})
end

function _keep_pattern()
        local kpattern = ""
        local files = luci.model.uci.cursor():get_all("luci", "flash_keep")
        if files then
                kpattern = ""
                for k, v in pairs(files) do
                        if k:sub(1,1) ~= "." and nixio.fs.glob(v)() then
                                kpattern = kpattern .. " " ..  v
                        end
                end
        end
        return kpattern
end

-- MSTC, Sharon mark maintenance->time
--[[
function action_timeSetting()
 	local apply = luci.http.formvalue("sysSubmit2")

        if apply then

           local mtenNew_Hour = luci.http.formvalue("mtenNew_Hour")
           local mtenNew_Min = luci.http.formvalue("mtenNew_Min")
           local mtenNew_Sec = luci.http.formvalue("mtenNew_Sec")
           local mtenNew_Year = luci.http.formvalue("mtenNew_Year")
           local mtenNew_Mon = luci.http.formvalue("mtenNew_Mon")
           local mtenNew_Day = luci.http.formvalue("mtenNew_Day")
           
	mtenNew_Hour=zero_padding(mtenNew_Hour)
	mtenNew_Min=zero_padding(mtenNew_Min)
	mtenNew_Sec=zero_padding(mtenNew_Sec)
	mtenNew_Year=zero_padding(mtenNew_Year)
	mtenNew_Mon=zero_padding(mtenNew_Mon)
	mtenNew_Day=zero_padding(mtenNew_Day)
	

           local mtenTimeZone = luci.http.formvalue("mtenTimeZone")
           local mten_ServiceType = luci.http.formvalue("mten_ServiceType")
           local startDay = luci.http.formvalue("startDay")
           local startMonth = luci.http.formvalue("startMonth")
           local startTime = luci.http.formvalue("startTime")
           local endDay = luci.http.formvalue("endDay")
           local endMonth = luci.http.formvalue("endMonth")
           local endTime = luci.http.formvalue("endTime")
           local tzIndex = luci.http.formvalue("tzIndex")
           local ntpName = luci.http.formvalue("ntpName")
           
           
	local btndaylight = luci.http.formvalue("btndaylight")
	if not btndaylight then
		btndaylight="0"
	else
		btndaylight="1"
	end


           uci:set("time","main","timezone",mtenTimeZone)


	
           
-- Modification for NTP Server error, NBG5715, WenHsiang, 2011/12/07
           local change_TimeSetting = "0"

	if mten_ServiceType == "0" then
	   mten_ServiceType = "manual"
	   change_TimeSetting = "1"
	else
	   mten_ServiceType = "NTP"
	end
-- Modification for NTP Server error, NBG5715, WenHsiang, 2011/12/07

	uci:set("time","DST","enable",btndaylight)

        uci:set("time","DST","start_month",startMonth)
        uci:set("time","DST","start_day",startDay)
        uci:set("time","DST","start_clock",startTime)
        uci:set("time","DST","end_month",endMonth)
        uci:set("time","DST","end_day",endDay)
        uci:set("time","DST","end_clock",endTime)
	   
	uci:set("time","main","manual_year",mtenNew_Year)
	uci:set("time","main","manual_mon",mtenNew_Mon)
	uci:set("time","main","manual_day",mtenNew_Day)
	uci:set("time","main","manual_hour",mtenNew_Hour)
	uci:set("time","main","manual_min",mtenNew_Min)
	uci:set("time","main","manual_sec",mtenNew_Sec)
	uci:set("time","main","mode",mten_ServiceType)
-- Modification for NTP Server error, NBG5715, WenHsiang, 2011/12/07	
	uci:set("time","main","change_TimeSetting",change_TimeSetting)
-- Modification for NTP Server error, NBG5715, WenHsiang, 2011/12/07
	uci:set("time","main","ntpName",ntpName)
	uci:set("time","main","tzIndex",tzIndex)
	uci:commit("time")
	uci:apply("time")
	   
        end

  	luci.template.render("expert_maintenance/time")
end
--]]

function zero_padding(num)
	if num == "0" or num == "1" or num == "2" or num == "3" or num == "4" or num == "5" or num == "6" or num == "7" or num == "8" or num == "9" then
		num="0" .. num
	end
	return num
end

function act_lang()
	local apply = luci.http.formvalue("apply")
	
	if apply then
		local lang = luci.http.formvalue("language")
		if lang then
			uci:set("luci","main","lang",lang)
			uci:commit("system")
		end

		luci.template.render("expert_maintenance/language",{reload_page=1})
		return
	end
	
	luci.template.render("expert_maintenance/language",{reload_page=0})
end

function action_restart()
	local restartsystem = luci.http.formvalue("restartsystem")
	
	if restartsystem then
		luci.template.render("expert_maintenance/restart",{rebootsystem=1})
		sys.exec("reboot")
	else
		luci.template.render("expert_maintenance/restart")
	end
end

-- MSTC, Sharon add oled
function action_oled_config()
local apply = luci.http.formvalue("sysSubmit")
local clear = luci.http.formvalue("sysClear")
	
	if apply then
		local OLED_DisplayTime = luci.http.formvalue("_oled_displayTime")
		uci:set("mtoled","oled","sleeptime",OLED_DisplayTime)
		uci:commit("mtoled")
		sys.exec("mtoled_config.sh sleeptime")	
	end

	if clear then		
		uci:set("mtoled","oled","traffic","0")
		uci:set("mtoled","oled","traffic_ipv4","0")
		uci:set("mtoled","oled","traffic_ipv6","0")	
		uci:commit("mtoled")
		sys.exec("mtoled_config.sh traffic")
	end	
	
	luci.template.render("expert_maintenance/oled_config")
end
-- end
