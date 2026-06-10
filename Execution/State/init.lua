---@diagnostic disable: trailing-space
local Tools = {
	Table = require"Moonrise.Tools.Table";
	String = require"Moonrise.Tools.String";
	Pretty = require"Moonrise.Tools.Pretty";
}
local Array = require"Moonrise.Tools.Array"
local Jump = require"Adapt.Transform.Jump"
local Recurse = require"Adapt.Execution.Recurse"
local Frame = require"Adapt.Execution.State.Frame"
local Map = require"Adapt.Execution.State.Map"
local Constraint = require"Adapt.Execution.State.Constraint"
local Pool = require"Moonrise.Pool"
local zone = require"jit.zone"

--[[local FramePool = Pool.Optimizable(Frame)
FramePool:Optimize()]]
local ArrayPool = Pool.Array()
ArrayPool:Optimize()

local OOP = require"Moonrise.OOP"

---@alias Adapt.Execution.Location string

---@param Pattern Adapt.Transform.Base
---@param SubPath table<integer, string>
local function ForwardSearch(Pattern, SubPath)
	for Index = 1,#SubPath do
		local Part = SubPath[Index]
		---@cast Pattern Adapt.Transform.Compound
		if Pattern.Children and Pattern.Children[Part] then
			Pattern = Pattern.Children[Part]
		else
			return
		end
	end
	return Pattern
end

---@param Stack Adapt.Transform.Base[]
---@param SubPath any
---@return Adapt.Transform.Base?
---@return string?
local function BackwardSearch(Stack, SubPath, At)
	for Index = #Stack, 1, -1 do
		local Haystack = Stack[Index]
		local Needle = ForwardSearch(Haystack, SubPath)
		if Needle then
			local FoundAtParts = {}
			for PartIndex = 1, Index do
				table.insert(FoundAtParts, At[Index])
			end
			if #SubPath == 1 then
				table.remove(FoundAtParts, #FoundAtParts)
			end
			local FoundAt = table.concat(FoundAtParts, ".") ..".".. table.concat(SubPath, ".")
			return Needle, FoundAt
		end
	end
end

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

---@class Adapt.Execution.State: Moonrise.Classes.Optimizable
---@field public Root Adapt.Transform.Base
---@field public Buffer Moonrise.Stream.Base
---@field public DebugBuffer Moonrise.Stream.Formatter.Indented?
---@field public DebugFlags Tools.Pretty.Any.Flags?
---@field public DebugCache table<userdata|table,boolean>?
---@field public DebugMentioned table<string,userdata|table>?
---@field public IgnoreDebug table<Adapt.Transform.Base, boolean>
---@field public NameMap table<Adapt.Transform.Base, string>
---@field public JumpMap table<Adapt.Transform.Base, Adapt.Transform.Base>
---@field public ActivePatterns table
---@field public Frames Adapt.Execution.State.Frame[]
---@field public Fragment boolean
---@field public Wrapper fun(CurrentState: Adapt.Execution.State, Pattern: Adapt.Transform.Base, Method: Adapt.Method, Argument: any): boolean, any
---@overload fun(Root: Adapt.Transform.Base, Buffer: Moonrise.Stream.Base, DebugBuffer: Moonrise.Stream.Formatter.Indented?, DebugFlags:Tools.Pretty.Any.Flags?, DebugCache: table<userdata|table,boolean>?, DebugMentioned: table<string, userdata|table>?, IgnoreDebug: table<Adapt.Transform.Base, boolean>?, NameMap: table<Adapt.Transform.Base, string>?, JumpMap: table<Adapt.Transform.Base, Adapt.Transform.Base>?, Fragment: boolean?): Adapt.Execution.State 
local State = OOP.Declarator.Shortcuts(
	"Adapt.Execution.State", {
		Optimizable
	}
)

---@param Instance Adapt.Execution.State
---@param Root Adapt.Transform.Base
---@param Buffer Moonrise.Stream.Base
---@param DebugBuffer Moonrise.Stream.Formatter.Indented?
---@param DebugFlags Tools.Pretty.Any.Flags?
---@param DebugCache table<userdata|table,boolean>?
---@param DebugMentioned table<string,userdata|table>?
---@param IgnoreDebug table<Adapt.Transform.Base, boolean>?
---@param NameMap table<Adapt.Transform.Base, string>?
---@param JumpMap table<Adapt.Transform.Base, Adapt.Transform.Base>?
---@param Fragment boolean?
---@param Wrapper fun(CurrentState: Adapt.Execution.State, Pattern: Adapt.Transform.Base, Method: Adapt.Method, Argument: any): boolean, any
function State:Initialize(Instance, Root, Buffer, DebugBuffer, DebugFlags, DebugCache, DebugMentioned, IgnoreDebug, NameMap, JumpMap, Fragment, Wrapper)
	if Fragment == nil then
		Fragment = false
	end
	Instance.Root = Root
	Instance.Buffer = Buffer
	Instance.DebugBuffer = DebugBuffer
	Instance.DebugFlags = DebugFlags
	Instance.DebugCache = DebugCache
	Instance.DebugMentioned = DebugMentioned
	Instance.IgnoreDebug = IgnoreDebug or {}
	Instance.NameMap = NameMap or {}
	Instance.JumpMap = JumpMap or {}
	Instance.Fragment = Fragment
	Instance.ActivePatterns = {}
	Instance.Frames = {}
	Instance.Wrapper = Wrapper
end

function State:Optimize()
		Optimizable.Optimize(self)
	self.Buffer:Optimize()
end

---@param Pattern Adapt.Transform.Base
---@param At string[]
---@param Stack Adapt.Transform.Base[]
---@param Seen table<Adapt.Transform.Jump, true>
function State:Link(Pattern, At, Stack, Seen)
	Seen = Seen or {}
	Stack = Stack or {Pattern}
	At = At or {"Root"}
	local Path = table.concat(At,".")
	if self.NameMap[Pattern] == Path then
		return --Already linked beyond here
	end
	self.NameMap[Pattern] = Path
	---@diagnostic disable-next-line:undefined-field
	if Pattern.Children ~= nil then
		---@cast Pattern Adapt.Transform.Compound
		for Name, Child in pairs(Pattern.Children) do
			--print(Path ..".".. Name, Child)
			if Seen[Child] then
				error("Encountered jump ".. tostring(Child) .." twice, duplicate jumps would break parsing")
			elseif OOP.Reflection.Type.Of(Jump, Child) then
				Seen[Child] = true
			end
			Tools.Table.PushLast(At, Name)
			Tools.Table.PushLast(Stack, Child)
				if self.DebugBuffer then
					self.DebugBuffer:AdjustIndentation(1)
				end
				self:Link(Child, At, Stack, Seen)
				if self.DebugBuffer then
					self.DebugBuffer:AdjustIndentation(-1)
				end
				if OOP.Reflection.Type.Name(Child) == "Adapt.Transform.Jump" then
					---@cast Child Adapt.Transform.Jump
					local SubPath = Tools.String.Explode(Child.SubPath,".")
					local Needle = BackwardSearch(Stack, SubPath, At)
					assert(Needle, "Didn't find jump target ".. Child.SubPath .." for ".. table.concat(At, "."))
					self.JumpMap[Child] = Needle
				end
			Tools.Table.PopLast(Stack)
			Tools.Table.PopLast(At)
		end
	end
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
	zone"State:OpenFrame"
	local RootFrame = self:GetFrame() or Frame()
	local New = Frame()
	RootFrame:Fork(self:Position(), Pattern, Argument, Lookahead, New)
	table.insert(self.Frames, New)
	zone()
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
	--[[if #Bookmark.Errors > 0 then
		table.insert(ResultFrame.Errors, Bookmark)
	end]]
	Array.Clean(ResultFrame.Constraints)
	Array.ShallowCopy(ResultFrame.Constraints, Bookmark.Constraints)
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
	--[[table.insert(
		CurrentFrame.Errors,
		Bookmark
	)]]
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
		local Constraint = Constraints[Index]
		local Bookmark = self:OpenFrame()

		self:Goto(Constraint.Position)
		local Success = Recurse(self, "Raise", Constraint.Pattern, Constraint.Argument)
		
		if Constraint.Mode == "Negative" then
			if Success then
				self:ErrorFrame(Bookmark)
				return false
			else
				if not Bookmark.Translation.HitEnd then
					table.remove(Constraints, Index)
				end
			end
		elseif Constraint.Mode == "Positive" then
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
	local Bookmark = self:OpenFrame()
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
