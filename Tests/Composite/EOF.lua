local Adapt = require"Adapt"
local Transform = Adapt.Transform
local Stream = require"Moonrise.Stream"
local Test = require"Moonrise.Test"

local TestGrammar = Transform.Grammar{
	Anything = Transform.Bytes(1);
	EOF = Transform.Lookahead("Negative", Transform.Jump"Anything");
	Line = Transform.Sequence{
		Transform.All(Transform.Jump"Anything");

		Transform.Select{
			Transform.String"\n";
			Transform.Jump"EOF";
		};
	};
	Transform.All(Transform.Jump"Line");
}

return Test.Series(
	"EOF", {

	}
)
