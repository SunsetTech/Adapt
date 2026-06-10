---@diagnostic disable:unused-function
---@diagnostic disable:empty-block

local Recurse = require"Adapt.Execution.Recurse"
local Base = require"Adapt.Transform.Base"

local OOP = require"Moonrise.OOP"

---@class Adapt.Transform.Jump : Adapt.Transform.Base
---@field public SubPath string
---@overload fun(SubPath: string):Adapt.Transform.Jump
Jump = OOP.Declarator.Shortcuts(
	"Adapt.Transform.Jump", {
		Base
	}
)

---@param Instance Adapt.Transform.Jump
---@param SubPath string | string[]
function Jump:Initialize(Instance, SubPath)
	if type(SubPath) == "table" then
		SubPath = table.concat(SubPath, ".")
	end
	Instance.SubPath = SubPath
end

---@param MethodName string
---@param CurrentState Adapt.Execution.State
---@param Argument any
function Jump:Execute(MethodName, CurrentState, Argument) --Root
	local Success, Result = Recurse(CurrentState, MethodName, CurrentState.JumpMap[self], Argument)
	return Success, Result
end

---@param CurrentState Adapt.Execution.State
---@param Argument any
---@return boolean
---@return any
function Jump:Raise(CurrentState, Argument)
	return self:Execute("Raise", CurrentState, Argument)
end

---@param CurrentState Adapt.Execution.State
---@param Argument any
---@return boolean
---@return any
function Jump:Lower(CurrentState, Argument) --Root
	return self:Execute("Lower", CurrentState, Argument)
end

function Jump:Optimize()
	Base.Optimize(self)
	self.Execute = Jump.Execute
end

---@return string
function Jump:__tostring()
	return "Jump'".. self.SubPath .."'"
end

return Jump

