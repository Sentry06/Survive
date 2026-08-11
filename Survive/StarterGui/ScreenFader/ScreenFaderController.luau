local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local ScreenFader = {}

local function getFrame()

	local player = Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")

	local screenFader = playerGui:WaitForChild("ScreenFader")
	local frame = screenFader:WaitForChild("FadeFrame")

	return frame

end


function ScreenFader.FadeOut()

	local frame = getFrame()

	frame.Visible = true
	frame.BackgroundTransparency = 1

	TweenService:Create(
		frame,
		TweenInfo.new(0.4),
		{BackgroundTransparency = 0}
	):Play()

	task.wait(0.4)

end


function ScreenFader.FadeIn()

	local frame = getFrame()

	TweenService:Create(
		frame,
		TweenInfo.new(0.4),
		{BackgroundTransparency = 1}
	):Play()

	task.wait(0.4)

	frame.Visible = false

end

return ScreenFader