module("luci.controller.fw_upgrade", package.seeall)
local uci = require("luci.model.uci").cursor()
local sys = require("luci.sys")

function index()
	local i18n = require("luci.i18n")
	local libuci = require("luci.model.uci").cursor()
	local lang = libuci:get("luci","main","lang") 
	i18n.load("fw_upgrade",lang)
	i18n.setlanguage(lang)
	
	local page  = node("expert", "maintenance", "fw")
	page.target = call("action_upgrade")
	page.title  = i18n.translate("Firmware_Upgrade")  
	page.order  = 70
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
			luci.template.render("fw", {checksum=filechecksum, filesize=loadfilesize, fileupload=1})
                else
			sys.exec("rm -rf /tmp/ras.bin")
			--sys.exec("cat /tmp/fwupgrade_log | awk '{sub(/^/, \"<p>\");print}' | \
			--	awk '{sub(/$/, \"</p>\");print}' > /tmp/fwupgrade_log2")
			ret = sys.exec("echo fail")
			luci.template.render("fw", {fileupload=2, errmsg=ret})
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

	luci.template.render("fw", {fileupload=0, on_line_check_fw=2,on_line_fw_dl=1})
end