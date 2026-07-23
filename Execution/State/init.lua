---@diagnostic disable: trailing-space
local Array = require"Moonrise.Tools.Array"
local Recurse = require"Adapt.Execution.Recurse"
local Frame = require"Adapt.Execution.State.Frame"
local Map = require"Adapt.Execution.State.Map"
local Constraint = require"Adapt.Execution.State.Constraint"
local Pool = require"Moonrise.Pool"

local ArrayPool = Pool.Array()
ArrayPool:Optimize()

local OOP = require"Moonrise.OOP"

---@alias Adapt.Execution.Location string

---@param String string
---@return integer[]
local function FindNewlines(String)
	local Positions = {}
	local Start = 1
	while true do
		local Position = string.find(String, "\n", Start, true)
		if not Position then break end
		table.insert(Positions, Position)
		Start = Position + 1
	end
	return Positions
end

local Optimizable = require"Moonrise.Classes.Optimizable"

---@alias Adapt.Execution.State.Wrapper fun(CurrentState: Adapt.Execution.State, Pattern: Adapt.Transform.Base, Method: Adapt.Method, Argument: any): boolean, any

---@class Adapt.Execution.State: Moonrise.Classes.Optimizable
---@field public Root Adapt.Transform.Base
---@field public Buffer Moonrise.Stream.Base
---@field public Maps Adapt.Execution.State.Map
---@field public ActivePatterns table
---@field public Frames Adapt.Execution.State.Frame[]
---@field public Fragment boolean
---@field public Wrapper Adapt.Execution.State.Wrapper?
---@overload fun(Root: Adapt.Transform.Base, Buffer: Moonrise.Stream.Base, Maps: Adapt.Execution.State.Map?, Fragment: boolean?, Wrapper: Adapt.Execution.State.Wrapper?): Adapt.Execution.State 
local State = OOP.Declarator.Shortcuts(
	"Adapt.Execution.State", {
		Optimizable
	}
)

---@param Instance Adapt.Execution.State
---@param Root Adapt.Transform.Base
---@param Buffer Moonrise.Stream.Base
---@param Maps Adapt.Execution.State.Map?
---@param Fragment boolean?
---@param Wrapper Adapt.Execution.State.Wrapper?
function State:Initialize(Instance, Root, Buffer, Maps, Fragment, Wrapper)
	if Fragment == nil then
		Fragment = false
	end
	Instance.Root = Root
	Instance.Buffer = Buffer
	if not Maps then
		Maps = Map()
		Maps:Link(Root)
	end
	Instance.Maps = Maps
	Instance.Fragment = Fragment
	Instance.ActivePatterns = {}
	Instance.Frames = {}
	Instance.Wrapper = Wrapper
end

function State:Optimize()
		Optimizable.Optimize(self)
	self.Buffer:Optimize()
end

---@return integer
function State:Position()
	local Position = self.Buffer:At()
	return Position
end

---@param Translation integer
---@return nil
function State:Goto(Translation)
	local Success = self.Buffer:Goto(Translation)
	return Success
end

---@param Index integer?
---@return Adapt.Execution.State.Frame
function State:GetFrame(Index)
	local Found = self.Frames[Index or #self.Frames]
	return Found
end

---@param Pattern Adapt.Transform.Base
---@param Argument any
---@param Lookahead Adapt.Execution.State.Lookahead?
---@return Adapt.Execution.State.Frame
function State:OpenFrame(Pattern, Argument, Lookahead)
	local RootFrame = self:GetFrame() or Frame()
	local New = Frame()
	RootFrame:Fork(self:Position(), Pattern, Argument, Lookahead, New)
	table.insert(self.Frames, New)
	return New
end

---@return Adapt.Execution.State.Frame
function State:PopFrame()
	local Popped = table.remove(self.Frames)
	return Popped
end

---@param Bookmark Adapt.Execution.State.Frame
function State:CloseFrame(Bookmark)
	assert(Bookmark == self:PopFrame(), "Bookmark didn't equal current frame")
	Bookmark.Translation.Hint = self:Position()
	local ResultFrame = self:GetFrame() or Frame()
	if Bookmark.Translation.FurthestAt > ResultFrame.Translation.FurthestAt then
		ResultFrame.Translation.FurthestAt = Bookmark.Translation.FurthestAt
	end
	return ResultFrame
end

---@param Bookmark Adapt.Execution.State.Frame
---@return Adapt.Execution.State.Frame ResultFrame
function State:CommitFrame(Bookmark)
	local ResultFrame = self:CloseFrame(Bookmark)
	Array.Clean(ResultFrame.Constraints)
	Array.ShallowCopy(Bookmark.Constraints, ResultFrame.Constraints)
	Array.Clean(Bookmark.Constraints)
	for _, Key in ipairs(Bookmark.Data.Variables.Keys) do
		ResultFrame.Data:Set(Key, Bookmark.Data:Get(Key))
	end
	return ResultFrame
end

---@param Bookmark Adapt.Execution.State.Frame
function State:CancelFrame(Bookmark)
	self.Buffer:Goto(Bookmark.Translation.At)
	local ResultFrame = self:CloseFrame(Bookmark)
	return ResultFrame
end

---@param Bookmark Adapt.Execution.State.Frame
---@return Adapt.Execution.State.Frame ResultFrame
function State:ErrorFrame(Bookmark)
	local CurrentFrame = self:CancelFrame(Bookmark)
	return CurrentFrame
end

---@param Pattern Adapt.Transform.Base
---@param Argument any
---@param Mode Adapt.Execution.State.Lookahead
function State:AddConstraint(Pattern, Argument, Mode)
	table.insert(
		self:GetFrame().Constraints,
		Constraint(self:Position(), Pattern, Argument, Mode)
	)
end

---@return boolean Valid
function State:CheckConstraints()
	local CurrentPosition = self:Position()
	local Constraints = self:GetFrame().Constraints
	for Index = #Constraints, 1, -1 do
		local Current = Constraints[Index]
		local Bookmark = self:OpenFrame(Current.Pattern)
		self:Goto(Current.Position)
		local Success = Recurse(self, "Raise", Current.Pattern, Current.Argument)
		
		if Current.Mode == "Negative" then
			if Success then
				self:ErrorFrame(Bookmark)
				return false
			else
				if not Bookmark.Translation.HitEnd then
					table.remove(Constraints, Index)
				end
			end
		elseif Current.Mode == "Positive" then
			if (not Success) and (not Bookmark.Translation.HitEnd) then
				self:ErrorFrame(Bookmark)
				return false
			elseif Success then
				table.remove(Constraints, Index)
			end
		end
		self:CancelFrame(Bookmark)
		self:Goto(CurrentPosition)
	end
	return true
end

---@param String string
function State:Write(String)
	assert(type(String) == "string")
	self.Buffer:Write(String)
	self:GetFrame().Translation.Chunk = String
	self:GetFrame().Translation.Newlines = FindNewlines(String)
	local ConstraintsSuccess = self:CheckConstraints()
	return ConstraintsSuccess
end

---@param Count integer
---@return string
function State:Read(Count)
	local Result = self.Buffer:Read(Count)
	if #Result < Count then
		self:GetFrame().Translation.HitEnd = true
	end
	self:GetFrame().Translation.Chunk = Result
	if type(Result) == "string" and Result ~= "" then
		self:GetFrame().Translation.Newlines = FindNewlines(Result)
	end
	return Result
end

---@param Count any
---@return boolean|string|nil
function State:Peek(Count)
	local Bookmark = self:OpenFrame(self.Root)
		local Contents = self:Read(Count)
	self:CancelFrame(Bookmark)
	return Contents
end

function State:HintError(At)
	self:GetFrame().Translation.Hint = At
end

function State:GetData(Key)
	local Value = self:GetFrame().Data:Get(Key)
	return Value
end

function State:SetData(Key, Value)
	self:GetFrame().Data:Set(Key, Value)
end

return State
