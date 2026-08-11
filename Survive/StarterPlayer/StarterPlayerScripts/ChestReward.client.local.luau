local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local WeaponRegistry = require(
	ReplicatedStorage.Shared:WaitForChild("WeaponRegistry")
)

local RewardEvent = Remotes:WaitForChild("ChestReward")
local CollectEvent = Remotes:WaitForChild("ChestCollect")

local gui = player.PlayerGui:WaitForChild("ChestGui")
local mainFrame = gui:WaitForChild("MainFrame")

local title = mainFrame:WaitForChild("Title")
local GoldContainer = mainFrame:WaitForChild("GoldContainer")
local goldLabel = GoldContainer:WaitForChild("GoldLabel")
local goldIcon = GoldContainer:WaitForChild("GoldIcon")
local rewardContainer = mainFrame:WaitForChild("RewardContainer")
local button = mainFrame:WaitForChild("CollectButton")

local uiStroke = mainFrame:FindFirstChildOfClass("UIStroke")

local TweenService = game:GetService("TweenService")

local AttributeFormatter = require(
	ReplicatedStorage.Shared:WaitForChild("AttributeFormatter")
)

local LevelUpFormatter = require(
	ReplicatedStorage.Shared:WaitForChild("LevelUpFormatter")
)

local UpgradePool = require(
	ReplicatedStorage.Shared:WaitForChild("UpgradePool")
)
local ATTRIBUTE_BALANCE = UpgradePool.ATTRIBUTE_BALANCE

local MULTIPLIER_ATTRS = {
	Damage = true,
	Cooldown = true,
	Range = true,
	ProjectileSpeed = true,
	AttackSize = true,
	MovementSpeed = true,
	MaxHP = true,
}

local ADDITIVE_ATTRS = {
	MultiAttack = true,
	ProjectilePierce = true,
	Shield = true,
	LifeRegen = true,
	Luck = true,
	AreaDamage = true,
}

local function roundNicePercent(n)

	local abs = math.abs(n)

	-- 🔥 valores pequenos NÃO arredondam
	if abs < 10 then
		return math.floor(abs + 0.5)
	end

	-- 🔥 valores grandes arredondam em 5
	return math.floor(abs / 5 + 0.5) * 5
end

local currentRewards = nil

gui.Enabled = false

-- =========================
-- LIMPAR REWARD CONTAINER
-- =========================

local function clearRewards()
	for _, child in ipairs(rewardContainer:GetChildren()) do
		if child:IsA("Frame") or child:IsA("TextLabel") then
			child:Destroy()
		end
	end
end

local function formatAttributeName(name)

	return name:gsub("(%l)(%u)", "%1 %2")

end

-- =========================
-- CRIAR LABEL DE REWARD
-- =========================

local function createRewardLabel(text, color)
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -10, 0, 35)
	label.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	label.TextColor3 = color or Color3.new(1,1,1)
	label.TextScaled = true
	label.Font = Enum.Font.Merriweather
	label.Text = text
	label.Parent = rewardContainer

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = label

end

-------------------------------------------------
-- 🔥 CALCULAR VALOR REAL DO CHEST (IGUAL SERVER)
-------------------------------------------------

local CHEST_COMPOSITION = {
	Bronze = {"Bronze"},
	Silver = {"Bronze", "Bronze"},
	Gold = {"Silver", "Silver", "Gold"},
	Diamond = {"Silver", "Silver", "Gold", "Gold", "Diamond"}
}

local function calculateFinalValue(attrName, baseValue, rarity)

	local sequence = CHEST_COMPOSITION[rarity] or {"Bronze"}
	local value = baseValue

	for _, tier in ipairs(sequence) do

		local v = ATTRIBUTE_BALANCE[attrName] and ATTRIBUTE_BALANCE[attrName][tier] or 0.02

		if MULTIPLIER_ATTRS[attrName] then

			if attrName == "Cooldown" then
				value *= (1 - v)
			else
				value *= (1 + v)
			end

		elseif attrName == "ShieldRegenDelay" then

			value -= v

		elseif ADDITIVE_ATTRS[attrName] then

			if attrName == "Shield" then
				value += (ATTRIBUTE_BALANCE.Shield[tier] or 10)
			else
				value += v
			end

		end
	end
	
	return value
end

-- =========================
-- RECEBER REWARD
-- =========================

RewardEvent.OnClientEvent:Connect(function(rewards, rarity)

	currentRewards = rewards
	gui.Enabled = true

	clearRewards()

	-- 🎨 ESTILO POR RARIDADE
	local rarityStyles = {
		Bronze = {
			Text = Color3.fromRGB(181, 101, 29),
			Stroke = Color3.fromRGB(150, 80, 20),
			Background = Color3.fromRGB(25, 18, 10)
		},
		Silver = {
			Text = Color3.fromRGB(220, 220, 220),
			Stroke = Color3.fromRGB(170, 170, 170),
			Background = Color3.fromRGB(30, 30, 30)
		},
		Gold = {
			Text = Color3.fromRGB(255, 200, 0),
			Stroke = Color3.fromRGB(200, 160, 0),
			Background = Color3.fromRGB(35, 28, 8)
		},
		Diamond = {
			Text = Color3.fromRGB(0, 200, 255),
			Stroke = Color3.fromRGB(0, 150, 200),
			Background = Color3.fromRGB(8, 28, 35)
		}
	}

	local style = rarityStyles[rarity]

	if style then
		title.TextColor3 = style.Text
		mainFrame.BackgroundColor3 = style.Background
		if uiStroke then
			uiStroke.Color = style.Stroke
		end
	end

	-- 🏷 Título
	title.Text = rarity .. " Chest"

	local function animateGold(targetAmount)

		local duration = 0.6

		local valueObject = Instance.new("NumberValue")
		valueObject.Value = 0

		valueObject:GetPropertyChangedSignal("Value"):Connect(function()
			local displayValue = math.floor(valueObject.Value)
			goldLabel.Text = "+" .. displayValue .. " Gold"
		end)

		local tween = TweenService:Create(
			valueObject,
			TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{Value = targetAmount}
		)

		tween:Play()

		-- 💥 Animação do Ícone (AGORA CORRETO)
		if goldIcon then

			goldIcon.Size = UDim2.new(0, 32, 0, 32)

			local iconTween = TweenService:Create(
				goldIcon,
				TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
				{Size = UDim2.new(0, 38, 0, 38)}
			)

			iconTween:Play()

			iconTween.Completed:Connect(function()
				TweenService:Create(
					goldIcon,
					TweenInfo.new(0.2),
					{Size = UDim2.new(0, 32, 0, 32)}
				):Play()
			end)
		end

		tween.Completed:Connect(function()
			valueObject:Destroy()
		end)
	end	

	-- 💰 Ouro
	animateGold(rewards.Gold)

	goldIcon.Image = "rbxassetid://80249759309977"
	goldIcon.BackgroundTransparency = 1
	goldLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
	goldLabel.TextScaled = true
	goldLabel.Font = Enum.Font.Merriweather

	-- 📈 Atributos
	for _, attr in ipairs(rewards.Attributes) do

		local name = AttributeFormatter.FormatName(attr.Name)

		local value

		local levels = ({
			Bronze = 1,
			Silver = 2,
			Gold = 3,
			Diamond = 5
		})[rarity] or 1

		local attrsFolder = player:WaitForChild("MatchStats"):WaitForChild("Attributes")
		local stat = attrsFolder:FindFirstChild(attr.Name)

		if stat then

			local baseValue = stat.Value
			local finalValue = calculateFinalValue(attr.Name, baseValue, rarity)

			local displayText
			
			if attr.Name == "ShieldRegenDelay" then

				local diff = finalValue - baseValue
				local rounded = math.floor(math.abs(diff) + 0.5)

				if diff < 0 then
					displayText = "-" .. rounded .. "s"
				else
					displayText = "+" .. rounded .. "s"
				end

			elseif MULTIPLIER_ATTRS[attr.Name] then

				local percent = (finalValue / baseValue - 1) * 100
				local rounded = roundNicePercent(percent)

				if percent < 0 then
					displayText = "-" .. rounded .. "%"
				else
					displayText = "+" .. rounded .. "%"
				end

			elseif ADDITIVE_ATTRS[attr.Name] then

				local flat = finalValue - baseValue

				-- 🔥 Luck e AreaDamage (percentual base 0)
				if attr.Name == "Luck" or attr.Name == "AreaDamage" then

					local percent = flat * 100
					local rounded = roundNicePercent(percent)

					if percent < 0 then
						displayText = "-" .. rounded .. "%"
					else
						displayText = "+" .. rounded .. "%"
					end

					-- 🔥 LifeRegen (decimal real)
				elseif attr.Name == "LifeRegen" then

					displayText = "+" .. string.format("%.2f", flat) .. "/s"

					-- 🔥 resto (inteiro)
				else

					local rounded = math.floor(math.abs(flat) + 0.5)

					if flat < 0 then
						displayText = "-" .. rounded
					else
						displayText = "+" .. rounded
					end
				end

			else
				displayText = "+"
			end

			createRewardLabel("⬆ "..name.." "..displayText, Color3.fromRGB(100,255,100))
		end

	end
	-- 🔮 Sinergia
	if rewards.Synergy then

		local container = Instance.new("Frame")
		container.Size = UDim2.new(1, 0, 0, 50)
		container.BackgroundColor3 = Color3.fromRGB(35,35,35)
		container.Parent = rewardContainer

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0,6)
		corner.Parent = container

		-- 🔹 Frame interno centralizado
		local content = Instance.new("Frame")
		content.AutomaticSize = Enum.AutomaticSize.X
		content.Size = UDim2.new(0,0,1,0)
		content.AnchorPoint = Vector2.new(0.5,0.5)
		content.Position = UDim2.new(0.5,0,0.5,0)
		content.BackgroundTransparency = 1
		content.Parent = container

		local layout = Instance.new("UIListLayout")
		layout.FillDirection = Enum.FillDirection.Horizontal
		layout.VerticalAlignment = Enum.VerticalAlignment.Center
		layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		layout.Padding = UDim.new(0,12)
		layout.Parent = content

		-- 🔮 Ícone MAIOR
		local icon = Instance.new("ImageLabel")
		icon.Size = UDim2.fromOffset(55,55)
		icon.BackgroundTransparency = 1
		icon.Image = rewards.SynergyImage or ""
		icon.Parent = content

		-- ✨ Nome GRANDE e adaptável
		local label = Instance.new("TextLabel")
		label.AutomaticSize = Enum.AutomaticSize.X
		label.Size = UDim2.new(0,0,1,0)
		label.BackgroundTransparency = 1
		label.Text = rewards.SynergyName or rewards.Synergy
		label.TextScaled = false
		label.TextSize = 40
		label.Font = Enum.Font.Merriweather
		label.TextColor3 = Color3.fromRGB(200,120,255)
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.TextWrapped = false
		label.TextTruncate = Enum.TextTruncate.AtEnd
		label.Parent = content
	end

	-- ⚔ Arma estilizada igual aos outros rewards
	if rewards.Weapon then

		local weaponFrame = Instance.new("Frame")
		weaponFrame.Size = UDim2.new(1, -10, 0, 35)
		weaponFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
		weaponFrame.Parent = rewardContainer

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 6)
		corner.Parent = weaponFrame

		local layout = Instance.new("UIListLayout")
		layout.FillDirection = Enum.FillDirection.Horizontal
		layout.VerticalAlignment = Enum.VerticalAlignment.Center
		layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		layout.Padding = UDim.new(0, 2)
		layout.Parent = weaponFrame

		-- Ícone
		local icon = Instance.new("ImageLabel")
		icon.Size = UDim2.fromOffset(55, 55)
		icon.BackgroundTransparency = 1
		icon.Image = rewards.WeaponImage or ""
		icon.ScaleType = Enum.ScaleType.Fit
		icon.Parent = weaponFrame

		-- Nome da arma
		local label = Instance.new("TextLabel")
		label.Size = UDim2.new(0, 0, 1, 0)
		label.AutomaticSize = Enum.AutomaticSize.X
		label.BackgroundTransparency = 1
		local def = WeaponRegistry.Definitions[rewards.Weapon]
		label.Text = def and def.DisplayName or rewards.Weapon
		label.TextScaled = false
		label.TextSize = 40
		label.Font = Enum.Font.Merriweather
		label.TextColor3 = Color3.fromRGB(255, 80, 80)
		label.Parent = weaponFrame
	end
end)

-- =========================
-- BOTÃO COLLECT
-- =========================

button.MouseEnter:Connect(function()
	button.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
end)

button.MouseLeave:Connect(function()
	button.BackgroundColor3 = Color3.fromRGB(0, 120, 0)
end)

button.MouseButton1Click:Connect(function()

	if not currentRewards then return end

	CollectEvent:FireServer(currentRewards)

	gui.Enabled = false
	currentRewards = nil
end)
