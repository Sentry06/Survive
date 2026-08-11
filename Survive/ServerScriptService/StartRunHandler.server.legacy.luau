local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local StartRun = Remotes:WaitForChild("StartRun")

local GameState = ReplicatedStorage:WaitForChild("GameState")
local RunActive = GameState:WaitForChild("RunActive")

local runSpawn = workspace:WaitForChild("RunSpawn")

local RunFlowService = require(game.ServerScriptService.RunFlowService)

StartRun.OnServerEvent:Connect(function(player)

	if RunActive.Value then
		print("Run já ativa")
		return
	end

	print("🔥 RUN STARTED BY", player.Name)

	RunFlowService:StartRun()

	player:LoadCharacter()

	local character = player.Character or player.CharacterAdded:Wait()
	local root = character:WaitForChild("HumanoidRootPart")

	root.CFrame = runSpawn.CFrame + Vector3.new(0,3,0)

end)