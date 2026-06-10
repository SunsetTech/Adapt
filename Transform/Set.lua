local Tools = {
	String = require"Moonrise.Tools.String"
}
local OOP = require"Moonrise.OOP"

---@class Adapt.Transform.Set: Adapt.Transform.Base
---@field private _Chars string | string[]
---@field private Lengths integer[]
---@field private LengthCache table<integer, boolean>
---@field private Chars table<string, boolean>
---@overload fun(Chars: string | string[]): Adapt.Transform.Set
local Set = OOP.Declarator.Shortcuts(
	"Adapt.Transform.Set", {
		require"Adapt.Transform.Base"
	}
)

---@param Instance Adapt.Transform.Set
---@param Chars string | table<string, boolean>
function Set:Initialize(Instance, Chars)
	local Exploded
	if type(Chars) == "string" then
		Instance._Chars = Chars
		Exploded = Tools.String.Explode(Chars)
	elseif type(Chars) == "table" then
		Instance._Chars = table.concat(Chars)
		Exploded = Chars
	else
		error"Chars must be string or array of strings"
	end
	Instance.Lengths = {}
	Instance.LengthCache = {}
	Instance.Chars = {}
	for _, Char in pairs(Exploded) do
		local Length = #Char
		if Instance.LengthCache[Length] == nil then
			Instance.LengthCache[Length] = true
			table.insert(Instance.Lengths, Length)
		end
		Instance.Chars[Char] = true
	end
end

---@param ExecutionState Adapt.Execution.State
---@param Input string
---@return boolean
function Set:Lower(ExecutionState, Input)
	if (type(Input) == "string") then
		if self.Chars[Input] then
			return ExecutionState:Write(Input)
		end
		return false
	end
	return false
end

---@param ExecutionState Adapt.Execution.State
---@return boolean
---@return string?
function Set:Raise(ExecutionState)
	for _, Length in ipairs(self.Lengths) do
		local Bookmark = ExecutionState:OpenFrame(self)
		local Input = ExecutionState:Read(Length)
		local Matches = self.Chars[Input]
		if not Matches then 
			ExecutionState:ErrorFrame(Bookmark)
		else
			ExecutionState:CommitFrame(Bookmark)
			return true, Input
		end
	end
	return false
end

---@return string
function Set:__tostring()
	return 'Set"'.. self._Chars ..'"'
end

return Set
