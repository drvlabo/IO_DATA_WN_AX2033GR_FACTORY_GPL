--[[

Session authentication
(c) 2008 Steven Barth <steven@midlink.org>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

$Id$

]]--

--- LuCI session library.
module("luci.sauth", package.seeall)
require("luci.util")
require("luci.sys")
require("luci.config")
local nixio = require "nixio", require "nixio.util"
local fs = require "nixio.fs"


luci.config.sauth = luci.config.sauth or {}
sessionpath = luci.config.sauth.sessionpath
sessiontime = tonumber(luci.config.sauth.sessiontime) or 15 * 60

--- Prepare session storage by creating the session directory.
function prepare()
	fs.mkdir(sessionpath, 700)
	if not sane() then
		error("Security Exception: Session path is not sane!")
	end
end

local function _read(id)
	local blob = fs.readfile(sessionpath .. "/" .. id)
	return blob
end

local function _write(id, data)
	--local f = nixio.open(sessionpath .. "/" .. id, "w", 600)
	local tempid = luci.sys.uniqueid(16)
	--[[ MSTC MBA Sean, rename session id file instead rewrite to avoid
		race condcition when multiple page access session file==>]]--
	local tempfile = sessionpath .. "/" .. tempid
	local sessfile = sessionpath .. "/" .. id
	local f = nixio.open(tempfile, "w", 600)
	--[[ MSTC MBA Sean,  <==]]--
	f:writeall(data)
	f:close()
	--[[ MSTC MBA Sean,  ==>]]--
	fs.rename(tempfile, sessfile)
	--[[ MSTC MBA Sean,  ==<]]--
end

local function _checkid(id)
	return not not (id and #id == 32 and id:match("^[a-fA-F0-9]+$"))
end

--- Write session data to a session file.
-- @param id	Session identifier
-- @param data	Session data table
function write(id, data)
	if not sane() then
		prepare()
	end

	assert(_checkid(id), "Security Exception: Session ID is invalid!")
	assert(type(data) == "table", "Security Exception: Session data invalid!")

	data.atime = luci.sys.uptime()

	_write(id, luci.util.get_bytecode(data))
end

--- Read a session and return its content.
-- @param id	Session identifier
-- @return		Session data table or nil if the given id is not found
function read(id)
	if not id or #id == 0 then
		return nil
	end

	assert(_checkid(id), "Security Exception: Session ID is invalid!")

	if not sane(sessionpath .. "/" .. id) then
		return nil
	end

	local blob = _read(id)
	local func = loadstring(blob)
	setfenv(func, {})

	local sess = func()
	local wait = 0
	while ((type(sess) == nil) and (wait < 50)) do
		wait = wait + 1
	end
	assert(type(sess) == "table", "Session data invalid!" .. wait )

	--MBA MSTC Sean, don't check sessiontime if sessiontime set to 0
	if ( (sessiontime > 0) and (sess.atime) and (sess.atime + sessiontime < luci.sys.uptime()) )then
		kill(id)
		return nil
	end

	-- refresh atime in session
	write(id, sess)

	return sess
end

--- Check whether Session environment is sane.
-- @return Boolean status
function sane(file)
	return luci.sys.process.info("uid")
			== fs.stat(file or sessionpath, "uid")
		and fs.stat(file or sessionpath, "modestr")
			== (file and "rw-------" or "rwx------")
end

--- Kills a session
-- @param id	Session identifier
function kill(id)
	assert(_checkid(id), "Security Exception: Session ID is invalid!")
	fs.unlink(sessionpath .. "/" .. id)
end

--- Remove all expired session data files
function reap()
	if sane() then
		local id
		for id in nixio.fs.dir(sessionpath) do
			if _checkid(id) then
				-- reading the session will kill it if it is expired
				read(id)
			end
		end
	end
end
