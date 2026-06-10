local OOP = require"Moonrise.OOP"

local Execution = require"Adapt.Execution"

---@class Adapt.Transform.Expect : Adapt.Transform.Compound
---@operator call:Adapt.Transform.Expect
Expect = OOP.Declarator.Shortcuts(
	"Adapt.Transform.Expect", {
		require"Adapt.Transform.Compound"
	}
)

function Expect:Initialize(Instance, Pattern)
---@diagnostic disable-next-line:undefined-field
		Expect.Parents.Compound:Initialize(Instance, {Pattern=Pattern})
end

---@param CurrentState Adapt.Execution.State
function Expect:FormatError(CurrentState, Where)
	return ("Failed at %s(%s) <%s..>"):format(CurrentState.NameMap[self.Children.Pattern], self.Children.Pattern, Where or "?")
end

---@param CurrentState Adapt.Execution.State
---@param Argument any
function Expect:Raise(CurrentState, Argument) --Root
	local Bookmark = CurrentState:Mark()
	local Success, Result = Execution.Recurse(CurrentState, "Raise", self.Children.Pattern, Argument)
	if not Success then
		CurrentState:Rewind(Bookmark)
		assert(Success, self:FormatError(CurrentState, CurrentState:Peek(32)))
	end
	return Success, Result
end

---@param CurrentState Adapt.Execution.State
---@param Argument any
function Expect:Lower(CurrentState, Argument)
	local Success, Result = Execution.Recurse(CurrentState, "Lower", self.Children.Pattern, Argument)
	assert(Success, self:FormatError(CurrentState))
	return Success, Result
end

function Expect:__tostring()
	return "!".. tostring(self.Children.Pattern) .."!"
end

return Expect

