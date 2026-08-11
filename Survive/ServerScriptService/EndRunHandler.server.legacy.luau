local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local RequestEndRun = Remotes:WaitForChild("RequestEndRun")

local RunResultController = require(game.ServerScriptService:WaitForChild("RunResultController"))

RequestEndRun.OnServerEvent:Connect(function(player)

	local GameState = ReplicatedStorage:WaitForChild("GameState")
	local RunActive = GameState:WaitForChild("RunActive")

	if not RunActive.Value then
		return
	end

	print("⛔ Player requested End Run:", player.Name)

	RunResultController:FinishRun("Defeat")
end)