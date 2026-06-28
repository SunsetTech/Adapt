---@diagnostic disable: trailing-space
local Tools = {
	Table = require"Moonrise.Tools.Table";
	String = require"Moonrise.Tools.String";
}
local Jump = require"Adapt.Transform.Jump"

local OOP = require"Moonrise.OOP"

---@param Node Adapt.Transform.Base
---@param SubPath table<integer, string>
local function ForwardSearch(Node, SubPath)
	for Index = 1,#SubPath do
		local Part = SubPath[Index]
		---@cast Node Adapt.Transform.Compound
		if Node.Children and Node.Children[Part] then
			Node = Node.Children[Part]
		else
			return
		end
	end
	return Node
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
			for _ = 1, Index do
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

---@class Adapt.Execution.State.Map.__Instance: Adapt.Execution.State.Map
---@overload fun()

---@class Adapt.Execution.State.Map
---@field Node table<string, Adapt.Transform.Base>
---@field Name table<Adapt.Transform.Base, string>
---@field Jump table<Adapt.Transform.Base, Adapt.Transform.Base>
---@overload fun(): Adapt.Execution.State.Map.__Instance
local Map = OOP.Declarator.Shortcuts"Adapt.Execution.State.Map"

---@param Instance Adapt.Execution.State.Map
function Map:Initialize(Instance)
	Instance.Node = {}
	Instance.Name = {}
	Instance.Jump = {}
end

---@param Node Adapt.Transform.Base
---@param At string[]?
---@param Stack Adapt.Transform.Base[]?
---@param Seen table<Adapt.Transform.Jump, boolean>?
function Map:Link(Node, At, Stack, Seen)
	Seen = Seen or {}
	Stack = Stack or {Node}
	At = At or {"Root"}
	local Path = table.concat(At,".")
	if self.Name[Node] == Path then
		return --Already linked beyond here
	end
	self.Name[Node] = Path
	self.Node[Path] = Node
	---@diagnostic disable-next-line:undefined-field
	if Node.Children ~= nil then
		---@cast Node Adapt.Transform.Compound
		for Name, Child in pairs(Node.Children) do
			if Seen[Child] then
				error("Encountered jump ".. tostring(Child) .." twice, duplicate jumps would break parsing")
			elseif OOP.Reflection.Type.Of(Jump, Child) then
				Seen[Child] = true
			end
			Tools.Table.PushLast(At, Name)
			Tools.Table.PushLast(Stack, Child)
				self:Link(Child, At, Stack, Seen)
				if OOP.Reflection.Type.Name(Child) == "Adapt.Transform.Jump" then
					---@cast Child Adapt.Transform.Jump
					local SubPath = Tools.String.Explode(Child.SubPath,".")
					local Needle = BackwardSearch(Stack, SubPath, At)
					assert(Needle, "Didn't find jump target ".. Child.SubPath .." for ".. table.concat(At, "."))
					self.Jump[Child] = Needle
				end
			Tools.Table.PopLast(Stack)
			Tools.Table.PopLast(At)
		end
	end
end

return Map
