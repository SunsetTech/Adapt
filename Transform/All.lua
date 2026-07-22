local Pretty = require"Moonrise.Tools.Pretty"
local Execution = require"Adapt.Execution"
local Compound = require"Adapt.Transform.Compound"

local OOP = require"Moonrise.OOP"

---@class Adapt.Transform.All : Adapt.Transform.Compound
---@field Children {Pattern: Adapt.Transform.Base}
---@overload fun(Pattern: Adapt.Transform.Base): Adapt.Transform.All
local All = OOP.Declarator.Shortcuts(
	"Adapt.Transform.All", {
		Compound
	}
)

---@param Instance Adapt.Transform.All
---@param Pattern Adapt.Transform.Base
function All:Initialize(Instance, Pattern)
		Compound:Initialize(Instance, {Pattern = Pattern})
end

---@param CurrentState Adapt.Execution.State
---@param Arguments any
---@return boolean
---@return Adapt.Execution.Bubble?
function All:Lower(CurrentState, Arguments)
	if Execution.Bubble.Is(Arguments) then --bubble->bubble
		local Results = Execution.Bubble.Form()
		local Success
		for Index = 1, #Arguments do
			local Argument = Arguments[Index]
			local Result
			Success, Result = Execution.Recurse(
				CurrentState,
				"Lower", self.Children.Pattern, Argument
			)
			if Success then
				table.insert(Results, Result)
			else
				return false
			end
		end
		CurrentState:AddConstraint(self.Children.Pattern, nil, "Negative")
		return true, Results
	else
		error"Must be a bubble"
	end
end

---@param CurrentState Adapt.Execution.State
---@param Argument any
---@return boolean
---@return Adapt.Execution.Bubble
function All:Raise(CurrentState, Argument)
	if Execution.Bubble.Is(Argument) then --TODO bubble->bubble args version
		error"help"
	else -- single->bubble
		local Success
		local Results = Execution.Bubble.Form()
		repeat
			local Result
			Success, Result = Execution.Recurse(
				CurrentState,
				"Raise", self.Children.Pattern, Argument
			)
			if Success then
				table.insert(Results, Result)
			end
		until not Success
		return true, Results
	end
end

---@return string
function All:__tostring()
	error"?"
	return Pretty.ToString(self)
end

---@param Sink Moonrise.Stream.Formatter.Fancy
---@param Flags Tools.Pretty.Any.Flags
---@param Cache Tools.Pretty.Any.Cache
---@param Mentioned Tools.Pretty.Any.Mentioned
function All:__pretty(Sink, Flags, Cache, Mentioned)
	Sink:Write("Adapt.Transform.All(")
	Pretty.Any(self.Children.Pattern, Sink, Flags, Cache, Mentioned)
	Sink:Write")"
end

return All
