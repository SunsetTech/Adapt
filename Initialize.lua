---@diagnostic disable:trailing-space	
---@param Root Adapt.Transform.Base 
---@param Buffer Moonrise.Stream.Base
---@param DebugBuffer Moonrise.Stream.Base?
---@param DebugFlags Tools.Pretty.Any.Flags?
---@param DebugCache table<userdata|table,boolean>?
---@param DebugMentioned table<string,userdata|table>?
---@param IgnoreDebug table<Adapt.Transform.Base,boolean>?
---@param NameMap table?
---@param JumpMap table?
---@param Fragment boolean?
local function Initialize(
	Root, Buffer,
	DebugBuffer, DebugFlags, DebugCache, DebugMentioned, IgnoreDebug, 
	NameMap, JumpMap,
	Fragment
)
	assert(Root ~= nil)
	local ProgramState = Adapt.Execution.State(
		Root, Buffer,
		DebugBuffer, DebugFlags, DebugCache, DebugMentioned, IgnoreDebug,
		NameMap, JumpMap,
		Fragment
	)
	ProgramState:Optimize()
	ProgramState:Link(Root)
	Buffer:Optimize()
	return ProgramState
end;
return Initialize
