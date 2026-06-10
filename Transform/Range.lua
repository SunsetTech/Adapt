local OOP = require"Moonrise.OOP"

---@class Adapt.Transform.Range: Adapt.Transform.Base
---@field public Start integer
---@field public End integer
---@overload fun(Start: string|integer, End:string|integer): Adapt.Transform.Range
local Range = OOP.Declarator.Shortcuts(
	"Adapt.Transform.Range", {
		require"Adapt.Transform.Base"
	}
)

---@param Instance Adapt.Transform.Range
---@param Start string|integer
---@param End string|integer
function Range:Initialize(Instance, Start, End)
	---@diagnostic disable: assign-type-mismatch
	Instance.Start = type(Start) == "string" and string.byte(Start) or Start
	---@diagnostic disable: assign-type-mismatch
	Instance.End = type(End) == "string" and string.byte(End) or End
end

---@param CurrentState Adapt.Execution.State
---@return boolean
---@return string?
function Range:Raise(CurrentState)
	local Input = CurrentState:Read(1)
	if Input and Input ~= "" then
		local Byte = string.byte(Input)
		local Matches = Byte >= self.Start and Byte <= self.End
		return Matches, Input
	else
		return false
	end
end

---@param CurrentState Adapt.Execution.State
---@param Input string
---@return boolean
function Range:Lower(CurrentState, Input)
	if type(Input) == "string" and #Input == 1 then
		local Byte = string.byte(Input)
		local Matches = Byte >= self.Start and Byte <= self.End
		if Matches then
			return CurrentState:Write(Input)
		end
		return false
	end
	return false
end

return Range
