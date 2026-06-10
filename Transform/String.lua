---@diagnostic disable: trailing-space
local OOP = require"Moonrise.OOP"

---@class Adapt.Transform.String : Adapt.Transform.Base
---@field Content string
---@field CaseInsensitive boolean
---@overload fun(Content: string, CaseInsensitive: boolean?): Adapt.Transform.String
local String = OOP.Declarator.Shortcuts(
	"Adapt.Transform.String", {
		require"Adapt.Transform.Base"
	}
)

---@param Content string
---@param CaseInsensitive boolean?
function String:Initialize(Instance, Content, CaseInsensitive)
	if CaseInsensitive == nil then
		CaseInsensitive = false
	end
	Instance.Content = Content or ""
	Instance.CaseInsensitive = CaseInsensitive
	assert(type(Instance.Content) == "string", "Content must be a string")
end

---@param CurrentState Adapt.Execution.State
---@param Input any
---@return boolean
function String:Lower(CurrentState, Input)
	if (self.CaseInsensitive and (Input:lower() == self.Content:lower())) or (Input == self.Content) then
		return CurrentState:Write(Input)
	end
	return false
end

---@param CurrentState Adapt.Execution.State
---@return boolean
---@return string
function String:Raise(CurrentState)
	local Input = CurrentState:Read(#self.Content)
	return (self.CaseInsensitive and (Input:lower() == self.Content:lower())) or (Input == self.Content), Input
end

---@return string
function String:__tostring()
	return "String'".. self.Content .."'"
end

return String
