-- BossSpawner.server
-- VERSÃO REESCRITA - ESCALA REAL DE RUN

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")

local XPService = require(game.ServerScriptService.XPService)
local DifficultyService = require(game.ServerScriptService.DifficultyService)
local DamageService = require(game.ServerScriptService.Combat.DamageService)
local GoldService = require(game.ServerScriptService.GoldService)
local EnemyTimeController = require(
	game.ServerScriptService.Combat.EnemyTimeController
)

local ArtifactRegistry = require(
	game.ServerScriptService.Artifacts.ArtifactRegistry
)

local ChestSpawner = require(
	game.ServerScriptService.Chests.ChestSpawner
)

local RunFlowService = require(game.ServerScriptService.RunFlowService)

-------------------------------------------------
-- GAME STATE
-------------------------------------------------

local GameState = ReplicatedStorage:WaitForChild("GameState")
local GamePaused = GameState:WaitForChild("GamePaused")

_G.Enemies = _G.Enemies or {}

-------------------------------------------------
-- CONFIG
-------------------------------------------------

local BOSS_INTERVAL = 5
local BASE_HP = 200
local BASE_DAMAGE = 40
local BASE_SPEED = 13
local BASE_XP = 100
local BASE_GOLD = 30

local ATTACK_RANGE = 10
local ATTACK_COOLDOWN = 1.6

-------------------------------------------------
-- STATE
-------------------------------------------------

local bossAlive = false
local bossTimer = 0
local bossIndex = 1

-------------------------------------------------
-- FOLDER
-------------------------------------------------

local enemiesFolder = workspace:FindFirstChild("Enemies")
if not enemiesFolder then
	enemiesFolder = Instance.new("Folder")
	enemiesFolder.Name = "Enemies"
	enemiesFolder.Parent = workspace
end

-------------------------------------------------
-- POWER SCORE
-------------------------------------------------

local function CalculatePlayerPower(player)

	local ms = player:FindFirstChild("MatchStats")
	if not ms then return 1 end

	local level = ms.Level.Value
	local attrs = player:GetAttributes()

	local damage = attrs.Damage or 1
	local attackSpeed = attrs.AttackSpeed or 1
	local area = attrs.AreaDamage or 0
	local multi = attrs.MultiAttack or 0
	local synergyCount = player:GetAttribute("ActiveSynergies") or 0

	local powerScore =
		(level * 1.0)
		+ (damage * 6)
		+ (attackSpeed * 5)
		+ (area * 4)
		+ (multi * 8)
		+ (synergyCount * 18)

	return powerScore
end

-------------------------------------------------
-- BOSS SCALING
-------------------------------------------------

local function GetBossScaling(powerScore)

	powerScore = tonumber(powerScore) or 0

	local threshold = 160
	local softness = 140

	local delta = math.max(powerScore - threshold, 0)
	local scaling = 1 + (delta / softness)

	return math.clamp(scaling, 1, 2.2)
end

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

local function getClosestPlayer(position)

	local closest
	local minDist = math.huge

	for _, player in ipairs(Players:GetPlayers()) do
		local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")

		if root then
			local dist = (root.Position - position).Magnitude
			if dist < minDist then
				minDist = dist
				closest = player
			end
		end
	end

	return closest
end

-------------------------------------------------
-- BOSS SPAWN POS
-------------------------------------------------

local function getBossSpawnPos()

	local center = getPlayerCenter()

	for attempt = 1, 15 do

		local angle = math.random() * math.pi * 2
		local dist = math.random(90, 130)

		local offset = Vector3.new(
			math.cos(angle) * dist,
			0,
			math.sin(angle) * dist
		)

		local spawnPos = center + offset

		if (spawnPos - center).Magnitude < 80 then
			continue
		end

		local tooClose = false
		for _, e in ipairs(_G.Enemies) do
			if e.Alive and e.Root then
				if (e.Root.Position - spawnPos).Magnitude < 20 then
					tooClose = true
					break
				end
			end
		end

		if tooClose then
			continue
		end

		local origin = spawnPos + Vector3.new(0, 120, 0)

		local rayParams = RaycastParams.new()
		rayParams.FilterDescendantsInstances = {workspace.Enemies}
		rayParams.FilterType = Enum.RaycastFilterType.Blacklist

		local result = workspace:Raycast(origin, Vector3.new(0, -250, 0), rayParams)

		if result then
			return result.Position + Vector3.new(0, 4, 0)
		end
	end

	return center + Vector3.new(0, 5, 100)
end

-------------------------------------------------
-- DROP ARTEFATO
-------------------------------------------------

local function dropRandomArtifact(position)

	local artifacts = ArtifactRegistry:GetAll()
	if not artifacts then return end

	local ids = {}

	for key, value in pairs(artifacts) do
		if typeof(key) == "string" then
			table.insert(ids, key)
		elseif typeof(value) == "table" and typeof(value.Id) == "string" then
			table.insert(ids, value.Id)
		end
	end

	if #ids == 0 then return end

	local ArtifactDropService = require(
		game.ServerScriptService.Artifacts.ArtifactDropService
	)

	local artifactId = ids[math.random(1, #ids)]
	ArtifactDropService:Spawn(artifactId, position)
end

-------------------------------------------------
-- BOSS AI
-------------------------------------------------

local function startBossAI(bossData, scaledDamage)

	local humanoid = bossData.Humanoid
	local root = bossData.Root
	local lastAttack = 0

	bossData.AIConn = RunService.Heartbeat:Connect(function(dt)

		if not bossData.Alive then return end

		if GamePaused.Value 
			or (EnemyTimeController and EnemyTimeController.IsFrozen and EnemyTimeController:IsFrozen()) then
			humanoid.WalkSpeed = 0
			humanoid:MoveTo(root.Position)
			return
		end

		local diff = DifficultyService:GetStats()

		local closestPlayer = getClosestPlayer(root.Position)
		if not closestPlayer then return end

		local playerRoot = closestPlayer.Character and closestPlayer.Character:FindFirstChild("HumanoidRootPart")
		if not playerRoot then return end

		local distance = (playerRoot.Position - root.Position).Magnitude

		local slow = EnemyTimeController:GetSlow()
		humanoid.WalkSpeed = BASE_SPEED * diff.SpeedMultiplier * slow
		humanoid:MoveTo(playerRoot.Position)

		lastAttack += dt

		if distance <= ATTACK_RANGE and lastAttack >= ATTACK_COOLDOWN then

			DamageService:TryDamagePlayer(
				root,
				scaledDamage * diff.DamageMultiplier,
				ATTACK_RANGE
			)

			lastAttack = 0
		end
	end)
end

-------------------------------------------------
-- SPAWN
-------------------------------------------------

local function spawnBoss()

	if bossAlive then return end
	if not GameState.RunActive.Value or GamePaused.Value then return end

	local template = ReplicatedStorage.Enemies:FindFirstChild("BossEnemy")
	if not template then
		warn("❌ BossEnemy não encontrado")
		return
	end

	local diff = DifficultyService:GetStats()
	local mod = _G.RunModifiers or {}
	local bossCount = mod.BossCount or 1

	bossAlive = true
	bossTimer = 0

	for i = 1, bossCount do

		local boss = template:Clone()
		local humanoid = boss:FindFirstChildWhichIsA("Humanoid")
		local root = boss:FindFirstChild("HumanoidRootPart")
		
		boss:SetAttribute("IsBoss", true)

		if not humanoid or not root then
			boss:Destroy()
			continue
		end

		local players = Players:GetPlayers()
		if #players == 0 then return end

		local targetPlayer = players[1]
		local powerScore = CalculatePlayerPower(targetPlayer)
		local scaling = GetBossScaling(powerScore)

		local hp = math.floor(
			BASE_HP
				* diff.HealthMultiplier
				* diff.BossMultiplier
				* scaling
		)

		local scaledDamage = BASE_DAMAGE * scaling

		humanoid.MaxHealth = hp
		humanoid.Health = hp

		boss:PivotTo(CFrame.new(getBossSpawnPos()))
		boss.Parent = enemiesFolder

		local bossData = {
			Alive = true,
			Humanoid = humanoid,
			Root = root,
			Model = boss,
			IsBoss = true
		}

		table.insert(_G.Enemies, bossData)

		startBossAI(bossData, scaledDamage)

		print("👑 BOSS SPAWNADO")

		-------------------------------------------------
		-- MORTE
		-------------------------------------------------

		humanoid.Died:Connect(function()

			bossData.Alive = false
			bossAlive = false

			if bossData.AIConn then
				bossData.AIConn:Disconnect()
			end

			for i, e in ipairs(_G.Enemies) do
				if e == bossData then
					table.remove(_G.Enemies, i)
					break
				end
			end

			local killer = getClosestPlayer(root.Position)

			if killer then
				local ms = killer:FindFirstChild("MatchStats")

				if ms then

					local xp = ms.XP
					local level = ms.Level
					local xpToNext = ms.XPToNext

					local diffStats = DifficultyService:GetStats()
					local runTime = ReplicatedStorage.GameState.ElapsedTime.Value or 0
					local minute = runTime / 60

					local timeScaling = 1 + (minute * 0.08)

					local gain = math.floor(
						BASE_XP
							* diffStats.XPMultiplier
							* diffStats.BossMultiplier
							* timeScaling
					)

					xp.Value += gain

					while xp.Value >= xpToNext.Value do
						xp.Value -= xpToNext.Value
						level.Value += 1
						xpToNext.Value = XPService:GetXPRequired(level.Value)
					end
				end

				GoldService:GiveRunGold(killer, BASE_GOLD, "Boss")
			end

			dropRandomArtifact(root.Position)

			if killer then
				local offset = Vector3.new(
					math.random(-8,8),
					0,
					math.random(-8,8)
				)

				ChestSpawner:SpawnChest(root.Position + offset, killer)
			end

			task.delay(0.1, function()
				if boss and boss.Parent then
					boss:Destroy()
				end
			end)

			if killer then
				local ms = killer:FindFirstChild("MatchStats")
				if ms and ms:FindFirstChild("BossesKilled") then
					ms.BossesKilled.Value += 1
				end
			end
		end)
	end
end

-------------------------------------------------
-- LOOP
-------------------------------------------------

RunService.Heartbeat:Connect(function(dt)

	if not GameState.RunActive.Value or GamePaused.Value then return end

	bossTimer += dt

	if bossTimer >= BOSS_INTERVAL then
		spawnBoss()
	end
end)

-------------------------------------------------
-- RESET
-------------------------------------------------

local function resetBossSpawner()

	bossTimer = 0
	bossIndex = 1
	bossAlive = false

	print("👑 BossSpawner resetado")

end

RunFlowService.Events.OnRunStarting.Event:Connect(function()

	resetBossSpawner()

end)

print("👑 BossSpawner REESCRITO (escala progressiva real)")