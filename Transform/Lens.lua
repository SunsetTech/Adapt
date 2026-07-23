---@diagnostic disable:trailing-space
---@alias Adapt.Transform.Lens.Recurse fun(Argument: any): boolean, any
---@alias Adapt.Transform.Lens.Method fun(Recurse: Adapt.Transform.Lens.Recurse, Node: Adapt.Transform.Base, Argument: any, CurrentState: Adapt.Execution.State): boolean, any

---@class Adapt.Transform.Lens.Definition
---@field Raise Adapt.Transform.Lens.Method
---@field Lower Adapt.Transform.Lens.Method
---@field __DebugName string?

local Pretty = require"Moonrise.Tools.Pretty"
local Null = require"Moonrise.Object.Null"
local OOP = require"Moonrise.OOP"

local Execution = require"Adapt.Execution"

local Recursor = OOP.Declarator.Shortcuts"Adapt.Transform.Lens.Recursor"

function Recursor:Initialize(Instance, CurrentState, MethodName, Pattern, Argument)
	Instance.CurrentState = CurrentState
	Instance.MethodName = MethodName
	Instance.Pattern = Pattern
	Instance.Argument = Argument or Null
end

function Recursor:__call(Argument)
	local Default = self.Argument
	if Default == Null then
		Default = nil
	end
	local Success, Result, Bookmark, ResultFrame = Execution.Recurse(
		self.CurrentState,
		self.MethodName,
		self.Pattern,
		Argument or Default
	)
	return Success, Result, Bookmark, ResultFrame
end

---@class Adapt.Transform.Lens : Adapt.Transform.Compound
---@field Definition Adapt.Transform.Lens.Definition
---@field Children {__LensSubpattern: Adapt.Transform.Base}
---@overload fun(Pattern: Adapt.Transform.Base, Definition: Adapt.Transform.Lens.Definition): Adapt.Transform.Lens
Lens = OOP.Declarator.Shortcuts(
	"Adapt.Transform.Lens", {
		require"Adapt.Transform.Compound"
	}
)

---@param Instance Adapt.Transform.Lens
---@param Pattern Adapt.Transform.Base
---@param Definition Adapt.Transform.Lens.Definition
function Lens:Initialize(Instance, Pattern, Definition)
	assert(Definition)
---@diagnostic disable-next-line:undefined-field
		Lens.Parents.Compound:Initialize(Instance, {__LensSubpattern = Pattern})
	Instance.Definition = Definition
end

---@param CurrentState Adapt.Execution.State
---@param Argument any
---@return boolean
---@return any
function Lens:Raise(CurrentState, Argument) --Root
	local Success, Result = self.Definition.Raise(
		Recursor(CurrentState, "Raise", self.Children.__LensSubpattern, Argument), 
		self.Children.__LensSubpattern, Argument, CurrentState
	)
	
	return Success, Result
end

---@param CurrentState Adapt.Execution.State
---@param Argument any
---@return boolean
---@return any
function Lens:Lower(CurrentState, Argument)
	local Success, Result = self.Definition.Lower(
		Recursor(CurrentState, "Lower", self.Children.__LensSubpattern, Argument), 
		self.Children.__LensSubpattern, Argument, CurrentState
	)
	
	return Success, Result
end

---@return string
function Lens:__tostring()
	return "(".. tostring(self.Children.__LensSubpattern) .."/{".. (self.Definition.__DebugName or tostring(self.Definition)) .."})"
end

---@param Buffer Moonrise.Stream.Formatter.Fancy
---@param Flags Tools.Pretty.Any.Flags
---@param Cache Tools.Pretty.Any.Cache
---@param Mentioned Tools.Pretty.Any.Mentioned
function Lens:__pretty(Buffer, Flags, Cache, Mentioned)
	Buffer:Write"Adapt.Transform.Lens("
	if Flags.Multiline then
		Buffer:NewLine()
		Buffer.Level = Buffer.Level + 1
	end
	Pretty.Any(self.Children.__LensSubpattern, Buffer, Flags, Cache, Mentioned)
	Buffer:Write", "
	if Flags.Multiline then
		Buffer:NewLine()
	end
	Buffer:Write(self.Definition.__DebugName or tostring(self.Definition))
	if Flags.Multiline then
		Buffer:NewLine()
		Buffer.Level = Buffer.Level - 1
	end
	Buffer:Write")"
end

return Lens

