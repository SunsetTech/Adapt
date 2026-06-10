---@diagnostic disable:trailing-space
local OOP = require"Moonrise.OOP"

---@class Adapt.Transform.Base
---@overload fun(): Adapt.Transform.Base 
local Base = OOP.Declarator.Shortcuts(
	"Adapt.Transform.Base", nil, nil, {
		__pretty = function()
			return function(self, Buffer)
				Buffer:Write(tostring(self))
			end
		end
	}
)

function Base:Initialize()
	self.Sides = {}
	self:Optimize()
end

---@param CurrentState Adapt.Execution.State
---@param Argument any
---@return boolean Success
---@return any Result
---@return Adapt.Transform.Base? NextNode
---@return any NextArgument
---@diagnostic disable-next-line:unused-local 
function Base:Lower(CurrentState, Argument) ---@diagnostic disable-line:unused-vararg
	error":Lower not implemented"
end

---@param CurrentState Adapt.Execution.State
---@param Argument any
---@return boolean Success
---@return any Result
---@return Adapt.Transform.Base? NextNode
---@return any NextArgument
---@diagnostic disable-next-line:unused-local
function Base:Raise(CurrentState, Argument) ---@diagnostic disable-line:unused-vararg
	error":Raise not implemented"
end

function Base:Optimize()
	self.Raise = self.Raise
	self.Lower = self.Lower
end

---@param RHS Adapt.Transform.Base
---@return Adapt.Transform.Select
function Base:__add(RHS)
	local Select = require"Adapt.Transform.Select"
	local Union = {}
	
	if OOP.Reflection.Type.Of(Select, self) then
		---@cast self Adapt.Transform.Select
		for _, SubPattern in pairs(self.Children) do
			table.insert(Union, SubPattern)
		end
	else
		table.insert(Union, self)
	end
	
	if OOP.Reflection.Type.Of(Select, RHS) then
		---@cast RHS Adapt.Transform.Select
		for _, SubPattern in pairs(RHS.Children) do
			table.insert(Union, SubPattern)
		end
	else
		table.insert(Union, RHS)
	end
	
	return Select(Union)
end

---@param RHS Adapt.Transform.Base
---@return Adapt.Transform.Sequence
function Base:__mul(RHS)
	local Sequence = require"Adapt.Transform.Sequence"
	local Union = {}
	
	if OOP.Reflection.Type.Name(self) == "Adapt.Transform.Sequence" then
		---@cast self Adapt.Transform.Sequence
		for _, SubPattern in pairs(self.Children) do
			table.insert(Union, SubPattern)
		end
	else
		table.insert(Union, self)
	end
	
	if OOP.Reflection.Type.Name(RHS) == "Adapt.Transform.Sequence" then
		---@cast RHS Adapt.Transform.Sequence
		for _, SubPattern in pairs(RHS.Children) do
			table.insert(Union, SubPattern)
		end
	else
		table.insert(Union, RHS)
	end
	
	return Sequence(Union)
end

---@param RHS Adapt.Transform.Base
---@return Adapt.Transform.Without
function Base:__sub(RHS)
	local Dematch = require"Adapt.Transform.Without"
	return Dematch(self, RHS)
end

---@param RHS Adapt.Transform.Lens.Definition
---@return Adapt.Transform.Lens
function Base:__div(RHS)
	local Lens = require"Adapt.Transform.Lens"
	return Lens(self, RHS)
end

---@param RHS integer
---@return Adapt.Transform.Atleast | Adapt.Transform.All | Adapt.Transform.Atmost
function Base:__pow(RHS)
	if RHS > 0 then 
		local Atleast = require"Adapt.Transform.Atleast"
		return Atleast(RHS, self)
	elseif RHS == 0 then
		local All = require"Adapt.Transform.All"
		return All(self)
	elseif RHS < 0 then
		local Atmost = require"Adapt.Transform.Atmost"
		return Atmost(RHS, self)
	---@diagnostic disable-next-line:missing-return
	end
end

--[[function Base:__unm()
	local Not = require"Adapt.Transform.Not"
	return Not(self)
end

function Base:__len()
	error"???"
	local Ghost = require"Adapt.Transform.Ghost"
	return Ghost(self)
end

function Base:__call()
	local Expect = require"Adapt.Transform.Expect"
	return Expect(self)
end]]

return Base
