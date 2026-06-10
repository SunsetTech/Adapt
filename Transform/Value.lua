---@diagnostic disable:trailing-space
local Null = require"Moonrise.Object.Null"
local OOP = require"Moonrise.OOP"

---@class Adapt.Transform.Value : Adapt.Transform.Base
---@field Contained any
---@overload fun(Contained: any): Adapt.Transform.Value
local Value = OOP.Declarator.Shortcuts(
	"Adapt.Transform.Value", {
		require"Adapt.Transform.Base"
	}
)

---@param Instance Adapt.Transform.Value
---@param Contained any
function Value:Initialize(Instance, Contained)
	Instance.Contained = Contained
end

---@return boolean
function Value:Lower(_, Argument)
	return Argument == self.Contained
end

---@return true
---@return any
function Value:Raise(_)
	return true, self.Contained
end

---@return string
function Value:__tostring()
	return "Value(".. tostring(self.Contained) ..")"
end

return Value
