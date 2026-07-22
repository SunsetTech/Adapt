local Execution = require"Adapt.Execution"
local Pretty = require"Moonrise.Tools.Pretty"

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
				Include = Include;
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
			return true, IncludeResult
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
	local IncludeSuccess, IncludeResult = Execution.Recurse(CurrentState, "Lower", self.Children.Include, Argument)
	if IncludeSuccess then
		local After = CurrentState:Position()
		CurrentState:Goto(Start)
		local ExcludeSuccess = Execution.Recurse(CurrentState, "Raise", self.Children.Exclude, Argument, "Negative")
		if ExcludeSuccess then
			if CurrentState:GetFrame().Translation.HitEnd then
				CurrentState:AddConstraint(self.Children.Exclude, IncludeResult, "Negative")
			end
			CurrentState:Goto(After)
			return true, IncludeResult
		end
		return false
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

