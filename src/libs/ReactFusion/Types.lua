--!strict
export type ElementProps = {[string|any]: any}
export type ElementComponent = string | (props: ElementProps, children: {Element}) -> Element

export type Element = {
	component: ElementComponent,
	props: ElementProps
}

export type StateObject<V> = {
	onChange: (StateObject<V>, callback: (new: V, old: V) -> nil) -> () -> nil
}

export type Use = <V>(target: StateObject<V>) -> V 
export type ComputedProcessor<T> = (Use) -> T
export type Computed<V, T> = StateObject<T> & {
	_using: {StateObject<any>},
	_processor: ComputedProcessor<T>
}

export type Value<V> = StateObject<V> & {
	set: (Value<V>, newValue: V) -> V,
	update: (Value<V>, predicate: (V) -> V) -> V,
	map: <T>(Value<V>, processor: (V) -> T) -> Computed<T, T>
}

export type Ref = {
	set: (Ref, instance: Instance) -> nil,
	get: (Ref) -> Instance?
}

export type Fragment = {
	elements: {Element}
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
	Fragment = createType('Fragment'),
	Element = createType('Element'),
	VirtualNode = createType('VirtualNode'),

	Value = createType('Value'),
	Computed = createType('Computed')
}

function Types.of(value)
	local vType = type(value)
	
	if vType == 'table' then
		if value[Symbols.Type] then
			return value[Symbols.Type]
		end
	end
	
	return vType
end

function Types.kindOf(value)
	local vType = type(value)
	
	if vType == 'table' then
		if value[Symbols.Kind] then
			return value[Symbols.Kind]
		end
	end
	
	return vType
end

return Types