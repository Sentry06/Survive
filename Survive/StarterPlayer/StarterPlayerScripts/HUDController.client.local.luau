-- HUDController.client
-- Reflete MatchStats no HUD (VERSÃO ESTÁVEL + TWEEN)

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer

-- =========================
-- DESATIVA UI PADRÃO ROBLOX
-- =========================
pcall(function()
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, false)
end)

-- =========================
-- FUNÇÃO DE TWEEN
-- =========================
local function tweenBar(fill, percent)

	if not fill then return end

	percent = math.clamp(percent,0,1)

	TweenService:Create(
		fill,
		TweenInfo.new(
			0.25,
			Enum.EasingStyle.Quad,
			Enum.EasingDirection.Out
		),
		{Size = UDim2.fromScale(percent,1)}
	):Play()

end

-- =========================
-- GUI
-- =========================
local gui = player:WaitForChild("PlayerGui"):WaitForChild("CombatGUI")
local root = gui:WaitForChild("Root")

local xpBar = root:WaitForChild("XPBar")
local xpFill = xpBar:WaitForChild("Fill")
local xpGlow = xpBar:WaitForChild("Glow")
local xpText = xpBar:WaitForChild("Text")

xpFill.BackgroundColor3 = Color3.fromRGB(170,0,255)
xpFill.AnchorPoint = Vector2.new(0,0)
xpFill.Position = UDim2.fromScale(0,0)

local bottomLeft = root:WaitForChild("BottomLeft")

local healthBar = bottomLeft:WaitForChild("HealthBar")
local healthFill = healthBar:WaitForChild("Fill")
local healthText = healthBar:WaitForChild("Text")

local shieldBar = bottomLeft:WaitForChild("ShieldBar")
local shieldFill = shieldBar:WaitForChild("Fill")
local shieldText = shieldBar:WaitForChild("Text")

local levelText = bottomLeft:WaitForChild("LevelText")
local goldContainer = bottomLeft:WaitForChild("GoldContainer")
local goldText = goldContainer:WaitForChild("Value")

-- =========================
-- DADOS
-- =========================
local matchStats = player:WaitForChild("MatchStats")
local attrs = matchStats:WaitForChild("Attributes")

local level = matchStats:WaitForChild("Level")
local xp = matchStats:WaitForChild("XP")
local xpToNext = matchStats:WaitForChild("XPToNext")
local gold = matchStats:WaitForChild("Gold")

local maxShield = attrs:WaitForChild("Shield")
local currentShield = attrs:FindFirstChild("CurrentShield")

if not currentShield then
	warn("⚠ CurrentShield não encontrado")
	return
end

-- =========================
-- HUMANOID
-- =========================
local humanoid

local healthConn
local maxHealthConn

-- =========================
-- UPDATE FUNCTIONS
-- =========================

local function updateHealth()

	if not humanoid then return end

	local ratio = humanoid.MaxHealth > 0 and humanoid.Health / humanoid.MaxHealth or 0

	tweenBar(healthFill,ratio)

	healthText.Text =
		string.format(
			"%d / %d",
			math.floor(humanoid.Health),
			math.floor(humanoid.MaxHealth)
		)

end


local function updateShield()

	local max = maxShield.Value
	local cur = currentShield.Value

	if max <= 0 then
		tweenBar(shieldFill,0)
		shieldText.Text = "0"
		return
	end

	local ratio = cur / max

	tweenBar(shieldFill,ratio)

	shieldText.Text = tostring(math.floor(cur))

end


local function updateXP()

	local ratio = xpToNext.Value > 0 and xp.Value / xpToNext.Value or 0

	tweenBar(xpFill,ratio)

	xpText.Text =
		string.format(
			"%d / %d",
			xp.Value,
			xpToNext.Value
		)

end


local function updateLevel()
	levelText.Text = "LEVEL "..level.Value
end


local function formatNumber(n)
	return tostring(n):reverse():gsub("(%d%d%d)","%1."):reverse():gsub("^%.","")
end


local function updateGold()

	goldText.Text = formatNumber(gold.Value)

	local tween = TweenService:Create(
		goldContainer,
		TweenInfo.new(0.1),
		{BackgroundTransparency = 1}
	)

	tween:Play()

	tween.Completed:Once(function()

		TweenService:Create(
			goldContainer,
			TweenInfo.new(0.3),
			{BackgroundTransparency = 1}
		):Play()

	end)

end

-- =========================
-- XP FLASH
-- =========================

local function flashXP()

	local tweenIn = TweenService:Create(
		xpGlow,
		TweenInfo.new(0.15),
		{BackgroundTransparency = 0.3}
	)

	local tweenOut = TweenService:Create(
		xpGlow,
		TweenInfo.new(0.3),
		{BackgroundTransparency = 1}
	)

	tweenIn:Play()

	tweenIn.Completed:Once(function()
		tweenOut:Play()
	end)

end


local lastXP = xp.Value

xp.Changed:Connect(function(newXP)

	if newXP > lastXP then
		flashXP()
	end

	lastXP = newXP

end)

-- =========================
-- HUMANOID BIND
-- =========================

local function bindHumanoid(char)

	humanoid = char:WaitForChild("Humanoid")

	humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff

	-- desconectar conexões antigas
	if healthConn then healthConn:Disconnect() end
	if maxHealthConn then maxHealthConn:Disconnect() end

	healthConn = humanoid.HealthChanged:Connect(updateHealth)
	maxHealthConn = humanoid:GetPropertyChangedSignal("MaxHealth"):Connect(updateHealth)

	updateHealth()

end


if player.Character then
	bindHumanoid(player.Character)
end

player.CharacterAdded:Connect(bindHumanoid)

-- =========================
-- CONEXÕES
-- =========================

xp.Changed:Connect(updateXP)
xpToNext.Changed:Connect(updateXP)

level.Changed:Connect(updateLevel)
gold.Changed:Connect(updateGold)

currentShield.Changed:Connect(updateShield)
maxShield.Changed:Connect(updateShield)

-- =========================
-- INIT
-- =========================

updateXP()
updateHealth()
updateShield()
updateLevel()
updateGold()

print("🧩 HUDController FINAL carregado com sucesso")