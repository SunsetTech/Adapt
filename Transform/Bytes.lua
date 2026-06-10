
local OOP = require"Moonrise.OOP"

---@class Adapt.Transform.Bytes : Adapt.Transform.Base
---@field Count integer
---@overload fun(Count: integer): Adapt.Transform.Bytes
local Bytes = OOP.Declarator.Shortcuts(
	"Adapt.Transform.Bytes", {
		require"Adapt.Transform.Base"
	}
)

---@param Count integer
function Bytes:Initialize(Instance, Count)
	Instance.Count = Count or 1
end

---@param CurrentState Adapt.Execution.State
---@param Input any
---@return boolean
function Bytes:Lower(CurrentState, Input)
	if Input and #Input == self.Count then
		return CurrentState:Write(Input)
	end
	return false
end

---@param CurrentState Adapt.Execution.State
---@return boolean
---@return string
function Bytes:Raise(CurrentState)
	local Input = CurrentState:Read(self.Count)
	return Input and #Input == self.Count or false, Input
end

---@return string
function Bytes:__tostring()
	return "Bytes(".. self.Count ..")"
end

return Bytes
