---@diagnostic disable:trailing-space
local Execution = require"Adapt.Execution"

---@alias Adapt.MethodName "Raise"|"Lower"
---@alias Adapt.Method Adapt.MethodName

---@param Root Adapt.Transform.Base 
---@param MethodName Adapt.MethodName 
---@param Buffer Moonrise.Stream.Base
---@param Argument any
---@param Maps Adapt.Execution.State.Map?
---@param Fragment boolean?
---@return boolean Success
---@return any Result
---@return Adapt.Execution.State ProgramState
return function(Root, MethodName, Buffer, Argument, Start, Maps, Fragment)
	assert(Root ~= nil)
	Start = Start or Root
	local ProgramState = Execution.State(Root, Buffer, Maps, Fragment)
	ProgramState:Optimize()
	Buffer:Optimize()
	local Success, Result = Execution.Recurse(ProgramState, MethodName, Start, Argument)
	return Success, Result, ProgramState
end;
