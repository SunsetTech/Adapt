---@diagnostic disable:trailing-space
local Pretty = require"Moonrise.Tools.Pretty"
local OOP = require"Moonrise.OOP"

local Execution = require"Adapt.Execution"
local Compound = require"Adapt.Transform.Compound"

---@class Adapt.Transform.Atleast : Adapt.Transform.Compound
---@field Amount integer
---@field Children {Pattern: Adapt.Transform.Base}
---@overload fun(Amount: integer, Pattern: Adapt.Transform.Base): Adapt.Transform.Atleast
local Atleast = OOP.Declarator.Shortcuts(
	"Adapt.Transform.Atleast", {
		Compound
	}
)

---@param Instance Adapt.Transform.Atleast
---@param Amount integer
---@param Pattern Adapt.Transform.Base
function Atleast:Initialize(Instance, Amount, Pattern)
		---@diagnostic disable-next-line:undefined-field
		Compound:Initialize(Instance, {Pattern = Pattern})
	Instance.Amount = Amount -- >0 = atmost <0 = atleast 0 = greedy
end

---@param CurrentState Adapt.Execution.State
---@param Arguments any
---@return boolean
---@return Adapt.Execution.Bubble
function Atleast:Lower(CurrentState, Arguments)
	if Execution.Bubble.Is(Arguments) then
		assert(#Arguments >= self.Amount)
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
				return false, Results
			end
		end
		return true, Results
	else
		error"Must be a bubble"
	end
end

---@param CurrentState Adapt.Execution.State
---@param Argument any
---@return boolean
---@return Adapt.Execution.Bubble|nil
function Atleast:Raise(CurrentState, Argument)
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
		return #Results >= self.Amount, #Results >= self.Amount and Results or nil
	end
end

---@return string
function Atleast:__tostring()
	return tostring(self.Children.Pattern) .."^".. self.Amount
end

---@param Buffer Moonrise.Stream.Base
---@param Flags Tools.Pretty.Any.Flags
---@param Cache Tools.Pretty.Any.Cache
---@param Mentioned Tools.Pretty.Any.Mentioned
function Atleast:__pretty(Buffer, Flags, Cache, Mentioned)
	Buffer:Write("Adapt.Transform.Atleast(".. self.Amount ..", ")
	Pretty.Any(self.Children.Pattern, Buffer, Flags, Cache, Mentioned)
	Buffer:Write")"
end

return Atleast
