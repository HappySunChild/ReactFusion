local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local TextService = game:GetService('TextService')

local player = Players.LocalPlayer
player.CharacterAdded:Wait()

local backpack = player:WaitForChild('Backpack')

local Rusion = require(ReplicatedStorage.Libraries.ReactFusion)
local Element = Rusion.createElement
local Value = Rusion.createValue

local HoverInfo = TweenInfo.new(0.4, Enum.EasingStyle.Circular)
local TooltipInfo = TweenInfo.new(0.2, Enum.EasingStyle.Exponential)

local function HotbarSlot(props)
	local tool = props.Item :: Tool
	local index = props.Index
	local callback = props.Callback

	local bounds = TextService:GetTextSize(tool.ToolTip, 14, Enum.Font.SourceSans, Vector2.new(math.huge, 15))

	local tooltipWidth = Value(0)
	local slotSize = Value(1)

	local toolParent = Value(tool.Parent)
	toolParent:bindToInstanceProperty(tool, 'Parent')

	return Element('TextButton', {
		Size = slotSize:map(function(v)
			return UDim2.fromScale(v, v)
		end),
		SizeConstraint = Enum.SizeConstraint.RelativeYY,

		LayoutOrder = index,

		BorderSizePixel = 1,
		BorderColor3 = toolParent:map(function(parent)
			if parent == backpack then
				return Color3.new(1, 1, 1)
			end

			return Color3.fromRGB(93, 85, 255)
		end),

		BackgroundColor3 = Color3.fromRGB(28, 32, 47),
		BackgroundTransparency = 0.4,

		Text = tool.Name,
		TextWrapped = true,
		TextTruncate = Enum.TextTruncate.AtEnd,
		TextColor3 = Color3.new(1, 1, 1),

		[Rusion.Event.Activated] = function(_, input: InputObject)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				if callback then
					callback(index)
				end
			end
		end,
		[Rusion.Event.MouseEnter] = function()
			slotSize:tween(1.1, HoverInfo)
			tooltipWidth:tween(bounds.X + 4, TooltipInfo)
		end,
		[Rusion.Event.MouseLeave] = function()
			slotSize:tween(1, HoverInfo)
			tooltipWidth:tween(0, TooltipInfo)
		end,
	}, {
		Tooltip = Element('TextLabel', {
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.new(0.5, 0, 0, -5),
			Size = tooltipWidth:map(function(width)
				return UDim2.fromOffset(width, 16)
			end),

			Text = tool.ToolTip,
			TextXAlignment = Enum.TextXAlignment.Center,
			TextYAlignment = Enum.TextYAlignment.Center,
			TextColor3 = Color3.new(1, 1, 1),

			ClipsDescendants = true,

			BackgroundTransparency = 0.5,
			BackgroundColor3 = Color3.fromRGB(53, 52, 78),
		}),
		SlotIndex = Element('TextLabel', {
			Size = UDim2.fromOffset(10, 10),
			BackgroundTransparency = 1,

			Text = index,
			TextColor3 = Color3.new(1, 1, 1),
		}),
	})
end

local HotbarComponent = Rusion.createComponent('Hotbar')

function HotbarComponent:init(props)
	local items = props.Items or {}

	local function update()
		self:setState({
			Items = items,
		})
	end

	local function removeTool(tool: Tool)
		local index = table.find(items, tool)

		if index then
			items[index] = nil

			update()
		end
	end

	local function addTool(child: Instance)
		if not child:IsA('Tool') then
			return
		end

		if table.find(items, child) then
			return
		end

		local connection
		connection = child.AncestryChanged:Connect(function(_, parent)
			if parent ~= backpack and parent ~= player.Character or parent == nil then
				connection:Disconnect()

				removeTool(child)
			end
		end)

		table.insert(items, child)
		update()
	end

	player.Character.ChildAdded:Connect(addTool)
	backpack.ChildAdded:Connect(addTool)

	for _, child in backpack:GetChildren() do
		addTool(child)
	end

	update()
end

function HotbarComponent:render()
	local state = self.state
	local props = self.props
	local items = state.Items

	local slots = {}

	for index, tool: Tool in items do
		table.insert(slots, Element(HotbarSlot, { Item = tool, Index = index, Callback = props.EquipCallback }))
	end

	local height = props.Height
	local padding = props.Padding

	local count = #slots

	return Element('Frame', {
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, -10),
		Size = UDim2.fromOffset(count * height + (count - 1) * padding, height),

		BackgroundTransparency = 1,
	}, {
		List = Rusion.createElement('UIListLayout', {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, padding),
		}),
		Slots = Rusion.createFragment(slots),
	})
end

return HotbarComponent
