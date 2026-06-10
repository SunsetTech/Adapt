---@diagnostic disable:trailing-space
local Pretty = require"Moonrise.Tools.Pretty"
local OOP = require"Moonrise.OOP"

local Execution = require"Adapt.Execution"

---@class Adapt.Transform.Atmost : Adapt.Transform.Compound
---@operator call:Adapt.Transform.Atmost
---@field Amount integer
---@field Pattern Adapt.Transform.Base
---@overload fun(Amount: integer, Pattern: Adapt.Transform.Base): Adapt.Transform.Atmost
local Atmost = OOP.Declarator.Shortcuts(
	"Adapt.Transform.Atmost", {
		require"Adapt.Transform.Compound"
	}
)

---@param Instance Adapt.Transform.Atmost
---@param Amount integer
---@param Pattern Adapt.Transform.Base
function Atmost:Initialize(Instance, Amount, Pattern)
		---@diagnostic disable-next-line:undefined-field
		Atmost.Parents.Compound:Initialize(Instance, {Pattern = Pattern})
	Instance.Amount = Amount -- >0 = atmost <0 = atleast 0 = greedy
	Instance.Pattern = Pattern
end

---@param CurrentState Adapt.Execution.State
---@param Arguments any
---@return boolean
---@return Adapt.Execution.Bubble?
function Atmost:Lower(CurrentState, Arguments)
	if Execution.Bubble.Is(Arguments) then
		if #Arguments <= self.Amount then
			local Results = Execution.Bubble.Form()
			
			local Success
			--for _, Argument in pairs(Arguments) do
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
			
			return true, Results
		else
			return false
		end
	else
		error"Must be a bubble"
	end
end

---@param CurrentState Adapt.Execution.State
---@param Argument any
---@return boolean
---@return Adapt.Execution.Bubble
function Atmost:Raise(CurrentState, Argument)
	if Execution.Bubble.Is(Argument) then -- TODO: bubble->bubble args version?
		error"help"
	else --single->bubble
		local Results = Execution.Bubble.Form()
		for _ = 1, self.Amount do
			local Success, Result = Execution.Recurse(
				CurrentState,
				"Raise", self.Children.Pattern, Argument
			)
			if Success then
				table.insert(Results, Result)
			else
				break
			end
		end
		return true, Results
	end
end

---@return string
function Atmost:__tostring()
	return tostring(self.Children.Pattern) .."^-1"
end

---@param Buffer Moonrise.Stream.Base
---@param Flags Tools.Pretty.Any.Flags
---@param Cache Tools.Pretty.Any.Cache
---@param Mentioned Tools.Pretty.Any.Mentioned
function Atmost:__pretty(Buffer, Flags, Cache, Mentioned)
	Buffer:Write("Adapt.Transform.Atmost(".. self.Amount ..", ")
	Pretty.Any(self.Children.Pattern, Buffer, Flags, Cache, Mentioned)
	Buffer:Write")"
end

return Atmost
