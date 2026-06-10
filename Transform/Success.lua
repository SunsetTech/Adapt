---@diagnostic disable:trailing-space
local Null = require"Moonrise.Object.Null"
local OOP = require"Moonrise.OOP"

---@class Adapt.Transform.Success : Adapt.Transform.Base
---@field Value boolean
---@overload fun(Value: boolean): Adapt.Transform.Success
local Success = OOP.Declarator.Shortcuts(
	"Adapt.Transform.Success", {
		require"Adapt.Transform.Base"
	}
)

---@param Instance Adapt.Transform.Success
---@param Value boolean
function Success:Initialize(Instance, Value)
	Instance.Value = Value 
end

---@return boolean
function Success:Lower()
	return self.Value
end

---@return boolean
function Success:Raise()
	return self.Value, Null
end

---@return string
function Success:__tostring()
	return "Success(".. tostring(self.Value) ..")"
end

return Success
