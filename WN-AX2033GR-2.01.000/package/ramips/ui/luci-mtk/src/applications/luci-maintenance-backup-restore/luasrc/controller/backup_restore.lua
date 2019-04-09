module("luci.controller.backup_restore", package.seeall)
local uci = require("luci.model.uci").cursor()
local sys = require("luci.sys")

function index()
	local i18n = require("luci.i18n")
	local libuci = require("luci.model.uci").cursor()
	local lang = libuci:get("luci","main","lang") 
	i18n.load("backup_restore",lang)
	i18n.setlanguage(lang)
	
	local page  = node("expert", "maintenance", "bakrestore")
	page.target = call("action_backup")
	page.title  = i18n.translate("Backup_Restore")  
	page.order  = 80
end

function action_backup()
        --local restore_cmd = "gunzip | tar -xC/ >/dev/null 2>&1"
		local restore_cmd = "cat >/tmp/romfile.bak "
        --local backup_cmd  = "tar -c %s | gzip 2>/dev/null"
		local backup_cmd  = "/usr/sbin/backup.sh -e config_backup.bak && cat config_backup.bak 2>/dev/null"

        local cnt=0
        local restore_fpi
        luci.http.setfilehandler(
                function(meta, chunk, eof)
                        if not restore_fpi then
                                restore_fpi = io.popen(restore_cmd, "w")
                        end
			if (cnt < 64) then
				if chunk then
                                	restore_fpi:write(chunk)
					cnt=cnt+1
				end
			end	
                        if eof then
                                restore_fpi:close()
                        end
                end
        )

		local upload = luci.http.formvalue("RestoreSubmit")
        local backup = luci.http.formvalue("Backup")
		local reset  = luci.http.formvalue("ResetSubmit")

	local logfile
                

        if upload=="1" then
				sys.exec("/usr/sbin/restore.sh -d -f /tmp/romfile.bak > /tmp/restore_log")
				local _result=1
                local _logfile = io.open("/tmp/restore_log", "r")
				local _msg
				
                while true do
                        _msg = _logfile:read("*line")

                        if not _msg then
							_result=1
                            break
                        end

                        if _msg == "OK" then
                            _result=0
                            break
                        end
                end
				if _result == 0 then
					luci.template.render("backup_restore",{rebootsystem=1,restore_result=_result})
					sys.exec("reboot")
				else
					luci.template.render("backup_restore",{restore_result=_result})
				end

        elseif backup then
                --luci.util.perror(backup_cmd:format(_keep_pattern()))
                local backup_fpi = io.popen(backup_cmd, "r")
                luci.http.header('Content-Disposition', 'attachment; filename="backup-%s.rom"' % {
                        os.date("%Y-%m-%d-%H%M%S")})
                luci.http.prepare_content("application/x-targz")
                luci.ltn12.pump.all(luci.ltn12.source.file(backup_fpi), luci.http.write)
				luci.template.render("backup_restore")
        elseif reset=="1" then
                luci.template.render("backup_restore",{rebootsystem=1})
				sys.exec("/usr/sbin/factoryreset.sh")

        else
                luci.template.render("backup_restore")
        end
end
