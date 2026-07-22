local Pretty = require"Moonrise.Tools.Pretty"
local Terminal = require"Moonrise.Tools.Terminal"

local Trace; Trace = {
	GetMatched = function(CurrentState, StartByte)
		local StopByte = CurrentState.Buffer:At()
		if StopByte <= StartByte then
			return ""
		end
		local Length = StopByte-StartByte
		CurrentState.Buffer:Goto(StartByte)
		local Read = CurrentState.Buffer:Read(Length)
		return Read
	end;

	---@param CurrentState Adapt.Execution.State
	---@param Pattern Adapt.Transform.Base
	---@param Method Adapt.Method
	---@param Argument any
	---@param TraceSink Moonrise.Stream.Formatter.Fancy
	---@param ObjectSink Moonrise.Stream.Formatter.Fancy
	---@param Flags Tools.Pretty.Any.Flags?
	---@param Cache Tools.Pretty.Any.Cache?
	---@param Mentioned Tools.Pretty.Any.Mentioned?
	Enter = function(CurrentState, Pattern, Method, Argument, TraceSink, ObjectSink, Flags, Cache, Mentioned)
		TraceSink:Open("(", true)
		if type(Argument) == "string" then
			Pretty.Any(Argument:gsub("\n","\\n"), ObjectSink)
		else
			Pretty.Any(Argument, ObjectSink, Flags, Cache, Mentioned)
		end
		if Method == "Raise" then
			TraceSink:Write(
				([[ @ %i %s]]):format(
					CurrentState:Position(),
					(
						Flags.Colorized
						and Terminal.Format(
							---@diagnostic disable-next-line:param-type-mismatch
							(CurrentState:Peek(6) or "?"):gsub("\n","\\n"), 
							{Terminal.Color.FG.Yellow}
						)
						---@diagnostic disable-next-line:param-type-mismatch
						or (CurrentState:Peek(6) or ""):gsub("\n","\\n")
					)
				)
			)
		end
		TraceSink:Write") -> "
		TraceSink:Write(Method)
		TraceSink:Write" "
		TraceSink:Write(CurrentState.Maps.Name[Pattern])
		TraceSink:Write"("
		Pretty.Any(Pattern, ObjectSink, Flags, Cache, Mentioned)
		TraceSink:Write")"
		TraceSink:NewLine()
		TraceSink.Level = TraceSink.Level + 1
	end;
	
	---@param CurrentState Adapt.Execution.State
	---@param Pattern Adapt.Transform.Base
	---@param Method Adapt.Method
	---@param Argument any
	---@param Success boolean
	---@param Result any
	---@param Frame Adapt.Execution.State.Frame
	---@param TraceSink Moonrise.Stream.Formatter.Fancy
	---@param ObjectSink Moonrise.Stream.Formatter.Fancy
	---@param Flags Tools.Pretty.Any.Flags?
	---@param Cache Tools.Pretty.Any.Cache?
	---@param Mentioned Tools.Pretty.Any.Mentioned?
	Exit = function(CurrentState, Pattern, Method, Argument, Success, Result, Frame, TraceSink, ObjectSink, Flags, Cache, Mentioned)
		TraceSink.Level = TraceSink.Level - 1
		TraceSink:Write"("
		if Success then
			TraceSink:Write(Terminal.Format("success", {Terminal.Color.FG.Green}))
		else
			TraceSink:Write(Terminal.Format("failure", {Terminal.Color.FG.Red}))
		end
		if type(Result) == "string" then
			---@cast Result string
			Result = Result:gsub("\n","\\n")
		end
		TraceSink:Write", "
		Pretty.Any(
			Result,
			ObjectSink,
			Flags,
			Cache,
			Mentioned
		)
		TraceSink:Write") <- "
		TraceSink:Write(Method)
		TraceSink:Write" "
		TraceSink:Write(CurrentState.Maps.Name[Pattern])
		TraceSink:Write"("
		Pretty.Any(
			Pattern,
			ObjectSink,
			Flags,
			Cache,
			Mentioned
		)
		TraceSink:Write") <- "
		if Method == "Raise" then
			local Read = Trace.GetMatched(CurrentState, Frame.Translation.At):gsub("\n","\\n")
			TraceSink:Write(
				Terminal.Format(
					Pretty.ToString(
						Read,
						Flags,
						ObjectSink.Level,
						ObjectSink.Prefixes,
						Cache,
						Mentioned
					),{
						Terminal.Color.FG.Blue
					}
				)
			)
		else
			if type(Argument) == "string" then
				---@cast Argument string
				Argument = Argument:gsub("\n","\\n")
			end
			TraceSink:Write", "
			Pretty.Any(
				Argument,
				ObjectSink,
				Flags,
				Cache,
				Mentioned
			)
		end
		TraceSink:NewLine()
		TraceSink:Close""
	end;
	
	---@param TraceSink Moonrise.Stream.Formatter.Fancy
	---@param ObjectSink Moonrise.Stream.Formatter.Fancy
	---@param Flags Tools.Pretty.Any.Flags?
	---@param Cache Tools.Pretty.Any.Cache?
	---@param Mentioned Tools.Pretty.Any.Mentioned?
	Generate = function(TraceSink, ObjectSink, Flags, Cache, Mentioned)
		---@param CurrentState Adapt.Execution.State
		---@param Pattern Adapt.Transform.Base
		---@param Method Adapt.Method
		---@param Argument any
		local New = function(CurrentState, Pattern, Method, Argument)
			Trace.Enter(CurrentState, Pattern, Method, Argument, TraceSink, ObjectSink, Flags, Cache, Mentioned)
			local Success, Result
			if Method == "Raise" then
				Success, Result = Pattern:Raise(CurrentState, Argument)
			else
				Success, Result = Pattern:Lower(CurrentState, Argument)
			end
			local Frame = CurrentState:GetFrame()
			Trace.Exit(CurrentState, Pattern, Method, Argument, Success, Result, Frame, TraceSink, ObjectSink, Flags, Cache, Mentioned)
			return Success, Result
		end
		
		return New
	end;
}; return Trace
