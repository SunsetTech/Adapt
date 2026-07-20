local Null = require"Moonrise.Object.Null"
local Stream = require"Moonrise.Stream"
local Test = require"Moonrise.Test"
local Adapt = require"Adapt"
local Transform = Adapt.Transform
local Wrapper = require"Adapt.Transform.Select.Wrapper"

local TestGrammar = Transform.Grammar{
	Anything = Transform.Bytes(1);
	EOF = Transform.Lookahead("Negative", Transform.Jump"Anything");
	Line = Transform.Sequence{
		Transform.All(Transform.Jump"Anything");
		Transform.String";";
		Transform.Select{
			Transform.String"\n";
			Transform.Jump"EOF";
		};
	};
	Transform.All(Transform.Jump"Line");
}

local TestPassingInput = Adapt.Execution.Bubble.Form(
	{
		Adapt.Execution.Bubble.Form("a","b","c");
		";";
		Wrapper(1, "\n")
	},
	{
		Adapt.Execution.Bubble.Form("d","e","f");
		";";
		Wrapper(2, Null);
	}
)

local TestFailingInput = Adapt.Execution.Bubble.Form(
	{
		Adapt.Execution.Bubble.Form("a","b","c");
		";";
		Wrapper(2, Null);
	},
	{
		Adapt.Execution.Bubble.Form("d","e","f");
		";";
		Wrapper(1, "\n")
	}
)

return Test.Series(
	"EOF", {
		Test.Passes(
			"unparse success", function()
				local Sink = Stream.String""
				local Success = Adapt.Process(TestGrammar, "Lower", Sink, TestPassingInput)
				assert(Success, "failed to unparse")
			end
		);
		Test.Fails(
			"fails with content after end", function()
				local Sink = Stream.String""
				local Success = Adapt.Process(TestGrammar, "Lower", Sink, TestFailingInput)
				assert(Success)
			end
		)
	}
)
