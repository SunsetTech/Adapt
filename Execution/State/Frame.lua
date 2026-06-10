---@diagnostic disable:trailing-space
local TranslationInfo = require"Adapt.Execution.State.TranslationInfo"
local Userdata = require"Adapt.Execution.State.Userdata"
local Array = require"Moonrise.Tools.Array"
local Null = require"Moonrise.Object.Null"
local Optimizable = require"Moonrise.Classes.Optimizable"
local Poolable = require"Moonrise.Classes.Poolable"

local OOP = require"Moonrise.OOP"

---@alias Adapt.Execution.State.Lookahead "Positive" | "Negative"

---@class Adapt.Execution.State.Frame: Moonrise.Classes.Optimizable
---@field public Data Adapt.Execution.State.Userdata
---@field public Translation Adapt.Execution.State.TranslationInfo
---@field public Constraints Adapt.Execution.State.Constraint[]
---@field public Lookahead Adapt.Execution.State.Lookahead | Moonrise.Object.Null
---@field public Errors Adapt.Execution.State.Frame[]
---@overload fun(Data: Adapt.Execution.State.Userdata?, Translation: Adapt.Execution.State.TranslationInfo?, Constraint: Adapt.Execution.State.Constraint[]?, Lookahead: Adapt.Execution.State.Lookahead?): Adapt.Execution.State.Frame
local Frame = OOP.Declarator.Shortcuts(
	"Adapt.Execution.State.Frame", {
		Optimizable, Poolable
	}
)

---@param Instance Adapt.Execution.State.Frame
---@param Data Adapt.Execution.State.Userdata?
---@param Translation Adapt.Execution.State.TranslationInfo?
---@param Constraints Adapt.Execution.State.Constraint[]?
---@param Lookahead Adapt.Execution.State.Lookahead?
function Frame:Initialize(Instance, Data, Translation, Constraints, Lookahead)
	Instance.Data = Data or Userdata()
	Instance.Translation = Translation or TranslationInfo()
	Instance.Constraints = Constraints or {}
	Instance.Lookahead = Lookahead or Null
	Instance.Errors = {}
end

function Frame:Reinitialize(Data, Translation, Constraints, Lookahead)
	self.Data = Data or self.Data
	self.Data:Clean()
	self.Translation = Translation or self.Translation
	self.Translation:Clean()
	self.Constraints = Constraints or self.Constraints
	Array.Clean(self.Constraints)
	self.Lookahead = Lookahead or self.Lookahead
end

function Frame:Optimize()
		Optimizable.Optimize(self)
	self.Data:Optimize()
	self.Translation:Optimize()
end

---@param At integer
---@param Pattern Adapt.Transform.Base
---@param Argument any
---@param Lookahead Adapt.Execution.State.Lookahead?
---@param Into Adapt.Execution.State.Frame?
---@return Adapt.Execution.State.Frame
function Frame:Fork(At, Pattern, Argument, Lookahead, Into)
	assert(Into)
	if Lookahead == nil then
		Lookahead = self.Lookahead
	end
	if Into then
		self.Data:Fork(Into.Data)
		self.Translation:Fork(At, Pattern, Argument, Into.Translation)
		Array.ShallowCopy(self.Constraints, Into.Constraints)
		Into.Lookahead = Lookahead or self.Lookahead
	else
		Into = Frame(
			self.Data:Fork(), 
			self.Translation:Fork(At, Pattern, Argument), 
			Array.ShallowCopy(self.Constraints),
			Lookahead or self.Lookahead
		)
	end
	return Into
end

return Frame
