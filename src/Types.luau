export type UsedAs<V> = StateObject<V> | V

export type NullFunc = () -> nil
export type Disconnect = NullFunc

export type StateObject<V> = {
	onChange: (StateObject<V>, callback: (new: V, old: V) -> nil) -> Disconnect,
}

export type Use = <V>(target: StateObject<V>) -> V
export type ComputedProcessor<T> = (Use) -> T

export type Computed<V, T> = StateObject<T> & {
	_using: { StateObject<any> },
	_processor: ComputedProcessor<T>,
}

export type Value<V> = StateObject<V> & {
	set: (Value<V>, newValue: V) -> V,
	update: (Value<V>, predicate: (V) -> V) -> V,
	map: <T>(Value<V>, processor: (V) -> T) -> Computed<T, T>,

	tween: (Value<V>, target: UsedAs<V>, info: UsedAs<TweenInfo>, completedCallback: NullFunc?) -> Disconnect,
	bindToInstanceProperty: (Value<V>, instance: Instance, property: string) -> (Disconnect, RBXScriptConnection),
}

export type Properties = { any }
export type Component = StatefulComponent | Instance | string | (props: Properties, children: { Element }) -> Element

export type Element = {
	component: Component,
	props: Properties,
}

export type Ref = {
	set: (Ref, instance: Instance) -> nil,
	get: (Ref) -> Instance?,
}

export type Fragment = {
	elements: { Element },
}

export type VirtualNode = {
	currentElement: Element,

	hostInstance: Instance?,
	hostParent: Instance?,
	hostKey: string?,

	componentInstance: StatefulComponent?,

	children: { VirtualNode },
	bindings: { [string]: () -> nil },
	connections: { RBXScriptConnection },

	wasUnmounted: boolean,
}

export type StatefulComponent = {
	props: Properties,
	state: { any },

	setState: (StatefulComponent, newState: any) -> nil,

	render: (StatefulComponent) -> Element,
	init: (StatefulComponent, initProps: Properties) -> nil,

	didUpdate: (StatefulComponent) -> nil,
	didMount: (StatefulComponent) -> nil,
	willUnmount: (StatefulComponent) -> nil,
}

local Symbols = require(script.Parent.Symbols)

local function createType(name)
	local newType = newproxy(true)

	getmetatable(newType).__tostring = function()
		return `<Type '{name}'>`
	end

	return newType
end

local Types = {
	Event = createType('Event'),
	Ref = createType('Ref'),
	Element = createType('Element'),
	VirtualNode = createType('VirtualNode'),

	Fragment = createType('Fragment'),
	StatefulComponent = createType('Stateful'),

	Tween = createType('Tween'),
	Value = createType('Value'),
	Computed = createType('Computed'),
}

function Types.of(value)
	local vType = typeof(value)

	if vType == 'table' then
		if value[Symbols.Type] then
			return value[Symbols.Type]
		end
	end

	return vType
end

return Types
