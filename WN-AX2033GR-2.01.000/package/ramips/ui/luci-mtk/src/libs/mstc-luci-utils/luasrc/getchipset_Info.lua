--[[

Author: MSTC MBA SW RD Olivia

2016/07/04

]]--
local io = require "io"
local os = require "os"
local sys = require "luci.sys"
local uci = require("luci.model.uci").cursor()
local http = require "luci.http"

module "luci.getchipset_Info"

function parse_chipset(fqc)
        local chipset_fqce_type={}
        local chipset_t
        local file
        if fqc and fqc == "2G" then
			file = io.popen("uci show wireless | grep\ \"2\.4G\" | awk\ -F\ \"\.\"\ \'\{\ print\ \$2\}\' | tr\ -d\ \'\\r\'", 'r')
        else
			file = io.popen("uci show wireless | grep\ \"5G\" | awk\ -F\ \"\.\"\ \'\{\ print\ \$2\}\' | tr\ -d\ \'\\r\'", 'r')
        end
        if file then
			chipset_t = file:read()
			if chipset_t then
				chipset_fqce_type[#chipset_fqce_type+1] = uci.get("wireless",chipset_t,"type")
			end
        end
        io.close(file)

        return chipset_fqce_type[1]
end
