local TweenService = game:GetService("TweenService")

local container = script.Parent

for _,buttonContainer in pairs(container:GetChildren()) do

	local button = buttonContainer:FindFirstChildWhichIsA("TextButton")

	if button then

		local stroke = button:FindFirstChild("UIStroke")

		if stroke then

			task.spawn(function()

				while true do

					local glow = TweenService:Create(
						stroke,
						TweenInfo.new(1.5),
						{Transparency = 0.35}
					)

					local fade = TweenService:Create(
						stroke,
						TweenInfo.new(1.5),
						{Transparency = 0.5}
					)

					glow:Play()
					glow.Completed:Wait()

					fade:Play()
					fade.Completed:Wait()

				end

			end)

		end
	end

end