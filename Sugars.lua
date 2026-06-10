---@diagnostic disable:trailing-space
local Transform = require"Adapt.Transform"

local Sugars; Sugars = {
	---@return Adapt.Transform.String
	Nothing = function()
		return Transform.String""
	end;
	
	---@param Pattern Adapt.Transform.Base
	---@return Adapt.Transform.Atmost
	Optional = function(Pattern)
		return Transform.Atmost(1, Pattern)
	end;
	
	---@param Pattern Adapt.Transform.Base
	---@return Adapt.Transform.Without
	Not = function(Pattern)
		return Transform.Without(Pattern, Sugars.Nothing())
	end;
	
	---@param Pattern Adapt.Transform.Base
	---@return Adapt.Transform.Without
	Ghost = function(Pattern)
		return Sugars.Not(Sugars.Not(Pattern))
	end;
}; return Sugars
