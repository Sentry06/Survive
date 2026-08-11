local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local ReturnToMenu = Remotes:WaitForChild("ReturnToMenu")

local RunSessionService = require(game.ServerScriptService.RunSessionService)

local lobbySpawn = workspace:WaitForChild("LobbySpawn")

local RunFlowService = require(game.ServerScriptService.RunFlowService)

ReturnToMenu.OnServerEvent:Connect(function(player)

	print("🏠 Player returned to lobby:", player.Name)

	RunSessionService:ResetRun()

	RunFlowService:ReturnToLobby()

	local character = player.Character
	if not character then return end

	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then return end

	root.CFrame = lobbySpawn.CFrame + Vector3.new(0,3,0)

end)