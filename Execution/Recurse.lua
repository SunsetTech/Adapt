---@diagnostic disable:trailing-space
local Null = require"Moonrise.Object.Null"
local OOP = require"Moonrise.OOP"

local Jump

---@param CurrentState Adapt.Execution.State
---@param MethodName Adapt.Method
---@param Pattern Adapt.Transform.Base
---@param Argument any
---@param Lookahead Adapt.Execution.State.Lookahead?
---@return boolean Success
---@return any Result
---@return Adapt.Execution.State.Frame Bookmark
---@return Adapt.Execution.State.Frame ResultFrame
return function(CurrentState, MethodName, Pattern, Argument, Lookahead)
	if Jump == nil then
		Jump = require"Adapt.Transform.Jump"
	end
	local Success, Result
	---@type Adapt.Transform.Base?
	local CurrentPattern = Pattern
	---@type any
	local CurrentArgument = Argument
	---@cast CurrentPattern Adapt.Transform.Base
	
	while OOP.Reflection.Type.Of(Jump, CurrentPattern) do
		CurrentPattern = CurrentState.JumpMap[CurrentPattern]
	end
	
	local Bookmark = CurrentState:OpenFrame(CurrentPattern, CurrentArgument, Lookahead)
	if CurrentState.Wrapper then
		Success, Result = CurrentState:Wrapper(CurrentPattern, MethodName, CurrentArgument)
	elseif MethodName == "Raise" then
		Success, Result = CurrentPattern:Raise(CurrentState, CurrentArgument)
	elseif MethodName == "Lower" then
		Success, Result = CurrentPattern:Lower(CurrentState, CurrentArgument)
	else
		error"Invalid Method Name"
	end
	local ResultFrame
	if Lookahead == "Negative" then
		if Success then
			Success = false
			ResultFrame = CurrentState:ErrorFrame(Bookmark)
		else
			Success = true
			ResultFrame = CurrentState:CancelFrame(Bookmark)
		end
	elseif Lookahead == "Positive" then
		if Success then
			Result = Null
			ResultFrame = CurrentState:CancelFrame(Bookmark)
		else
			Result = Null
			ResultFrame = CurrentState:ErrorFrame(Bookmark)
		end
	else
		if Success then
			ResultFrame = CurrentState:CommitFrame(Bookmark)
		else
			ResultFrame = CurrentState:ErrorFrame(Bookmark)
		end
	end
	return Success, Result, Bookmark, ResultFrame
end
