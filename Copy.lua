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
---@return boolean ReadSuccess
---@return boolean WriteSuccess
local function Copy(Pattern, From, To)
    local Start = getTime()
    local ReadSuccess, ReadResult = Process(Pattern, "Raise", From)
    local ReadTime = getTime() - Start
    local WriteSuccess = false
	local WriteTime
    if ReadSuccess then
		Pretty.Print(ReadResult)
        Start = getTime()
        WriteSuccess = Process(Pattern, "Lower", To, ReadResult)
        WriteTime = getTime() - Start
    end
	print("Read in ".. ReadTime .."s")
	print("Write in ".. WriteTime .."s")
    return ReadSuccess, WriteSuccess
end

return Copy
