module("luci.controller.sim", package.seeall)
local uci = require("luci.model.uci").cursor()
local sys = require("luci.sys")

function index()
	local i18n = require("luci.i18n")
	local libuci = require("luci.model.uci").cursor()
	local lang = libuci:get("luci","main","lang") 
	i18n.load("sim",lang)
	i18n.setlanguage(lang)
	
	local page  = node("expert", "configuration", "lte", "sim")
	page.target = call("action_lte_sim")
	page.title  = i18n.translate("SIM")
	page.order  = 42  
end

function action_lte_sim()
	local apply = luci.http.formvalue("sysSubmit")
	
	if apply then
		local sim_status = luci.http.formvalue("sim_status")
		local enablePIN = luci.http.formvalue("enablePIN")
		local ltePin = luci.http.formvalue("ltePin")
		local ltePuk = luci.http.formvalue("ltePuk")
		local lteModification = luci.http.formvalue("lteModification")
		local lteOldPin = luci.http.formvalue("lteOldPin")
		local lteNewPin = luci.http.formvalue("lteNewPin")
		
	-- PIN disabled
		if sim_status == "SIM_PIN_DISABLE" then 
			if enablePIN == "1" then -- Select Enable for PIN Verification
				sys.exec("sim_maintain.sh set_pin "..ltePin.." 1")
			end
	-- PIN required			
		elseif sim_status == "CELL_DEVST_SIM_PIN" then
			sys.exec("sim_maintain.sh verify_pin "..ltePin)			
	-- PIN verified		
		elseif sim_status == "CELL_DEVST_SIM_RDY" then
			if enablePIN == "1" then -- Select Enable for PIN Verification or the default for PIN Verification in the PIN verified status
				if lteModification == "1" then -- Selecte Modification
					sys.exec("sim_maintain.sh change_pin "..lteOldPin.." "..lteNewPin)
				end
			else -- Select Disable for PIN Verification
				sys.exec("sim_maintain.sh set_pin "..ltePin.." 0")
			end
	-- PIN locked		
		elseif sim_status == "CELL_DEVST_SIM_PUK" then
			sys.exec("sim_maintain.sh unblock_pin "..ltePuk.." "..lteNewPin)
		end
	end

	luci.template.render("sim")
end