local OOP = require"Moonrise.OOP"

local Base = require"Adapt.Transform.Base"
---@class Adapt.Transform.Compound : Adapt.Transform.Base
---@field Children table<any, Adapt.Transform.Base>
---@overload fun(Children: table<any, Adapt.Transform.Base>): Adapt.Transform.Compound
local Compound = OOP.Declarator.Shortcuts(
	"Adapt.Transform.Compound", {
		Base
	}
)

---@param Instance Adapt.Transform.Compound
---@param Children table<any, Adapt.Transform.Base>
function Compound:Initialize(Instance, Children)
	Instance.Children = Children or {}
end

function Compound:Optimize()
	Base.Optimize(self)
	for _, Child in pairs(self.Children or {}) do 
		Child:Optimize()
	end
end

return Compound
