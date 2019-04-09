module("luci.controller.dhcp_table", package.seeall)
local uci = require("luci.model.uci").cursor()
local sys = require("luci.sys")

function index()
	local i18n = require("luci.i18n")
	local libuci = require("luci.model.uci").cursor()
	local lang = libuci:get("luci","main","lang") 
	i18n.load("dhcp_table",lang)
	i18n.setlanguage(lang)
	
	local page  = node("expert", "monitor", "dhcptable")
	page.target = call("action_monitorClientList")
	page.title  = i18n.translate("DHCP_Table")  
	page.order  = 50
end

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

	luci.template.render("Sum_DHCP")
end