local player = game.Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "StrikerUI"
gui.ResetOnSpawn = false
gui.Parent = player.PlayerGui
gui.DisplayOrder = 100

gui.Enabled = false

player:GetAttributeChangedSignal("HasEliteStriker"):Connect(function()

	if player:GetAttribute("HasEliteStriker") then
		gui.Enabled = true
	end

end)

-------------------------------------------------
-- TEXT (COMBO)
-------------------------------------------------

local comboText = Instance.new("TextLabel")
comboText.Size = UDim2.new(0.3,0,0.05,0)
comboText.Position = UDim2.new(0.35,0,0.82,0)
comboText.BackgroundTransparency = 1
comboText.TextScaled = true
comboText.Font = Enum.Font.Merriweather
comboText.TextColor3 = Color3.fromRGB(255,255,255)
comboText.Text = "0 GOALS 😭⚽"
comboText.Parent = gui

-------------------------------------------------
-- GOAL BAR
-------------------------------------------------

local bar = Instance.new("Frame")
bar.Size = UDim2.new(0.25,0,0.02,0)
bar.Position = UDim2.new(0.375,0,0.88,0)
bar.BackgroundColor3 = Color3.fromRGB(20,20,20)
bar.Parent = gui

local fill = Instance.new("Frame")
fill.Size = UDim2.new(0,0,1,0)
fill.BackgroundColor3 = Color3.fromRGB(0,200,0)
fill.Parent = bar

-------------------------------------------------
-- REMOTES
-------------------------------------------------

local uiRemote = game.ReplicatedStorage.Remotes:WaitForChild("StrikerUI")
local goalRemote = game.ReplicatedStorage.Remotes:WaitForChild("StrikerGoal")

-------------------------------------------------
-- EMOJI SISTEMA
-------------------------------------------------

local function getEmoji(goals)

	if goals < 5 then
		return "😭⚽"
	elseif goals < 15 then
		return "😐⚽"
	elseif goals < 25 then
		return "👌⚽"
	elseif goals < 35 then
		return "😁⚽"
	else
		return "🔥⚽"
	end

end

-------------------------------------------------
-- UPDATE
-------------------------------------------------

uiRemote.OnClientEvent:Connect(function(combo, goals)

	-------------------------------------------------
	-- COMBO TEXTO
	-------------------------------------------------

	comboText.Text = combo.." GOALS "..getEmoji(combo)

	-------------------------------------------------
	-- BAR (GOALS ATÉ 50)
	-------------------------------------------------

	local percent = math.clamp(goals / 50, 0, 1)
	fill.Size = UDim2.new(percent,0,1,0)
	
	print("Striker UI:", combo, goals)

end)

-------------------------------------------------
-- 🎉 GOAL EFFECT
-------------------------------------------------

goalRemote.OnClientEvent:Connect(function()

	local sound = Instance.new("Sound")
	sound.SoundId = "rbxassetid://108581425993341"
	sound.Volume = 2
	sound.Parent = gui
	sound:Play()

	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(0.6,0.2)
	label.Position = UDim2.fromScale(0.5,0.4)
	label.AnchorPoint = Vector2.new(0.5,0.5)
	label.BackgroundTransparency = 1
	label.TextScaled = true
	label.Font = Enum.Font.Merriweather
	label.Text = "⚽ GOOOOAL ⚽"
	label.TextColor3 = Color3.fromRGB(255,215,0)
	label.Parent = gui

	game:GetService("TweenService"):Create(label,
		TweenInfo.new(0.5),
		{TextTransparency = 0}
	):Play()

	task.wait(1.5)
	label:Destroy()

end)