local player = game.Players.LocalPlayer
local remote = game.ReplicatedStorage.Remotes:WaitForChild("BaileCombo")
local TweenService = game:GetService("TweenService")

print("🟣 UI INICIADA")

local RankImages = {
	F = "rbxassetid://103642660224236",
	D = "rbxassetid://117805889570353",
	C = "rbxassetid://97775470082610",
	B = "rbxassetid://130767614332145",
	A = "rbxassetid://99177099225795",
	S = "rbxassetid://138213682452857",
	["S+"] = "rbxassetid://98143091378993"
}

local HitsImages = {
	F = "rbxassetid://104949524002107",
	D = "rbxassetid://91712714882303",
	C = "rbxassetid://88848098135400",
	B = "rbxassetid://137332956936053",
	A = "rbxassetid://73626805960050",
	S = "rbxassetid://111915712571591",
	["S+"] = "rbxassetid://119069676374848"
}


-------------------------------------------------
-- REFERÊNCIA DE STATS
-------------------------------------------------

local stats = player:WaitForChild("MatchStats")
local attributelevels = stats:WaitForChild("AttributeLevels")
local areaDamage = attributelevels:WaitForChild("AreaDamage")

-------------------------------------------------
-- GUI BASE
-------------------------------------------------

local gui = Instance.new("ScreenGui")
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.DisplayOrder = 50
gui.Parent = player:WaitForChild("PlayerGui")

-------------------------------------------------
-- RANK (EM CIMA)
-------------------------------------------------
local lastRank = nil
local rankImage = Instance.new("ImageLabel")
rankImage.AnchorPoint = Vector2.new(0, 0.5)
rankImage.Position = UDim2.fromScale(0.12, 0.25)
rankImage.Position += UDim2.fromOffset(math.random(-5,5), math.random(-5,5))
rankImage.Size = UDim2.fromScale(0.12, 0.12)

rankImage.BackgroundTransparency = 1
rankImage.Image = ""
rankImage.Parent = gui

local aspect = Instance.new("UIAspectRatioConstraint")
aspect.AspectRatio = 1
aspect.Parent = rankImage
-------------------------------------------------
-- HITS (EMBAIXO)
-------------------------------------------------
local hitsContainer = Instance.new("Frame")
hitsContainer.AnchorPoint = Vector2.new(0.5, 0.5)
hitsContainer.Position = UDim2.fromScale(0.18, 0.32)
hitsContainer.Size = UDim2.fromScale(1, 0.5)

hitsContainer.BackgroundTransparency = 1
hitsContainer.Parent = gui

local layout = Instance.new("UIListLayout")
layout.FillDirection = Enum.FillDirection.Horizontal
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.VerticalAlignment = Enum.VerticalAlignment.Center
layout.Padding = UDim.new(0, -90) -- espaçamento entre número e HITS
layout.Parent = hitsContainer
layout.SortOrder = Enum.SortOrder.LayoutOrder

local scale = Instance.new("UIScale")
scale.Scale = 1.5
scale.Parent = hitsContainer

-- NÚMERO
local hitsNumber = Instance.new("TextLabel")
hitsNumber.AnchorPoint = Vector2.new(0, 0.5)
hitsNumber.TextScaled = true
hitsNumber.Size = UDim2.fromScale(0.6, 1)

hitsNumber.BackgroundTransparency = 1
hitsNumber.TextScaled = true
hitsNumber.Font = Enum.Font.Merriweather
hitsNumber.TextColor3 = Color3.new(1,1,1)

hitsNumber.TextStrokeColor3 = Color3.new(0,0,0)
hitsNumber.TextStrokeTransparency = 0

hitsNumber.Text = ""
hitsNumber.Parent = hitsContainer
hitsNumber.LayoutOrder = 1

-- IMAGEM "HITS"
local hitsImage = Instance.new("ImageLabel")
hitsImage.AnchorPoint = Vector2.new(0, 0.5)
hitsImage.Size = UDim2.fromScale(1.2, 1)

hitsImage.BackgroundTransparency = 1
hitsImage.Image = ""
hitsImage.Parent = hitsContainer
hitsImage.LayoutOrder = 2

local aspect2 = Instance.new("UIAspectRatioConstraint")
aspect2.AspectRatio = 2.5 -- hits é mais largo
aspect2.Parent = hitsImage

local hitSound = Instance.new("Sound")
hitSound.SoundId = "rbxassetid://139737653393320"
hitSound.Volume = 1
hitSound.Parent = gui

-------------------------------------------------
-- RANK SYSTEM
-------------------------------------------------

local function getRank(stacks)

	if stacks < 5 then
		return "F", Color3.fromRGB(150,150,150)
	elseif stacks < 10 then
		return "D", Color3.fromRGB(100,200,255)
	elseif stacks < 20 then
		return "C", Color3.fromRGB(100,255,100)
	elseif stacks < 30 then
		return "B", Color3.fromRGB(255,255,100)
	elseif stacks < 40 then
		return "A", Color3.fromRGB(255,150,50)
	elseif stacks < 50 then
		return "S", Color3.fromRGB(255,80,80)
	else
		return "S+", Color3.fromRGB(255,0,255)
	end

end

local function getRankScale(rank)

	if rank == "F" then return 0.10
	elseif rank == "D" then return 0.12
	elseif rank == "C" then return 0.14
	elseif rank == "B" then return 0.17
	elseif rank == "A" then return 0.20
	elseif rank == "S" then return 0.24
	elseif rank == "S+" then return 0.28
	end

	return 0.1
end

local function getRankColor(rank)

	if rank == "F" then
		return Color3.fromRGB(158, 218, 246) -- azul claro

	elseif rank == "D" then
		return Color3.fromRGB(0,0,0) -- preto

	elseif rank == "C" then
		return Color3.fromRGB(33, 126, 184) -- azul

	elseif rank == "B" then
		return Color3.fromRGB(255,80,80) -- vermelho

	elseif rank == "A" then
		return Color3.fromRGB(255,215,0) -- dourado

	elseif rank == "S" then
		return Color3.fromRGB(255,215,0) -- dourado

	elseif rank == "S+" then
		return Color3.fromRGB(180,0,255) -- roxo
	end

	return Color3.new(1,1,1)
end

local function playRankSound(rank)

	local sound = Instance.new("Sound")
	sound.SoundId = "rbxassetid://92353385304048" -- som base (pode trocar depois)
	sound.Volume = 1

	-- pitch baseado no rank
	if rank == "F" then sound.PlaybackSpeed = 0.8
	elseif rank == "D" then sound.PlaybackSpeed = 0.9
	elseif rank == "C" then sound.PlaybackSpeed = 1
	elseif rank == "B" then sound.PlaybackSpeed = 1.1
	elseif rank == "A" then sound.PlaybackSpeed = 1.2
	elseif rank == "S" then sound.PlaybackSpeed = 1.3
	elseif rank == "S+" then sound.PlaybackSpeed = 1.5
	end

	sound.Parent = workspace
	sound:Play()

	game.Debris:AddItem(sound, 2)

end

local function getRankPitch(rank)

	if rank == "A" then
		return 1
	elseif rank == "S" then
		return 1.2
	elseif rank == "S+" then
		return 1.4
	end

	return nil -- ranks baixos não tocam som

end

-------------------------------------------------
-- VISUAL
-------------------------------------------------

local function showCombo(stacks)

	if areaDamage.Value <= 0 then
		return
	end

	if stacks <= 0 then

		print("💥 COMBO BREAK")

		-- animação
		TweenService:Create(rankImage, TweenInfo.new(0.3), {
			ImageTransparency = 1
		}):Play()

		TweenService:Create(hitsImage, TweenInfo.new(0.3), {
			ImageTransparency = 1
		}):Play()

		TweenService:Create(hitsNumber, TweenInfo.new(0.3), {
			TextTransparency = 1
		}):Play()

		-- 🔊 SOM
		local breakSound = Instance.new("Sound")
		breakSound.SoundId = "rbxassetid://137908167664234"
		breakSound.Volume = 2
		breakSound.Parent = game:GetService("SoundService")
		breakSound:Play()

		game.Debris:AddItem(breakSound, 2)

		return
	end

	local rank = getRank(stacks)
	
	local pitch = getRankPitch(rank)

	if pitch then
		hitSound.PlaybackSpeed = pitch
		local pitch = getRankPitch(rank)

		if pitch then
			hitSound.PlaybackSpeed = pitch
			hitSound:Play()
		end
	end

	if rank ~= lastRank then
		lastRank = rank

		-- 🔥 ANIMAÇÃO DE IMPACTO
		rankImage.Size = UDim2.fromScale(0.3, 0.3)

		TweenService:Create(rankImage, TweenInfo.new(0.25, Enum.EasingStyle.Back), {
			Size = UDim2.fromScale(getRankScale(rank), getRankScale(rank))
		}):Play()

		-- 🔊 SOM DE RANK UP
		playRankSound(rank)
	end

	local color = getRankColor(rank)
	hitsNumber.TextColor3 = color

	-- 🔥 SET IMAGES
	rankImage.Image = RankImages[rank]
	hitsImage.Image = HitsImages[rank]

	-- 🔢 NÚMERO
	hitsNumber.Text = tostring(stacks)

	-- RESET
	local scale = getRankScale(rank)

	rankImage.Size = UDim2.fromScale(scale, scale)

	hitsNumber.TextTransparency = 0.2
	rankImage.ImageTransparency = 0.2
	hitsImage.ImageTransparency = 0.2

	rankImage.Position = UDim2.fromScale(0.05, 0.25)

	rankImage.Position += UDim2.fromOffset(
		math.random(-3,3),
		math.random(-3,3)
	)

	hitsNumber.Position = UDim2.fromScale(0.05, 0.36)
	hitsImage.Position = UDim2.fromScale(0.11, 0.36)

	hitsNumber.TextSize = 90
	TweenService:Create(hitsNumber, TweenInfo.new(0.15, Enum.EasingStyle.Back), {
		TextSize = 120
	}):Play()

	-- 🔥 ANIMAÇÃO
	TweenService:Create(hitsNumber, TweenInfo.new(0.15, Enum.EasingStyle.Back), {
		Size = UDim2.fromScale(0.15, 0.1),
		TextTransparency = 0
	}):Play()

	TweenService:Create(rankImage, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.fromScale(scale * 1.15, scale * 1.15),
		ImageTransparency = 0
	}):Play()

	TweenService:Create(hitsImage, TweenInfo.new(0.15, Enum.EasingStyle.Back), {
		Size = UDim2.fromScale(0.22, 0.1),
		ImageTransparency = 0
	}):Play()

	-- FADE
	task.delay(0.8, function()
		TweenService:Create(hitsNumber, TweenInfo.new(0.3), {
			TextTransparency = 0.5
		}):Play()

		TweenService:Create(rankImage, TweenInfo.new(0.3), {
			ImageTransparency = 0.5
		}):Play()

		TweenService:Create(hitsImage, TweenInfo.new(0.3), {
			ImageTransparency = 0.5
		}):Play()
	end)

end

-------------------------------------------------
-- REMOTE
-------------------------------------------------

remote.OnClientEvent:Connect(function(stacks)
	print("📩 RECEBI:", stacks)
	showCombo(stacks)
end)