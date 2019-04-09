module("luci.controller.apn", package.seeall)
local uci = require("luci.model.uci").cursor()
local sys = require("luci.sys")

function index()
	local i18n = require("luci.i18n")
	local libuci = require("luci.model.uci").cursor()
	local lang = libuci:get("luci","main","lang") 
	i18n.load("apn",lang)
	i18n.setlanguage(lang)
	
	local page  = node("expert", "configuration", "lte", "APN")
	page.target = call("action_lte_apn")
	page.title  = i18n.translate("APN")
	page.order  = 42
	
	local page  = node("expert", "configuration", "lte", "APN","apn_edit")
	page.target = call("action_apn_edit")
	page.title  = "APN Edit"
	page.order  = 42
end

function action_lte_apn()
	luci.template.render("apn_application")
end

function action_apn_edit()
	local edit = luci.http.formvalue("edit")
	local apply = luci.http.formvalue("APNSubmit")
	
	if apply then
		local rules = luci.http.formvalue("rules")
		local enabled = luci.http.formvalue("APNenabled")
		local cid_Name = luci.http.formvalue("cid_Name")
		local apn_type = luci.http.formvalue("_apn_type")
		local apn = luci.http.formvalue("apn")
		local auto_apn = luci.http.formvalue("_auto_apn")
		local auth = luci.http.formvalue("_auth")
		local username = luci.http.formvalue("username")
		local password = luci.http.formvalue("password")
		local url = luci.dispatcher.build_url("expert","configuration","lte","APN")
		
		uci:set("wanconfig","pdp"..rules,"name",cid_Name)
		uci:set("wanconfig","pdp"..rules,"enable",enabled)
		uci:set("wanconfig","pdp"..rules,"type",apn_type)	
		uci:set("wanconfig","pdp"..rules,"auto_apn",auto_apn)
		uci:set("wanconfig","pdp"..rules,"auth",auth)
		if username == nil or username == "" then
			uci:set("wanconfig","pdp"..rules,"username","na")
		else
			uci:set("wanconfig","pdp"..rules,"username",username)
		end
		if password == nil or password == "" then
			uci:set("wanconfig","pdp"..rules,"password","na")
		else
			uci:set("wanconfig","pdp"..rules,"password",password)
		end
		
		if auto_apn == "1" then
			uci:set("wanconfig","pdp"..rules,"apn","na")
			sys.exec("wan_profile.sh del_apn")
		else
			uci:set("wanconfig","pdp"..rules,"apn",apn)
			
			local pdp_type
			if apn_type == v4 then
				pdp_type = "0"
			elseif apn_type == "v6" then
				pdp_type = "1"
			elseif apn_type =="v4v6" then
				pdp_type = "2"
			else
				pdp_type = "2"
			end
			
				sys.exec("wan_profile.sh set_apn "..apn.." "..pdp_type)
			end	
			
		if auth == "0" then
			sys.exec("wan_profile.sh del_auth")
		else
			sys.exec("wan_profile.sh set_auth "..username.." "..password)
		end
		sys.exec("wan_profile.sh set_auth_method "..auth)
		
		uci:save("wanconfig")
		uci:commit("wanconfig")
		luci.http.redirect(url)	
	end
	if edit then
		local rules = edit
		local enabled = uci:get("wanconfig","pdp"..rules,"enable")
		local cid_name = uci:get("wanconfig","pdp"..rules,"name")
		local auto_apn = uci.get("wanconfig","pdp"..rules,"auto_apn")	
		local apn_type = uci:get("wanconfig","pdp"..rules,"type")	
		local apn = uci:get("wanconfig","pdp"..rules,"apn")
		local auth = uci:get("wanconfig","pdp"..rules,"auth")
		local username = uci:get("wanconfig","pdp"..rules,"username")
		local password = uci:get("wanconfig","pdp"..rules,"password")
		
		if apn == nil then
			apn = ""
		end	
		if cid_name == nil then
			cid_name = ""
		end	
		local url = luci.dispatcher.build_url("expert","configuration","lte","APN","apn_edit")
		luci.http.redirect(url .. "?" .. "&rules=" .. rules .. "&enabled=" .. enabled .. "&cid_name=" .. cid_name .. "&auth=" .. auth .. "&username=" .. username .. "&password=" .. password .. "&auto_apn=" .. auto_apn .. "&apn_type=" .. apn_type .. "&apn=" .. apn .. "&rt=" .. 1 .. "&errmsg=test!!")
		return
	end
	luci.template.render("apn_application_edit")
end