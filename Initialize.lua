---@diagnostic disable:trailing-space
local State = require"Adapt.Execution.State"

---@param Root Adapt.Transform.Base 
---@param Buffer Moonrise.Stream.Base
---@param Maps Adapt.Execution.State.Map?
---@param Fragment boolean?
local function Initialize(Root, Buffer, Maps, Fragment)
	assert(Root ~= nil)
	local ProgramState = State(Root, Buffer, Maps, Fragment)
	ProgramState:Optimize()
	Buffer:Optimize()
	return ProgramState
end;

return Initialize
