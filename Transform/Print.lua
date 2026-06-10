---@diagnostic disable: trailing-space
local Base = require"Adapt.Transform.Base"

local OOP = require"Moonrise.OOP"

---@class Adapt.Transform.Print: Adapt.Transform.Base
---@field public Message string
---@overload fun(Message: string): Adapt.Transform.Print
local Print = OOP.Declarator.Shortcuts(
	"Adapt.Transform.Print", {
		Base
	}
)

---@param Instance Adapt.Transform.Print
---@param Message string
function Print:Initialize(Instance, Message)
	Instance.Message = Message
end

---@return true
function Print:Raise() --Root
	print(self.Message)
	return true
end

---@return true
function Print:Lower()
	print(self.Message)
	return true
end

return Print

