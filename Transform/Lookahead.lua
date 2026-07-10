---@diagnostic disable:trailing-space
local Execution = require"Adapt.Execution"
local Null = require"Moonrise.Object.Null"

local OOP = require"Moonrise.OOP"

local Compound = require"Adapt.Transform.Compound"

---@class Adapt.Transform.Lookahead: Adapt.Transform.Compound
---@field Children {__LookaheadPattern: Adapt.Transform.Base}
---@field Mode Adapt.Execution.State.Lookahead
---@overload fun(Mode: Adapt.Execution.State.Lookahead, Pattern: Adapt.Transform.Base): Adapt.Transform.Lookahead
local Lookahead = OOP.Declarator.Shortcuts(
	"Adapt.Transform.Lookahead", {
		Compound
	}
)

---@param Instance Adapt.Transform.Lookahead
---@param Mode Adapt.Execution.State.Lookahead
---@param Pattern Adapt.Transform.Base
function Lookahead:Initialize(Instance, Mode, Pattern)
		Compound:Initialize(Instance, {__LookaheadPattern = Pattern})
	Instance.Mode = Mode
end

function Lookahead:Raise(CurrentState, Argument)
	local Success, _, ResultFrame = Execution.Recurse(CurrentState, "Raise", self.Children.__LookaheadPattern, Argument, self.Mode)
	if CurrentState.Fragment and ResultFrame.Translation.HitEnd then
		return true, Null
	elseif Success then
		return true, Null
	end
	return false
end

function Lookahead:Lower(CurrentState, Argument)
	if Argument == Null then
		CurrentState:AddConstraint(self.Children.__LookaheadPattern, nil, self.Mode)
		return true
	end
	return false
end

return Lookahead

