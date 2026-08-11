local player = game.Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

gui.Enabled = false

-------------------------------------------------
-- BACKGROUND FLASH
-------------------------------------------------

local flash = Instance.new("Frame")
flash.Size = UDim2.fromScale(1,1)
flash.BackgroundColor3 = Color3.fromRGB(255,0,0)
flash.BackgroundTransparency = 1
flash.Parent = gui

-------------------------------------------------
-- ALERT TEXT
-------------------------------------------------

local text = Instance.new("TextLabel")
text.Size = UDim2.fromScale(0.8,0.2)
text.Position = UDim2.fromScale(0.5,0.5)
text.AnchorPoint = Vector2.new(0.5,0.5)
text.BackgroundTransparency = 1
text.TextScaled = true
text.Font = Enum.Font.Arcade
text.TextColor3 = Color3.fromRGB(255,0,0)
text.TextStrokeTransparency = 0
text.TextStrokeColor3 = Color3.new(0,0,0)

text.Text = "⚠ ALERT ⚠\nTHE ███████ HAVE BREACHED CONTAINMENT"
text.Parent = gui

-------------------------------------------------
-- SOUND
-------------------------------------------------

local sound = Instance.new("Sound")
sound.SoundId = "rbxassetid://8610623488" -- sirene (troca se quiser)
sound.Volume = 2
sound.Looped = true
sound.Parent = gui

-------------------------------------------------
-- REMOTE
-------------------------------------------------

local remote = game.ReplicatedStorage.Remotes:WaitForChild("SCPAlert")

-------------------------------------------------
-- EFFECT
-------------------------------------------------

local TweenService = game:GetService("TweenService")

local function playEffect()

	gui.Enabled = true
	sound:Play()

	-------------------------------------------------
	-- FLASH LOOP
	-------------------------------------------------

	local running = true

	task.spawn(function()
		while running do

			TweenService:Create(flash,TweenInfo.new(0.3),{
				BackgroundTransparency = 0.6
			}):Play()

			task.wait(0.3)

			TweenService:Create(flash,TweenInfo.new(0.3),{
				BackgroundTransparency = 1
			}):Play()

			task.wait(0.3)
		end
	end)

	-------------------------------------------------
	-- TEXT SHAKE
	-------------------------------------------------

	task.spawn(function()
		while running do
			text.Position = UDim2.fromScale(
				0.5 + math.random(-2,2)/100,
				0.5 + math.random(-2,2)/100
			)
			task.wait(0.05)
		end
	end)

	-------------------------------------------------
	-- DURATION
	-------------------------------------------------

	task.wait(20)

	running = false

	sound:Stop()
	gui.Enabled = false
end

remote.OnClientEvent:Connect(playEffect)