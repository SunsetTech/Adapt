---@diagnostic disable:trailing-space
return {
	All = require"Adapt.Transform.All";
	Atleast = require"Adapt.Transform.Atleast";
	Atmost = require"Adapt.Transform.Atmost";
	Base = require"Adapt.Transform.Base";
	Between = require"Adapt.Transform.Between";
	Bytes = require"Adapt.Transform.Bytes";
	Compound = require"Adapt.Transform.Compound";
	Dynamic = require"Adapt.Transform.Dynamic";
	Grammar = require"Adapt.Transform.Grammar";
	Lens = require"Adapt.Transform.Lens";
	Lookahead = require"Adapt.Transform.Lookahead";
	Jump = require"Adapt.Transform.Jump";
	Packed = require"Adapt.Transform.Packed";
	Print = require"Adapt.Transform.Print";
	Range = require"Adapt.Transform.Range";
	String = require"Adapt.Transform.String";
	Select = require"Adapt.Transform.Select";
	Sequence = require"Adapt.Transform.Sequence";
	Set = require"Adapt.Transform.Set";
	Success = require"Adapt.Transform.Success";
	Value = require"Adapt.Transform.Value";
	Without = require"Adapt.Transform.Without";
	
	---@deprecated
	Expect = require"Adapt.Transform.Expect";
	---@deprecated
	Dematch = require"Adapt.Transform.Without";
	---@deprecated
	Rule = require"Adapt.Transform.Jump";
	---@deprecated
	DebugBuoy = require"Adapt.Transform.Print";
}
