local Null = require"Moonrise.Object.Null"
local Stream = require"Moonrise.Stream"
local Test = require"Moonrise.Test"
local Pretty = require"Moonrise.Tools.Pretty"
local Adapt = require"Adapt"
local Transform = Adapt.Transform
local Bubble = Adapt.Execution.Bubble
local Wrapper = require"Adapt.Transform.Select.Wrapper"

local TestGrammar = Transform.Grammar{
	Anything = Transform.Without(Transform.String";", Transform.Bytes(1));
	EOF = Transform.Lookahead("Negative", Transform.Jump"Anything");
	Line = Transform.Sequence{
		Transform.All(Transform.Jump"Anything");
		Transform.String";";
		Transform.Select{
			Transform.String"\n";
			Transform.Jump"EOF";
		};
	};
	Transform.Sequence{
		Transform.All(Transform.Jump"Line");
		Transform.Jump"EOF";
	}
}

return Test.Series(
	"EOF", {
		Test.Series(
			"parse", {
				Test.Passes(
					"succeeds with correct input", function()
						local Input = "abc;"
						local Source = Stream.String(Input)
						local Success = Adapt.Process(TestGrammar, "Raise", Source)
						Test.Assert(Success, "failed to parse")
					end
				);
				Test.Passes(
					"fails with content after end", function()
						local Input = "abc;\ndef;\nghi"
						local Source = Stream.String(Input)
						local Success = Adapt.Process(TestGrammar, "Raise", Source)
						Test.Deny(Success, "failed to reject content after EOF")
					end
				);
			}
		);
		Test.Series(
			"unparse", {
				Test.Passes(
					"succeeds with correct input", function()
						local Input = {
							Bubble.Form(
								{
									Bubble.Form("a","b","c");
									";";
									Wrapper(2, Null)
								}
							);
							Null
						}
						local TestSink = Stream.String""
						local Success = Adapt.Process(TestGrammar, "Lower", TestSink, Input)
						Test.Assert(Success, "failed to unparse")
					end
				);
				Test.Passes(
					"fails with content after end", function()
						local Input = {
							Bubble.Form(
								{
									Bubble.Form("a","b","c");
									";";
									Wrapper(2, Null);
								},
								{
									Bubble.Form("d","e","f");
									";";
									Wrapper(1, "\n")
								}
							);
							Null
						}
						
						local Sink = Stream.String""
						local Success = Adapt.Process(TestGrammar, "Lower", Sink, Input)
						Test.Deny(Success, "failed to reject bad input")
					end
				)
			}
		)
	}
)
