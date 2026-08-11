-- EnemySpawner.server
-- VERSÃO REESCRITA - ESCALA PROFISSIONAL

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")

local XPService = require(game.ServerScriptService.XPService)
local DifficultyService = require(game.ServerScriptService.DifficultyService)
local DamageService = require(game.ServerScriptService.Combat.DamageService)
local EnemyTimeController = require(
	game.ServerScriptService.Combat:WaitForChild("EnemyTimeController")
)
local GoldService = require(game.ServerScriptService.GoldService)

local GameState = ReplicatedStorage:WaitForChild("GameState")
local GamePaused = GameState:WaitForChild("GamePaused")
local elapsedValue = GameState:WaitForChild("ElapsedTime")

_G.Enemies = _G.Enemies or {}

-------------------------------------------------
-- CONFIG BASE
-------------------------------------------------

local BASE_SPAWN_RATE = 0.8         -- mais rápido
local BASE_MAX_ENEMIES = 150         -- muito maior
local BASE_HP = 20                   -- mais tanque
local BASE_DAMAGE = 15
local BASE_SPEED = 10
local BASE_XP = 10

local ATTACK_RANGE = 6
local ATTACK_COOLDOWN = 1.2

local SPAWN_DISTANCE_MIN = 50
local SPAWN_DISTANCE_MAX = 80

-------------------------------------------------
-- FOLDER
-------------------------------------------------

local enemiesFolder = workspace:FindFirstChild("Enemies")
if not enemiesFolder then
	enemiesFolder = Instance.new("Folder")
	enemiesFolder.Name = "Enemies"
	enemiesFolder.Parent = workspace
end

local lastSpawn = 0

-------------------------------------------------
-- UTIL	
-------------------------------------------------

local function getPlayerCenter()
	for _, player in ipairs(Players:GetPlayers()) do
		local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
		if root then
			return root.Position
		end
	end
	return Vector3.new(0,5,0)
end
local function getRandomSpawnPos()

	local center = getPlayerCenter()

	for attempt = 1, 12 do

		-- 🎯 DIREÇÃO TOTALMENTE ALEATÓRIA
		local angle = math.random() * math.pi * 2

		-- 📏 DISTÂNCIA SEGURA
		local dist = math.random(SPAWN_DISTANCE_MIN, SPAWN_DISTANCE_MAX)

		local offset = Vector3.new(
			math.cos(angle) * dist,
			0,
			math.sin(angle) * dist
		)

		local spawnPos = center + offset

		-- 🚫 GARANTE DISTÂNCIA MÍNIMA REAL DO PLAYER
		if (spawnPos - center).Magnitude < SPAWN_DISTANCE_MIN then
			continue
		end

		-- 🚫 EVITA MUITOS INIMIGOS PERTO DO PLAYER
		local nearbyCount = 0

		for _, e in ipairs(_G.Enemies) do
			if e.Alive and e.Root then
				if (e.Root.Position - center).Magnitude < 25 then
					nearbyCount += 1
				end
			end
		end

		if nearbyCount > 8 then
			continue
		end

		-- 🚫 EVITA SPAWN COLADO EM OUTRO INIMIGO
		local tooClose = false
		for _, e in ipairs(_G.Enemies) do
			if e.Alive and e.Root then
				if (e.Root.Position - spawnPos).Magnitude < 8 then
					tooClose = true
					break
				end
			end
		end

		if tooClose then
			continue
		end

		-- 📌 RAYCAST PARA CHÃO
		local origin = spawnPos + Vector3.new(0, 100, 0)

		local rayParams = RaycastParams.new()
		rayParams.FilterDescendantsInstances = {workspace.Enemies}
		rayParams.FilterType = Enum.RaycastFilterType.Blacklist

		local result = workspace:Raycast(origin, Vector3.new(0, -200, 0), rayParams)

		if result then
			return result.Position + Vector3.new(0, 4, 0)
		else
			return spawnPos + Vector3.new(0, 5, 0)
		end
	end

	-- fallback seguro
	return center + Vector3.new(0, 5, SPAWN_DISTANCE_MAX)
end

-------------------------------------------------
-- IA
-------------------------------------------------

local function startEnemyAI(enemyData, baseDamage)

	local humanoid = enemyData.Humanoid
	local root = enemyData.Root
	local lastAttack = 0

	enemyData.AIConn = RunService.Heartbeat:Connect(function(dt)

		if not enemyData.Alive then return end

		if GamePaused.Value or EnemyTimeController:IsFrozen() then
			humanoid.WalkSpeed = 0
			humanoid:MoveTo(root.Position)
			return
		end

		local diff = DifficultyService:GetStats()

		local closestPlayer
		local closestRoot
		local minDist = math.huge

		for _, player in ipairs(Players:GetPlayers()) do
			local pr = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
			if pr then
				local d = (pr.Position - root.Position).Magnitude
				if d < minDist then
					minDist = d
					closestPlayer = player
					closestRoot = pr
				end
			end
		end

		if closestRoot then
			local slow = EnemyTimeController:GetSlow()
			local mod = _G.RunModifiers or {}

			humanoid.WalkSpeed =
				BASE_SPEED
				* diff.SpeedMultiplier
				* slow
				* (mod.EnemySpeed or 1)
			
			humanoid:MoveTo(closestRoot.Position)

			lastAttack += dt

			if minDist <= ATTACK_RANGE and lastAttack >= ATTACK_COOLDOWN then

				local mod = _G.RunModifiers or {}

				DamageService:TryDamagePlayer(
					root,
					baseDamage
						* diff.DamageMultiplier
						* (mod.EnemyDamage or 1),
					ATTACK_RANGE
				)

				lastAttack = 0
			end
		end
	end)
end

-------------------------------------------------
-- SPAWN
-------------------------------------------------

local function spawnEnemy()

	-- evita spawn muito perto do player se já tiver muitos próximos
	local closeCount = 0
	local playerPos = getPlayerCenter()

	for _, e in ipairs(_G.Enemies) do
		if e.Alive and e.Root then
			if (e.Root.Position - playerPos).Magnitude < 20 then
				closeCount += 1
			end
		end
	end

	if closeCount > 8 then
		return
	end

	if not GameState.RunActive.Value or GamePaused.Value then return end

	local diff = DifficultyService:GetStats()

	local runTime = 0
	if elapsedValue and elapsedValue.Value then
		runTime = elapsedValue.Value
	end
	
	-- Crescimento suave nos primeiros 3 minutos
	local timeMultiplier = 1 + math.clamp(runTime / 240, 0, 2)

	local maxEnemies = math.floor(BASE_MAX_ENEMIES * diff.SpawnMultiplier * timeMultiplier)

	local count = 0
	for _, e in ipairs(_G.Enemies) do
		if not e.IsBoss then
			count += 1
		end
	end

	if count >= maxEnemies then return end

	local template = ReplicatedStorage.Enemies:FindFirstChild("BasicEnemy")
	if not template then return end

	local enemy = template:Clone()
	local humanoid = enemy:FindFirstChildOfClass("Humanoid")
	local root = enemy:FindFirstChild("HumanoidRootPart")

	if not humanoid or not root then
		enemy:Destroy()
		return
	end

	local hp = math.floor(BASE_HP * diff.HealthMultiplier)

	humanoid.MaxHealth = hp
	humanoid.Health = hp

	enemy:PivotTo(CFrame.new(getRandomSpawnPos()))
	enemy.Parent = enemiesFolder

	local enemyData = {
		Alive = true,
		Root = root,
		Humanoid = humanoid,
		Model = enemy
	}

	table.insert(_G.Enemies, enemyData)

	startEnemyAI(enemyData, BASE_DAMAGE)

	-------------------------------------------------
	-- MORTE
	-------------------------------------------------

	humanoid.Died:Connect(function()

		enemyData.Alive = false

		if enemyData.AIConn then
			enemyData.AIConn:Disconnect()
		end

		for i, e in ipairs(_G.Enemies) do
			if e == enemyData then
				table.remove(_G.Enemies, i)
				break
			end
		end

		local closestPlayer
		local minDist = math.huge

		for _, p in ipairs(Players:GetPlayers()) do
			local pr = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
			if pr then
				local d = (pr.Position - root.Position).Magnitude
				if d < minDist then
					minDist = d
					closestPlayer = p
				end
			end
		end

		if closestPlayer then
			local ms = closestPlayer:FindFirstChild("MatchStats")
			if ms then
				local xp = ms.XP
				local level = ms.Level
				local xpToNext = ms.XPToNext

				local runTime = elapsedValue.Value or 0
				local minute = runTime / 60

				-- =========================
				-- 🎯 ESCALA DE XP POR FASE
				-- =========================

				local phaseMultiplier = 1

				if minute <= 10 then
					phaseMultiplier = 1.6  -- early muito forte
				elseif minute <= 15 then
					phaseMultiplier = 1.3  -- mid game ainda forte
				else
					phaseMultiplier = 1.1  -- late estabiliza
				end

				-- crescimento leve contínuo
				local timeScaling = 1 + (minute * 0.04)

				local mod = _G.RunModifiers or {}

				local gain = math.floor(
					BASE_XP
						* (mod.EnemyXP or 1)
						* diff.XPMultiplier
						* phaseMultiplier
						* timeScaling
				)

				xp.Value += gain

				while xp.Value >= xpToNext.Value do
					xp.Value -= xpToNext.Value
					level.Value += 1
					xpToNext.Value = XPService:GetXPRequired(level.Value)
				end
			end

			GoldService:GiveRunGold(closestPlayer, 1, "Enemy")
		end

		task.delay(0.1, function()
			if enemy and enemy.Parent then
				enemy:Destroy()
			end
		end)
		if closestPlayer then
			local ms = closestPlayer:FindFirstChild("MatchStats")
			if ms and ms:FindFirstChild("EnemiesKilled") then
				ms.EnemiesKilled.Value += 1
			end
		end
		
	end)
end

-------------------------------------------------
-- LOOP
-------------------------------------------------

RunService.Heartbeat:Connect(function(dt)

	if not GameState.RunActive.Value or GamePaused.Value then return end

	lastSpawn += dt
	local runTime = elapsedValue.Value or 0
	local diff = DifficultyService:GetStats()

	-- =========================
	-- 📈 ESCALA DE DENSIDADE
	-- =========================

	local minute = runTime / 60

	-- Começa já com pressão boa
	local baseDensity = 30

	-- Crescimento suave por minuto
	local densityGrowth = minute * 10

	local maxEnemies = math.floor(
		(baseDensity + densityGrowth)
			* diff.SpawnMultiplier
	)

	maxEnemies = math.clamp(maxEnemies, 15, 180)

	-- Conta vivos
	local count = 0
	for _, e in ipairs(_G.Enemies) do
		if e.Alive and not e.IsBoss then
			count += 1
		end
	end

	if count >= maxEnemies then return end

	-- =========================
	-- ⏱️ CONTROLE DE RITMO
	-- =========================

	-- Intervalo começa rápido
	local baseInterval = 0.9

	-- Vai diminuindo lentamente
	local intervalDecay = minute * 0.05

	local mod = _G.RunModifiers or {}

	local spawnInterval =
		(baseInterval - intervalDecay)
		/ (mod.SpawnRate or 1)
	spawnInterval = math.clamp(spawnInterval, 0.25, 1)

	if lastSpawn < spawnInterval then return end

	-- =========================
	-- 💥 BURST INTELIGENTE
	-- =========================

	-- Burst começa em 2 já no início
	local burst = 2 + math.floor(minute / 2)

	burst = math.clamp(burst, 2, 6)

	-- Segurança: não ultrapassar maxEnemies
	burst = math.min(burst, maxEnemies - count)

	for i = 1, burst do
		spawnEnemy()
	end

	lastSpawn = 0
end)

print("👹 EnemySpawner REESCRITO (escala progressiva real)")
