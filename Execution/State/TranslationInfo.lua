---@diagnostic disable:trailing-space
local Array = require"Moonrise.Tools.Array"
local Optimizable = require"Moonrise.Classes.Optimizable"
local Cleanable = require"Moonrise.Classes.Cleanable"

local OOP = require"Moonrise.OOP"

---@class Adapt.Execution.State.TranslationInfo: Moonrise.Classes.Optimizable, Moonrise.Classes.Cleanable
---@field public At integer
---@field public End integer?
---@field public Hint integer
---@field public Newlines integer[]
---@field public HitEnd boolean
---@field public Pattern Adapt.Transform.Base?
---@field public Argument any
---@field public Chunk string
---@field public Errors Adapt.Execution.State.TranslationInfo[]
---@field public FurthestAt integer
---@overload fun(At: integer?, Hint: integer?, Newlines: integer[]?, HitEnd: boolean?, Pattern: Adapt.Transform.Base?, Argument: any, Chunk: string?, Errors: Adapt.Execution.State.TranslationInfo[]?): Adapt.Execution.State.TranslationInfo
local TranslationInfo = OOP.Declarator.Shortcuts(
	"Adapt.Execution.State.TranslationInfo", {
		Optimizable, Cleanable
	}
)

---@param Instance Adapt.Execution.State.TranslationInfo
---@param At integer?
---@param Hint integer?
---@param Newlines integer[]?
---@param HitEnd boolean?
---@param Pattern Adapt.Transform.Base?
---@param Argument any
---@param Chunk string?
---@param Errors Adapt.Execution.State.TranslationInfo[]?
function TranslationInfo:Initialize(Instance, At, Hint, Newlines, HitEnd, Pattern, Argument, Chunk, Errors)
	Instance.At = At or 0
	Instance.Hint = Hint or 0
	Instance.Newlines = Newlines or {}
	Instance.HitEnd = HitEnd or false 
	Instance.Pattern = Pattern
	Instance.Argument = Argument
	Instance.Chunk = Chunk or ""
	Instance.Errors = Errors or {}
	Instance.FurthestAt = Instance.At
end

function TranslationInfo:Clean()
	Array.Clean(self.Newlines)
	Array.Clean(self.Errors)
end

---@param At integer
---@param Pattern Adapt.Transform.Base
---@param Argument any
---@param Into Adapt.Execution.State.TranslationInfo?
---@return Adapt.Execution.State.TranslationInfo
function TranslationInfo:Fork(At, Pattern, Argument, Into)
	if Into then
		Into.At = At
		Into.Hint = self.Hint
		Array.ShallowCopy(self.Newlines, Into.Newlines)
		Into.HitEnd = self.HitEnd
		Into.Pattern = Pattern
		Into.Argument = Argument
		Into.Chunk = self.Chunk
		Array.ShallowCopy(self.Errors, Into.Errors)
		Into.FurthestAt = At
	else
		Into = TranslationInfo(
			At,
			self.Hint,
			Array.ShallowCopy(self.Newlines),
			self.HitEnd,
			Pattern,
			Argument,
			self.Chunk,
			Array.ShallowCopy(self.Errors)
		)
	end
	return Into
end

return TranslationInfo
