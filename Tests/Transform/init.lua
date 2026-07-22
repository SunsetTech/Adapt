local Test = require"Moonrise.Test"

return Test.Series(
	"Transform", {
		require"Adapt.Tests.Transform.All";
		require"Adapt.Tests.Transform.Atleast";
		require"Adapt.Tests.Transform.Bytes";
	}
)
