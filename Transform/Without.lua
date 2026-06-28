local Stream = require"Moonrise.Stream"
local Execution = require"Adapt.Execution"
local Pretty = require"Moonrise.Tools.Pretty"

---@param CurrentState Adapt.Execution.State
---@param Pattern Adapt.Transform.Base
---@param Argument any
---@param Lookahead Adapt.Execution.State.Lookahead?
---@return boolean
---@return any
---@return string
local function LowerAndReadBack(CurrentState, Pattern, Argument, Lookahead)
	local Start = CurrentState:Position()
	local Success, Result = Execution.Recurse(CurrentState, "Lower", Pattern, Argument, Lookahead)
	if Success then
		local After = CurrentState:Position()
		CurrentState.Buffer:Goto(Start)
		local Written = CurrentState:Read(After - Start)
		return Success, Result, Written
	end
	return false, nil, ""
end

local Compound = require"Adapt.Transform.Compound"

local OOP = require"Moonrise.OOP"

---@class Adapt.Transform.Without : Adapt.Transform.Compound
---@field public Children {Exclude: Adapt.Transform.Base, Include: Adapt.Transform.Base}
---@overload fun(Exclude: Adapt.Transform.Base, Include:Adapt.Transform.Base): Adapt.Transform.Without
local Without = OOP.Declarator.Shortcuts(
	"Adapt.Transform.Without", {
		Compound
	}
)

function Without:Initialize(Instance, Exclude, Include)
	---@diagnostic disable-next-line:undefined-field
		Compound:Initialize(
			Instance, {
				Exclude = Exclude;
				Include = Include
			}
		)
end

---@param CurrentState Adapt.Execution.State
---@param Argument any
---@return boolean
---@return any
function Without:Raise(CurrentState, Argument)
	local Start = CurrentState:Position()
	local IncludeSuccess, IncludeResult = Execution.Recurse(CurrentState, "Raise", self.Children.Include, Argument)
	if IncludeSuccess then
		local After = CurrentState:Position()
		CurrentState:Goto(Start)
		local ExcludeSuccess = Execution.Recurse(CurrentState, "Raise", self.Children.Exclude, Argument, "Negative")
		if ExcludeSuccess then
			CurrentState:Goto(After)
			return IncludeSuccess, IncludeResult
		end
		return false
	end
	return false
end

---@param CurrentState Adapt.Execution.State
---@param Argument any
---@return boolean
---@return any
function Without:Lower(CurrentState, Argument)
	local Start = CurrentState:Position()
	local IncludeSuccess, IncludeResult, IncludeWritten = LowerAndReadBack(CurrentState, self.Children.Include, Argument)
	if IncludeSuccess then
		local AfterInclude = CurrentState:Position()
		local CurrentBuffer = CurrentState.Buffer
		CurrentState.Buffer = Stream.String("")
		local ExcludeSuccess, _, ExcludeWritten = LowerAndReadBack(CurrentState, self.Children.Exclude, Argument, "Negative")
		CurrentState.Buffer = CurrentBuffer
		if not ExcludeSuccess and (#IncludeWritten >= #ExcludeWritten) then
			local AfterExclude = CurrentState:Position()
			local IncludeSubstring = IncludeWritten:sub(1, #ExcludeWritten)
			if ExcludeWritten ~= IncludeSubstring then
				CurrentState:Goto(Start)
				CurrentState:AddConstraint(self.Children.Exclude, IncludeResult, "Negative")
				CurrentBuffer:Goto(AfterInclude)
				return true, IncludeResult
			end
			CurrentState:Goto(AfterExclude)
			return false
		else
			CurrentState:Goto(Start)
			if CurrentState:GetFrame().Translation.HitEnd then
				CurrentState:AddConstraint(self.Children.Exclude, IncludeResult, "Negative")
			end
			CurrentBuffer:Goto(AfterInclude)
			return true, IncludeResult
		end
	end
	return false
end

---@param Buffer Moonrise.Stream.Formatter.Indented
---@param Flags Tools.Pretty.Any.Flags
---@param Cache Tools.Pretty.Any.Cache
---@param Mentioned Tools.Pretty.Any.Mentioned
function Without:__pretty(Buffer, Flags, Cache, Mentioned)
	Buffer:Write"Adapt.Transform.Without("
	Pretty.Any(self.Children.Exclude, Buffer, Flags, Cache, Mentioned)
	Buffer:Write","
	Pretty.Any(self.Children.Include, Buffer, Flags, Cache, Mentioned)
	Buffer:Write")"
end

return Without

