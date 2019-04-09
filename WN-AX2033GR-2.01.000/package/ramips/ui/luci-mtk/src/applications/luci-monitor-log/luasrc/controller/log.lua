module("luci.controller.log", package.seeall)
local uci = require("luci.model.uci").cursor()
local sys = require("luci.sys")

function index()
	local i18n = require("luci.i18n")
	local libuci = require("luci.model.uci").cursor()
	local lang = libuci:get("luci","main","lang") 
	i18n.load("log",lang)
	i18n.setlanguage(lang)
	
	local page  = node("expert", "monitor", "log")
	page.target = call("action_viewlog")
	page.title  = i18n.translate("Log")  
	page.order  = 40
	
	local page  = node("expert", "monitor", "log", "logsettings")
	page.target = call("action_log_setting")
	page.title  = "Log Settings"  
	page.order  = 40
end

function action_viewlog()
	local srcMsgFileName = "/var/log/messages"
	local dstMsgFileName = "/tmp/logMsgs"
	local submitType = luci.http.formvalue("ViewLogSubmitType")

	if submitType and "Clear Log" == submitType then
		sys.exec("/etc/init.d/syslog restart")
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
		-- marco, remove init string
		sys.exec("sed -i '/syslogd started:/d' " .. srcMsgFileName)

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

	luci.template.render("viewlog")

	os.remove(dstMsgFileName)
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

	luci.template.render("log_settings")
end
