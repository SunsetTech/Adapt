local OOP = require"Moonrise.OOP"
local Compound = require"Adapt.Transform.Compound"
local Execution = require"Adapt.Execution"
local Pretty = require"Moonrise.Tools.Pretty"

---@class Adapt.Transform.Dynamic: Adapt.Transform.Compound
---@field Children {__Generated: Adapt.Transform.Base}
---@field __Arguments any[]
local Dynamic = OOP.Declarator.Shortcuts(
	"Adapt.Transform.Dynamic", {
		Compound
	}
)

---@param Instance Adapt.Transform.Dynamic
function Dynamic:Initialize(Instance, ...)
	Compound:Initialize(Instance, {})
	Instance.__Arguments = {...}
	Instance:Update()
end

---@return Adapt.Transform.Base
function Dynamic:Generate()
	---@diagnostic disable-next-line:missing-return
end

function Dynamic:Update()
	self.Children.__Generated = self:Generate()
end

function Dynamic:Raise(CurrentState, Argument)
	local Success, Result = Execution.Recurse(CurrentState, "Raise", self.Children.__Generated, Argument)
	return Success, Result
end

function Dynamic:Lower(CurrentState, Argument)
	local Success, Result = Execution.Recurse(CurrentState, "Lower", self.Children.__Generated, Argument)
	return Success, Result
end

--[[function Dynamic:__tostring()
	return tostring(self.Children.__Generated)
end]]

function Dynamic:__pretty(Buffer, Flags, Cache, Mentioned)
	--Buffer:Write("@".. OOP.Reflection.Type.Name(self))
	--Pretty.Any(self.__Arguments, Buffer, Flags, Cache, Mentioned)
	--Buffer:Write"->"
	Pretty.Any(self.Children.__Generated, Buffer, Flags, Cache, Mentioned)
end

return Dynamic
