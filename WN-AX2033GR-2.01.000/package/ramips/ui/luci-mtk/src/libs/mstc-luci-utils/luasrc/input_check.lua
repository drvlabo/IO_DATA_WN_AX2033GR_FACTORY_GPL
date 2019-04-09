--[[

Author: MSTC MBA SW Sean, port from zyxel

]]--
module ("luci.input_check", package.seeall)

function checkInjection(str)

        if nil ~= string.match(str,"'") then
			return false
        end

        if nil ~= string.match(str,"-") then
			return false
        end

        if nil ~= string.match(str,"<") then
			return false
        end

        if nil ~= string.match(str,">") then
			return false
        end

        return str
end
