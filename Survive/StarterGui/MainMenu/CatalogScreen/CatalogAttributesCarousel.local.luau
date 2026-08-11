local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TweenService = game:GetService("TweenService")

local AttributeRegistry = require(ReplicatedStorage.Shared:WaitForChild("AttributeCardRegistry"))

local catalog = script.Parent

local viewer = catalog.ItemViewerContainer
local itemsFrame = viewer.ItemsFrame

local mainItem = itemsFrame.MainItem
local nextItem = itemsFrame.NextBlurItem
local prevItem = itemsFrame.PreviousBlurItem

local mainPos = mainItem.Position
local nextPos = nextItem.Position
local prevPos = prevItem.Position

local arrows = catalog.ArrowsContainer

local left = arrows.LeftArrowContainer.LeftButton
local right = arrows.RightArrowContainer.RightButton

local info = catalog.InfoPanel
local title = info.ItemTitle
local description = info.ItemDescription


local attributes = {}

for _,data in pairs(AttributeRegistry) do
	table.insert(attributes,data)
end

table.sort(attributes,function(a,b)
	return a.CardName < b.CardName
end)


local index = 1


local function getIndex(i)

	if i < 1 then
		return #attributes
	elseif i > #attributes then
		return 1
	end

	return i

end

local function animate(item)

	local tween = TweenService:Create(
		item,
		TweenInfo.new(
			0.15,
			Enum.EasingStyle.Quad,
			Enum.EasingDirection.Out
		),
		{ImageTransparency = 0}
	)

	tween:Play()

end

local function slide(item, offset)

	local startPos = item.Position

	local goal = {}
	goal.Position = startPos + UDim2.new(offset,0,0,0)

	local tween = TweenService:Create(
		item,
		TweenInfo.new(
			0.2,
			Enum.EasingStyle.Quad,
			Enum.EasingDirection.Out
		),
		goal
	)

	tween:Play()

end

local function update()

	local current = attributes[index]
	local next = attributes[getIndex(index+1)]
	local prev = attributes[getIndex(index-1)]

	mainItem.Image = current.Image
	nextItem.Image = next.Image
	prevItem.Image = prev.Image

	title.Text = current.CardName.." ("..current.DisplayName..")"
	description.Text = current.Description

	animate(mainItem)
	animate(nextItem)
	animate(prevItem)
	
	local mainRarity = mainItem:FindFirstChild("RarityLabel")
	local nextRarity = nextItem:FindFirstChild("RarityLabel")
	local prevRarity = prevItem:FindFirstChild("RarityLabel")

	if mainRarity then mainRarity.Visible = false end
	if nextRarity then nextRarity.Visible = false end
	if prevRarity then prevRarity.Visible = false end

end

local function animateCarousel(direction)

	local duration = 0.18

	if direction == "right" then

		TweenService:Create(
			mainItem,
			TweenInfo.new(duration,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),
			{Position = prevPos}
		):Play()

		TweenService:Create(
			nextItem,
			TweenInfo.new(duration,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),
			{Position = mainPos}
		):Play()

		TweenService:Create(
			prevItem,
			TweenInfo.new(duration,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),
			{Position = mainPos - UDim2.new(0.35,0,0,0)}
		):Play()

	elseif direction == "left" then

		TweenService:Create(
			mainItem,
			TweenInfo.new(duration,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),
			{Position = nextPos}
		):Play()

		TweenService:Create(
			prevItem,
			TweenInfo.new(duration,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),
			{Position = mainPos}
		):Play()

		TweenService:Create(
			nextItem,
			TweenInfo.new(duration,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),
			{Position = mainPos + UDim2.new(0.35,0,0,0)}
		):Play()

	end

end

local function pressButton(button)

	local scale = button:FindFirstChildOfClass("UIScale")

	if not scale then return end

	local press = TweenService:Create(
		scale,
		TweenInfo.new(
			0.08,
			Enum.EasingStyle.Quad,
			Enum.EasingDirection.Out
		),
		{Scale = 0.85}
	)

	local release = TweenService:Create(
		scale,
		TweenInfo.new(
			0.08,
			Enum.EasingStyle.Quad,
			Enum.EasingDirection.Out
		),
		{Scale = 1}
	)

	press:Play()

	press.Completed:Connect(function()
		release:Play()
	end)

end

left.MouseButton1Click:Connect(function()

	pressButton(left)

	animateCarousel("left")

	task.wait(0.18)

	index = getIndex(index-1)
	update()

	mainItem.Position = mainPos
	nextItem.Position = nextPos
	prevItem.Position = prevPos

end)


right.MouseButton1Click:Connect(function()

	pressButton(right)

	animateCarousel("right")

	task.wait(0.18)

	index = getIndex(index+1)
	update()

	mainItem.Position = mainPos
	nextItem.Position = nextPos
	prevItem.Position = prevPos

end)


update()