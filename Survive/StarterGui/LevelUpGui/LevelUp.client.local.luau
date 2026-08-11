-- LevelUp.client.lua (VERSÃO PREMIUM ESTÁVEL)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local PickUpgrade = Remotes:WaitForChild("PickUpgrade")
local LevelUpGuiRemote = Remotes:WaitForChild("LevelUpGui")

local gui = script.Parent
local content = gui:WaitForChild("Content")
local title = gui:WaitForChild("TitleText")

local CardRegistry = require(
	ReplicatedStorage.Shared:WaitForChild("AttributeCardRegistry")
)

local AttributeFormatter = require(
	ReplicatedStorage.Shared:WaitForChild("AttributeFormatter")
)

local LevelUpFormatter = require(
	ReplicatedStorage.Shared:WaitForChild("LevelUpFormatter")
)

local currentOptions = {}
-- =========================
-- CONFIG
-- =========================

local RARITY_COLORS = {
	Bronze = Color3.fromRGB(140, 90, 45),
	Silver = Color3.fromRGB(170, 170, 170),
	Gold = Color3.fromRGB(255, 215, 90),
	Diamond = Color3.fromRGB(0, 255, 255),
}

local goldSoundId = "rbxassetid://131722044536461"
local diamondSoundId = "rbxassetid://129803893719799"

local cardFrames = {
	content:WaitForChild("Card1"),
	content:WaitForChild("Card2"),
	content:WaitForChild("Card3"),
}

local sideButtons = gui:WaitForChild("SideButtons")
local rerollButton = sideButtons:WaitForChild("Reroll")
local banishButton = sideButtons:WaitForChild("Banish")

local activeDiamondLoop = {}
local playedRaritySound = false


-- =========================
-- RESET CARDS (ANTI DIAMOND BUG)
-- =========================

local function resetCards()

	for _, card in ipairs(cardFrames) do

		local stroke = card.CardContainer:FindFirstChildOfClass("UIStroke")
		if stroke then
			stroke.Transparency = 0.2
			stroke.Thickness = 4
		end

		-- 🔥 Cancela qualquer loop ativo
		activeDiamondLoop[card] = nil

	end
end

-- =========================
-- CAMERA
-- =========================

local camera = workspace.CurrentCamera
local originalFOV = camera.FieldOfView

-- =========================
-- BACKGROUND CÓSMICO PREMIUM
-- =========================

local cosmicBackground

local function applyCosmicBackground(rarity)

	if not cosmicBackground then
		cosmicBackground = Instance.new("Frame")
		cosmicBackground.Size = UDim2.new(1,0,1,0)
		cosmicBackground.Position = UDim2.new(0,0,0,0)
		cosmicBackground.BorderSizePixel = 0
		cosmicBackground.ZIndex = 0
		cosmicBackground.Active = false
		cosmicBackground.Parent = gui

		local gradient = Instance.new("UIGradient")
		gradient.Parent = cosmicBackground
	end

	local gradient = cosmicBackground:FindFirstChildOfClass("UIGradient")
	local base = RARITY_COLORS[rarity] or Color3.fromRGB(40,40,60)

	gradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, base:Lerp(Color3.new(0,0,0),0.6)),
		ColorSequenceKeypoint.new(1, Color3.new(0,0,0))
	}

	task.spawn(function()
		while gui.Enabled do
			gradient.Rotation += 0.1
			task.wait()
		end
	end)
end

-- =========================
-- RARITY BADGE PREMIUM
-- =========================

local function styleRarityBadge(card, rarity)

	local badge = card.RarityBadge
	local color = RARITY_COLORS[rarity]

	badge.BackgroundColor3 = color
	badge.BackgroundTransparency = 0.1
	badge.RarityText.Text = rarity
	badge.RarityText.TextColor3 = Color3.new(1,1,1)

	local stroke = badge:FindFirstChildOfClass("UIStroke")
	if not stroke then
		stroke = Instance.new("UIStroke")
		stroke.Parent = badge
	end

	stroke.Color = color:Lerp(Color3.new(1,1,1),0.4)
	stroke.Thickness = 2

	local gradient = badge:FindFirstChildOfClass("UIGradient")
	if not gradient then
		gradient = Instance.new("UIGradient")
		gradient.Parent = badge
	end

	gradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, color:Lerp(Color3.new(1,1,1),0.3)),
		ColorSequenceKeypoint.new(1, color)
	}
end

-- =========================
-- EFEITOS RARIDADE
-- =========================

local function applySpecialEffects(card, rarity)

	local stroke = card.CardContainer:FindFirstChildOfClass("UIStroke")
	if not stroke then return end

	stroke.Color = RARITY_COLORS[rarity]

	if rarity == "Gold" then
		stroke.Thickness = 6

		if not playedRaritySound then
			playedRaritySound = true
			local s = Instance.new("Sound")
			s.SoundId = "rbxassetid://131722044536461"
			s.Volume = 0.6
			s.Parent = gui
			s:Play()
			game.Debris:AddItem(s,3)
		end

	elseif rarity == "Diamond" then

		stroke.Thickness = 7

		activeDiamondLoop[card] = true
		
		if not playedRaritySound then
			playedRaritySound = true
			local s = Instance.new("Sound")
			s.SoundId = "rbxassetid://131722044536461"
			s.Volume = 1
			s.Parent = gui
			s:Play()
			game.Debris:AddItem(s,3)
		end

		task.spawn(function()

			while gui.Enabled and activeDiamondLoop[card] do
				stroke.Transparency = 0
				task.wait(0.5)

				if not activeDiamondLoop[card] then break end

				stroke.Transparency = 0.4
				task.wait(0.5)
			end

			-- 🔥 garante que volta ao normal
			if stroke then
				stroke.Transparency = 0.2
			end

		end)
	end
end

-- =========================
-- TITLE
-- =========================

local function animateTitle()
	title.Text = "QUICK! CHOOSE AN UPGRADE!"
	title.TextTransparency = 1
	title.TextStrokeTransparency = 1

	TweenService:Create(title, TweenInfo.new(0.4), {
		TextTransparency = 0,
		TextStrokeTransparency = 0.3
	}):Play()
end

-- =========================
-- SHOW OPTIONS
-- =========================

local function showOptions(options)

	if not options or #options == 0 then return end
	
	currentOptions = options

	gui.DisplayOrder = 100
	gui.Enabled = true


	resetCards()
	animateTitle()

	playedRaritySound = false

	-- detectar maior raridade
	local priority = {Bronze=1, Silver=2, Gold=3, Diamond=4}
	local highest = "Bronze"
	local max = 0

	for _,opt in ipairs(options) do
		if priority[opt.Rarity] > max then
			max = priority[opt.Rarity]
			highest = opt.Rarity
		end
	end

	applyCosmicBackground(highest)

	for i,card in ipairs(cardFrames) do

		local opt = options[i]
		if not opt then
			card.Visible = false
			continue
		end

		local data = CardRegistry[opt.Id]
		if not data then
			card.Visible = false
			continue
		end

		card.Visible = true
		card.CardContainer.CardImage.Image = data.Image
		
		local text = ""

		if opt.Type == "Attribute" then

			local formatted = LevelUpFormatter.Format(opt.Id, opt.Value)
			
			text = formatted .. " " .. data.DisplayName

		else
			text = data.DisplayName
		end

		card.AttributeButton.Text = text

		styleRarityBadge(card, opt.Rarity)
		applySpecialEffects(card, opt.Rarity)
	end
end

-- =========================
-- CLOSE
-- =========================

local function closeGui()

	gui.Enabled = false
	
	for card,_ in pairs(activeDiamondLoop) do
		activeDiamondLoop[card] = false
	end
end

-- =========================
-- SIDE BUTTONS (FIXED)
-- =========================

local function buttonClickEffect(button)

	local originalSize = button.Size

	local grow = TweenService:Create(button, TweenInfo.new(
		0.08,
		Enum.EasingStyle.Quad,
		Enum.EasingDirection.Out
		), {
			Size = originalSize + UDim2.new(0,0,0.02,0)
		})

	local shrink = TweenService:Create(button, TweenInfo.new(
		0.08,
		Enum.EasingStyle.Quad,
		Enum.EasingDirection.In
		), {
			Size = originalSize
		})

	grow:Play()
	grow.Completed:Connect(function()
		shrink:Play()
	end)

end


rerollButton.MouseButton1Click:Connect(function()

	buttonClickEffect(rerollButton)

	PickUpgrade:FireServer({
		Action = "REROLL"
	})

end)


banishButton.MouseButton1Click:Connect(function()

	buttonClickEffect(banishButton)

	PickUpgrade:FireServer({
		Action = "BANISH"
	})

end)

-- =========================
-- CLICK
-- =========================

for i, card in ipairs(cardFrames) do
	card.AttributeButton.MouseButton1Click:Connect(function()

		local opt = currentOptions[i]
		if not opt then return end

		PickUpgrade:FireServer({
			Action = "PICK",
			Type = "Attribute",
			Id = opt.Id,
			Rarity = opt.Rarity,
			Value = opt.Value,
		})

		closeGui()
	end)
end

-- =========================
-- REMOTES
-- =========================

local LevelUpClosed = Remotes:WaitForChild("LevelUpClosed")

LevelUpGuiRemote.OnClientEvent:Connect(function(options)
	if not options then
		closeGui()
		return
	end
	showOptions(options)
end)

LevelUpClosed.OnClientEvent:Connect(function()
	closeGui()
end)

print("🎮 LevelUp.client PREMIUM carregado")