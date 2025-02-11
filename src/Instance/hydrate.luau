local package = script.Parent.Parent

local Renderer = require(package.Renderer)
local Types = require(package.Types)
local createElement = require(package.Node.createElement)

local function hydrate(target: Instance, props: Types.Properties, children: { Types.Element }?)
	local element = createElement(target, props, children)

	return Renderer.mount(element)
end

return hydrate
