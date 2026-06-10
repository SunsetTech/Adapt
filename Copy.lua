---@diagnostic disable:trailing-space
local posix = require("posix")
local Process = require "Adapt.Process"
local Pretty = require"Moonrise.Tools.Pretty"

---Function to get the current time in seconds with nanosecond precision
---@return number
local function getTime()
    local s, ns = posix.clock_gettime(posix.CLOCK_REALTIME)
    return s + ns*1e-9
end

---@param Pattern Adapt.Transform.Base
---@param From Moonrise.Stream.Base
---@param To Moonrise.Stream.Base
---@param DebugBuffer Moonrise.Stream.Base?
---@param DebugFlags Tools.Pretty.Any.Flags?
---@param DebugCache table<userdata|table,boolean>?
---@param DebugMentioned table<string,userdata|table>?
---@param IgnoreDebug table<Adapt.Transform.Base, boolean>?
---@return boolean ReadSuccess
---@return boolean WriteSuccess
local function Copy(Pattern, From, To, DebugBuffer, DebugFlags, DebugCache, DebugMentioned, IgnoreDebug)
    local Start = getTime()
	if DebugBuffer then
    	DebugBuffer:AddLine"Reading..."
	end
    local ReadSuccess, ReadResult, ReadFinalState = Process(
		Pattern, "Raise", From, nil, nil, 
		DebugBuffer, DebugFlags, IgnoreDebug
	)
	if DebugBuffer then 
		DebugBuffer:AddLine("Current memory usage: ".. collectgarbage"count" / 1024 .."MB")
	end
    local ReadTime = getTime() - Start
    local WriteSuccess = false
	local WriteTime
    if ReadSuccess then
		Pretty.Print(ReadResult, DebugFlags, DebugCache, DebugMentioned)
		if DebugBuffer then
			DebugBuffer:AddLine"Writing..."
		end
        Start = getTime()
        WriteSuccess = Process(
			Pattern, "Lower", To, ReadResult, nil,
			DebugBuffer, DebugFlags, DebugCache, DebugMentioned, IgnoreDebug,
			ReadFinalState.NameMap, ReadFinalState.JumpMap
		)
		if DebugBuffer then
			DebugBuffer:AddLine("Current memory usage: ".. collectgarbage"count" /1024 .."MB")
		end
        WriteTime = getTime() - Start
    end
	--[[]if DebugBuffer then--[[]]
		print("Read in ".. ReadTime .."s")
		print("Write in ".. WriteTime .."s")
	--[[]end--[[]]
    return ReadSuccess, WriteSuccess
end

return Copy
