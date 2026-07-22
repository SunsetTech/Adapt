local Test = require"Moonrise.Test"
local Stream = require"Moonrise.Stream"
local Adapt = require"Adapt"
local Transform = Adapt.Transform
local Bubble = Adapt.Execution.Bubble

local TestGrammar = Transform.Grammar{
	Atom = Transform.String"a";
	Anything = Transform.Bytes(1);
	Transform.Sequence{
		Transform.All(Transform.Jump"Atom");
		Transform.Jump"Anything";
	}
}

return Test.Series(
	"All", {
		Test.Series(
			":Lower()", {
				Test.Series(
					"Rejects", {
						Test.Passes(
							"Matching trailing content", function()
								local TestSink = Stream.String""
								local TestInput = {
									Bubble.Form(
										"a",
										"a",
										"a"
									);
									"a";
								}
								local Success = Adapt.Process(TestGrammar, "Lower", TestSink, TestInput)
								Test.Deny(Success)
							end
						)
					}
				)
			}
		);
	}
)
