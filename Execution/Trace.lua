local Pretty = require"Moonrise.Tools.Pretty"
local Terminal = require"Moonrise.Tools.Terminal"

local Trace; Trace = {
	GetMatched = function(State, StartByte)
		local StopByte = State.Buffer:At()
		if StopByte <= StartByte then
			return ""
		end
		local Length = StopByte-StartByte
		State.Buffer:Goto(StartByte)
		local Read = State.Buffer:Read(Length)
		return Read
	end;
	
	Enter = function(State, Pattern, Method, Argument, Buffer, Flags, Cache, Mentioned)
		Buffer:AddLine"("
		if type(Argument) == "string" then
			Pretty.Any(Argument:gsub("\n","\\n"), Buffer)
		else
			Pretty.Any(Argument, Buffer, Flags, Cache, Mentioned)
		end
		if Method == "Raise" then
			Buffer:Write(
				([[ @ %i "%s"]]):format(
					State:Position(),
					(
						Flags.Colorized
						and Terminal.Format(
							---@diagnostic disable-next-line:param-type-mismatch
							(State:Peek(6) or "?"):gsub("\n","\\n"), 
							{Terminal.Color.FG.Yellow}
						)
						---@diagnostic disable-next-line:param-type-mismatch
						or (State:Peek(6) or ""):gsub("\n","\\n")
					)
				)
			)
		end
		Buffer:Write") -> "
		Buffer:Write(Method)
		Buffer:Write" "
		Buffer:Write(State.Maps.Name[Pattern])
		Buffer:Write"("
		Pretty.Any(Pattern, Buffer, Flags, Cache, Mentioned)
		Buffer:Write")"
		Buffer:AdjustIndentation(1)
	end;
	
	Exit = function(State, Pattern, Method, Argument, Success, Result, Frame, Buffer, Flags, Cache, Mentioned)
		Buffer:AdjustIndentation(-1)
		Buffer:AddLine"("
		if Success then
			Buffer:Write(Terminal.Format("success", {Terminal.Color.FG.Green}))
		else
			Buffer:Write(Terminal.Format("failure", {Terminal.Color.FG.Red}))
		end
		if type(Result) == "string" then
			---@cast Result string
			Result = Result:gsub("\n","\\n")
		end
		Buffer:Write", "
		Pretty.Any(
			Result,
			Buffer,
			Flags,
			Cache,
			Mentioned
		)
		Buffer:Write") <- "
		Buffer:Write(Method)
		Buffer:Write" "
		Buffer:Write(State.Maps.Name[Pattern])
		Buffer:Write"("
		Pretty.Any(
			Pattern,
			Buffer,
			Flags,
			Cache,
			Mentioned
		)
		Buffer:Write") <- "
		if Method == "Raise" then
			local Read = Trace.GetMatched(State, Frame.Translation.At):gsub("\n","\\n")
			Buffer:Write[["]]
			Buffer:Write(
				Terminal.Format(
					Pretty.ToString(
						Read,
						Flags,
						"",
						Cache,
						Mentioned
					),{
						Terminal.Color.FG.Blue
					}
				)
			)
			Buffer:Write[["]]
		else
			if type(Argument) == "string" then
				---@cast Argument string
				Argument = Argument:gsub("\n","\\n")
			end
			Buffer:Write", "
			Pretty.Any(
				Argument,
				Buffer,
				Flags,
				Cache,
				Mentioned
			)
		end
	end;
	
	---@param Buffer Moonrise.Stream.Formatter.Indented
	---@param Flags Tools.Pretty.Any.Flags?
	---@param Cache Tools.Pretty.Any.Cache?
	---@param Mentioned Tools.Pretty.Any.Mentioned?
	Generate = function(Buffer, Flags, Cache, Mentioned)
		---@param State Adapt.Execution.State
		---@param Pattern Adapt.Transform.Base
		---@param Method Adapt.Method
		---@param Argument any
		local New = function(State, Pattern, Method, Argument)
			Trace.Enter(State, Pattern, Method, Argument, Buffer, Flags, Cache, Mentioned)
			local Success, Result
			if Method == "Raise" then
				Success, Result = Pattern:Raise(State, Argument)
			else
				Success, Result = Pattern:Lower(State, Argument)
			end
			local Frame = State:GetFrame()
			Trace.Exit(State, Pattern, Method, Argument, Success, Result, Frame, Buffer, Flags, Cache, Mentioned)
			return Success, Result
		end
		
		return New
	end;
}; return Trace
