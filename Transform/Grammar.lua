local String = require"Moonrise.Tools.String"
local OOP = require"Moonrise.OOP"
local Pretty = require"Moonrise.Tools.Pretty"

local Execution = require"Adapt.Execution"
local Compound = require"Adapt.Transform.Compound"

---@class Adapt.Transform.Grammar : Adapt.Transform.Compound
---@overload fun(Children: table<any, Adapt.Transform.Base>): Adapt.Transform.Grammar
local Grammar = OOP.Declarator.Shortcuts(
	"Adapt.Transform.Grammar", {
		Compound
	}
)

---@param Instance Adapt.Transform.Grammar
---@param Children table<any, Adapt.Transform.Base>
function Grammar:Initialize(Instance, Children)
		Compound:Initialize(Instance, Children)
end

---@param CurrentState Adapt.Execution.State
---@param Argument any
---@return boolean
---@return any
function Grammar:Raise(CurrentState, Argument) --Root
	assert(self.Children[1], CurrentState.NameMap[self])
	return Execution.Recurse(CurrentState, "Raise", self.Children[1], Argument)
end

---@param CurrentState Adapt.Execution.State
---@param Argument any
---@return boolean
---@return any
function Grammar:Lower(CurrentState, Argument)
	assert(self.Children[1])
	return Execution.Recurse(CurrentState, "Lower", self.Children[1], Argument)
end

---@return string
function Grammar:__tostring()
	return Pretty.ToString(
		self, {
			Colorized = true;
			Multiline = true;
			ObjectMode = "Print";
			SkipCache = false;
			SkipNumericKeys = false;
			SkipRootBookends = false
		}, "  "
	)
end

function Grammar:__pretty(Buffer, Flags, Cache, Mentioned)
	Buffer:Write"Grammar"
	Pretty.Any(
		self.Children, Buffer, {
			SkipRootBookends = false;
			SkipNumericKeys = false;
			ObjectMode = Flags.ObjectMode;
			Multiline = Flags.Multiline;
			Colorized = Flags.Colorized;
			SkipCache = Flags.SkipCache;
		}, Cache, Mentioned
	)
end

return Grammar

