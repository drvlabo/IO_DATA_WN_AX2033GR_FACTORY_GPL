module("luci.controller.sms", package.seeall)
local uci = require("luci.model.uci").cursor()
local sys = require("luci.sys")

function index()
	local i18n = require("luci.i18n")
	local libuci = require("luci.model.uci").cursor()
	local lang = libuci:get("luci","main","lang") 
	i18n.load("sms",lang)
	i18n.setlanguage(lang)
	
	local page  = node("expert", "monitor", "sms")
	page.target = call("action_sms")
	page.title  = "SMS"  
	page.order  = 75
	
	local page  = node("expert", "monitor", "sms", "sms_send")
	page.target = call("action_sms_send")
	page.title  = "SMS"  
	page.order  = 75
end

function action_sms()
	luci.template.render("sms")
	
	local apply = luci.http.formvalue("apply")
	
	if(apply == "1") then
		local deleteNo = luci.http.formvalue("deleteNo")
		local storageType = luci.http.formvalue("storageType")
		
		sys.exec("rm /tmp/del_c")
		cmd = "echo "..storageType..","..deleteNo.." > /tmp/del_c"
		sys.exec(cmd)
		sys.exec("/usr/sbin/sms.sh delete")
	end
end

function parse_sms(callback)
	sys.exec("rm /tmp/smscount")
	local counter = 0
	sys.exec("/usr/sbin/sms.sh read")
	return callback(counter)
end


function action_sms_send()
	luci.template.render("sms_send")

	local apply = luci.http.formvalue("apply")
	
	if(apply == "1") then
		local Receiver = luci.http.formvalue("Receiver")
		local Length = luci.http.formvalue("Length")
		local Data = luci.http.formvalue("Data")
		local ContentType = luci.http.formvalue("ContentType")
		if (Receiver ~= nil ) then
			local tmpbuf = "echo "..Receiver.." >> /tmp/errReceive"
			sys.exec(tmpbuf)
		end
		if (Length ~= nil ) then
			local tmpbuf = "echo "..Length.." >> /tmp/errLength"
			sys.exec(tmpbuf)
		end
		if (Data ~= nil ) then
		        local tmpbuf = "echo "..Data.." >> /tmp/errData"
		        sys.exec(tmpbuf)
		end
		if (ContentType ~= nil ) then
        		local tmpbuf = "echo "..ContentType.." >> /tmp/errType"
                        sys.exec(tmpbuf)		
		end
		local s_file="/tmp/sms_send1"
		local s_f,err=io.open(s_file,"w")
		if (err ~= nil) then
			sys.exec("echo 555 >> /tmp/openfail")
		end
--		local cmdbuf = "echo \"mo_sms_gsm "..Receiver.."\" >> /usr/bin/commandpipe" -- Receiver's phone number 
		s_f:write(ContentType.." "..Length.." "..Data)
		s_f:close()
		local cmdbuf = "/usr/sbin/sms.sh send "..Receiver
		sys.exec(cmdbuf)
	end
end
