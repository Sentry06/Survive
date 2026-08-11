local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local ShowSummaryScreen = Remotes:WaitForChild("ShowSummaryScreen")
local ReturnToMenu = Remotes:WaitForChild("ReturnToMenu")

local summaryGui = player.PlayerGui:WaitForChild("SummaryGui")


local WeaponRegistry = require(
	ReplicatedStorage.Shared:WaitForChild("WeaponRegistry")
)

local SynergyRegistry = require(
	ReplicatedStorage.Shared:WaitForChild("SynergyRegistry")
)

local GameState = ReplicatedStorage:WaitForChild("GameState")

local GetDiscoveredSynergies =
	ReplicatedStorage.Remotes:WaitForChild("GetDiscoveredSynergies")

local matchStats = player:WaitForChild("MatchStats")
local attributesFolder = matchStats:WaitForChild("Attributes")
local attributeLevels = matchStats:WaitForChild("AttributeLevels")
local synergyBonuses = matchStats:WaitForChild("SynergyBonuses")

local AttributeCardRegistry =
	require(game.ReplicatedStorage.Shared:WaitForChild("AttributeCardRegistry"))

local activeSynergiesFolder =
	player:WaitForChild("MatchStats")
	:WaitForChild("ActiveSynergies")

local GetCurrentWeapons =
	ReplicatedStorage.Remotes:WaitForChild("GetCurrentWeapons")

summaryGui.Enabled = false

local function formatTime(seconds)
	seconds = math.floor(seconds or 0)

	local minutes = math.floor(seconds / 60)
	local remainingSeconds = seconds % 60

	return string.format("%02d:%02d", minutes, remainingSeconds)
end

local function renderWeaponsSummary(main)

	local container =
		main.WeaponsEquippedContainer.WeaponsEquippedFrame

	-- limpar antigo
	for _, child in ipairs(container:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end

	local weapons = {}

	local success, result = pcall(function()
		return GetCurrentWeapons:InvokeServer()
	end)

	if success and type(result) == "table" then
		weapons = result
	end

	for _, data in ipairs(weapons) do

		local def = WeaponRegistry.Definitions[data.Name]
		if not def then continue end

		local item = Instance.new("Frame")
		item.Size = UDim2.new(0, 70, 0, 85)
		item.BackgroundTransparency = 1
		item.Parent = container

		-- ICON
		local icon = Instance.new("ImageLabel")
		icon.Size = UDim2.new(0, 55, 0, 55)
		icon.Position = UDim2.new(0.5, -27, 0, 0)
		icon.BackgroundTransparency = 1
		icon.Image = def.Image
		icon.Parent = item

		-- NAME
		local nameLabel = Instance.new("TextLabel")
		nameLabel.Size = UDim2.new(1, 0, 0, 18)
		nameLabel.Position = UDim2.new(0, 0, 0, 55)
		nameLabel.BackgroundTransparency = 1
		nameLabel.TextScaled = true
		nameLabel.Font = Enum.Font.Merriweather
		nameLabel.TextColor3 = Color3.fromRGB(226,197,33)
		nameLabel.Text = def.DisplayName
		nameLabel.Parent = item

		-- LEVEL
		local levelLabel = Instance.new("TextLabel")
		levelLabel.Size = UDim2.new(1, 0, 0, 18)
		levelLabel.Position = UDim2.new(0, 0, 0, 70)
		levelLabel.BackgroundTransparency = 1
		levelLabel.TextScaled = true
		levelLabel.Font = Enum.Font.Merriweather
		levelLabel.TextColor3 = Color3.fromRGB(255,255,255)
		levelLabel.Text = "Level "..tostring(data.Level or 1)
		levelLabel.Parent = item
	end
end

local function renderSynergiesSummary(main)

	local container =
		main.SynergiesEquippedUnlockedContainer
		.SynergiesEquippedContainer
		.SynergiesEquippedFrame

	-- limpar anterior
	for _, child in ipairs(container:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end

	for _, valueObj in ipairs(activeSynergiesFolder:GetChildren()) do

		local def = SynergyRegistry.Definitions[valueObj.Name]
		if not def then continue end

		local item = Instance.new("Frame")
		item.Size = UDim2.new(0, 100, 0, 120)
		item.BackgroundTransparency = 1
		item.Parent = container

		-- ORB
		local orb = Instance.new("ImageLabel")
		orb.Size = UDim2.new(0, 70, 0, 70)
		orb.Position = UDim2.new(0.5, -35, 0, 0)
		orb.BackgroundTransparency = 1
		orb.Image = def.Image
		orb.Parent = item

		local aspect = Instance.new("UIAspectRatioConstraint")
		aspect.AspectRatio = 1
		aspect.Parent = orb

		-- NAME
		local nameLabel = Instance.new("TextLabel")
		nameLabel.Size = UDim2.new(1, 0, 0, 22)
		nameLabel.Position = UDim2.new(0, 0, 0, 70)
		nameLabel.BackgroundTransparency = 1
		nameLabel.TextScaled = true
		nameLabel.Font = Enum.Font.Merriweather
		nameLabel.TextColor3 = Color3.fromRGB(226,197,33)
		nameLabel.Text = def.DisplayName
		nameLabel.Parent = item

		-- LEVEL
		local levelLabel = Instance.new("TextLabel")
		levelLabel.Size = UDim2.new(1, 0, 0, 20)
		levelLabel.Position = UDim2.new(0, 0, 0, 92)
		levelLabel.BackgroundTransparency = 1
		levelLabel.TextScaled = true
		levelLabel.Font = Enum.Font.Merriweather
		levelLabel.TextColor3 = Color3.new(1,1,1)
		levelLabel.Text = "Level "..tostring(valueObj.Value or 1)
		levelLabel.Parent = item
	end
end

local function renderUnlockedSynergies(main)

	local container =
		main.SynergiesEquippedUnlockedContainer
		.SynergiesUnlockedContainer
		.SynergiesUnlockedFrame

	-- limpar anterior
	for _, child in ipairs(container:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end

	local discovered = {}

	local success, result = pcall(function()
		return GetDiscoveredSynergies:InvokeServer()
	end)

	if success and type(result) == "table" then
		discovered = result
	end

	for synergyId, isUnlocked in pairs(discovered) do

		if not isUnlocked then continue end

		local def = SynergyRegistry.Definitions[synergyId]
		if not def then continue end

		local item = Instance.new("Frame")
		item.Size = UDim2.new(0, 110, 0, 110)
		item.BackgroundTransparency = 1
		item.Parent = container

		-- layout vertical
		local layout = Instance.new("UIListLayout")
		layout.FillDirection = Enum.FillDirection.Vertical
		layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		layout.VerticalAlignment = Enum.VerticalAlignment.Center
		layout.Padding = UDim.new(0.02,0)
		layout.Parent = item

		-- ORB
		local orb = Instance.new("ImageLabel")
		orb.Size = UDim2.new(0, 70, 0, 70)
		orb.BackgroundTransparency = 1
		orb.Image = def.Image
		orb.Parent = item

		local aspect = Instance.new("UIAspectRatioConstraint")
		aspect.AspectRatio = 1
		aspect.Parent = orb

		-- NAME
		local nameLabel = Instance.new("TextLabel")
		nameLabel.Size = UDim2.new(1, 0, 0, 22)
		nameLabel.BackgroundTransparency = 1
		nameLabel.TextScaled = true
		nameLabel.Font = Enum.Font.Merriweather
		nameLabel.TextColor3 = Color3.fromRGB(226,197,33)
		nameLabel.Text = def.DisplayName
		nameLabel.Parent = item

		-- NEW LABEL
		local newLabel = Instance.new("TextLabel")
		newLabel.Size = UDim2.new(1, 0, 0, 18)
		newLabel.BackgroundTransparency = 1
		newLabel.TextScaled = true
		newLabel.Font = Enum.Font.Merriweather
		newLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
		newLabel.Text = "*NEW*"
		newLabel.Parent = item
	end
end

local ATTRIBUTE_ORDER = {
	"Damage","Cooldown","Range","ProjectileSpeed","AttackSize","MovementSpeed",
	"MultiAttack","ProjectilePierce","AreaDamage",
	"Shield","ShieldRegenDelay",
	"MaxHP","LifeRegen","Luck"
}

local function renderFinalAttributes(main)

	local frame =
		main.FinalAttributesStatsContainer
		.FinalAttributesStatsFrame

	-- limpar
	for _, child in ipairs(frame:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end

	for _, attrName in ipairs(ATTRIBUTE_ORDER) do

		local registryData = AttributeCardRegistry[attrName]
		if not registryData then continue end

		local statValue = attributesFolder:FindFirstChild(attrName)
		local bonusValue = synergyBonuses:FindFirstChild(attrName)
		local levelValue = attributeLevels:FindFirstChild(attrName)

		local baseStat = statValue and statValue.Value or 0
		local bonusStat = bonusValue and bonusValue.Value or 0
		local finalStat = baseStat + bonusStat
		local level = levelValue and levelValue.Value or 0

		-- ROW
		local row = Instance.new("Frame")
		row.Size = UDim2.new(1, -6, 0, 34)
		row.BackgroundTransparency = 1
		row.Parent = frame

		-- ICON
		local icon = Instance.new("ImageLabel")
		icon.Size = UDim2.new(0, 25, 0, 28)
		icon.Position = UDim2.new(0, 6, 0.5, -14)
		icon.BackgroundTransparency = 1
		icon.Image = registryData.Image
		icon.Parent = row

		local aspect = Instance.new("UIAspectRatioConstraint")
		aspect.AspectRatio = 9/16
		aspect.Parent = icon

		-- FORMAT VALUE (mesma lógica do pause)

		local formattedValue = ""

		if attrName == "Cooldown" then
			local percent = (1 - finalStat) * 100
			formattedValue = string.format("-%d%%", percent)

		elseif attrName == "ShieldRegenDelay" then
			formattedValue = tostring(math.floor(finalStat)) .. "s"

		elseif attrName == "MultiAttack"
			or attrName == "ProjectilePierce"
			or attrName == "Shield"
			or attrName == "LifeRegen" then

			formattedValue = tostring(math.floor(finalStat))

		elseif attrName == "AreaDamage"
			or attrName == "Luck" then

			formattedValue = string.format("+%d%%", finalStat * 100)

		else
			local percent = (finalStat - 1) * 100
			formattedValue = string.format("+%d%%", percent)
		end

		-- TEXT
		local textLabel = Instance.new("TextLabel")
		textLabel.Size = UDim2.new(1, -40, 1, 0)
		textLabel.Position = UDim2.new(0, 32, 0, 0)
		textLabel.BackgroundTransparency = 1
		textLabel.TextXAlignment = Enum.TextXAlignment.Left
		textLabel.TextYAlignment = Enum.TextYAlignment.Center
		textLabel.Font = Enum.Font.Merriweather
		textLabel.TextSize = 25
		textLabel.Text =
			registryData.DisplayName ..
			"  |  Level " .. level ..
			"  |  " .. formattedValue

		-- 🔥 COR SE TIVER SINERGIA
		if math.abs(bonusStat) > 0.0001 then
			textLabel.TextColor3 = Color3.fromRGB(120,255,120)
		else
			textLabel.TextColor3 = Color3.fromRGB(226,197,33)
		end

		textLabel.Parent = row
	end

	local layout = frame:FindFirstChildOfClass("UIListLayout")

	if layout then
		layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			frame.CanvasSize =
				UDim2.new(0,0,0,layout.AbsoluteContentSize.Y + 6)
		end)

		frame.CanvasSize =
			UDim2.new(0,0,0,layout.AbsoluteContentSize.Y + 6)
	end
end

ShowSummaryScreen.OnClientEvent:Connect(function(stats)

	summaryGui.Enabled = true

	local main = summaryGui.MainFrame

	main.EnemiesContainer.EnemiesDefeatedFrame.EnemiesDefeatedText.Text =
		"ENEMIES DEFEATED: "..stats.EnemiesKilled

	main.EnemiesContainer.BossesDefeatedFrame.BossesDefeatedText.Text =
		"BOSSES DEFEATED: "..stats.BossesKilled
	
	local goldContainer = main.GoldCollectedContainer
	local totalGold = stats.TotalGold or stats.Gold or 0
	
	goldContainer.GoldCollectedText.Text =
		"YOU'VE COLLECTED: "..tostring(totalGold).." GOLD"
	
	local main = summaryGui:WaitForChild("MainFrame")
	local level = stats.Level or 1

	main.LevelReachedContainer
		.LevelReachedText.Text =
		"LEVEL REACHED: "..tostring(level)
	
	local formattedTime = formatTime(stats.TimeSurvived)

	main.MatchDurationContainer
		.MatchDurationFrame
		.MatchDurationText.Text =
		"MATCH DURATION: "..formattedTime
	
	renderWeaponsSummary(main)
	renderSynergiesSummary(main)
	renderUnlockedSynergies(main)
	renderFinalAttributes(main)
	
	local mainMenuButton =
		summaryGui.MainFrame.MainMenuContainer:WaitForChild("MainMenuButton")

	mainMenuButton.MouseButton1Click:Connect(function()

		summaryGui.Enabled = false

		ReturnToMenu:FireServer()

		player.PlayerGui.MainMenu.Enabled = true

	end)
	
end)