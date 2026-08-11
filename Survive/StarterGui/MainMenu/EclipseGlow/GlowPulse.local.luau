local TweenService = game:GetService("TweenService")

local glow = script.Parent
local scale = glow:WaitForChild("UIScale")

while true do

	local expand = TweenService:Create(
		scale,
		TweenInfo.new(3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
		{Scale = 1.08}
	)

	local shrink = TweenService:Create(
		scale,
		TweenInfo.new(3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
		{Scale = 1}
	)

	expand:Play()
	expand.Completed:Wait()

	shrink:Play()
	shrink.Completed:Wait()

end