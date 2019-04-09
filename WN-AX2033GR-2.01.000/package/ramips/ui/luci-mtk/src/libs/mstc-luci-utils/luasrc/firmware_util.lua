--[[

Author: MSTC MBA SW Sean, port from zyxel

]]--
module ("luci.firmware_util", package.seeall)

local uci = require("luci.model.uci").cursor()
local sys = require("luci.sys")

local tmpfile = "/tmp/rootfs"

function storage_size()
	local size = 0
	if nixio.fs.access("/proc/mtd") then
		for l in io.lines("/proc/mtd") do
			local d, s, e, n = l:match('^([^%s]+)%s+([^%s]+)%s+([^%s]+)%s+"([^%s]+)"')
			--if n == "fs" then
			if ((n == "fs") or (n == "firmware")) then
				size = tonumber(s, 16)
				break
			end
		end
	elseif nixio.fs.access("/proc/partitions") then
		for l in io.lines("/proc/partitions") do
			local x, y, b, n = l:match('^%s*(%d+)%s+(%d+)%s+([^%s]+)%s+([^%s]+)')
			if b and n and not n:match('[0-9]') then
				size = tonumber(b) * 1024
				break
			end
		end
	end
	return size
end

function check_firmware()
	local product_name = uci:get("system","main","product_name")

	local logfile
	
	flashsize = storage_size()
	filechecksum = image_checksum()
	loadfilesize=nixio.fs.stat(tmpfile).size
		
	local fw_info = io.open("/tmp/fw_mtd", "r")
	local dual_image = nil 
	if fw_info then
		dual_image = fw_info:read("*line")
		fw_info:close()
	end

	if ((dual_image) and (dual_image ~= "single")) then
		if dual_image == "ff01" or dual_image == "ffff" then
			io.popen("fw_upgrade fw_check 1> /tmp/logfile 2> /dev/null")
		else
			sys.exec("dd if=/dev/mtdblock3 of=/tmp/mtd3 bs=2 count=1")
			sys.exec("hexdump /tmp/mtd3 | grep '0000000'|cut -c '9-12' >/tmp/fw_mtd")
			io.popen("fw_upgrade fw_check $(cat /tmp/fw_mtd) 1> /tmp/logfile 2> /dev/null")
		end
	else
		local cmd = "/sbin/mstc_fwcheck " .. tmpfile .. " > /dev/null 2>&1";
		ret = sys.call(cmd);
	end
	
	--MSTC MBA Sean, Check 1:mstc_fwcheck 2:size 3:firmware id
	if  ( (ret == 0) and (flashsize > loadfilesize) and (get_current_firmware_id() == get_uploaded_firmware_id() ) )then
		return 0
	else
		return -1
	end
	
end

function get_current_firmware_id()
	local firmware_id = ""
	file = io.popen("sys atsh | grep \'Firmware Version\'", 'r')
	if file then
		local data_raw = file:read()
		if data_raw then
			firmware_id = data_raw:match(".+:%s.+%((.+)%.%d%).+")
		end
		io.close(file)
	end
	
	return firmware_id
end

function get_uploaded_firmware_id()
	local firmware_id = ""
	local file = assert(io.open(tmpfile, 'rb'))
	local t = {}

	local str = file:read(64) --MBA Sean, Read all mkimage header out
	file:close()

	local frimware_version = string.sub(str, 33, 56) --MBA Sean, mkimage name part
	firmware_id = frimware_version:match(".+%((.+)%.%d%).+")
	return firmware_id
end

function image_checksum()
	return (luci.sys.exec("md5sum %q" % tmpfile):match("^([^%s]+)"))
end

function do_fwupgrade()
	sys.exec("sleep 1 && echo 1 > /proc/sys/vm/drop_caches")
	sys.exec("echo 'Firmware upgrading, Please wait !' > /dev/console")
	sys.exec("zyxel_led_ctrl upgrate")
	--sys.exec("do_fw_upgrade.sh")
	local cmd = "/bin/sleep 2 && /sbin/sysupgrade -n " .. tmpfile .. " > /dev/console 2>&1 &";
	sys.call(cmd);
end