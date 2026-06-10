---@diagnostic disable:trailing-space
unpack = unpack or table.unpack
local Pretty = require"Moonrise.Tools.Pretty"

local OOP = require"Moonrise.OOP"

local Bubble = {}

---@class Adapt.Execution.Bubble
Bubble.Class = OOP.Derive(
	"Bubble", {}, {
		__instantiate = function(self, ...)
			local Instance = {...}
			return OOP.Create(self, Instance)
		end;
		__call = function(self)
			return table.unpack(self)
		end;
		---@param self Adapt.Execution.Bubble
		---@param Buffer Moonrise.Stream.Base
		---@param Flags Tools.Pretty.Any.Flags
		---@param Cache table<userdata|table,boolean>
		---@param Mentioned table<string,userdata|table>
		__pretty = function(self, Buffer, Flags, Cache, Mentioned)
			local InertClone = {}
			for Index, Value in ipairs(self) do
				InertClone[Index] = Value
			end
			Buffer:Write"Adapt.Execution.Bubble.Form("
			Pretty.Any(
				InertClone, Buffer, {
					ObjectMode = Flags.ObjectMode;
					Colorized = Flags.Colorized;
					SkipRootBookends = true;
					SkipNumericKeys = true;
					SkipCache = Flags.SkipCache;
					Multiline = Flags.Multiline;
				}, 
				Cache, Mentioned
			)
			Buffer:Write")"
			--[[if Flags.Multiline then
				Buffer:AddLine")"
			else
				Buffer:Write")"
			end]]
		end;
	}
)

Bubble.Form = OOP.Class.Factory(Bubble.Class)

function Bubble.Pop(What)
	if Bubble.Is(What) then
		return What()
	else
		return What
	end
end

function Bubble.Is(What)
	return getmetatable(What) == Bubble.Class
end

return Bubble
