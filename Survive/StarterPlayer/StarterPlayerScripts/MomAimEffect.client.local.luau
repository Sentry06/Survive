local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local MomAimEffect = Remotes:WaitForChild("MomAimEffect")

-------------------------------------------------
-- UI SETUP
-------------------------------------------------

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MomAimUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local container = Instance.new("Frame")
container.Size = UDim2.fromScale(1,1)
container.BackgroundTransparency = 1
container.Parent = screenGui

-------------------------------------------------
-- EFFECT FUNCTION
-------------------------------------------------

local function showEffect()

	-- TEXTO
	local text = Instance.new("TextLabel")
	text.Size = UDim2.fromScale(0.3,0.1)
	text.Position = UDim2.fromScale(0.35,0.4)
	text.BackgroundTransparency = 1
	text.Text = "EXECUTED!"
	text.TextScaled = true
	text.TextColor3 = Color3.fromRGB(255, 80, 80)
	text.Font = Enum.Font.Merriweather
	text.Parent = container

	-- IMAGEM DO CHINELO
	local image = Instance.new("ImageLabel")
	image.Size = UDim2.fromScale(0.15,0.15)
	image.Position = UDim2.fromScale(0.425,0.25)
	image.BackgroundTransparency = 1
	image.Image = "rbxassetid://96137138854827" -- mesma da arma
	image.Parent = container

	-- ANIMAÇÃO
	text.TextTransparency = 1
	image.ImageTransparency = 1

	game:GetService("TweenService"):Create(text, TweenInfo.new(0.15), {
		TextTransparency = 0
	}):Play()

	game:GetService("TweenService"):Create(image, TweenInfo.new(0.15), {
		ImageTransparency = 0
	}):Play()

	task.delay(0.6, function()

		game:GetService("TweenService"):Create(text, TweenInfo.new(0.3), {
			TextTransparency = 1
		}):Play()

		game:GetService("TweenService"):Create(image, TweenInfo.new(0.3), {
			ImageTransparency = 1
		}):Play()

		task.delay(0.3, function()
			text:Destroy()
			image:Destroy()
		end)

	end)

end

-------------------------------------------------
-- EVENT
-------------------------------------------------

MomAimEffect.OnClientEvent:Connect(showEffect)