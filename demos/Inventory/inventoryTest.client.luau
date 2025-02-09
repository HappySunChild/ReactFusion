local ContextActionService = game:GetService('ContextActionService')
local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local StarterGui = game:GetService('StarterGui')

local player = Players.LocalPlayer

StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)

local HotbarComponent = require(script.Parent.HotbarComponent)

local Rusion = require(ReplicatedStorage.Libraries.ReactFusion)
local Element = Rusion.createElement

local keys = {
	Enum.KeyCode.One,
	Enum.KeyCode.Two,
	Enum.KeyCode.Three,
	Enum.KeyCode.Four,
	Enum.KeyCode.Five,
	Enum.KeyCode.Six,
	Enum.KeyCode.Seven,
	Enum.KeyCode.Eight,
	Enum.KeyCode.Nine,
	Enum.KeyCode.Zero,
}

local items = {}
local current = nil

local function characterAdded(character: Model)
	character.ChildAdded:Connect(function(child)
		if child:IsA('Tool') then
			current = child
		end
	end)

	character.ChildRemoved:Connect(function(child)
		if child == current then
			current = nil
		end
	end)
end

local function equipTool(index: number)
	local tool = items[index]

	if not tool then
		return
	end

	if current == tool then
		current.Parent = player.Backpack

		return
	end

	if current then
		current.Parent = player.Backpack
	end

	tool.Parent = player.Character
end

Rusion.mount(
	Element('ScreenGui', nil, {
		Hotbar = Element(HotbarComponent, {
			Height = 50,
			Padding = 5,

			Items = items,
			EquipCallback = equipTool,
		}),
	}),
	player.PlayerGui,
	'InventoryHotbar'
)

ContextActionService:BindAction('Equip', function(_, state: Enum.UserInputState, input: InputObject)
	if state ~= Enum.UserInputState.Begin then
		return
	end

	local index = table.find(keys, input.KeyCode)

	equipTool(index)
end, false, unpack(keys))

characterAdded(player.Character or player.CharacterAdded:Wait())
player.CharacterAdded:Connect(characterAdded)
