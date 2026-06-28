---@diagnostic disable:trailing-space
local Pretty = require"Moonrise.Tools.Pretty"
local OOP = require"Moonrise.OOP"
local Execution = require"Adapt.Execution"
local Compound = require"Adapt.Transform.Compound"

---@class Adapt.Transform.Sequence : Adapt.Transform.Compound
local Sequence = OOP.Declarator.Shortcuts(
	"Adapt.Transform.Sequence", {
		Compound
	}
)

---@param ExecutionState Adapt.Execution.State
---@param MethodName Adapt.MethodName
---@param Arguments any[]
---@return boolean
---@return any[]?
function Sequence:ExecuteChildren(ExecutionState, MethodName, Arguments)
	Arguments = Arguments or {}
	
	local Results = {}
	for Index = 1, #self.Children do
		local Child = self.Children[Index]
		local Argument = Arguments[Index]
		local Success, Result = Execution.Recurse(
			ExecutionState, 
			MethodName, Child, 
			Argument
		)
		
		if Success then
			Results[Index] = Result
		else
			return false
		end
	end
	
	return true, Results
end

---@param ExecutionState Adapt.Execution.State
---@param Arguments any[]
---@return boolean
---@return any[]?
function Sequence:Raise(ExecutionState, Arguments)
	return self:ExecuteChildren(ExecutionState, "Raise", Arguments)
end

---@param ExecutionState Adapt.Execution.State
---@param Arguments any[]
---@return boolean
---@return any[]?
function Sequence:Lower(ExecutionState, Arguments)
	return self:ExecuteChildren(ExecutionState, "Lower", Arguments)
end

function Sequence:Optimize()
	Compound.Optimize(self)
	self.ExecuteChildren = Sequence.ExecuteChildren
end

---@return string
function Sequence:__tostring()
	local Parts = {}
	for _, Child in pairs(self.Children) do
		table.insert(Parts, tostring(Child))
	end
	return "(".. table.concat(Parts, " * ") ..")"
end

---@param Buffer Moonrise.Stream.Formatter.Indented
---@param Flags any
---@param Cache any
---@param Mentioned any
function Sequence:__pretty(Buffer, Flags, Cache, Mentioned)
	Buffer:Write"Adapt.Transform.Sequence"
	Pretty.Any(
		self.Children, Buffer, {
			Multiline = Flags.Multiline;
			SkipRootBookends = false;
			SkipNumericKeys = true;
			SkipCache = Flags.SkipCache;
			ObjectMode = Flags.ObjectMode;
			Colorized = Flags.Colorized;
			Override = {};
		}, Cache, Mentioned
	)
end

return Sequence
