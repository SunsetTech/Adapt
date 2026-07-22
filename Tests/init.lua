local Test = require"Moonrise.Test"

return Test.Series(
	"Adapt", {
		require"Adapt.Tests.Composite";
		require"Adapt.Tests.Transform";
	}
)
