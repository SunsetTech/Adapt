local Adapt = require"Adapt"
local Stream = require"Moonrise.Stream"
local Test = require"Moonrise.Test"

local TestContent = "abc"
local TestGrammar = Adapt.Transform.Bytes(3)

return Test.Series(
	"Bytes", {
		Test.Series(
			"Raise", {
				Test.Passes(
					"Accepts exact size", function()
						local Source = Stream.String(TestContent)
						local Success, Result = Adapt.Process(TestGrammar, "Raise", Source)
						assert(Success, "Raise failed")
						assert(Result == TestContent, "Wrong result")
					end
				);
				Test.Fails(
					"Rejects undersized", function()
						local Source = Stream.String(TestContent:sub(2))
						local Success = Adapt.Process(TestGrammar, "Raise", Source)
						assert(Success)
					end
				);
			}
		);
		Test.Series(
			"Lower", {
				Test.Passes(
					"Accepts exact size", function()
						local Sink = Stream.String""
						local Success = Adapt.Process(TestGrammar, "Lower", Sink, TestContent)
						assert(Success, "Lower failed")
						Sink:Goto(1)
						local Result = Sink:Read(Sink:Size())
						assert(Result == TestContent, "Wrong result")
					end
				);
			}
		);
		Test.Series(
			"Roundtrip", {
				Test.Passes(
					"Raise->Lower", function()
						local Source = Stream.String(TestContent)
						local Success, Result = Adapt.Process(TestGrammar, "Raise", Source)
						assert(Success, "Raise failed")
						local Sink = Stream.String""
						Success = Adapt.Process(TestGrammar, "Lower", Sink, Result)
						assert(Success, "Lower failed")
					end
				);
				Test.Passes(
					"Lower->Raise", function()
						local IO = Stream.String""
						local Success = Adapt.Process(TestGrammar, "Lower", IO, TestContent)
						assert(Success, "Lower failed")
						IO:Goto(1)
						Success = Adapt.Process(TestGrammar, "Raise", IO)
						assert(Success, "Raise failed")
					end
				);
			}
		)
	}
)
