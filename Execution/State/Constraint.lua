local OOP = require"Moonrise.OOP"

---@class Adapt.Execution.State.Constraint
---@field Position integer
---@field Pattern Adapt.Transform.Base
---@field Argument any
---@field Mode Adapt.Execution.State.Lookahead
---@overload fun(Position:integer, Pattern: Adapt.Transform.Base, Argument: any, Mode: Adapt.Execution.State.Lookahead): Adapt.Execution.State.Constraint
local Constraint = OOP.Declarator.Shortcuts"Adapt.Execution.State.Constraint"

---@param Instance Adapt.Execution.State.Constraint
---@param Position integer
---@param Pattern Adapt.Transform.Base
---@param Argument any
---@param Mode Adapt.Execution.State.Lookahead
function Constraint:Initialize(Instance, Position, Pattern, Argument, Mode)
	if Positive == nil then
		Positive = false
	end
	Instance.Position = Position
	assert(Instance.Position ~= nil)
	Instance.Pattern = Pattern
	Instance.Argument = Argument
	Instance.Mode = Mode
end

return Constraint
