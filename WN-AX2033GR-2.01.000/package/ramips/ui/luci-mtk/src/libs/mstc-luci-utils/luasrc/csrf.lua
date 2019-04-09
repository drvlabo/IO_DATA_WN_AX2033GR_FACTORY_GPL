--[[

Author: MSTC MBA SW RD Sean

2016/07/04

]]--
local io     = require "io"
local os     = require "os"
local sys = require "luci.sys"
local http = require "luci.http"

module "luci.csrf"

csrf_token_path = "/tmp/csrf_token"

function create_token()

	-- this will create token for every page.
	-- "/tmp/csrf_token/user_ip/page"

	file = io.open(csrf_token_path , "w")
	
	if file then 
		rand = sys.uniqueid(32)

		file:write(rand)
	
		file:close()
	end
	
	return rand
	
end

function get_csrf_token_in_web()

	local csrf_token  = http.formvalue("csrf_token")
	return csrf_token

end

function get_token()

	file = io.open(csrf_token_path, "r")
	if file then 
		csrf_token = file:read()

		file:close()
	end
	
	return csrf_token
	
end

function verify(token)

	local file = io.open(csrf_token_path  , "r")
	if file and token then 
		csrf_token = file:read()
		
		file:close()
	
		if ( not (csrf_token == token) ) then 
			--remove the token to avoid attacker try again
			os.remove(csrf_token_path)
			return false
		else
			os.remove(csrf_token_path)
			return true
		end
	else
		os.remove(csrf_token_path)
		return false
	end
	
end

function http_return_200()

	http.status(200, "OK")

end

function http_return_403()

	http.status(403, "Forbidden")

end
