local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local ArtifactUtilRegistry = require(
	ReplicatedStorage.Shared:WaitForChild("ArtifactUtilRegistry")
)

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

-------------------------------------------------
-- LIST
-------------------------------------------------

local artifacts = {}

for id,data in pairs(ArtifactUtilRegistry) do
	data.Id = id
	table.insert(artifacts,data)
end

table.sort(artifacts,function(a,b)
	return a.DisplayName < b.DisplayName
end)

local index = 1

-------------------------------------------------
-- INDEX LOOP
-------------------------------------------------

local function getIndex(i)

	if i < 1 then
		return #artifacts
	elseif i > #artifacts then
		return 1
	end

	return i

end

-------------------------------------------------
-- BUTTON PRESS
-------------------------------------------------

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

-------------------------------------------------
-- BUILD DESCRIPTION
-------------------------------------------------

local function buildDescription(data)

	local lines = {}

	-------------------------------------------------
	-- DESCRIPTION
	-------------------------------------------------

	table.insert(lines,data.Description)
	table.insert(lines,"")

	-------------------------------------------------
	-- DURATION
	-------------------------------------------------

	if data.Duration then
		table.insert(lines,"• Duration")
		table.insert(lines,tostring(data.Duration))
		table.insert(lines,"")
	end

	-------------------------------------------------
	-- BONUSES
	-------------------------------------------------

	if data.Bonus then

		table.insert(lines,"• Bonuses")

		for _,bonus in ipairs(data.Bonus) do
			table.insert(lines,bonus)
		end

	end

	return table.concat(lines,"\n")

end

-------------------------------------------------
-- UPDATE DISPLAY
-------------------------------------------------

local function update()

	local current = artifacts[index]
	local next = artifacts[getIndex(index+1)]
	local prev = artifacts[getIndex(index-1)]

	mainItem.Image = current.Image
	nextItem.Image = next.Image
	prevItem.Image = prev.Image

	title.Text = current.DisplayName
	description.Text = buildDescription(current)

end

-------------------------------------------------
-- CAROUSEL ANIMATION
-------------------------------------------------

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

-------------------------------------------------
-- BUTTONS
-------------------------------------------------

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

-------------------------------------------------
-- START
-------------------------------------------------

update()