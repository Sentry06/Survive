local RunService = game:GetService("RunService")

local ArtifactVisualController = {}

local FLOAT_HEIGHT = 0.6
local FLOAT_SPEED = 2
local ROTATION_SPEED = 60

function ArtifactVisualController:Attach(model)

	if not model.PrimaryPart then return end

	local startPosition = model.PrimaryPart.Position
	local time = 0

	local connection
	connection = RunService.Heartbeat:Connect(function(dt)

		if not model or not model.Parent then
			connection:Disconnect()
			return
		end

		time += dt

		local floatOffset = math.sin(time * FLOAT_SPEED) * FLOAT_HEIGHT

		local baseCFrame = CFrame.new(startPosition + Vector3.new(0, floatOffset, 0))
		local rotation = CFrame.Angles(0, math.rad(time * ROTATION_SPEED), 0)

		model:PivotTo(baseCFrame * rotation)
	end)
end

return ArtifactVisualController
