local package = script.Parent.Parent

local Symbols = require(package.Symbols)

return {
	Idle = Symbols.named('idle'),
	Init = Symbols.named('init'),
	Render = Symbols.named('render'),
	DidMount = Symbols.named('didMount'),
	WillUnmount = Symbols.named('willUnmount')
}