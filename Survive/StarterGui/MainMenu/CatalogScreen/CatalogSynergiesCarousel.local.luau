local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

local SynergyRegistry = require(ReplicatedStorage.Shared:WaitForChild("SynergyRegistry"))

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local GetDiscoveredSynergies = Remotes:WaitForChild("GetDiscoveredSynergies")
local SynergyUnlocked = Remotes:WaitForChild("SynergyUnlocked")

local AttributeFormatter = require(
	ReplicatedStorage.Shared:WaitForChild("AttributeFormatter")
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

local tierColors = {
	[1] = Color3.fromRGB(120,255,120),
	[2] = Color3.fromRGB(120,180,255),
	[3] = Color3.fromRGB(200,120,255)
}

-------------------------------------------------
-- DISCOVERED SYNERGIES
-------------------------------------------------

local discovered = {}
local DEBUG_SHOW_ALL = false

local success, result = pcall(function()
	return GetDiscoveredSynergies:InvokeServer()
end)

if success and result then
	for id,_ in pairs(result) do
		discovered[id] = true
	end
end

-------------------------------------------------
-- SYNERGY LIST
-------------------------------------------------

local synergies = {}

for _,data in pairs(SynergyRegistry.Definitions) do
	table.insert(synergies,data)
end

table.sort(synergies,function(a,b)
	if a.Tier == b.Tier then
		return a.DisplayName < b.DisplayName
	end
	return a.Tier < b.Tier
end)

local index = 1

-------------------------------------------------
-- CREATE NOISE (UMA VEZ)
-------------------------------------------------

local function createNoiseOverlay(item)

	local existing = item:FindFirstChild("NoiseOverlay")
	if existing then return existing end

	local noise = Instance.new("ImageLabel")

	noise.Name = "NoiseOverlay"
	noise.BackgroundTransparency = 1

	-- tamanho centralizado
	noise.Size = UDim2.fromScale(1,1)
	noise.Position = UDim2.fromScale(0,0.25)

	noise.Image = "rbxassetid://117266253034518"
	noise.ImageTransparency = 0.45
	noise.ZIndex = item.ZIndex + 1

	noise.Visible = false
	noise.Parent = item

	-- força formato quadrado
	local ratio = Instance.new("UIAspectRatioConstraint")
	ratio.AspectRatio = 1
	ratio.Parent = noise

	-- círculo perfeito
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(1,0)
	corner.Parent = noise

	return noise

end

local mainNoise = createNoiseOverlay(mainItem)
local nextNoise = createNoiseOverlay(nextItem)
local prevNoise = createNoiseOverlay(prevItem)

-------------------------------------------------
-- INDEX LOOP
-------------------------------------------------

local function getIndex(i)

	if i < 1 then
		return #synergies
	elseif i > #synergies then
		return 1
	end

	return i

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

local function formatAttributeName(name)

	-- separa palavras CamelCase
	local formatted = name:gsub("(%l)(%u)", "%1 %2")

	return formatted

end

-------------------------------------------------
-- BUILD INFO
-------------------------------------------------

local function buildInfo(data)

	local discoveredSynergy = DEBUG_SHOW_ALL or discovered[data.Id]

	if not discoveredSynergy then

		title.Text = "???"
		description.Text = "This entry has not yet been discovered.\n\nContinue playing to reveal its secrets."
		return

	end

	local lines = {}

	-------------------------------------------------
	-- TIER
	-------------------------------------------------

	table.insert(lines,"• TIER "..data.Tier)
	table.insert(lines,"")

	-------------------------------------------------
	-- REQUIREMENTS
	-------------------------------------------------

	table.insert(lines,"• REQUIRES")

	for attr,value in pairs(data.Requires) do

		local name = formatAttributeName(attr)

		table.insert(lines,name.." "..value)

	end

	-------------------------------------------------
	-- BONUSES
	-------------------------------------------------

	if data.Bonuses then

		table.insert(lines,"")
		table.insert(lines,"• Bonuses")

		for stat,value in pairs(data.Bonuses) do

			local name = formatAttributeName(stat)
			local formatted = AttributeFormatter.Format(stat,value)

			table.insert(lines,name.." "..formatted)

		end

	end

	title.Text = data.DisplayName
	description.Text = data.Description.."\n\n"..table.concat(lines,"\n")

end

-------------------------------------------------
-- NOISE ANIMATION
-------------------------------------------------

local function animateNoise(noise)

	task.spawn(function()

		local rotation = 0

		while noise.Visible do

			rotation += 1
			noise.Rotation = rotation

			noise.ImageTransparency = 0.45 + math.random()*0.1

			task.wait(0.08)

		end

	end)

end

-------------------------------------------------
-- RENDER ITEM
-------------------------------------------------

local function render(item,data,noise)

	local discoveredSynergy = discovered[data.Id]

	item.Image = data.Image

	if discoveredSynergy then

		item.ImageColor3 = Color3.new(1,1,1)

		if noise then
			noise.Visible = false
		end

	else

		item.ImageColor3 = Color3.new(0,0,0)

		if noise then
			if not noise.Visible then
				noise.Visible = true
				animateNoise(noise)
			end
		end

	end

end

-------------------------------------------------
-- UPDATE
-------------------------------------------------

local function update()

	local current = synergies[index]
	local next = synergies[getIndex(index+1)]
	local prev = synergies[getIndex(index-1)]

	render(mainItem,current,mainNoise)
	render(nextItem,next,nextNoise)
	render(prevItem,prev,prevNoise)

	buildInfo(current)

	local function applyTier(item,data)

		local label = item:FindFirstChild("RarityLabel")
		if not label then return end

		label.Visible = true
		label.Text = "Tier "..data.Tier
		label.TextColor3 = tierColors[data.Tier] or Color3.new(1,1,1)

	end

	applyTier(mainItem,current)
	applyTier(nextItem,next)
	applyTier(prevItem,prev)

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
-- CLEANUP (QUANDO TROCAR DE CATEGORIA)
-------------------------------------------------

script:GetPropertyChangedSignal("Disabled"):Connect(function()

	if script.Disabled then

		for _,item in pairs({mainItem,nextItem,prevItem}) do
			local noise = item:FindFirstChild("NoiseOverlay")
			if noise then
				noise:Destroy()
			end
		end

	end

end)

-------------------------------------------------
-- START
-------------------------------------------------

SynergyUnlocked.OnClientEvent:Connect(function(data)

	discovered[data.Id] = true
	update()

end)

update()
