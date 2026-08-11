-- GAMBLER CLIENT FINAL (BASE PRESERVADA + CORREÇÕES)

local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local remotes = game.ReplicatedStorage:WaitForChild("Remotes")

local uiEvent = remotes:WaitForChild("GamblerUI")
local rollEvent = remotes:WaitForChild("GamblerRoll")

local selectedModifier =
	player:WaitForChild("GlobalStats")
	:WaitForChild("SelectedModifier")


-------------------------------------------------
-- UI BASE
-------------------------------------------------

local gui = Instance.new("ScreenGui")
gui.Name = "GamblerUI"
gui.ResetOnSpawn = false
gui.Parent = playerGui
gui.Enabled = false
-------------------------------------------------
-- 💰 PARTICLES
-------------------------------------------------

local emojis = {"💰","🎰","🃏","💎"}

local function spawnParticles()
	for i = 1,12 do
		local txt = Instance.new("TextLabel")
		txt.Text = emojis[math.random(1,#emojis)]
		txt.Size = UDim2.fromOffset(40,40)
		txt.Position = UDim2.fromScale(math.random(),math.random())
		txt.BackgroundTransparency = 1
		txt.TextScaled = true
		txt.Parent = gui

		TweenService:Create(txt,TweenInfo.new(1),{
			Position = txt.Position - UDim2.new(0,0,0.25,0),
			TextTransparency = 1
		}):Play()

		Debris:AddItem(txt,1)
	end
end

local CardColors = {
	Ace = Color3.fromRGB(0,0,0),
	King = Color3.fromRGB(255,200,0),
	Queen = Color3.fromRGB(255,0,4),
	Jack = Color3.fromRGB(20, 200, 255),
	Joker = Color3.fromRGB(81,0,255)
}

-------------------------------------------------
-- PROGRESS BAR
-------------------------------------------------

local bar = Instance.new("Frame")
bar.Size = UDim2.new(0.3,0,0.035,0)
bar.Position = UDim2.new(0.35,0,0.85,0)
bar.BackgroundColor3 = Color3.fromRGB(10,10,10)
bar.Parent = gui

local fill = Instance.new("Frame")
fill.Size = UDim2.new(0,0,1,0)
fill.Parent = bar

local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new{
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 225, 0)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(81, 255, 0))
}
gradient.Parent = fill

local border = Instance.new("UIStroke")
border.Color = Color3.fromRGB(255,215,0)
border.Thickness = 6
border.Parent = bar

local text = Instance.new("TextLabel")
text.Text = "0/50"
text.Size = UDim2.new(1,0,1,0)
text.BackgroundTransparency = 1
text.TextScaled = true
text.Font = Enum.Font.Merriweather
text.TextColor3 = Color3.new(1,1,1)
text.Parent = bar

-------------------------------------------------
-- SLOT MACHINE
-------------------------------------------------

local machine = Instance.new("Frame")
machine.Size = UDim2.new(0.55,0,0.45,0)
machine.Position = UDim2.new(0.225,0,0.22,0)
machine.BackgroundColor3 = Color3.fromRGB(20,10,0)
machine.Visible = false
machine.Parent = gui

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(255,215,0)
stroke.Thickness = 6
stroke.Parent = machine

local glow = Instance.new("UIStroke")
glow.Color = Color3.fromRGB(255,200,0)
glow.Thickness = 12
glow.Transparency = 0.8
glow.Parent = machine

task.spawn(function()
	while true do
		TweenService:Create(glow,TweenInfo.new(0.8),{Transparency = 0.4}):Play()
		task.wait(0.8)
		TweenService:Create(glow,TweenInfo.new(0.8),{Transparency = 0.8}):Play()
		task.wait(0.8)
	end
end)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(0.9,0,0.15,0)
title.Position = UDim2.new(0.05,0,0.03,0)
title.BackgroundTransparency = 1
title.Text = "SLOT MACHINE"
title.Font = Enum.Font.Merriweather
title.TextScaled = true
title.TextColor3 = Color3.fromRGB(255,215,0)
title.Parent = machine

-------------------------------------------------
-- INNER
-------------------------------------------------

local inner = Instance.new("Frame")
inner.Size = UDim2.new(0.92,0,0.7,0)
inner.Position = UDim2.new(0.04,0,0.2,0)
inner.BackgroundColor3 = Color3.fromRGB(245,245,245)
inner.Parent = machine

-------------------------------------------------
-- SLOTS
-------------------------------------------------

local slots = {}

for i = 1,3 do
	local slot = Instance.new("Frame")
	slot.Size = UDim2.new(0.28,0,1,0)
	slot.Position = UDim2.new((i-1)*0.33 + 0.02,0,0,0)
	slot.BackgroundTransparency = 1
	slot.Parent = inner

	if i < 3 then
		local divider = Instance.new("Frame")
		divider.Size = UDim2.new(0,6,1,0)
		divider.Position = UDim2.new(1,0,0,0)
		divider.BackgroundColor3 = Color3.fromRGB(255,215,0)
		divider.Parent = slot
	end

	local img = Instance.new("ImageLabel")
	img.Size = UDim2.new(0.6,0,0.8,0)
	img.Position = UDim2.new(0.5,0,0.4,0)
	img.AnchorPoint = Vector2.new(0.5,0.5)
	img.BackgroundTransparency = 1
	img.ScaleType = Enum.ScaleType.Fit
	img.Parent = slot

	Instance.new("UIAspectRatioConstraint", img).AspectRatio = 9/16

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1,0,0.3,0)
	label.Position = UDim2.new(0.5,0,0.75,0)
	label.AnchorPoint = Vector2.new(0.5,0.5)
	label.BackgroundTransparency = 1
	label.TextScaled = true
	label.Font = Enum.Font.Merriweather
	label.TextColor3 = Color3.fromRGB(0,0,0)
	label.Parent = slot

	slots[i] = {Image = img, Label = label}
end

-------------------------------------------------
-- RESULT
-------------------------------------------------

local resultFrame = Instance.new("Frame")
resultFrame.Size = UDim2.new(0.16,0,0.4,0)
resultFrame.Position = UDim2.new(0.80,0,0.3,0)
resultFrame.BackgroundTransparency = 1
resultFrame.Visible = false
resultFrame.Parent = gui

local resultImage = Instance.new("ImageLabel")
resultImage.Size = UDim2.new(1,0,0.7,0)
resultImage.Position = UDim2.new(0.5,0,0.3,0)
resultImage.AnchorPoint = Vector2.new(0.5,0.5)
resultImage.BackgroundTransparency = 1
resultImage.ScaleType = Enum.ScaleType.Fit
resultImage.Parent = resultFrame
Instance.new("UIAspectRatioConstraint", resultImage).AspectRatio = 9/16

local resultText = Instance.new("TextLabel")
resultText.Size = UDim2.new(1,0,0.5,0)
resultText.Position = UDim2.new(0,0,0.55,0)
resultText.BackgroundTransparency = 1
resultText.TextWrapped = true
resultText.TextScaled = false
resultText.TextSize = 28
resultText.LineHeight = 1.2
resultText.TextStrokeTransparency = 0.5
resultText.TextStrokeColor3 = Color3.new(0,0,0)
resultText.TextYAlignment = Enum.TextYAlignment.Top
resultText.Font = Enum.Font.Merriweather
resultText.TextColor3 = Color3.fromRGB(255,215,0)
resultText.Parent = resultFrame

local function getGlobalColor(card, value)

	-- 🎴 prioridade: cor da carta
	local baseColor = CardColors[card] or Color3.new(1,1,1)

	-- 💎 intensidade pelo valor
	local percent = math.floor((value-1)*100)

	if card == "Joker" then
		return baseColor
	end

	if percent >= 100 then
		return Color3.fromRGB(255,215,0) -- dourado
	elseif percent >= 50 then
		return baseColor:Lerp(Color3.new(1,1,1), 0.2)
	elseif percent >= 25 then
		return baseColor:Lerp(Color3.new(0.5,0.5,1), 0.3)
	else
		return baseColor:Lerp(Color3.new(0.3,0.3,0.8), 0.5)
	end
end

-------------------------------------------------
-- DATA
-------------------------------------------------

local cards = {"Ace","King","Queen","Jack","Joker"}

local CardImages = {
	Ace = "rbxassetid://83176381033818",
	King = "rbxassetid://137133956364316",
	Queen = "rbxassetid://90692022817505",
	Jack = "rbxassetid://126311395582728",
	Joker = "rbxassetid://123341847045953"
}

local statMap = {
	Ace = "Damage",
	King = "Attack Size",
	Queen = "Range",
	Jack = "Projectile Speed",
	Joker = "Multi Attack"
}

-------------------------------------------------
-- SPIN
-------------------------------------------------

local function spinSlots(pool, isCard, duration, isJoker)
	local start = tick()

	while tick() - start < duration do
		for _,slot in ipairs(slots) do
			local val = pool[math.random(1,#pool)]

			if isCard then
				slot.Image.Visible = true
				slot.Image.Image = CardImages[val] or ""

				slot.Label.Text = val
				slot.Label.TextColor3 = CardColors[val] or Color3.new(1,1,1)

				-- 🔥 VOLTA POSIÇÃO ORIGINAL DAS CARTAS
				slot.Label.AnchorPoint = Vector2.new(0,0)
				slot.Label.Position = UDim2.new(0,0,0.7,0)
				slot.Label.TextXAlignment = Enum.TextXAlignment.Center
				slot.Label.TextYAlignment = Enum.TextYAlignment.Top
			else
				slot.Image.Visible = false

				local percent

				local textValue
				
				if isJoker then
					-- 🃏 JOKER (usar valores fixos)
					local flat = val
					textValue = tostring(flat)
				else
					-- 💎 NORMAL (%)
					local percent = math.floor((val-1)*100)
					percent = math.floor(percent/5)*5
					textValue = percent.."%"
				end

				slot.Label.Text = "+"..textValue
				
				local function getColorFromText(text)
					local number = tonumber(string.match(text, "%d+"))

					if not number then
						return Color3.new(1,1,1)
					end

					if number >= 100 then
						return Color3.fromRGB(255,215,0) -- dourado
					elseif number >= 50 then
						return Color3.fromRGB(255,120,0) -- quente
					elseif number >= 25 then
						return Color3.fromRGB(0,200,255) -- frio médio
					else
						return Color3.fromRGB(100,100,255) -- frio
					end
				end

				-- 🎯 CENTRALIZAÇÃO APENAS AQUI
				slot.Label.AnchorPoint = Vector2.new(0.5,0.5)
				slot.Label.Position = UDim2.new(0.5,0,0.5,0)
				slot.Label.TextXAlignment = Enum.TextXAlignment.Center
				slot.Label.TextYAlignment = Enum.TextYAlignment.Center
				
			end
		end

		task.wait(0.04 + (tick()-start)*0.03)
	end
end

-------------------------------------------------
-- CINEMATIC
-------------------------------------------------

local function playCinematic(card, stat, value)
	
	bar.Visible = false
	
	local dark = Instance.new("Frame")
	dark.Size = UDim2.fromScale(1,1)
	dark.BackgroundColor3 = Color3.new(0,0,0)
	dark.BackgroundTransparency = 0.4
	dark.Parent = gui

	local img = Instance.new("ImageLabel")
	img.Size = UDim2.fromOffset(0,0)
	img.Position = UDim2.fromScale(0.5,0.4)
	img.AnchorPoint = Vector2.new(0.5,0.5)
	img.Image = CardImages[card]
	img.BackgroundTransparency = 1
	img.Parent = dark

	local txt = Instance.new("TextLabel")
	txt.Size = UDim2.fromScale(0.6,0.3)
	txt.Position = UDim2.fromScale(0.5,0.75)
	txt.AnchorPoint = Vector2.new(0.5,0.5)
	txt.BackgroundTransparency = 1
	txt.TextScaled = true
	txt.Font = Enum.Font.Merriweather
	txt.TextColor3 = CardColors[card]

	local isJoker = (card == "Joker")

	if isJoker then
		txt.Text = card.."\n"..stat.."\n+"..value
		txt.TextColor3 = CardColors[card] or Color3.new(1,1,1)
	elseif value < 1 then
		txt.Text = card.."\n"..stat.."\n+"..math.floor(value)
		txt.TextColor3 = CardColors[card] or Color3.new(1,1,1)
	else
		local percent = math.floor((value-1)*100)
		percent = math.floor(percent/5)*5
		txt.Text = card.."\n"..stat.."\n+"..percent.."%"
		txt.TextColor3 = CardColors[card] or Color3.new(1,1,1)
	end

	txt.Parent = dark

	TweenService:Create(img,TweenInfo.new(0.6),{
		Size = UDim2.fromOffset(260,260)
	}):Play()

	task.wait(2)
	dark:Destroy()
end

-------------------------------------------------
-- ROLL
-------------------------------------------------

local rolling = false

rollEvent.OnClientEvent:Connect(function(card, value)
	if rolling then return end
	
	rolling = true
	
	bar.Visible = false

	machine.Visible = true

	local spinSound = Instance.new("Sound")
	spinSound.SoundId = "rbxassetid://131190373635255"
	spinSound.Looped = true
	spinSound.Parent = machine
	spinSound:Play()

	spinSlots(cards, true, 2)
	
	resultFrame.Visible = true
	resultImage.Image = CardImages[card]

	local stat = statMap[card]
	resultText.Text = card.."\n"..stat
	resultText.TextColor3 = CardColors[card]
	
	spawnParticles()

	local color = CardColors[card] or Color3.new(1,1,1)

	for _,slot in ipairs(slots) do
		slot.Image.Image = CardImages[card]
		slot.Label.Text = card
		slot.Label.TextColor3 = color
	end

	task.wait(0.5)
	
	local valuePool

	if card == "Joker" then
		valuePool = {5,10,15,20,30,40,50}
	else
		valuePool = {1.15,1.25,1.35,1.5,1.75,2,3}
	end

	spinSlots(valuePool, false, 2, card == "Joker")
	spinSound:Stop()
	spinSound:Destroy()

	spawnParticles()

	local percent = math.floor((value-1)*100)
	percent = math.floor(percent/5)*5

	local color = getGlobalColor(card, value)

	local color = CardColors[card] or Color3.new(1,1,1)

	for _,slot in ipairs(slots) do
		if card == "Joker" then
			local flat = value -- já vem correto do server
			slot.Label.Text = "+"..flat
		else
			slot.Label.Text = "+"..percent.."%"
		end

		slot.Label.TextColor3 = color
	end
	
	resultFrame.Visible = true
	resultImage.Image = CardImages[card]

	local stat = statMap[card]

	local isJoker = (card == "Joker")

	if isJoker then
		resultText.Text = card.."\n"..stat.."\n+"..value
	elseif value < 1 then
		resultText.Text = card.."\n"..stat.."\n+"..math.floor(value)
		resultText.TextColor3 = CardColors[card]
	else
		local percent = math.floor((value-1)*100)
		percent = math.floor(percent/5)*5
		resultText.Text = card.."\n"..stat.."\n+"..percent.."%"
		resultText.TextColor3 = CardColors[card]
	end

	local win = Instance.new("Sound")
	win.SoundId = "rbxassetid://1839881844"
	win.Parent = machine
	win:Play()

	task.wait(1)

	machine.Visible = false
	resultFrame.Visible = false

	task.wait(0.3)

	playCinematic(card, stat, value)
	
	bar.Visible = true

	game.ReplicatedStorage.Remotes.GamblerFinished:FireServer()

	rolling = false

end)

-------------------------------------------------
-- UPDATE
-------------------------------------------------

uiEvent.OnClientEvent:Connect(function(kills, target)
	fill.Size = UDim2.new(kills/target,0,1,0)
	text.Text = kills.." / "..target
	
	local function update()
		gui.Enabled = (selectedModifier.Value == "Gambler")
	end

	update()

	selectedModifier:GetPropertyChangedSignal("Value"):Connect(update)

end)