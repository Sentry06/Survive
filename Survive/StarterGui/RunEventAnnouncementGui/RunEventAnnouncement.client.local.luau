local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local EventRemote = Remotes:WaitForChild("RunEventAnnouncement")

-------------------------------------------------
-- GUI
-------------------------------------------------

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RunEventUI"
screenGui.Parent = player:WaitForChild("PlayerGui")

local label = Instance.new("TextLabel")

label.Size = UDim2.new(0.4,0,0.08,0)
label.Position = UDim2.new(0.3,0,0.1,0)

label.BackgroundTransparency = 1
label.TextScaled = true
label.TextColor3 = Color3.fromRGB(226, 197, 33)

label.Font = Enum.Font.Merriweather
label.TextStrokeTransparency = 0.5
label.TextStrokeColor3 = Color3.fromRGB(0,0,0)

label.TextTransparency = 1

label.Parent = screenGui

-------------------------------------------------
-- EVENT
-------------------------------------------------

EventRemote.OnClientEvent:Connect(function(text)

	label.Text = text
	label.TextTransparency = 1

	local fadeIn = TweenService:Create(
		label,
		TweenInfo.new(0.4),
		{TextTransparency = 0}
	)

	local fadeOut = TweenService:Create(
		label,
		TweenInfo.new(0.6),
		{TextTransparency = 1}
	)

	fadeIn:Play()

	task.wait(2)

	fadeOut:Play()

end)