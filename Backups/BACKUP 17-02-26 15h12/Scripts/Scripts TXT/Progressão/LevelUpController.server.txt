-- LevelUpController.server
-- AUTORIDADE ÚNICA DO LEVEL UP (DEFINITIVO)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameState = ReplicatedStorage:WaitForChild("GameState")
local GamePauseService = require(
	game.ServerScriptService:WaitForChild("GamePauseService")
)
local GamePaused = GameState:WaitForChild("GamePaused")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local LevelUpGui = Remotes:WaitForChild("LevelUpGui")
local PickUpgrade = Remotes:WaitForChild("PickUpgrade")

local UpgradePool = require(game.ServerScriptService.Upgrades.UpgradePool)

local ALL_ATTRIBUTES = {
	"Damage",
	"Cooldown",
	"Range",
	"MultiAttack",
	"MovementSpeed",
	"AttackSize",
	"ProjectileSpeed",
	"Luck",
	"Shield",
	"ShieldRegenDelay",
	"MaxHP",
	"LifeRegen",
	"ProjectilePierce",
	"AreaDamage",
}

	
local playerPools = {}
local levelUpOpen = {}

local function openLevelUp(player)
	if levelUpOpen[player] then return end

	local pool = UpgradePool.new(nil, ALL_ATTRIBUTES)
	playerPools[player] = pool
	levelUpOpen[player] = true

	GamePauseService:AddPause("LevelUp")

	local options = pool:RollAttributeOptions(3)
	LevelUpGui:FireClient(player, options)

	print("🃏 LevelUp ABERTO para", player.Name)
end

local function closeLevelUp(player)
	levelUpOpen[player] = nil
	playerPools[player] = nil

	GamePauseService:RemovePause("LevelUp")

	print("▶ LevelUp FECHADO para", player.Name)
end

-- RECEBE AÇÃO DO CLIENT
PickUpgrade.OnServerEvent:Connect(function(player, data)
	if not levelUpOpen[player] then return end
	local pool = playerPools[player]
	if not pool then return end

	if data.Action == "REROLL" then
		local options = pool:RollAttributeOptions(3)
		LevelUpGui:FireClient(player, options)
		return
	end

	if data.Action == "BANISH" then
		pool:Ban(data.UpgradeId)
		local options = pool:RollAttributeOptions(3)
		LevelUpGui:FireClient(player, options)
		return
	end

	if data.Action == "PICK" then
		closeLevelUp(player)
	end
end)

-- HOOK DE LEVEL
local function hookPlayer(player)
	local level = player:WaitForChild("MatchStats"):WaitForChild("Level")
	local last = level.Value

	level.Changed:Connect(function(new)
		if new > last then
			openLevelUp(player)
		end
		last = new
	end)
end

Players.PlayerAdded:Connect(hookPlayer)
for _, p in ipairs(Players:GetPlayers()) do
	hookPlayer(p)
end

print("🃏 LevelUpController DEFINITIVO (autoridade única)")
