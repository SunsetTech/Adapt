---@diagnostic disable:trailing-space
local OrderedMap = require"Moonrise.Structure.OrderedMap"
local Optimizable = require"Moonrise.Classes.Optimizable"
local Cleanable = require"Moonrise.Classes.Cleanable"
local OOP = require"Moonrise.OOP"

---@class Adapt.Execution.State.Userdata: Moonrise.Classes.Optimizable, Moonrise.Classes.Cleanable
---@field public Variables Moonrise.Structure.OrderedMap
---@overload fun(Variables: Moonrise.Structure.OrderedMap?): Adapt.Execution.State.Userdata
local Userdata = OOP.Declarator.Shortcuts(
	"Adapt.Execution.State.Userdata", {
		Optimizable, Cleanable
	}
)

---@param Instance Adapt.Execution.State.Userdata
---@param Variables Moonrise.Structure.OrderedMap?
function Userdata:Initialize(Instance, Variables)
	Instance.Variables = Variables or OrderedMap()
end

function Userdata:Clean()
	self.Variables:Clean()
end

function Userdata:Optimize()
		Optimizable.Optimize(self)
	self.Variables:Optimize()
end

---@param Into Adapt.Execution.State.Userdata?
---@return Adapt.Execution.State.Userdata
function Userdata:Fork(Into)
	if Into then
		self.Variables:ShallowCopy(Into.Variables)
	else
		Into = Userdata(self.Variables)
	end
	return Into
end

---@param Key Moonrise.Structure.UniqueKey
---@return boolean
function Userdata:Exists(Key)
	return self.Variables.Present[Key]
end

---@generic ValueType
---@param Key Moonrise.Structure.UniqueKey
---@param Value ValueType
function Userdata:Set(Key, Value)
	if not self:Exists(Key) then
		self.Variables:Add(Key, Value)
	else
		self.Variables:Set(Key, Value)
	end
end

---@param Key Moonrise.Structure.UniqueKey
---@return any
function Userdata:Get(Key)
	return self.Variables:Get(Key)
end

return Userdata
