module("luci.controller.wlan", package.seeall)
local uci = require("luci.model.uci").cursor()
local sys = require("luci.sys")

--[[
country_code_table = {
	FF={"reg0", "reg10"},				 -- USA           //DEBUG   old:{"reg0", "reg7"}
	FE={"reg1", "reg7"},				 -- S.Africa     
	FD={"reg1", "reg1"},				 -- Netherland   
	FC={"reg1", "reg1"},				 -- Denmark      
	FA={"reg1", "reg1"},				 -- Sweden       
	F9={"reg1", "reg1"},				 -- UK           
	F8={"reg1", "reg1"},				 -- Belgium      
	F7={"reg1", "reg1"},				 -- Greece       
	F6={"reg1", "reg2"},				 -- Czech        
	F5={"reg1", "reg1"},				 -- Norway       
	F4={"reg1", "reg9"},				 -- Australia    
	F3={"reg1", "reg9"},				 -- New Zealand   //without 165
	F2={"reg1", "reg7"},				 -- Hong Kong    
	F1={"reg1", "reg0"},				 -- Singapore    
	F0={"reg1", "reg1"},				 -- Finland      
	EF={"reg1", "reg6"},				 -- Morocco	     
	EE={"reg0", "reg3"},				 -- Taiwan       // old: {"reg0", "reg13"} 
	ED={"reg1", "reg1"},				 -- German       
	EC={"reg1", "reg1"},				 -- Italy        
	EB={"reg1", "reg1"},				 -- Ireland      
	EA={"reg1", "reg1"},				 -- Japan         //without 184 188 192 196
	E9={"reg1", "reg1"},				 -- Austria      
	E8={"reg1", "reg0"},				 -- Malaysia     
	E7={"reg1", "reg1"},				 -- Poland       
	E6={"reg1", "reg0"},				 -- Russia       
	E5={"reg1", "reg1"},				 -- Hungary      
	E4={"reg1", "reg1"},				 -- Slovak 	     
	E3={"reg1", "reg7"},				 -- Thailand     
	E2={"reg1", "reg2"},				 -- Israel       
	E1={"reg1", "reg1"},				 -- Switzerland  
	E0={"reg1", "reg1"},				 -- UAE          
	DE={"reg1", "reg4"},				 -- China        
	DD={"reg1", "reg0"},				 -- Ukraine      
	DC={"reg1", "reg1"},				 -- Portugal     
	DB={"reg1", "reg1"},				 -- France       
	DA={"reg1", "reg11"},				 -- Korea        
	D9={"reg1", "reg7"},				 -- Korea        
	D8={"reg1", "reg7"},				 -- Philippine   
	D7={"reg1", "reg1"},				 -- Slovenia	 
	D6={"reg1", "reg7"},				 -- India        
	D5={"reg1", "reg1"},				 -- Spain        
	D3={"reg1", "reg1"},				 -- Turkey       
	D1={"reg1", "reg7"},				 -- Peru         
	D0={"reg0", "reg7"},				 -- Brazil       
	CB={"reg1", "reg1"},				 -- Bulgaria     
	CC={"reg1", "reg1"},				 -- Luxembourg   
	CE={"reg0", "reg9"},				 -- Canada 	     
	CD={"reg1", "reg1"},				 -- Iceland	     
	CF={"reg1", "reg1"}				 -- Romania                             	                                           
}
--]]


-- Leo, This table is mapping to ISO country code; you can set the country code in /etc/config/wireless to decide the channel displayed in Web GUI.
country_code_table = {
	US={"reg0", "reg10"},				 -- USA           //DEBUG   old:{"reg0", "reg7"}
	ZA={"reg1", "reg7"},				 -- S.Africa     
	NL={"reg1", "reg1"},				 -- Netherland   
	DK={"reg1", "reg1"},				 -- Denmark      
	SE={"reg1", "reg1"},				 -- Sweden       
	GB={"reg1", "reg1"},				 -- UK           
	BE={"reg1", "reg1"},				 -- Belgium      
	GR={"reg1", "reg1"},				 -- Greece       
	CZ={"reg1", "reg2"},				 -- Czech        
	NO={"reg1", "reg1"},				 -- Norway       
	AU={"reg1", "reg9"},				 -- Australia    
	NZ={"reg1", "reg9"},				 -- New Zealand   //without 165
	HK={"reg1", "reg7"},				 -- Hong Kong    
	SG={"reg1", "reg0"},				 -- Singapore    
	FI={"reg1", "reg1"},				 -- Finland      
	MA={"reg1", "reg6"},				 -- Morocco	     
	TW={"reg0", "reg3"},				 -- Taiwan       // old: {"reg0", "reg13"} 
	DE={"reg1", "reg1"},				 -- German       
	IT={"reg1", "reg1"},				 -- Italy        
	IE={"reg1", "reg1"},				 -- Ireland      
	JP={"reg1", "reg1"},				 -- Japan         //without 184 188 192 196
	AT={"reg1", "reg1"},				 -- Austria      
	MY={"reg1", "reg0"},				 -- Malaysia     
	PL={"reg1", "reg1"},				 -- Poland       
	RU={"reg1", "reg0"},				 -- Russia       
	HU={"reg1", "reg1"},				 -- Hungary      
	SK={"reg1", "reg1"},				 -- Slovak 	     
	TH={"reg1", "reg7"},				 -- Thailand     
	IL={"reg1", "reg2"},				 -- Israel       
	CH={"reg1", "reg1"},				 -- Switzerland  
	AE={"reg1", "reg1"},				 -- UAE          
	CN={"reg1", "reg4"},				 -- China        
	UA={"reg1", "reg0"},				 -- Ukraine      
	PT={"reg1", "reg1"},				 -- Portugal     
	FR={"reg1", "reg1"},				 -- France       
	KP={"reg1", "reg11"},				 -- North Korea        
	KR={"reg1", "reg7"},				 -- South Korea        
	PH={"reg1", "reg7"},				 -- Philippine   
	SI={"reg1", "reg1"},				 -- Slovenia	 
	IN={"reg1", "reg7"},				 -- India        
	ES={"reg1", "reg1"},				 -- Spain        
	TR={"reg1", "reg1"},				 -- Turkey       
	PE={"reg1", "reg7"},				 -- Peru         
	BR={"reg0", "reg7"},				 -- Brazil       
	BG={"reg1", "reg1"},				 -- Bulgaria     
	LU={"reg1", "reg1"},				 -- Luxembourg   
	CA={"reg0", "reg9"},				 -- Canada 	     
	IS={"reg1", "reg1"},				 -- Iceland	     
	RO={"reg1", "reg1"}				 -- Romania                             	                                           
}


channelRange = {
	reg0="1-11",    --region 0
	reg1="1-13",    --region 1
	reg2="10-11",   --region 2
	reg3="10-13",   --region 3
	reg4="14",      --region 4
	reg5="1-14",    --region 5
	reg6="3-9",     --region 6
	reg7="5-13"    --region 7
}

channelRange5G = {
	reg0 = "36,40,44,48,52,56,60,64,132,136,140,149,153,157,161,165", --region 0
	reg1 = "36,40,44,48,52,56,60,64,100,104,108,112,116,120,124,128,132,136,140", --region 1
	reg2 = "36,40,44,48,52,56,60,64", --region 2
	reg3 = "52,56,60,64,149,153,157,161", --region 3
	reg4 = "149,153,157,161,165", --region 4
	reg5 = "149,153,157,161", --region 5
	reg6 = "36,40,44,48", --region 6
	reg8 = "52,56,60,64", --region 8
	reg9 = "36,40,44,48,52,56,60,64,100,104,108,112,116,132,136,140,149,153,157,161,165", --region 9
	reg10 = "36,40,44,48,149,153,157,161,165", --region 10
	reg11 = "36,40,44,48,52,56,60,64,100,104,108,112,116,120,149,153,157,161" --region 11
}

function index()
	local i18n = require("luci.i18n")
	local libuci = require("luci.model.uci").cursor()
	local lang = libuci:get("luci","main","lang") 
	i18n.load("wlan",lang)
	i18n.setlanguage(lang)
	
	local page  = node("expert", "configuration", "network", "wlan")
	page.target = call("wlan_general")
	page.title  = i18n.translate("wireless_lan")  
	page.order  = 53

	local page  = node("expert", "configuration", "network", "wlan", "wlanmacfilter")
	page.target = call("wlanmacfilter")
	page.title  = "MAC Filter"  
	page.order  = 44
end

function wlan_general()
	require("luci.model.uci")
	local apply = luci.http.formvalue("sysSubmit")
--	local tmppsk	
	local wifi_iface = "wlan0"
	local wifi_device = "general"
	
	if apply then		
	--SSID
		local SSID = luci.http.formvalue("SSID_value")
		local SSID_old = uci:get("wireless", wifi_iface,"ssid")
				
		if not (SSID == SSID_old)then
			uci:set("wireless", wifi_iface, "ssid", SSID)
		end--SSID
	--radioON
		local Wireless_enable = luci.http.formvalue("ssid_state")
		local Wireless_enable_old = uci:get("wireless", wifi_device, "disabled")
		if not(Wireless_enable == Wireless_enable_old)then
			uci:set("wireless", wifi_device, "disabled", Wireless_enable)
		end--radioON
	--HideSSID
		local wireless_hidden = luci.http.formvalue("Hide_SSID")
		local wireless_hidden_old = uci:get("wireless", wifi_iface, "hidden")
		
		if not (wireless_hidden)then
			wireless_hidden = "0"
		else
			wireless_hidden = "1"
		end

		if not(wireless_hidden == wireless_hidden_old)then			
			uci:set("wireless", wifi_iface, "hidden", wireless_hidden)
		end
	--ChannelID
		local Channel_Freq = luci.http.formvalue("Channel_Freq")
		local Channel_ID = luci.http.formvalue("Channel_ID_index")
		--local Auto_Channel = luci.http.formvalue("Auto_Channel") -- the formvalue Auto_Channel has been removed
		local Auto_Channel = "0"
			
		if (Channel_Freq == "0") then -- 2.4G 
			local channel = luci.http.formvalue("Channel_ID")
			if (channel == "0") then -- 2.4G with Auto
				Auto_Channel = "1"
			end
		else -- 5G
			local channel = luci.http.formvalue("Channel_ID_5G")
			if (channel == "0") then -- 5G with Auto
				Auto_Channel = "1"
			end
		end
					
		if not (Auto_Channel == "1") then
			if (Channel_ID == "auto") then
				Channel_ID = "1"
			end
			local Channel_ID_old = uci:get("wireless", wifi_device, "ch_op", Channel_ID)
			if not(Channel_ID)then
				Channel_ID = Channel_ID_old
			end
						
			uci:set("wireless", wifi_device, "channel", Channel_ID)
			uci:set("wireless", wifi_device, "ch_op", Channel_ID)
			uci:set("wireless", wifi_device, "frequency", Channel_Freq)

		end
	--AutoChSelect
		if (Auto_Channel == "1") then
			uci:set("wireless", wifi_device, "frequency", Channel_Freq)
			uci:set("wireless", wifi_device, "ch_op", "auto")
		--[[	
			sys.exec("sh /usr/sbin/auto_channel_selection.sh")
			local file = io.open("/tmp/auto_channel", "r")	
			local Channel_ID_auto = file:read("*line")	
			--sys.exec("echo "..Channel_ID_auto.." > /tmp/Channel_ID_auto")
			file:close()
			uci:set("wireless", wifi_device, "channel", Channel_ID_auto)
			--uci:set("wireless", wifi_device, "channel", "auto")
		--]]	
		end
	--ChannelWidth
		--local Channel_Width = luci.http.formvalue("ChWidth_select")
		--if (Channel_Width == "HT20") then
			--uci:set("wireless", wifi_device, "htmode", Channel_Width)
		--else
			local channel_set
			--[[
			if (Auto_Channel == "1") then
				local file = io.open("/tmp/auto_channel", "r")	
				local Channel_ID_auto = file:read("*line")	
				channel_set = tonumber(Channel_ID_auto)
				file:close()
			else
				channel_set = tonumber(Channel_ID)
			end
			--]]
			
			channel_set = Channel_ID

			if (tonumber(channel_set) <= 4) or (tonumber(channel_set) == 149) or (tonumber(channel_set) == 157) then
				Channel_Width = "HT40+"
			elseif (tonumber(channel_set) >= 10 ) or (tonumber(channel_set) == 153) or (tonumber(channel_set) == 161) then
				Channel_Width = "HT40-"
			else
				Channel_Width = "HT40- HT40+"
			end
			
			uci:set("wireless", wifi_device, "htmode", Channel_Width)		
		--end
	--tx power
		local txPower = luci.http.formvalue("TxPower_value")
		local txPower_old = uci:get("wireless", wifi_device, "txpower")
		if not (txPower) then
			uci:set("wireless", wifi_device, "txpower","18")
		else
			if not (txPower == txPower_old) then 
				uci:set("wireless", wifi_device, "txpower",txPower)
			end
		end
	--WirelessMode
		local Wireless_Mode = luci.http.formvalue("Mode_select")
		local Wireless_Mode_5G = luci.http.formvalue("Mode_select_5G")
				
		if (Wireless_Mode) then
			uci:set("wireless", wifi_device, "hwmode", Wireless_Mode)
		elseif (Wireless_Mode_5G) then
			uci:set("wireless", wifi_device, "hwmode", Wireless_Mode_5G)
		else
			--should not enter here
		end
	--IdleMode
		local Idlemode = luci.http.formvalue("idlemode_select")
		uci:set("wireless", wifi_device, "idlemode", Idlemode)
	--SecurityMode
		local security_mode = luci.http.formvalue("security_value")
		local encryption_method = luci.http.formvalue("encryption_method")
				
		if (security_mode) then
			--No security
			if( security_mode == "NONE") then
				uci:set("wireless", wifi_iface, "auth","OPEN")
				uci:set("wireless", wifi_iface, "_encryption","NONE")
				-- encryption
				uci:set("wireless", wifi_iface, "encryption","none")
			end

			--WEP
			if( security_mode == "WEP")then
				local EncrypAuto_shared = luci.http.formvalue("auth_method")
				uci:set("wireless", wifi_iface,"_encryption","WEP")
				if (EncrypAuto_shared)	then
					if(EncrypAuto_shared == "WEPOPEN")then
						uci:set("wireless", wifi_iface,"auth",EncrypAuto_shared)
						-- encryption
						uci:set("wireless", wifi_iface, "encryption","wep+open")
					elseif(EncrypAuto_shared == "SHARED") then
						uci:set("wireless", wifi_iface,"auth",EncrypAuto_shared)
						-- encryption
						uci:set("wireless", wifi_iface, "encryption","wep+shared")
					end
				end
				--64-128bit
				local WEP64_128 = luci.http.formvalue("WEP64_128")
				if (WEP64_128)then
					if(WEP64_128 == "0")then--[[64-bit]]--
						uci:set("wireless", wifi_iface,"wepencryp128", WEP64_128)
					elseif(WEP64_128 == "1") then--[[128-bit]]--
						uci:set("wireless", wifi_iface,"wepencryp128", WEP64_128)
					end
				end
				--ASCIIHEX
				local WEPKey_Code = luci.http.formvalue("WEPKey_Code")
				if (WEPKey_Code == "1")then--[[HEx]]--
					uci:set("wireless", wifi_iface,"keytype", "1")
				elseif (WEPKey_Code == "0") then--[[ASCII]]--
					uci:set("wireless", wifi_iface,"keytype", "0")
				end
				--keyindex
				local DefWEPKey = luci.http.formvalue("DefWEPKey")
				if (DefWEPKey)then
					uci:set("wireless", wifi_iface,"key", DefWEPKey)
				end
                                	
				--WEP key value
                                local wepkey
                                local key_name
                                for i=1,4 do
                                        wepkey = luci.http.formvalue("wep_key_"..i)
                                        key_name="key"..i
                                        if ( wepkey ) then
                                                uci:set("wireless", wifi_iface, key_name, wepkey)
                               	        else
                               	                uci:set("wireless", wifi_iface, key_name, "")
                               	        end
                               	end
			end

			--WPAPSK
			if(security_mode == "WPAPSK")then
				uci:set("wireless", wifi_iface,"auth","WPAPSK")			
				
				if (encryption_method == "TKIP") then			
					uci:set("wireless", wifi_iface,"_encryption","TKIP")
					-- encryption
					uci:set("wireless", wifi_iface, "encryption","psk+tkip")
				elseif (encryption_method == "AES") then		
					uci:set("wireless", wifi_iface,"_encryption","AES")
					-- encryption
					uci:set("wireless", wifi_iface, "encryption","psk+aes")
				else			
					uci:set("wireless", wifi_iface,"_encryption","AES/TKIP")
					-- encryption
					uci:set("wireless", wifi_iface, "encryption","psk/tkip+aes")				
				end
				
				local WPAPSKkey = luci.http.formvalue("PSKey")
				if (WPAPSKkey == "") then
					uci:set("wireless", wifi_iface,"WPAPSKkey", "")
					uci:set("wireless", wifi_iface,"key", "")
				else						
					uci:set("wireless", wifi_iface,"WPAPSKkey", WPAPSKkey)
					uci:set("wireless", wifi_iface,"key", WPAPSKkey)
				end
			end

			--WPA2PSK
			if(security_mode=="WPA2PSK")then
				uci:set("wireless", wifi_iface,"auth","WPA2PSK")
				
				if (encryption_method == "TKIP") then		
					uci:set("wireless", wifi_iface,"_encryption","TKIP")
					-- encryption
					uci:set("wireless", wifi_iface, "encryption","psk2+tkip")
				elseif (encryption_method == "AES") then			
					uci:set("wireless", wifi_iface,"_encryption","AES")
					-- encryption
					uci:set("wireless", wifi_iface, "encryption","psk2+aes")
				else				
					uci:set("wireless", wifi_iface,"_encryption","AES/TKIP")
					-- encryption
					uci:set("wireless", wifi_iface, "encryption","psk2/tkip+aes")				
				end				
				
				--uci:set("wireless", wifi_iface,"_encryption","AES")
				-- encryption
				--uci:set("wireless", wifi_iface, "encryption","psk2+aes")
				local WPAPSKkey = luci.http.formvalue("PSKey")
				if (WPAPSKkey == "") then
					uci:set("wireless", wifi_iface,"WPAPSKkey", "")
					uci:set("wireless", wifi_iface,"key", "")
				else
					uci:set("wireless", wifi_iface,"WPAPSKkey", WPAPSKkey)
					uci:set("wireless", wifi_iface,"key", WPAPSKkey)
				end
			end			
			--WPAPSKWPA2PSK
			if(security_mode=="WPAPSKWPA2PSK")then
				uci:set("wireless", wifi_iface,"auth","WPAPSKWPA2PSK")
				
				if (encryption_method == "TKIP") then			
					uci:set("wireless", wifi_iface,"_encryption","TKIP")
					-- encryption
					uci:set("wireless", wifi_iface, "encryption","psk-mixed/tkip")
				elseif (encryption_method == "AES") then					
					uci:set("wireless", wifi_iface,"_encryption","AES")
					-- encryption
					uci:set("wireless", wifi_iface, "encryption","psk-mixed/aes")
				else					
					uci:set("wireless", wifi_iface,"_encryption","AES/TKIP")
					-- encryption
					uci:set("wireless", wifi_iface, "encryption","psk-mixed/tkip+aes")				
				end
				
				--uci:set("wireless", wifi_iface,"_encryption","AES")
				-- encryption
				--uci:set("wireless", wifi_iface, "encryption","psk-mixed/aes")
				local WPAPSKkey = luci.http.formvalue("PSKey")
				if (WPAPSKkey == "") then
					uci:set("wireless", wifi_iface,"WPAPSKkey", "")
					uci:set("wireless", wifi_iface,"key", "")
				else
					uci:set("wireless", wifi_iface,"WPAPSKkey", WPAPSKkey)
					uci:set("wireless", wifi_iface,"key", WPAPSKkey)
				end
			end

		end
		uci:commit("wireless")
		--uci:apply("wireless")
		sys.exec("/sbin/wifi") 
	end --end apply

--[[
	sys.exec("set_tmp_psk")
	tmppsk=sys.exec("cat /tmp/tmppsk")
	sys.exec("rm /tmp/tmppsk")

	local file = io.open("/var/countrycode", "r")	
	local temp = file:read("*all")
	file:close()
]]--

	local country = uci:get("wireless", "general", "country")
	--local code = country:match("([0-9a-zA-Z]+)")
	local region = country_code_table[country:gsub("[a-zA-Z]", string.upper)]

	luci.template.render("wlan", {channels = channelRange[region[1]], channels5G = channelRange5G[region[2]]})	
end

function wlanmacfilter()
	local apply = luci.http.formvalue("sysSubmit")
	local select_ap = luci.http.formvalue("ap_select")
	local changed = 0
	local filter

--[[	
	if not select_ap then
		select_ap="0"
	end

	filter="general"..select_ap
]]--	

	if apply then
		--filter on/of
		local MACfilter_ON = luci.http.formvalue("MACfilter_ON")
		MACfilter_ON_old = uci:get("wireless_macfilter", "filter","mac_state")
		if not (MACfilter_ON == MACfilter_ON_old) then
			changed = 1
			uci:set("wireless_macfilter", "filter","mac_state", MACfilter_ON)
		end
		--filter action
		local filter_act = luci.http.formvalue("filter_act")
		filter_act_old = uci:get("wireless_macfilter", "filter","filter_action")
		if not (filter_act == filter_act_old) then
			changed = 1
			uci:set("wireless_macfilter", "filter","filter_action", filter_act)
		end

		--mac address
		local MacAddr
		local Mac_field
		local MacAddr_old
		--MSTC MBA SW Sean, 20160113, the original openwrt dont have get_t function, we mark it anyway
		--local wlan_filter_number = tonumber(uci.get_t("web", "gui_config", "wlan_macfilter_max"))
		
		for i = 1, wlan_filter_number do
			Mac_field="MacAddr"..i
			MacAddr_old = uci:get("wireless_macfilter", "filter", Mac_field)
			MacAddr = luci.http.formvalue(Mac_field)
			if not ( MacAddr == MacAddr_old ) then
				changed = 1
				uci:set("wireless_macfilter", "filter", Mac_field, MacAddr)
			end
		end

		--new value need to be saved
		if (changed == 1) then
		--[[
			local iface_reset="ra"..select_ap
			local iface
			local iface_filter
			for i=0,3 do
				iface="ra"..i
				iface_filter="general"..i
				if (iface == iface_reset) then
					uci:set("wireless_macfilter", iface_filter, "reset", "1")
				else
					uci:set("wireless_macfilter", iface_filter, "reset", "0")	
				end
			end
		]]--
			uci:set("wireless_macfilter", "filter", "reset", "1")
			uci:commit("wireless_macfilter")
			uci:apply("wireless_macfilter")
			sys.exec("/sbin/wifi")
		end
	end
	luci.template.render("wlanmacfilter",{filter_iface=filter, ap=select_ap})	
end