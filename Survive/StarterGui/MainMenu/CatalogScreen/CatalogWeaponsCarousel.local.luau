local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local WeaponRegistry = require(
	ReplicatedStorage.Shared:WaitForChild("WeaponRegistry")
)

local AttributeFormatter = require(
	ReplicatedStorage.Shared:WaitForChild("AttributeFormatter")
)

local player = game.Players.LocalPlayer

local unlockedFolder =
	player:WaitForChild("GlobalStats")
	:WaitForChild("UnlockedWeapons")

-------------------------------------------------
-- CHECK UNLOCK
-------------------------------------------------

local function isUnlocked(id)

	local flag = unlockedFolder:FindFirstChild(id)

	return flag ~= nil and flag.Value == true

end

-------------------------------------------------
-- UI REFERENCES
-------------------------------------------------

local catalog = script.Parent

local viewer = catalog.ItemViewerContainer
local itemsFrame = viewer.ItemsFrame

local mainItem = itemsFrame.MainItem
local nextItem = itemsFrame.NextBlurItem
local prevItem = itemsFrame.PreviousBlurItem

local mainPos = mainItem.Position
local nextPos = nextItem.Position
local prevPos = prevItem.Position

local mainRarity = mainItem:WaitForChild("RarityLabel")
local nextRarity = nextItem:WaitForChild("RarityLabel")
local prevRarity = prevItem:WaitForChild("RarityLabel")

local arrows = catalog.ArrowsContainer

local left = arrows.LeftArrowContainer.LeftButton
local right = arrows.RightArrowContainer.RightButton

local info = catalog.InfoPanel
local title = info.ItemTitle
local description = info.ItemDescription
local buyButton = info:WaitForChild("BuyButton")

local PurchaseWeapon =
	ReplicatedStorage.Remotes:WaitForChild("PurchaseWeapon")

-------------------------------------------------
-- RARITY COLORS
-------------------------------------------------

local rarityColors = {

	Common = Color3.fromRGB(200,200,200),
	Uncommon = Color3.fromRGB(100,255,120),
	Rare = Color3.fromRGB(80,160,255),
	Epic = Color3.fromRGB(200,80,255),
	Legendary = Color3.fromRGB(255,180,50)

}

-------------------------------------------------
-- WEAPON LIST
-------------------------------------------------

local weapons = {}

for _,data in pairs(WeaponRegistry:GetAll()) do
	table.insert(weapons,data)
end

table.sort(weapons,function(a,b)
	return a.DisplayName < b.DisplayName
end)

local index = 1

-------------------------------------------------
-- INDEX LOOP
-------------------------------------------------

local function getIndex(i)

	if i < 1 then
		return #weapons
	elseif i > #weapons then
		return 1
	end

	return i

end

-------------------------------------------------
-- ANIMATION
-------------------------------------------------

local function animate(item)

	TweenService:Create(
		item,
		TweenInfo.new(0.15,Enum.EasingStyle.Quad),
		{ImageTransparency = 0}
	):Play()

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
-- BUTTON PRESS
-------------------------------------------------

local function pressButton(button)

	local scale = button:FindFirstChildOfClass("UIScale")
	if not scale then return end

	local press = TweenService:Create(
		scale,
		TweenInfo.new(0.08),
		{Scale = 0.85}
	)

	local release = TweenService:Create(
		scale,
		TweenInfo.new(0.08),
		{Scale = 1}
	)

	press:Play()

	press.Completed:Connect(function()
		release:Play()
	end)

end

local function formatAttributeName(name)

	return name:gsub("(%l)(%u)", "%1 %2")

end


local function buildWeaponStats(weapon)

	local lines = {}

	-------------------------------------------------
	-- BASE STATS
	-------------------------------------------------

	table.insert(lines,"• Base Stats")

	local statsOrder = {
		"Damage",
		"Cooldown",
		"Range",
		"ProjectileSpeed",
		"AttackSize",
		"ProjectilePierce",
		"AreaDamage"
	}

	for _,stat in ipairs(statsOrder) do

		local value = weapon.BaseStats[stat]

		if value ~= nil then

			local name = AttributeFormatter.FormatName(stat)
			local WeaponStatsFormatter = require(
				ReplicatedStorage.Shared:WaitForChild("WeaponStatsFormatter")
			)

			local formatted = WeaponStatsFormatter.Format(stat,value)

			table.insert(lines, name..": "..formatted)

		end

	end

	-------------------------------------------------
	-- UPGRADABLE
	-------------------------------------------------

	if weapon.UpgradeableStats then

		table.insert(lines,"")
		table.insert(lines,"• Upgradeable Attributes")

		for _,stat in ipairs(weapon.UpgradeableStats) do

			local name = formatAttributeName(stat)

			table.insert(lines,name)

		end

	end
	
	if weapon.CardEffects then

		table.insert(lines,"")
		table.insert(lines,"Card Effects")

		for name,effect in pairs(weapon.CardEffects) do
			table.insert(lines,name.." → "..effect)
		end

	end

	return table.concat(lines,"\n")

end

-------------------------------------------------
-- RENDER ITEM
-------------------------------------------------

local function renderItem(item,data)

	local unlocked = isUnlocked(data.Id)

	item.Image = data.Image

	if unlocked then
		item.ImageColor3 = Color3.new(1,1,1)
	else
		item.ImageColor3 = Color3.new(0,0,0)
	end

end

-------------------------------------------------
-- UPDATE DISPLAY
-------------------------------------------------

local function update()

	local current = weapons[index]
	local next = weapons[getIndex(index+1)]
	local prev = weapons[getIndex(index-1)]

	renderItem(mainItem,current)
	renderItem(nextItem,next)
	renderItem(prevItem,prev)

	title.Text = current.DisplayName

	local unlocked = isUnlocked(current.Id)

	-------------------------------------------------
	-- DESCRIPTION
	-------------------------------------------------

	if unlocked then

		local statsText = buildWeaponStats(current)

		description.Text =
			current.Description.."\n\n"..statsText

		buyButton.Visible = false

	else

		local price = current.Price or 0

		description.Text =
			"LOCKED\n\nPrice: "..price.." Gold"

		buyButton.Visible = true

	end

	-------------------------------------------------
	-- RARITY
	-------------------------------------------------

	local function applyRarity(label,data)

		if data.Rarity then

			label.Visible = true
			label.Text = data.Rarity
			label.TextColor3 =
				rarityColors[data.Rarity] or Color3.new(1,1,1)

		else
			label.Visible = false
		end

	end

	applyRarity(mainRarity,current)
	applyRarity(nextRarity,next)
	applyRarity(prevRarity,prev)

	animate(mainItem)
	animate(nextItem)
	animate(prevItem)

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
-- BUY BUTTON
-------------------------------------------------

buyButton.MouseButton1Click:Connect(function()

	local weapon = weapons[index]

	if isUnlocked(weapon.Id) then
		return
	end

	local success, result =
		PurchaseWeapon:InvokeServer(weapon.Id)

	if success then
		update()
	else
		warn(result)
	end

end)

-------------------------------------------------
-- INITIAL LOAD
-------------------------------------------------

update()