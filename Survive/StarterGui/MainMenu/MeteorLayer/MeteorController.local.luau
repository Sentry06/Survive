local TweenService = game:GetService("TweenService")

local layer = script.Parent
local template = layer:WaitForChild("MeteorTemplate")

local function spawnMeteor()

	local meteor = template:Clone()
	meteor.Visible = true
	meteor.Parent = layer

	local startY = math.random(10,40)/100
	local endY = startY + 0.2

	meteor.Position = UDim2.new(-0.2,0,startY,0)

	local tween = TweenService:Create(
		meteor,
		TweenInfo.new(1.2, Enum.EasingStyle.Linear),
		{
			Position = UDim2.new(1.2,0,endY,0),
			ImageTransparency = 1
		}
	)

	tween:Play()

	tween.Completed:Connect(function()
		meteor:Destroy()
	end)

end


while true do

	task.wait(math.random(4,8))

	spawnMeteor()

end