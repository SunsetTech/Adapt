---@diagnostic disable:trailing-space

local Execution = require"Adapt.Execution"

local OOP = require"Moonrise.OOP"

---@class Adapt.Transform.Packed: Adapt.Transform.Base
---@field public Format string
---@overload fun(Format: string): Adapt.Transform.Packed
local Packed = OOP.Declarator.Shortcuts(
	"Adapt.Transform.Packed", {
		require"Adapt.Transform.Base"
	}
)

---@param Instance Adapt.Transform.Packed
---@param Format string
function Packed:Initialize(Instance, Format)
	Instance.Format = Format
end

---@param Value any
---@param ... any
---@return any
---@return any
local function DropLast(Value, ...)
	if select("#", ...) > 1 then
		return Value, DropLast(...)
	else
		return Value
	end
end

---@param ExecutionState Adapt.Execution.State
---@return boolean
---@return any[]?
function Packed:Raise(ExecutionState)
	local PackSize = string.packsize(self.Format)
	
	local Input = ExecutionState:Read(PackSize)
	if #Input < PackSize then
		return false
	else
		return true, Execution.Bubble.Form(DropLast(string.unpack(self.Format, Input)))
	end
end

---@param ExecutionState Adapt.Execution.State
---@param Argument Adapt.Execution.Bubble
---@return boolean
function Packed:Lower(ExecutionState, Argument)
	return ExecutionState:Write(
		string.pack(self.Format, Execution.Bubble.Pop(Argument))
	)
end

return Packed
