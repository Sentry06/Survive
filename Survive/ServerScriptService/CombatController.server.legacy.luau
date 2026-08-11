-- CombatController.server
-- Controla ataques automáticos
-- RESPEITA GameState.GamePaused (VERSÃO FINAL)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local enemiesFolder = workspace:WaitForChild("Enemies")

local RunService = game:GetService("RunService")

-- =========================
-- GAME STATE
-- =========================
local GameState = ReplicatedStorage:WaitForChild("GameState")
local GamePaused = GameState:WaitForChild("GamePaused")

-- =========================
-- REMOTES
-- =========================
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local AttackEvent = Remotes:WaitForChild("Attack") -- BindableEvent

local Workspace = game:GetService("Workspace")

local enemiesFolder = Workspace:FindFirstChild("Enemies")
if not enemiesFolder then
	enemiesFolder = Instance.new("Folder")
	enemiesFolder.Name = "Enemies"
	enemiesFolder.Parent = Workspace
end

-- =========================
-- CONFIG
-- =========================
local ATTACK_RANGE = 40
local BASE_ATTACK_INTERVAL = 0.25

local lastAttack = {}

-- =========================
-- MAIN LOOP
-- =========================
RunService.Heartbeat:Connect(function()

	-- ⏸️ PAUSA GLOBAL
	if GamePaused.Value then
		return
	end

	-- 🔒 Partida ainda não começou
	if not _G.GameStarted then
		return
	end

	for _, player in ipairs(Players:GetPlayers()) do

		local char = player.Character
		local root = char and char:FindFirstChild("HumanoidRootPart")
		if not root then
			continue
		end

		-- 🔥 GARANTE QUE TEM ARMA
		local weapon = player:FindFirstChild("Weapon")
		if not weapon then
			continue
		end

		-- 🔥 PEGA ATRIBUTOS FINAIS (ÚNICA FONTE DE VERDADE)
		local attrs = weapon:GetFinalAttributes()
		if not attrs then
			continue
		end

		-- 🔥 COOLDOWN REAL
		local cooldown = attrs.Cooldown or 1
		local attackInterval = BASE_ATTACK_INTERVAL * cooldown

		-- 🔥 CONTROLE DE TEMPO
		lastAttack[player] = lastAttack[player] or 0

		if tick() - lastAttack[player] < attackInterval then
			continue
		end

		-- 🔍 PROCURA INIMIGO MAIS PRÓXIMO
		local closestEnemy
		local minDist = ATTACK_RANGE

		for _, enemy in ipairs(enemiesFolder:GetChildren()) do
			local eroot = enemy:FindFirstChild("HumanoidRootPart")
			if eroot then
				local d = (eroot.Position - root.Position).Magnitude
				if d < minDist then
					minDist = d
					closestEnemy = enemy
				end
			end
		end

		-- ⚔️ ATAQUE
		if closestEnemy then
			lastAttack[player] = tick()
			AttackEvent:Fire(player, closestEnemy)
		end
	end

end)

print("⚔️ CombatController FINAL (respeita GamePaused)")