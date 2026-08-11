local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local RunFlowService = require(ServerScriptService.RunFlowService)
local RunSessionService = require(ServerScriptService.RunSessionService)

local SynergyService = require(ServerScriptService.Synergies.SynergyService)

local ModifierService = require(
	game.ServerScriptService.Modifiers.ModifierService
)

local Players = game:GetService("Players")


local RunDirector = {}

-------------------------------------------------
-- LIMPAR OBJETOS DA RUN
-------------------------------------------------

local function clearFolder(folderName)

	local folder = workspace:FindFirstChild(folderName)
	if not folder then return end

	for _,obj in ipairs(folder:GetChildren()) do
		obj:Destroy()
	end

	print("🧹 Limpou pasta:", folderName)

end

local function clearRunObjects()

	clearFolder("Artifacts")
	clearFolder("Chests")
	clearFolder("Enemies")

end

-------------------------------------------------
-- RUN STARTING
-------------------------------------------------

RunFlowService.Events.OnRunStarting.Event:Connect(function()

	print("🎬 RunDirector: limpando mapa")

	clearRunObjects()
	
	for _, player in ipairs(Players:GetPlayers()) do
		SynergyService:ResetPlayer(player)
		ReplicatedStorage.Remotes.WeaponsUpdated:FireClient(player, {})
	end

end)

-------------------------------------------------
-- RUN RUNNING
-------------------------------------------------

RunFlowService.Events.OnRunRunning.Event:Connect(function()

	print("🚀 RunDirector: gameplay ativo")

	for _,player in ipairs(game.Players:GetPlayers()) do
		ModifierService:ApplyModifier(player)
	end

end)

-------------------------------------------------
-- RUN ENDING
-------------------------------------------------

RunFlowService.Events.OnRunEnding.Event:Connect(function(result)

	print("🛑 RunDirector: run terminando")
	SynergyService:ResetPlayer(Players)
	ModifierService:Clear(Players)

end)

-------------------------------------------------
-- RUN RESULTS
-------------------------------------------------

RunFlowService.Events.OnRunResults.Event:Connect(function()

	print("📊 RunDirector: tela de resultados")

end)

return RunDirector