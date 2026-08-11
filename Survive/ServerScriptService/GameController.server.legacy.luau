-- GameController.server
-- Controle global da RUN (VERSÃO ESTÁVEL REAL)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PhysicsService = game:GetService("PhysicsService")
local RunService = game:GetService("RunService")

local SynergyService = require(
	game.ServerScriptService.Synergies:WaitForChild("SynergyService")
)
-------------------------------------------------
-- CONFIG
-------------------------------------------------

Players.CharacterAutoLoads = false

-------------------------------------------------
-- GAME STATE
-------------------------------------------------

local GameState = ReplicatedStorage:WaitForChild("GameState")
local GamePaused = GameState:WaitForChild("GamePaused")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local TogglePause = Remotes:WaitForChild("TogglePause")

GamePaused.Value = false

_G.GameStarted = true
GameState.RunActive.Value = false
_G.RunResult = nil

-------------------------------------------------
-- COLLISION GROUP
-------------------------------------------------

local PLAYER_GROUP = "Players"

pcall(function()
	PhysicsService:RegisterCollisionGroup(PLAYER_GROUP)
end)

PhysicsService:CollisionGroupSetCollidable(PLAYER_GROUP, PLAYER_GROUP, false)

local function applyCollisionGroup(character)
	for _, obj in ipairs(character:GetDescendants()) do
		if obj:IsA("BasePart") then
			obj.CollisionGroup = PLAYER_GROUP
		end
	end
end

-------------------------------------------------
-- PAUSE SYSTEM (SEM RECURSÃO)
-------------------------------------------------

local function freezePlayer(player, frozen)

	local char = player.Character
	if not char then return end

	local humanoid = char:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end

	if frozen then
		humanoid:SetAttribute("Frozen", true)
		humanoid.WalkSpeed = 0
		humanoid.JumpPower = 0
	else
		humanoid:SetAttribute("Frozen", false)
		humanoid.WalkSpeed = 16
		humanoid.JumpPower = 50
	end
end

function _G.SetGamePaused(paused)

	if GamePaused.Value == paused then return end

	GamePaused.Value = paused

	for _, player in ipairs(Players:GetPlayers()) do
		freezePlayer(player, paused)
	end

	print(paused and "⏸️ JOGO PAUSADO" or "▶ JOGO RETOMADO")
end

-------------------------------------------------
-- TOGGLE PAUSE REMOTE
-------------------------------------------------

TogglePause.OnServerEvent:Connect(function(player, shouldPause)

	if not GameState.RunActive.Value then
		return
	end

	_G.SetGamePaused(shouldPause)

end)

-------------------------------------------------
-- MAX HP
-------------------------------------------------

local function applyMaxHP(player)

	local char = player.Character
	if not char then return end

	local humanoid = char:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end

	local ms = player:FindFirstChild("MatchStats")
	local attrs = ms and ms:FindFirstChild("Attributes")
	local maxHP = attrs and attrs:FindFirstChild("MaxHP")

	if not maxHP then return end

	if humanoid:GetAttribute("BaseMaxHealth") == nil then
		humanoid:SetAttribute("BaseMaxHealth", humanoid.MaxHealth)
	end

	local base = humanoid:GetAttribute("BaseMaxHealth")

	local oldMax = humanoid.MaxHealth
	local newMax = math.floor(base * maxHP.Value)

	local ratio = oldMax > 0 and humanoid.Health / oldMax or 1

	humanoid.MaxHealth = newMax
	humanoid.Health = math.clamp(newMax * ratio,1,newMax)

end
-------------------------------------------------
-- FINALIZAR RUN
-------------------------------------------------

local function endRun(result)

	if not GameState.RunActive.Value then return end

	GameState.RunActive.Value = false
	_G.RunResult = result

	_G.SetGamePaused(true)

	-- limpar inimigos vivos
	for _, enemy in ipairs(_G.Enemies or {}) do
		if enemy.Model and enemy.Model.Parent then
			enemy.Model:Destroy()
		end
	end

	table.clear(_G.Enemies)

	print("🏁 RUN FINALIZADA:", result)
end

-------------------------------------------------
-- INICIAR RUN
-------------------------------------------------

local function startRun()

	for _,player in ipairs(Players:GetPlayers()) do

		local stats = player:FindFirstChild("MatchStats")
		if stats then
			stats.ActiveSynergies:ClearAllChildren()

			for _,v in ipairs(stats.AttributeLevels:GetChildren()) do
				v.Value = 0
			end

			for _,player in ipairs(game.Players:GetPlayers()) do
				SynergyService:ResetPlayer(player)
			end

			local MULTIPLIER_ATTRS = {
				Damage = true,
				Range = true,
				ProjectileSpeed = true,
				AttackSize = true,
				MovementSpeed = true,
				MaxHP = true,
			}

			local INVERSE_ATTRS = {
				Cooldown = true,
				ShieldRegenDelay = true,
			}

			for _, v in ipairs(stats.SynergyBonuses:GetChildren()) do

				if MULTIPLIER_ATTRS[v.Name] or INVERSE_ATTRS[v.Name] then
					v.Value = 1
				else
					v.Value = 0
				end

			end
		end

	end

	if GameState.RunActive.Value then return end

	GameState.RunActive.Value = true
	_G.RunResult = nil
	_G.SetGamePaused(false)

	print("🔥 RUN INICIADA")
end

-------------------------------------------------
-- SETUP CHARACTER
-------------------------------------------------

local function setupCharacter(player, character)

	applyCollisionGroup(character)

	local humanoid = character:WaitForChild("Humanoid")

	task.defer(function()
		applyMaxHP(player)
	end)

	humanoid.Died:Once(function()

		if not GameState.RunActive.Value then return end

		print("💀 PLAYER MORREU — DERROTA")
		local RunResultController = require(game.ServerScriptService.RunResultController)
		RunResultController:FinishRun("Defeat")
	end)

	-- hook MaxHP upgrade
	task.defer(function()

		local ms = player:WaitForChild("MatchStats")
		local attrs = ms:WaitForChild("Attributes")
		local maxHP = attrs:WaitForChild("MaxHP")

		maxHP.Changed:Connect(function()
			applyMaxHP(player)
		end)

	end)
end

-------------------------------------------------
-- SETUP PLAYER
-------------------------------------------------

local function setupPlayer(player)
	local lobbySpawn = workspace:WaitForChild("LobbySpawn")

	local function teleportToLobby(character)

		local root = character:WaitForChild("HumanoidRootPart")

		root.CFrame = lobbySpawn.CFrame + Vector3.new(0,3,0)

	end

	player.CharacterAdded:Connect(function(character)

		setupCharacter(player, character)

		if not GameState.RunActive.Value then
			teleportToLobby(character)
		end

	end)

	player:LoadCharacter()
end

-------------------------------------------------
-- PLAYER CONNECTION
-------------------------------------------------

Players.PlayerAdded:Connect(setupPlayer)

-- Play Solo suporte
for _, player in ipairs(Players:GetPlayers()) do
	setupPlayer(player)
end

-------------------------------------------------
-- LIFE REGEN
-------------------------------------------------

RunService.Heartbeat:Connect(function(dt)

	if not GameState.RunActive.Value then return end
	if GamePaused.Value then return end

	for _, player in ipairs(Players:GetPlayers()) do

		local char = player.Character
		local humanoid = char and char:FindFirstChildOfClass("Humanoid")

		if not humanoid or humanoid.Health <= 0 then continue end

		local ms = player:FindFirstChild("MatchStats")
		local attrs = ms and ms:FindFirstChild("Attributes")
		local regen = attrs and attrs:FindFirstChild("LifeRegen")

		if regen and regen.Value > 0 then
			humanoid.Health = math.min(
				humanoid.MaxHealth,
				humanoid.Health + regen.Value * dt
			)
		end
	end
end)

local function resetMatchStats(player)

	local old = player:FindFirstChild("MatchStats")
	if old then
		old:Destroy()
	end

	local MatchStatsScript = require(game.ServerScriptService.MatchStatsCreator)
	MatchStatsScript:Create(player)

end

print("🎮 GameController DEFINITIVO ESTÁVEL")
