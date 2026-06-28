---@diagnostic disable:trailing-space
local Pretty = require"Moonrise.Tools.Pretty"
local OOP = require"Moonrise.OOP"

---@class Adapt.Transform.Select.Wrapper
---@field public Which integer
---@field public Value any
---@overload fun(Which: integer, Value: any): Adapt.Transform.Select.Wrapper
local Wrapper = OOP.Declarator.Shortcuts"Adapt.Transform.Select.Wrapper"

---@param Instance Adapt.Transform.Select.Wrapper
---@param Which integer
---@param Value any
function Wrapper:Initialize(Instance, Which, Value)
	Instance.Which = Which
	Instance.Value = Value
end

---@param Buffer Moonrise.Stream.Formatter.Indented
---@param Flags Tools.Pretty.Any.Flags
---@param Cache table
---@param Mentioned table
function Wrapper:__pretty(Buffer, Flags, Cache, Mentioned)
	local InertClone = {self.Which, self.Value}
	Buffer:Write"Adapt.Transform.Select.Wrapper("
	Pretty.Any(
		InertClone, Buffer, {
			Multiline = Flags.Multiline;
			Colorized = Flags.Colorized;
			ObjectMode = Flags.ObjectMode;
			SkipCache = Flags.SkipCache;
			SkipNumericKeys = true;
			SkipRootBookends = true;
			Override = {};
		}, Cache, Mentioned
	)
	Buffer:Write")"
end

return Wrapper
