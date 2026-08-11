local TweenService = game:GetService("TweenService")

local scale = script.Parent:WaitForChild("UIScale")

while true do

	local grow = TweenService:Create(
		scale,
		TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
		{Scale = 1.03}
	)

	local shrink = TweenService:Create(
		scale,
		TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
		{Scale = 1}
	)

	grow:Play()
	grow.Completed:Wait()

	shrink:Play()
	shrink.Completed:Wait()

end