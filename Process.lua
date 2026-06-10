---@diagnostic disable:trailing-space
local Execution = require"Adapt.Execution"

---@alias Adapt.MethodName "Raise"|"Lower"
---@alias Adapt.Method Adapt.MethodName

---@param Root Adapt.Transform.Base 
---@param MethodName Adapt.MethodName 
---@param Buffer Moonrise.Stream.Base
---@param Argument any
---@param DebugBuffer Moonrise.Stream.Base?
---@param DebugFlags Tools.Pretty.Any.Flags?
---@param DebugCache table<userdata|table,boolean>?
---@param DebugMentioned table<string,userdata|table>?
---@param IgnoreDebug table<Adapt.Transform.Base,boolean>?
---@param NameMap table?
---@param JumpMap table?
---@param Fragment boolean?
---@return boolean Success
---@return any Result
---@return Adapt.Execution.State ProgramState
return function(
	Root, MethodName, Buffer, Argument, Start, 
	DebugBuffer, DebugFlags, DebugCache, DebugMentioned, IgnoreDebug, 
	NameMap, JumpMap,
	Fragment
)
	assert(Root ~= nil)
	Start = Start or Root
	local ProgramState = Execution.State(
		Root, Buffer, 
		DebugBuffer, DebugFlags, DebugCache, DebugMentioned, IgnoreDebug, 
		NameMap, JumpMap,
		Fragment
	)
	ProgramState:Optimize()
	ProgramState:Link(Root)
	Buffer:Optimize()
	local Success, Result = Execution.Recurse(ProgramState, MethodName, Start, Argument)
	return Success, Result, ProgramState
end;
