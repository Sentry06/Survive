local TweenService = game:GetService("TweenService")

local container = script.Parent

for _,buttonContainer in pairs(container:GetChildren()) do

	local button = buttonContainer:FindFirstChildWhichIsA("TextButton")

	if button then

		local scale = button:FindFirstChild("UIScale")
		local stroke = button:FindFirstChild("UIStroke")

		if scale then

			local hoverGrow = TweenService:Create(scale,TweenInfo.new(0.12),{Scale = 1.05})
			local hoverShrink = TweenService:Create(scale,TweenInfo.new(0.12),{Scale = 1})

			local pressDown = TweenService:Create(scale,TweenInfo.new(0.08),{Scale = 0.97})
			local pressUp = TweenService:Create(scale,TweenInfo.new(0.08),{Scale = 1.05})

			button.MouseEnter:Connect(function()
				hoverGrow:Play()
				if stroke then stroke.Transparency = 0.2 end
			end)

			button.MouseLeave:Connect(function()
				hoverShrink:Play()
				if stroke then stroke.Transparency = 0.5 end
			end)

			button.MouseButton1Down:Connect(function()
				pressDown:Play()
			end)

			button.MouseButton1Up:Connect(function()
				pressUp:Play()
			end)

		end
	end
end