local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local DifficultyService = require(game.ServerScriptService.DifficultyService)
local RunResultController = require(game.ServerScriptService.RunResultController)

local GameState = ReplicatedStorage:WaitForChild("GameState")
local RunActive = GameState:WaitForChild("RunActive")
local GamePaused = GameState:WaitForChild("GamePaused")
local FinalBattleActive = GameState:WaitForChild("FinalBattleActive")

_G.Enemies = _G.Enemies or {}

-------------------------------------------------
-- CONFIG
-------------------------------------------------

local FINAL_BOSS_TIME = 1200 -- tempo reduzido para teste
local spawned = false
local bossConnection = nil

-------------------------------------------------
-- IA DO BOSS
-------------------------------------------------

local function startFinalBossAI(bossData)

	local humanoid = bossData.Humanoid
	local root = bossData.Root

	humanoid.WalkSpeed = 20

	bossConnection = RunService.Heartbeat:Connect(function()

		if not RunActive.Value then return end
		if GamePaused.Value then return end
		if humanoid.Health <= 0 then return end

		local closestRoot
		local minDist = math.huge

		for _, player in ipairs(Players:GetPlayers()) do
			local char = player.Character
			local hrp = char and char:FindFirstChild("HumanoidRootPart")

			if hrp then
				local dist = (hrp.Position - root.Position).Magnitude
				if dist < minDist then
					minDist = dist
					closestRoot = hrp
				end
			end
		end

		if closestRoot then
			humanoid:MoveTo(closestRoot.Position)
		end
	end)
end

-------------------------------------------------
-- SPAWN FINAL BOSS
-------------------------------------------------

local function spawnFinalBoss()

	if spawned then return end
	if not RunActive.Value then return end

	local template = ReplicatedStorage.Enemies:FindFirstChild("FinalBossEnemy")
	if not template then
		warn("❌ FinalBossEnemy não encontrado")
		return
	end

	spawned = true
	FinalBattleActive.Value = true

	print("🔥 FINAL BOSS SURGIU")

	-------------------------------------------------
	-- LIMPA INIMIGOS
	-------------------------------------------------

	for _, enemy in ipairs(_G.Enemies) do
		if enemy.Model and enemy.Model.Parent then
			enemy.Model:Destroy()
		end
	end

	table.clear(_G.Enemies)

	-------------------------------------------------
	-- GARANTE PASTA ENEMIES
	-------------------------------------------------

	local enemiesFolder = workspace:FindFirstChild("Enemies")
	if not enemiesFolder then
		enemiesFolder = Instance.new("Folder")
		enemiesFolder.Name = "Enemies"
		enemiesFolder.Parent = workspace
	end

	-------------------------------------------------
	-- CRIA BOSS
	-------------------------------------------------

	local boss = template:Clone()
	boss:ScaleTo(3)
	
	boss:SetAttribute("IsFinalBoss", true)

	local humanoid = boss:FindFirstChildOfClass("Humanoid")
	local root = boss:FindFirstChild("HumanoidRootPart")

	if not humanoid or not root then
		boss:Destroy()
		return
	end

	root.Anchored = false
	boss.PrimaryPart = root

	local diff = DifficultyService:GetStats()
	local hp = math.floor(2000 * diff.BossMultiplier)

	humanoid.MaxHealth = hp
	humanoid.Health = hp

	root.CFrame = CFrame.new(0, 5, -50)
	boss.Parent = enemiesFolder

	-------------------------------------------------
	-- REGISTRA NO SISTEMA GLOBAL
	-------------------------------------------------

	local bossData = {
		Alive = true,
		Model = boss,
		Root = root,
		Humanoid = humanoid,
		IsFinalBoss = true
	}

	table.insert(_G.Enemies, bossData)

	-------------------------------------------------
	-- DANO POR CONTATO
	-------------------------------------------------

	local DAMAGE_TOUCH_BASE = 80
	local DAMAGE_COOLDOWN = 0.6
	local lastHit = {}

	for _, part in ipairs(boss:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Touched:Connect(function(hit)

				if not RunActive.Value then return end
				if GamePaused.Value then return end

				local character = hit.Parent
				local player = Players:GetPlayerFromCharacter(character)
				if not player then return end

				local hum = character:FindFirstChildOfClass("Humanoid")
				if not hum or hum.Health <= 0 then return end

				if lastHit[player] and tick() - lastHit[player] < DAMAGE_COOLDOWN then
					return
				end

				lastHit[player] = tick()

				local diffStats = DifficultyService:GetStats()
				local damage = DAMAGE_TOUCH_BASE
					* diffStats.DamageMultiplier
					* diffStats.BossMultiplier

				hum:TakeDamage(damage)

				print("🔥 FINAL BOSS ACERTOU:", player.Name, "Dano:", math.floor(damage))
			end)
		end
	end

	-------------------------------------------------
	-- MORTE DO BOSS
	-------------------------------------------------

	humanoid.Died:Connect(function()

		print("👑 FINAL BOSS DERROTADO")

		bossData.Alive = false

		if bossConnection then
			bossConnection:Disconnect()
		end

		-- Remove da lista global
		for i, e in ipairs(_G.Enemies) do
			if e.Model == boss then
				table.remove(_G.Enemies, i)
				break
			end
		end

		RunResultController:FinishRun("Victory")
	end)

	-------------------------------------------------
	-- INICIA IA
	-------------------------------------------------

	startFinalBossAI(bossData)
end

-------------------------------------------------
-- LOOP
-------------------------------------------------

RunService.Heartbeat:Connect(function()

	if not RunActive.Value then return end
	if GamePaused.Value then return end

	if DifficultyService:GetTime() >= FINAL_BOSS_TIME then
		spawnFinalBoss()
	end
end)

print("🔥 FinalBossSpawner carregado (corrigido)")
