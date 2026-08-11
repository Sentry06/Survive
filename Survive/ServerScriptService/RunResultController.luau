local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameState = ReplicatedStorage:WaitForChild("GameState")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local GamePaused = GameState:WaitForChild("GamePaused")
local RunActive = GameState:WaitForChild("RunActive")
local FinalBattleActive = GameState:WaitForChild("FinalBattleActive")
local RunResult = GameState:WaitForChild("RunResult")
local RequestEndRun = Remotes:WaitForChild("RequestEndRun")
local GoldService = require(game.ServerScriptService.GoldService)
local ArtifactService = require(game.ServerScriptService.Artifacts.ArtifactService)
local RunSessionService = require(game.ServerScriptService.RunSessionService)

local ShowEndScreen = Remotes:WaitForChild("ShowEndScreen")
local RequestSummary = Remotes:WaitForChild("RequestSummary")
local ShowSummaryScreen = Remotes:WaitForChild("ShowSummaryScreen")


local RunResultController = {}

local LastRunStats = {}

-------------------------------------------------
-- COLETAR ESTATÍSTICAS
-------------------------------------------------

local function collectStats(player)

	local stats = {
		Gold = 0,
		EnemiesKilled = 0,
		BossesKilled = 0,
		ArtifactsActivated = 0,
		WeaponsEquipped = 0,
		SynergiesUnlocked = 0,
		Level = 1,
		TimeSurvived = 0,
		Result = RunResult.Value
	}

	local ms = player:FindFirstChild("MatchStats")
	if not ms then return stats end

	if ms:FindFirstChild("Gold") then
		stats.Gold = ms.Gold.Value
	end

	if ms:FindFirstChild("EnemiesKilled") then
		stats.EnemiesKilled = ms.EnemiesKilled.Value
	end

	if ms:FindFirstChild("BossesKilled") then
		stats.BossesKilled = ms.BossesKilled.Value
	end

	if ms:FindFirstChild("ArtifactsActivated") then
		stats.ArtifactsActivated = ms.ArtifactsActivated.Value
	end

	if ms:FindFirstChild("WeaponsEquipped") then
		stats.WeaponsEquipped = ms.WeaponsEquipped.Value
	end

	if ms:FindFirstChild("SynergiesUnlocked") then
		stats.SynergiesUnlocked = ms.SynergiesUnlocked.Value
	end

	if ms:FindFirstChild("Level") then
		stats.Level = ms.Level.Value
	end

	if ms:FindFirstChild("RunDuration") then
		stats.TimeSurvived = ms.RunDuration.Value
	end

	return stats
end

-------------------------------------------------
-- UNLOCK MODIFIER
-------------------------------------------------

local WeaponModifiers = {

	Knife = "Berserker",
	BolaFutebol = "Pinball",
	Chinelo = "MothersWrath",
	Pancadao = "Bassquake",
	Bricks = "Demolition",
	Boomerang = "Cyclone",
	Molotov = "Inferno",
	CardDealer = "RoyalGambit",
	SCPNecromancer = "ContainmentBreach"

}

local function unlockModifier(player)

	local global = player:FindFirstChild("GlobalStats")
	if not global then return end

	local selectedWeapon = global:FindFirstChild("SelectedWeapon")
	if not selectedWeapon then return end

	local modifierId = WeaponModifiers[selectedWeapon.Value]
	if not modifierId then return end

	local unlockedFolder = global:FindFirstChild("UnlockedModifiers")
	if not unlockedFolder then return end

	if unlockedFolder:FindFirstChild(modifierId) then
		return
	end

	local flag = Instance.new("BoolValue")
	flag.Name = modifierId
	flag.Value = true
	flag.Parent = unlockedFolder

	print("🔓 Modifier desbloqueado:", modifierId, "para", player.Name)

end

-------------------------------------------------
-- FINALIZAR RUN
-------------------------------------------------

function RunResultController:FinishRun(result)

	if not RunActive.Value then return end

	local RunFlowService = require(game.ServerScriptService.RunFlowService)
	RunFlowService:EndRun(result)

	RunActive.Value = false
	FinalBattleActive.Value = false
	RunResult.Value = result

	GamePaused.Value = true
	
	print("🏁 RUN FINALIZADA:", result)

	for _, player in ipairs(Players:GetPlayers()) do

		local stats = collectStats(player)

		-- BONUS DE VITÓRIA
		local victoryBonus = 0
		if result == "Victory" then
			victoryBonus = 1000
			stats.Gold += victoryBonus

			unlockModifier(player)

		end
		
		if result == "Victory" then

			local ModifierUnlockService = require(
				game.ServerScriptService.Modifiers.ModifierUnlockService
			)

			ModifierUnlockService:UnlockFromWeapon(player)

		end

		stats.VictoryBonus = victoryBonus

		LastRunStats[player.UserId] = stats

		GoldService:CommitRunGold(player)

		ShowEndScreen:FireClient(player, result, stats)
	end
end

RequestEndRun.OnServerEvent:Connect(function(player)

	local GameState = ReplicatedStorage:WaitForChild("GameState")
	local RunActive = GameState:WaitForChild("RunActive")

	if not RunActive.Value then return end

	RunResultController:FinishRun("Defeat")

end)

RequestSummary.OnServerEvent:Connect(function(player)

	local stats = LastRunStats[player.UserId]
	if not stats then return end

	ShowSummaryScreen:FireClient(player, stats)

end)

return RunResultController
