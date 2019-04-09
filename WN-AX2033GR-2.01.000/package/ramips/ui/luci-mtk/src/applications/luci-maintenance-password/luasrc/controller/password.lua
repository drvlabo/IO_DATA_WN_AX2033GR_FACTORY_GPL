module("luci.controller.password", package.seeall)
local uci = require("luci.model.uci").cursor()
local sys = require("luci.sys")

function index()
	local i18n = require("luci.i18n")
	local libuci = require("luci.model.uci").cursor()
	local lang = libuci:get("luci","main","lang") 
	i18n.load("password",lang)
	i18n.setlanguage(lang)
	
	local page  = node("expert", "maintenance", "password")
	page.target = call("action_password")
	page.title  = i18n.translate("Password")  
	page.order  = 50
end

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

        luci.template.render("password",{pw_confirm = pw_result})
end