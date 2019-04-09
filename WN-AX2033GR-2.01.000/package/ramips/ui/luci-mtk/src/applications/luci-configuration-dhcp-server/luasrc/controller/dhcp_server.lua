module("luci.controller.dhcp_server", package.seeall)
local uci = require("luci.model.uci").cursor()
local sys = require("luci.sys")

function index()
	local i18n = require("luci.i18n")
	local libuci = require("luci.model.uci").cursor()
	local lang = libuci:get("luci","main","lang") 
	i18n.load("dhcp_server",lang)
	i18n.setlanguage(lang)
	
	local page  = node("expert", "configuration", "network", "dhcpserver")
	page.target = call("action_dhcpSetup")
	page.title  = i18n.translate("DHCP_Server")
	page.order  = 68  
end

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

        luci.template.render("lan_dhcp_setup")
end