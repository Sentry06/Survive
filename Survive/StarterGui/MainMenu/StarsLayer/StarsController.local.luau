local TweenService = game:GetService("TweenService")

local layer = script.Parent
local template = layer:WaitForChild("StarTemplate")

local stars = {}

local STAR_COUNT = 25

-- criar estrelas
for i = 1, STAR_COUNT do

	local star = template:Clone()
	star.Visible = true
	star.Parent = layer

	star.Position = UDim2.new(
		math.random(),
		0,
		math.random(),
		0
	)

	table.insert(stars, star)

end


-- animar estrelas
for _,star in pairs(stars) do

	task.spawn(function()

		while true do

			local fadeIn = TweenService:Create(
				star,
				TweenInfo.new(math.random(2,4), Enum.EasingStyle.Sine),
				{ImageTransparency = 0.2}
			)

			local fadeOut = TweenService:Create(
				star,
				TweenInfo.new(math.random(2,4), Enum.EasingStyle.Sine),
				{ImageTransparency = 1}
			)

			fadeIn:Play()
			fadeIn.Completed:Wait()

			fadeOut:Play()
			fadeOut.Completed:Wait()

		end

	end)

end