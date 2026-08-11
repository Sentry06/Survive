local player = game.Players.LocalPlayer
local mouse = player:GetMouse()

local background = script.Parent.Background

local intensity = 0.015

mouse.Move:Connect(function()

	local camera = workspace.CurrentCamera
	local viewport = camera.ViewportSize

	local x = (mouse.X / viewport.X) - 0.5
	local y = (mouse.Y / viewport.Y) - 0.5

	background.Position = UDim2.new(
		0.5 + x * intensity,
		0,
		0.5 + y * intensity,
		0
	)

end)