local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
local SynergyUnlocked = ReplicatedStorage.Remotes:WaitForChild("SynergyUnlocked")

--------------------------------------------------
-- GUI BASE
--------------------------------------------------

local gui = Instance.new("ScreenGui")
gui.Name = "SynergyCinematic"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

gui.Enabled = false

local dark = Instance.new("Frame")
dark.Size = UDim2.fromScale(1,1)
dark.BackgroundColor3 = Color3.new(0,0,0)
dark.BackgroundTransparency = 1
dark.Parent = gui

local icon = Instance.new("ImageLabel")
icon.Size = UDim2.fromOffset(200,200)
icon.Position = UDim2.fromScale(0.5,0.5)
icon.AnchorPoint = Vector2.new(0.5,0.5)
icon.BackgroundTransparency = 1
icon.Parent = dark

local nameLabel = Instance.new("TextLabel")
nameLabel.Size = UDim2.fromScale(0.8,0.1)
nameLabel.Position = UDim2.fromScale(0.5,0.7)
nameLabel.AnchorPoint = Vector2.new(0.5,0.5)
nameLabel.BackgroundTransparency = 1
nameLabel.TextScaled = true
nameLabel.Font = Enum.Font.Merriweather
nameLabel.TextColor3 = Color3.new(1,1,1)
nameLabel.Parent = dark

local descLabel = Instance.new("TextLabel")
descLabel.Size = UDim2.fromScale(0.8,0.08)
descLabel.Position = UDim2.fromScale(0.5,0.78)
descLabel.AnchorPoint = Vector2.new(0.5,0.5)
descLabel.BackgroundTransparency = 1
descLabel.TextScaled = true
descLabel.Font = Enum.Font.Merriweather
descLabel.TextColor3 = Color3.fromRGB(200,200,200)
descLabel.Parent = dark

--------------------------------------------------
-- EFEITO
--------------------------------------------------

local function playCinematic(data)

	gui.Enabled = true

	icon.Image = data.Image
	nameLabel.Text = data.DisplayName
	descLabel.Text = data.Description

	-- Escurecer tela
	TweenService:Create(
		dark,
		TweenInfo.new(0.4),
		{BackgroundTransparency = 0.3}
	):Play()

	-- Ícone explode do centro
	icon.Size = UDim2.fromOffset(0,0)

	TweenService:Create(
		icon,
		TweenInfo.new(0.6, Enum.EasingStyle.Back),
		{Size = UDim2.fromOffset(200,200)}
	):Play()

	-- Pequeno brilho pulsando
	task.wait(2)

	-- Fade out
	TweenService:Create(
		dark,
		TweenInfo.new(0.5),
		{BackgroundTransparency = 1}
	):Play()

	task.wait(0.5)

	gui.Enabled = false
end

SynergyUnlocked.OnClientEvent:Connect(playCinematic)