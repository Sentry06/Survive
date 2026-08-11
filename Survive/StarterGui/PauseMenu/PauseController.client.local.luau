-------------------------------------------------
-- SERVICES
-------------------------------------------------

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera

local MIN_LAYOUT_WIDTH = 1400

local function isMobileLayout()
	local viewport = Camera.ViewportSize
	return viewport.X < 1100
end

-------------------------------------------------
-- BUTTON HOVER EFFECT
-------------------------------------------------

local function applyButtonEffects(button)

	local originalColor = button.BackgroundColor3

	button.MouseEnter:Connect(function()
		TweenService:Create(
			button,
			TweenInfo.new(0.15),
			{
				BackgroundColor3 = Color3.fromRGB(226, 197, 33)
			}
		):Play()
	end)

	button.MouseLeave:Connect(function()
		TweenService:Create(
			button,
			TweenInfo.new(0.15),
			{
				BackgroundColor3 = originalColor
			}
		):Play()
	end)
end

-------------------------------------------------
-- GUI REFERENCES
-------------------------------------------------

local PauseMenu = PlayerGui:WaitForChild("PauseMenu")
local MainFrame = PauseMenu:WaitForChild("MainFrame")
local MainStroke = MainFrame:FindFirstChildOfClass("UIStroke")
local Title = MainFrame:WaitForChild("Title")

task.spawn(function()
	while true do
		TweenService:Create(
			Title,
			TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
			{Position = Title.Position - UDim2.new(0,0,0,5)}
		):Play()

		task.wait(2)

		TweenService:Create(
			Title,
			TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
			{Position = Title.Position + UDim2.new(0,0,0,5)}
		):Play()

		task.wait(2)
	end
end)

local MainScale = MainFrame:WaitForChild("UIScale")

local WeaponsFrameContainer = MainFrame:WaitForChild("WeaponsFrameContainer")
local SynergiesActiveContainer = MainFrame:WaitForChild("SynergiesActiveContainer")
local GoldFrameContainer = MainFrame:WaitForChild("GoldFrameContainer")
local AttributesListContainer = MainFrame:WaitForChild("AttributesListContainer")
local CatalogFrameContainer = MainFrame:WaitForChild("CatalogFrameContainer")

local AttributesFrame = AttributesListContainer:WaitForChild("AttributesFrame")
local CatalogFrame = CatalogFrameContainer:WaitForChild("CatalogFrame")
local GoldFrame = GoldFrameContainer:WaitForChild("GoldFrame")
local SynergiesActive = SynergiesActiveContainer:WaitForChild("SynergiesActive")
local WeaponsFrame = WeaponsFrameContainer:WaitForChild("WeaponsFrame")

local ContinueButton = MainFrame:WaitForChild("ContinueButton")
local DarkOverlay = PauseMenu:WaitForChild("DarkOverlay")
-------------------------------------------------
-- REGISTRIES
-------------------------------------------------
local Shared = ReplicatedStorage:WaitForChild("Shared")

local AttributeRegistry = require(Shared:WaitForChild("AttributeCardRegistry"))
local SynergyRegistry = require(Shared:WaitForChild("SynergyRegistry"))
local WeaponRegistry = require(Shared:WaitForChild("WeaponRegistry"))

-------------------------------------------------
-- REMOTES
-------------------------------------------------
local WeaponsUpdated = Remotes:WaitForChild("WeaponsUpdated")

local GetDiscoveredSynergies = Remotes:WaitForChild("GetDiscoveredSynergies")
local SynergiesUpdated = Remotes:WaitForChild("SynergiesUpdated")
local SynergyUnlocked = Remotes:WaitForChild("SynergyUnlocked")

-------------------------------------------------
-- CONFIG
-------------------------------------------------

local GOLD_COLOR = Color3.fromRGB(201,163,63)
local GOLD_LIGHT = Color3.fromRGB(230,200,120)

local ATTRIBUTE_ORDER = {
	"Damage","Cooldown","Range","ProjectileSpeed","AttackSize",
	"MovementSpeed","MultiAttack","ProjectilePierce","AreaDamage",
	"Shield","ShieldRegenDelay","MaxHP","LifeRegen","Luck"
}

-------------------------------------------------
-- RUNTIME REFERENCES
-------------------------------------------------

local matchStats = player:WaitForChild("MatchStats")
local attributesFolder = matchStats:WaitForChild("Attributes")
local attributeLevels = matchStats:WaitForChild("AttributeLevels")
local activeSynergiesFolder = matchStats:WaitForChild("ActiveSynergies")
local synergyBonuses = attributesFolder.Parent:WaitForChild("SynergyBonuses")

-------------------------------------------------
-- UTILS
-------------------------------------------------

local function clearFrame(frame)
	for _, child in ipairs(frame:GetChildren()) do
		if not child:IsA("UIGridLayout")
			and not child:IsA("UIListLayout")
			and not child:IsA("UICorner")
			and not child:IsA("UIStroke") then
			child:Destroy()
		end
	end
end

local function getSafeViewportWidth()
	local width = workspace.CurrentCamera.ViewportSize.X
	return math.max(width, MIN_LAYOUT_WIDTH)
end

-------------------------------------------------
-- RENDER GOLD
-------------------------------------------------

local function renderGold()

	local goldValue = matchStats:FindFirstChild("Gold")
	if not goldValue then return end

	GoldFrame.GoldValue.Text = tostring(goldValue.Value)

	local goldicon = GoldFrame:FindFirstChild("GoldIcon")

	goldValue:GetPropertyChangedSignal("Value"):Connect(function()
		GoldFrame.GoldValue.Text = tostring(goldValue.Value)
	end)
end

-------------------------------------------------
-- RENDER ATTRIBUTES (VERTICAL LIST - FINAL)
-------------------------------------------------

local function renderAttributes()

	clearFrame(AttributesFrame)

	for _, attrName in ipairs(ATTRIBUTE_ORDER) do

		local registryData = AttributeRegistry[attrName]
		if not registryData then continue end

		local levelValue = attributeLevels:FindFirstChild(attrName)
		local statValue = attributesFolder:FindFirstChild(attrName)
		local bonusValue = synergyBonuses:FindFirstChild(attrName)

		local baseStat = statValue and statValue.Value or 0
		local bonusStat = bonusValue and bonusValue.Value or 0
		local level = levelValue and levelValue.Value or 0

		local finalStat = baseStat + bonusStat

		-- LINHA PRINCIPAL
		local row = Instance.new("Frame")
		row.Size = UDim2.new(1, -6, 0, 34)
		row.BackgroundTransparency = 1
		row.Parent = AttributesFrame

		-- BORDA INFERIOR DOURADA
		local divider = Instance.new("Frame")
		divider.Size = UDim2.new(1, -6, 0, 1)
		divider.Position = UDim2.new(0, 3, 1, -1)
		divider.BackgroundColor3 = GOLD_COLOR
		divider.BorderSizePixel = 0
		divider.BackgroundTransparency = 0.4
		divider.Parent = row

		-- ÍCONE (pequeno)
		local icon = Instance.new("ImageLabel")
		icon.Size = UDim2.new(0, 20, 0, 28)
		icon.Position = UDim2.new(0, 6, 0.5, -14)
		icon.BackgroundTransparency = 1
		icon.Image = registryData.Image
		icon.Parent = row

		local aspect = Instance.new("UIAspectRatioConstraint")
		aspect.AspectRatio = 9/16
		aspect.Parent = icon

		-------------------------------------------------
		-- FORMAT ATTRIBUTE VALUE (FINAL VERSION)
		-------------------------------------------------

		local BASE_ONE_PERCENT = {
			Damage = true,
			Range = true,
			ProjectileSpeed = true,
			AttackSize = true,
			MovementSpeed = true,
			MaxHP = true,
		}

		local ZERO_BASE_PERCENT = {
			AreaDamage = true,
			Luck = true,
		}

		local NEGATIVE_PERCENT = {
			Cooldown = true,
		}

		local INTEGER_ATTRS = {
			MultiAttack = true,
			ProjectilePierce = true,
			Shield = true,
			LifeRegen = true,
		}

		local formattedValue = ""

		if BASE_ONE_PERCENT[attrName] then

			local percent = math.floor((finalStat - 1) * 100 + 0.5)
			formattedValue = "+" .. percent .. "%"

		elseif ZERO_BASE_PERCENT[attrName] then

			local percent = math.floor(finalStat * 100 + 0.5)
			formattedValue = string.format("+%d%%", percent)

		elseif NEGATIVE_PERCENT[attrName] then

			local percent = math.floor((1 - finalStat) * 100 + 0.5)
			formattedValue = string.format("-%d%%", percent)

		elseif attrName == "ShieldRegenDelay" then

			formattedValue = tostring(math.floor(finalStat)) .. "s"

		elseif INTEGER_ATTRS[attrName] then

			formattedValue = tostring(math.floor(finalStat))

		else
			formattedValue = tostring(finalStat)
		end

		-- TEXTO DO ATRIBUTO
		local textLabel = Instance.new("TextLabel")
		textLabel.Size = UDim2.new(1, -40, 1, 0)
		textLabel.Position = UDim2.new(0, 32, 0, 0)
		textLabel.BackgroundTransparency = 1
		textLabel.TextXAlignment = Enum.TextXAlignment.Left
		textLabel.TextYAlignment = Enum.TextYAlignment.Center
		textLabel.Font = Enum.Font.Merriweather
		textLabel.TextSize = 14
		if math.abs(bonusStat) > 0 then
			textLabel.TextColor3 = Color3.fromRGB(120, 255, 120) -- verde mágico
		else
			textLabel.TextColor3 = Color3.fromRGB(230,200,120) -- dourado padrão
		end
		textLabel.Text = registryData.DisplayName ..
			" :  Level " .. level ..
			"   -   " .. formattedValue
		textLabel.Parent = row
	end

	local layout = AttributesFrame:FindFirstChildOfClass("UIListLayout")

	if layout then
		layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			AttributesFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 6)
		end)

		-- força atualizar uma vez
		AttributesFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 6)
	end
end

-------------------------------------------------
-- WEAPON SYSTEM
-------------------------------------------------

local equippedWeapons = {}
local weaponsInitialized = false

local function renderWeapons()

	clearFrame(WeaponsFrame)

	for _, data in ipairs(equippedWeapons) do

		local weaponDef = WeaponRegistry.Definitions[data.Name]
		if not weaponDef then continue end

		local container = Instance.new("Frame")
		container.Size = UDim2.new(0, 55, 0, 70)
		container.BackgroundTransparency = 1
		container.Parent = WeaponsFrame

		local icon = Instance.new("ImageLabel")
		icon.Size = UDim2.new(0, 45, 0, 45)
		icon.Position = UDim2.new(0.5, -22, 0, 5)
		icon.BackgroundTransparency = 1
		icon.Image = weaponDef.Image
		icon.Parent = container

		local levelLabel = Instance.new("TextLabel")
		levelLabel.Size = UDim2.new(1, 0, 0, 18)
		levelLabel.Position = UDim2.new(0, 0, 0, 40)
		levelLabel.BackgroundTransparency = 1
		levelLabel.TextScaled = true
		levelLabel.Font = Enum.Font.Merriweather
		levelLabel.TextColor3 = GOLD_COLOR
		levelLabel.Text = "Level " .. tostring(data.Level or 1)
		levelLabel.Parent = container
	end
end

WeaponsUpdated.OnClientEvent:Connect(function(data)

	if type(data) ~= "table" then return end

	equippedWeapons = data
	weaponsInitialized = true
	renderWeapons()
end)

local GetCurrentWeapons = Remotes:WaitForChild("GetCurrentWeapons")

-- força sincronização inicial
task.spawn(function()
	local success, result = pcall(function()
		return GetCurrentWeapons:InvokeServer()
	end)

	if success and type(result) == "table" then
		equippedWeapons = result
		renderWeapons()
	end
end)

-------------------------------------------------
-- ATTRIBUTE FORMATTER (REUTILIZÁVEL)
-------------------------------------------------

local BASE_ONE_PERCENT = {
	Damage = true,
	Range = true,
	ProjectileSpeed = true,
	AttackSize = true,
	MovementSpeed = true,
	MaxHP = true,
}

local ZERO_BASE_PERCENT = {
	AreaDamage = true,
	Luck = true,
}

local NEGATIVE_PERCENT = {
	Cooldown = true,
}

local INTEGER_ATTRS = {
	MultiAttack = true,
	ProjectilePierce = true,
	Shield = true,
	LifeRegen = true,
}

local function formatSignedPercent(value)
	local rounded = math.floor(value + 0.5)

	if rounded >= 0 then
		return string.format("+%d%%", rounded)
	else
		return string.format("-%d%%", math.abs(rounded))
	end
end

local function formatSignedInteger(value)
	local rounded = math.floor(value + 0.5)

	if rounded >= 0 then
		return "+" .. rounded
	else
		return tostring(rounded)
	end
end

local function formatAttributeValue(attrName, stat)

	-- atributos que já são percentuais diretos
	if BASE_ONE_PERCENT[attrName] then
		return formatSignedPercent(stat * 100)

	elseif ZERO_BASE_PERCENT[attrName] then
		return formatSignedPercent(stat * 100)

	elseif NEGATIVE_PERCENT[attrName] then
		return formatSignedPercent(stat * 100)

	elseif attrName == "ShieldRegenDelay" then
		return tostring(math.floor(stat)) .. "s"

	elseif INTEGER_ATTRS[attrName] then
		return formatSignedInteger(stat)

	else
		return tostring(stat)
	end
end
-------------------------------------------------
-- ORDEM FIXA DAS SINERGIAS
-------------------------------------------------

local SYNERGY_ORDER = {
	--Tier 1--
	"IgniferAeternum",
	"MareVastum",
	"AstrumPenetratio",
	"CeleritasDivina",
	"UmbraVitalis",
	"AegisPerpetua",
	"FortunaMajor",
	"MagnusOrbis",
	"VelocitasAstra",
	"TempusDominus",
	--Tier 2--
	"Cataclysmus",
	"Hypernova",
	"Eternitas",
	"ChaosFortuna",
	"Tempestas",
	--Tier 3--
	"DeusExMachina",
	"Singularitas",
	"ApexPredator",
	"Immortalis",
	"CosmosAbsolutum"
}

local DiscoveredSynergies = {}
-------------------------------------------------
-- RENDER CATALOG (ESTÁVEL E RESPONSIVO)
-------------------------------------------------

DiscoveredSynergies = GetDiscoveredSynergies:InvokeServer()

local function renderCatalog()

	clearFrame(CatalogFrame)

	-- Layout vertical do Catalog
	local catalogLayout = CatalogFrame:FindFirstChildOfClass("UIListLayout")

	if not catalogLayout then
		catalogLayout = Instance.new("UIListLayout")
		catalogLayout.Padding = UDim.new(0,15)
		catalogLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		catalogLayout.Parent = CatalogFrame
	end

	catalogLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		CatalogFrame.CanvasSize = UDim2.new(0,0,0,catalogLayout.AbsoluteContentSize.Y + 20)
	end)

	local TIERS = {1,2,3}

	for _, tier in ipairs(TIERS) do

		---------------------------------------
		-- TIER TITLE
		---------------------------------------

		local tierLabel = Instance.new("TextLabel")
		tierLabel.Size = UDim2.new(1,-20,0,40)
		tierLabel.BackgroundTransparency = 1
		tierLabel.Font = Enum.Font.Merriweather
		tierLabel.TextScaled = true
		tierLabel.TextColor3 = Color3.fromRGB(226,197,33)
		tierLabel.Text = "TIER " .. tier
		tierLabel.Parent = CatalogFrame

		---------------------------------------
		-- LOOP SYNERGIES
		---------------------------------------

		for _, synergyName in ipairs(SYNERGY_ORDER) do

			local def = SynergyRegistry.Definitions[synergyName]
			if not def then continue end
			if def.Tier ~= tier then continue end

			local discovered = DiscoveredSynergies[synergyName]

			---------------------------------------
			-- MAIN CONTAINER
			---------------------------------------

			local container = Instance.new("Frame")
			container.Size = UDim2.new(1,-20,0,200)
			container.BackgroundColor3 = Color3.fromRGB(25,18,12)
			container.BackgroundTransparency = 0.1
			container.Parent = CatalogFrame
			
			local rowLayout = Instance.new("UIListLayout")
			rowLayout.FillDirection = Enum.FillDirection.Horizontal
			rowLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
			rowLayout.VerticalAlignment = Enum.VerticalAlignment.Center
			rowLayout.Parent = container

			Instance.new("UIStroke", container).Color = GOLD_COLOR

			local padding = Instance.new("UIPadding")
			padding.PaddingLeft = UDim.new(0.02,0)
			padding.PaddingRight = UDim.new(0.02,0)
			padding.PaddingTop = UDim.new(0.08,0)
			padding.PaddingBottom = UDim.new(0.08,0)
			padding.Parent = container

			---------------------------------------
			-- ATTRIBUTES COLUMN (60%)
			---------------------------------------

			local attributesFrame = Instance.new("Frame")
			attributesFrame.Size = UDim2.fromScale(0.6,1)
			attributesFrame.BackgroundTransparency = 1
			attributesFrame.Parent = container

			local attrLayout = Instance.new("UIListLayout")
			attrLayout.FillDirection = Enum.FillDirection.Horizontal
			attrLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
			attrLayout.VerticalAlignment = Enum.VerticalAlignment.Center
			attrLayout.Padding = UDim.new(0.02,0)
			attrLayout.Parent = attributesFrame

			---------------------------------------
			-- EQUAL COLUMN (5%)
			---------------------------------------

			local equalFrame = Instance.new("Frame")
			equalFrame.Size = UDim2.fromScale(0.05,1)
			equalFrame.BackgroundTransparency = 1
			equalFrame.Parent = container

			local equal = Instance.new("TextLabel")
			equal.Size = UDim2.fromScale(1,1)
			equal.BackgroundTransparency = 1
			equal.Text = "="
			equal.TextScaled = true
			equal.Font = Enum.Font.Merriweather
			equal.TextColor3 = GOLD_COLOR
			equal.Parent = equalFrame

			---------------------------------------
			-- RESULT COLUMN (35%)
			---------------------------------------

			local synergyFrame = Instance.new("Frame")
			synergyFrame.Size = UDim2.fromScale(0.35,1)
			synergyFrame.BackgroundTransparency = 1
			synergyFrame.Parent = container
			
			---------------------------------------
			-- BLOCO DE ATRIBUTOS (ESTÁVEL)
			---------------------------------------

			local requiresList = {}

			for attrName, level in pairs(def.Requires) do
				table.insert(requiresList, {
					Name = attrName,
					Level = level
				})
			end

			table.sort(requiresList, function(a,b)
				return a.Name < b.Name
			end)

			---------------------------------------
			-- LAYOUT PROPORCIONAL INTELIGENTE
			---------------------------------------

			local attrCount = #requiresList
			local plusCount = attrCount - 1

			-- Pesos relativos
			local CARD_WEIGHT = 1
			local PLUS_WEIGHT = 0.35

			local totalWeight = (attrCount * CARD_WEIGHT) + (plusCount * PLUS_WEIGHT)

			for i, data in ipairs(requiresList) do

				-- LARGURA DA CARTA
				local cardWidthScale = (CARD_WEIGHT / totalWeight)
				
				-- CRIA CARD SLOT
				local cardSlot = Instance.new("Frame")
				cardSlot.Size = UDim2.fromScale(cardWidthScale, 1)
				cardSlot.BackgroundTransparency = 1
				cardSlot.Parent = attributesFrame

				-- 🔥 Layout vertical centralizado
				local verticalLayout = Instance.new("UIListLayout")
				verticalLayout.FillDirection = Enum.FillDirection.Vertical
				verticalLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
				verticalLayout.VerticalAlignment = Enum.VerticalAlignment.Center
				verticalLayout.Padding = UDim.new(0.02,0)
				verticalLayout.Parent = cardSlot

				local attrData = AttributeRegistry[data.Name]
				if not attrData then continue end

				-- NOME (EM CIMA)
				local nameTop = Instance.new("TextLabel")
				nameTop.Size = UDim2.fromScale(1, 0.18)
				nameTop.BackgroundTransparency = 1
				nameTop.TextScaled = true
				nameTop.Font = Enum.Font.Merriweather
				nameTop.TextColor3 = GOLD_LIGHT
				nameTop.Text = discovered and attrData.DisplayName or "???"
				nameTop.Parent = cardSlot

				-- CARTA
				local icon = Instance.new("ImageLabel")
				icon.Size = UDim2.fromScale(0.75, 0.55)
				icon.BackgroundTransparency = 1
				icon.Image = discovered and attrData.Image or ""
				icon.Parent = cardSlot

				local aspect = Instance.new("UIAspectRatioConstraint")
				aspect.AspectRatio = 9/16
				aspect.Parent = icon

				-- LEVEL
				local levelBottom = Instance.new("TextLabel")
				levelBottom.Size = UDim2.fromScale(1, 0.18)
				levelBottom.BackgroundTransparency = 1
				levelBottom.TextScaled = true
				levelBottom.Font = Enum.Font.Merriweather
				levelBottom.TextColor3 = GOLD_COLOR
				levelBottom.Text = discovered and ("Level "..data.Level) or "???"
				levelBottom.Parent = cardSlot
				

				-- SLOT DO "+"
				if i < attrCount then

					local plusWidthScale = (PLUS_WEIGHT / totalWeight)

					local plusSlot = Instance.new("Frame")
					plusSlot.Size = UDim2.fromScale(plusWidthScale, 1)
					plusSlot.BackgroundTransparency = 1
					plusSlot.Parent = attributesFrame

					local plus = Instance.new("TextLabel")
					plus.Size = UDim2.fromScale(1,1)
					plus.BackgroundTransparency = 1
					plus.Text = "+"
					plus.TextScaled = true
					plus.Font = Enum.Font.Merriweather
					plus.TextColor3 = GOLD_COLOR
					plus.Parent = plusSlot

				end
			end

			---------------------------------------
			-- RESULT BLOCK
			---------------------------------------

			local synergyNameLabel = Instance.new("TextLabel")
			synergyNameLabel.Size = UDim2.new(1,0,0,30)
			synergyNameLabel.BackgroundTransparency = 1
			synergyNameLabel.TextScaled = true
			synergyNameLabel.Font = Enum.Font.Merriweather
			synergyNameLabel.TextColor3 = GOLD_LIGHT
			synergyNameLabel.Text = discovered and def.DisplayName or "???"
			synergyNameLabel.Parent = synergyFrame

			local orb = Instance.new("ImageLabel")
			orb.Size = UDim2.new(0,90,0,90)
			orb.Position = UDim2.new(0.5,-45,0,30)
			orb.BackgroundTransparency = 1
			orb.Image = discovered and def.Image or ""
			orb.Parent = synergyFrame

			local orbAspect = Instance.new("UIAspectRatioConstraint")
			orbAspect.AspectRatio = 1
			orbAspect.Parent = orb

			local bonusText = ""
			for attr,value in pairs(def.Bonuses or {}) do
				bonusText ..= attr.." "..formatAttributeValue(attr,value).."\n"
			end

			local bonusLabel = Instance.new("TextLabel")
			bonusLabel.Size = UDim2.new(1,0,0,50)
			bonusLabel.Position = UDim2.new(0,0,0,125)
			bonusLabel.BackgroundTransparency = 1
			bonusLabel.TextWrapped = true
			bonusLabel.TextScaled = true
			bonusLabel.Font = Enum.Font.Merriweather
			bonusLabel.TextColor3 = GOLD_COLOR
			bonusLabel.Text = discovered and bonusText or "Unknown Combination"
			bonusLabel.Parent = synergyFrame
		end
	end
end
-------------------------------------------------
-- RENDER ACTIVE SYNERGIES
-------------------------------------------------

local function renderActiveSynergies()

	clearFrame(SynergiesActive)

	for _, valueObj in ipairs(activeSynergiesFolder:GetChildren()) do

		local def = SynergyRegistry.Definitions[valueObj.Name]
		if not def then continue end

		local container = Instance.new("Frame")
		container.Size = UDim2.new(1,-10,0,60)
		container.BackgroundTransparency = 1
		container.Parent = SynergiesActive

		local icon = Instance.new("ImageLabel")
		icon.Size = UDim2.new(0,50,0,50)
		icon.Position = UDim2.new(0,5,0,5)
		icon.BackgroundTransparency = 1
		icon.Image = def.Image
		icon.Parent = container

		local nameLabel = Instance.new("TextLabel")
		nameLabel.Size = UDim2.new(1,-60,1,0)
		nameLabel.Position = UDim2.new(0,60,0,0)
		nameLabel.BackgroundTransparency = 1
		nameLabel.TextScaled = true
		nameLabel.Font = Enum.Font.Merriweather
		nameLabel.TextColor3 = GOLD_LIGHT
		nameLabel.Text = def.DisplayName.." Lv "..valueObj.Value
		nameLabel.Parent = container

		local layout = SynergiesActive:FindFirstChildOfClass("UIListLayout")

		if not SynergiesActive:FindFirstChildOfClass("UIListLayout") then
			local layout = Instance.new("UIListLayout")
			layout.Padding = UDim.new(0,8)
			layout.Parent = SynergiesActive
		end

		local activeLayout = SynergiesActive:FindFirstChildOfClass("UIListLayout")

		activeLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			SynergiesActive.CanvasSize =
				UDim2.new(0,0,0,activeLayout.AbsoluteContentSize.Y + 10)
		end)
	end
end

-------------------------------------------------
-- SYNERGY AUTO UPDATE LISTENERS
-------------------------------------------------

activeSynergiesFolder.ChildAdded:Connect(function(child)
	renderActiveSynergies()

	-- Atualiza quando nível mudar
	child:GetPropertyChangedSignal("Value"):Connect(renderActiveSynergies)
end)

activeSynergiesFolder.ChildRemoved:Connect(renderActiveSynergies)

-- Conecta também para sinergias já existentes
for _, child in ipairs(activeSynergiesFolder:GetChildren()) do
	child:GetPropertyChangedSignal("Value"):Connect(renderActiveSynergies)
end

SynergiesUpdated.OnClientEvent:Connect(function()
	renderActiveSynergies()
end)

SynergyUnlocked.OnClientEvent:Connect(function(data)

	-- Atualiza no servidor novamente
	local updated = GetDiscoveredSynergies:InvokeServer()
	DiscoveredSynergies = updated

	renderCatalog()
end)

-------------------------------------------------
-- MENU OPEN ANIMATION
-------------------------------------------------
local originalPosition = MainFrame.Position

local function animateMenuOpen()

	MainFrame.Position = originalPosition - UDim2.new(0,0,0,40)
	MainFrame.BackgroundTransparency = 1
	MainScale.Scale = 0.92

	local slideTween = TweenService:Create(
		MainFrame,
		TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{Position = originalPosition, BackgroundTransparency = 0}
	)

	local scaleTween = TweenService:Create(
		MainScale,
		TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{Scale = 1}
	)

	slideTween:Play()
	scaleTween:Play()
end

-------------------------------------------------
-- GOLD PULSE EFFECT
-------------------------------------------------

if MainStroke then
	task.spawn(function()
		while true do
			TweenService:Create(
				MainStroke,
				TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
				{Transparency = 0.2}
			):Play()

			task.wait(1.2)

			TweenService:Create(
				MainStroke,
				TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
				{Transparency = 0.6}
			):Play()

			task.wait(1.2)
		end
	end)
end

-------------------------------------------------
-- PAUSE BUTTON SYSTEM (CORRIGIDO)
-------------------------------------------------

local ContinueButton = MainFrame:WaitForChild("ContinueButton")
local PauseButtonGui = PlayerGui:WaitForChild("PauseButtonGui")
local PauseButton = PauseButtonGui:WaitForChild("PauseButton")
local TogglePause = Remotes:WaitForChild("TogglePause")

-- começa fechado
PauseMenu.Enabled = false

-------------------------------------------------
-- PAUSE BUTTON (ABRIR MENU E PAUSAR)
-------------------------------------------------

PauseButton.MouseButton1Click:Connect(function()

	PauseMenu.Enabled = true
	animateMenuOpen()
	TogglePause:FireServer(true)

end)

-------------------------------------------------
-- CONTINUE BUTTON (FECHAR MENU E DESPAUSAR)
-------------------------------------------------

ContinueButton.MouseButton1Click:Connect(function()

	-- fecha menu
	PauseMenu.Enabled = false

	-- despausa explicitamente
	TogglePause:FireServer(false)

end)

local EndRunButton = MainFrame:WaitForChild("EndRunButton")
local ConfirmFrame = PauseMenu:WaitForChild("ConfirmEndFrame")
local ConfirmButton = ConfirmFrame:WaitForChild("ConfirmButton")
local CancelButton = ConfirmFrame:WaitForChild("CancelButton")
local RequestEndRun = Remotes:WaitForChild("RequestEndRun")
local ConfirmScale = ConfirmFrame:WaitForChild("UIScale")

applyButtonEffects(ContinueButton)
applyButtonEffects(EndRunButton)
applyButtonEffects(ConfirmButton)
applyButtonEffects(CancelButton)

ConfirmFrame.Visible = false
DarkOverlay.Visible = false
DarkOverlay.BackgroundTransparency = 1
DarkOverlay.Active = true

-------------------------------------------------
-- OVERLAY EFFECT FUNCTIONS
-------------------------------------------------

local function fadeInOverlay()

	DarkOverlay.Visible = true
	DarkOverlay.BackgroundTransparency = 1

	local tween = TweenService:Create(
		DarkOverlay,
		TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{BackgroundTransparency = 0.4}
	)

	tween:Play()
end

local function fadeOutOverlay()

	local tween = TweenService:Create(
		DarkOverlay,
		TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{BackgroundTransparency = 1}
	)

	tween:Play()
	tween.Completed:Wait()

	DarkOverlay.Visible = false
end

-------------------------------------------------
-- CONFIRM POPUP ANIMATION
-------------------------------------------------

local function animateConfirmOpen()

	ConfirmScale.Scale = 0.8

	local tween = TweenService:Create(
		ConfirmScale,
		TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{Scale = 1}
	)

	tween:Play()
end

-------------------------------------------------
-- END RUN BUTTON (ABRE CONFIRMAÇÃO)
-------------------------------------------------

EndRunButton.MouseButton1Click:Connect(function()

	fadeInOverlay()
	ConfirmFrame.Visible = true
	animateConfirmOpen()

end)

-------------------------------------------------
-- CANCEL END RUN
-------------------------------------------------

CancelButton.MouseButton1Click:Connect(function()

	ConfirmFrame.Visible = false
	fadeOutOverlay()

end)

-------------------------------------------------
-- CONFIRM END RUN
-------------------------------------------------

ConfirmButton.MouseButton1Click:Connect(function()

	ConfirmFrame.Visible = false
	fadeOutOverlay()
	PauseMenu.Enabled = false

	RequestEndRun:FireServer()

end)

-------------------------------------------------
-- AUTO UPDATE SYSTEM
-------------------------------------------------

local function setupAttributeListeners()

	local matchStats = player:WaitForChild("MatchStats")
	local attributesFolder = matchStats:WaitForChild("Attributes")
	local levelsFolder = matchStats:WaitForChild("AttributeLevels")

	for _, attrName in ipairs(ATTRIBUTE_ORDER) do

		local statObj = attributesFolder:FindFirstChild(attrName)
		local levelObj = levelsFolder:FindFirstChild(attrName)

		if statObj then
			statObj:GetPropertyChangedSignal("Value"):Connect(function()
				renderAttributes()
			end)
		end

		if levelObj then
			levelObj:GetPropertyChangedSignal("Value"):Connect(function()
				renderAttributes()
			end)
		end
	end
end
-------------------------------------------------
-- INITIALIZE
-------------------------------------------------
setupAttributeListeners()
renderAttributes()
renderGold()
renderActiveSynergies()
renderCatalog()

print("ARCANUM CODEX UI READY")