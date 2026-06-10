---@diagnostic disable:trailing-space
local Pretty = require"Moonrise.Tools.Pretty"
local Execution = require"Adapt.Execution"

local Wrapper = require"Adapt.Transform.Select.Wrapper"

local OOP = require"Moonrise.OOP"

---@class Adapt.Transform.Select : Adapt.Transform.Compound
---@overload fun(Children: table<any, Adapt.Transform.Base>): Adapt.Transform.Select
local Select = OOP.Declarator.Shortcuts(
	"Adapt.Transform.Select", {
		require"Adapt.Transform.Compound"
	}
)

---@param CurrentState Adapt.Execution.State
---@param MethodName Adapt.MethodName
---@param Index integer
---@param Child table
---@param Argument any
---@return boolean
---@return Adapt.Transform.Select.Wrapper?
local function TryChild(CurrentState, MethodName, Index, Child, Argument)
	local Success, Result = Execution.Recurse(
		CurrentState,
		MethodName, Child,
		Argument
	)
	
	if not Success then
		return false
	else
		Result = Wrapper(Index, Result)
		return Success, Result
	end
end

---@param CurrentState Adapt.Execution.State
---@param ArgumentMap Adapt.Transform.Select.Wrapper?
---@return boolean
---@return Adapt.Transform.Select.Wrapper?
function Select:Raise(CurrentState, ArgumentMap)
	ArgumentMap = ArgumentMap or {}
	for Index = 1, #self.Children do
		local Child = self.Children[Index]
		local Argument = ArgumentMap[Index]
		local Success, Result = TryChild(CurrentState, "Raise", Index, Child, Argument)
		if Success then
			return Success, Result
		end
	end
	return false -- TODO: return partial results?
end

---@param CurrentState Adapt.Execution.State
---@param Argument Adapt.Transform.Select.Wrapper?
---@return boolean
---@return Adapt.Transform.Select.Wrapper?
function Select:Lower(CurrentState, Argument)
	if (OOP.Reflection.Type.Of(Wrapper, Argument)) then --the user or a previous parse indicated which branch to take
		---@cast Argument Adapt.Transform.Select.Wrapper
		local Index = Argument.Which
		Argument = Argument.Value
		local Child = self.Children[Index]
		local Success, Result = TryChild(CurrentState, "Lower", Index, Child, Argument)
		return Success, Result
	end
	return false
end

---@return string
function Select:__tostring()
	local Parts = {}
	for _, Child in pairs(self.Children) do
		table.insert(Parts, tostring(Child))
	end
	return "(".. table.concat(Parts, " + ") ..")"
end

function Select:__pretty(Buffer, Flags, Cache, Mentioned)
	Buffer:Write"Adapt.Transform.Select("
	Pretty.Any(self.Children, Buffer, Flags, Cache, Mentioned)
	Buffer:Write")"
end

return Select

