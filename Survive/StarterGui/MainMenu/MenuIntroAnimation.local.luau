local TweenService = game:GetService("TweenService")

local menu = script.Parent

local logo = menu:WaitForChild("LogoContainer"):WaitForChild("Logo")
local buttonsContainer = menu:WaitForChild("ButtonsContainer")

local tweenInfo = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- coleta botões
local buttons = {}

for _,container in ipairs(buttonsContainer:GetChildren()) do
	if container:IsA("Frame") then
		local button = container:FindFirstChildWhichIsA("TextButton")
		if button then
			table.insert(buttons, button)
		end
	end
end


local function playAnimation()

	-- reset visual
	logo.ImageTransparency = 1

	for _,button in ipairs(buttons) do
		button.BackgroundTransparency = 1
		button.TextTransparency = 1

		local stroke = button:FindFirstChild("UIStroke")
		if stroke then
			stroke.Transparency = 1
		end
	end

	-- anima logo
	TweenService:Create(
		logo,
		tweenInfo,
		{ImageTransparency = 0}
	):Play()

	task.wait(0.35)

	-- anima botões
	for _,button in ipairs(buttons) do

		local finalPos = button.Position
		button.Position = finalPos + UDim2.new(0,0,0,14)

		TweenService:Create(
			button,
			tweenInfo,
			{
				Position = finalPos,
				BackgroundTransparency = 0,
				TextTransparency = 0
			}
		):Play()

		local stroke = button:FindFirstChild("UIStroke")

		if stroke then
			TweenService:Create(
				stroke,
				tweenInfo,
				{Transparency = 0.5}
			):Play()
		end

		task.wait(0.12)
	end

end


-- primeira vez
playAnimation()

-- sempre que menu abrir
menu:GetPropertyChangedSignal("Enabled"):Connect(function()

	if menu.Enabled then
		playAnimation()
	end

end)