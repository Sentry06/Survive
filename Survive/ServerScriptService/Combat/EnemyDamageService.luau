local EnemyStatusService = require(
	game.ServerScriptService.Combat.EnemyStatusService
)

local ModifierService = require(
	game.ServerScriptService.Modifiers.ModifierService
)

local ArtifactService = require(
	game.ServerScriptService.Artifacts.ArtifactService
)

local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local EnemyDamageService = {}


-------------------------------------------------
-- 🔥 VISUAL DE AREA DAMAGE
-------------------------------------------------
local function spawnAreaVisual(position, radius)

	if not position then return end

	local circle = Instance.new("Part")
	circle.Shape = Enum.PartType.Cylinder
	circle.Anchored = true
	circle.CanCollide = false
	circle.Material = Enum.Material.Neon
	circle.Color = Color3.fromRGB(255, 255, 255)
	circle.Transparency = 0.65

	-- começa menor
	circle.Size = Vector3.new(0.2, radius * 0.3, radius * 0.3)
	circle.CFrame =
		CFrame.new(position)
		* CFrame.Angles(0, 0, math.rad(90))

	circle.Parent = workspace

	local tween = TweenService:Create(
		circle,
		TweenInfo.new(
			0.45,
			Enum.EasingStyle.Quad,
			Enum.EasingDirection.Out
		),
		{
			Size = Vector3.new(0.2, radius * 1.6, radius * 1.6),
			Transparency = 1
		}
	)

	tween:Play()
	Debris:AddItem(circle, 0.5)
end

-------------------------------------------------
-- 💥 VISUAL DO FRAGOR (EXPLOSÃO)
-------------------------------------------------
local function spawnExplosionVisual(position, radius)

	if not position then return end

	local part = Instance.new("Part")
	part.Shape = Enum.PartType.Ball
	part.Anchored = true
	part.CanCollide = false
	part.Material = Enum.Material.Neon
	part.Color = Color3.fromRGB(255, 120, 0)
	part.Transparency = 0.4

	part.Size = Vector3.new(1,1,1)
	part.CFrame = CFrame.new(position)
	part.Parent = workspace

	local tween = TweenService:Create(
		part,
		TweenInfo.new(
			0.35,
			Enum.EasingStyle.Quad,
			Enum.EasingDirection.Out
		),
		{
			Size = Vector3.new(radius*2, radius*2, radius*2),
			Transparency = 1
		}
	)

	tween:Play()
	Debris:AddItem(part, 0.4)
end

-------------------------------------------------
-- ⚡ PIERCE CHAIN VISUAL + DAMAGE
-------------------------------------------------
local function spawnPierceChain(startEnemy, player, baseDamage)

	if typeof(baseDamage) == "Instance" then
		baseDamage = baseDamage.Value
	end

	if not startEnemy.Root then
		warn("❌ StartEnemy sem Root")
		return
	end

	if not startEnemy or not startEnemy.Root then return end

	local ms = player:FindFirstChild("MatchStats")
	local attrs = ms and ms:FindFirstChild("Attributes")
	local pierceStat = attrs and attrs:FindFirstChild("ProjectilePierce")
	
	local ms = player:FindFirstChild("MatchStats")
	local attrFolder = ms and ms:FindFirstChild("Attributes")

	local function getStat(name, default)
		local stat = attrFolder and attrFolder:FindFirstChild(name)
		return stat and stat.Value or default
	end

	local pierce = math.floor(getStat("ProjectilePierce", 0))
	local attackSize = getStat("AttackSize", 1)

	local pierce = pierceStat and math.floor(pierceStat.Value) or 0

	if pierce <= 0 then return end

	local BASE_RADIUS = 10
	local ms = player:FindFirstChild("MatchStats")
	local attrFolder = ms and ms:FindFirstChild("Attributes")
	local attackSizeStat = attrFolder and attrFolder:FindFirstChild("AttackSize")

	local attackSize = attackSizeStat and attackSizeStat.Value or 1
	local radius = BASE_RADIUS * attackSize

	local hitEnemies = {}
	
	local currentEnemy = startEnemy
	local currentDamage = baseDamage * 0.5 -- 👈 metade do dano

	if not currentEnemy.Root then
		warn("❌ currentEnemy sem Root")
		return
	end

	for i = 1, pierce do

		if not currentEnemy then break end

		local MAX_CHAIN_DISTANCE = radius * 2

		hitEnemies[currentEnemy] = true

		-- 🔎 achar próximo alvo
		local nextEnemy
		local shortest = math.huge

		for _, enemy in ipairs(_G.Enemies or {}) do
			if enemy.Alive
				and enemy.Root
				and enemy.Humanoid
				and not hitEnemies[enemy] then

				local currentRoot = currentEnemy.Root
				if not currentRoot then break end

				local dist =
					(enemy.Root.Position - currentRoot.Position).Magnitude

				if dist <= radius and dist < shortest then
					shortest = dist
					nextEnemy = enemy
				end
			end
		end

		if not nextEnemy then break end
		
		local originPos = startEnemy.Root.Position

		local distFromOrigin =
			(nextEnemy.Root.Position - originPos).Magnitude

		if distFromOrigin > MAX_CHAIN_DISTANCE then
			break
		end
		
		-- 💰 total dividido igualmente
		local damagePerHit = baseDamage / pierce

		-- 📏 distância
		local dist =
			(nextEnemy.Root.Position - currentEnemy.Root.Position).Magnitude

		-- 📉 falloff (mais longe = menos dano)
		local falloff = 1 - (dist / radius)
		falloff = math.clamp(falloff, 0.3, 1)

		local finalDamage = damagePerHit * falloff

		-- ⚡ VISUAL (usa o mesmo do lightning)
		local beam = Instance.new("Part")
		local dir = nextEnemy.Root.Position - currentEnemy.Root.Position
		local dist = dir.Magnitude

		beam.Anchored = true
		beam.CanCollide = false
		beam.Material = Enum.Material.Neon
		beam.Color = Color3.fromRGB(255, 255, 100) -- 👈 cor diferente do electric
		beam.Size = Vector3.new(0.6, 0.6, dist)
		beam.CFrame =
			CFrame.new(currentEnemy.Root.Position, nextEnemy.Root.Position)
			* CFrame.new(0, 0, -dist/2)

		beam.Parent = workspace
		Debris:AddItem(beam, 0.2)

		-- 💥 aplicar dano
		nextEnemy.Humanoid:TakeDamage(finalDamage)
		
		local hitPart = Instance.new("Part")
		hitPart.Shape = Enum.PartType.Ball
		hitPart.Size = Vector3.new(1.5,1.5,1.5)
		hitPart.Anchored = true
		hitPart.CanCollide = false
		hitPart.Material = Enum.Material.Neon
		hitPart.Color = Color3.fromRGB(255, 255, 120)
		hitPart.CFrame = nextEnemy.Root.CFrame
		hitPart.Parent = workspace

		game:GetService("Debris"):AddItem(hitPart, 0.15)
		currentEnemy = nextEnemy
	end
end

-------------------------------------------------
-- 💥 DAMAGE
-------------------------------------------------
function EnemyDamageService:DamageEnemy(player, humanoid, damage, isSplash)

	local activeModifier = player:GetAttribute("ActiveModifier")

	local enemyData

	for _, e in ipairs(_G.Enemies or {}) do
		if e.Humanoid == humanoid 
			or (e.Model and humanoid.Parent == e.Model) then

			enemyData = e
			break
		end
	end

	-------------------------------------------------
	-- 🛡️ INVULNERABILIDADE PLAYER
	-------------------------------------------------

	local char = player.Character
	if char then
		local ph = char:FindFirstChildOfClass("Humanoid")
		if ph and ph:GetAttribute("Invulnerable") then
			return
		end
	end

	-- ❌ VALIDAÇÃO
	-------------------------------------------------

	if not humanoid or humanoid.Health <= 0 then
		return
	end

	-------------------------------------------------
	-- 🧠 HOOK (CASO QUEIRA USAR NO FUTURO)
	-------------------------------------------------

	local ModifierService = require(
		game.ServerScriptService.Modifiers:WaitForChild("ModifierService")
	)

	local damageData = {
		Amount = damage,
		Multiplier = 1,
		IsBoss = humanoid.Parent:GetAttribute("IsBoss") == true
	}

	ModifierService:OnHit(player, enemyData, damageData)

	damage = damageData.Amount * (damageData.Multiplier or 1)

	-------------------------------------------------
	-- 💥 APLICA DANO
	-------------------------------------------------

	humanoid:TakeDamage(damage)
	
	-- ☠️ DETECTAR MORTE + ON KILL
	if humanoid.Health <= 0 then

		-- 🔎 achar enemyData correto (segurança)
		local deadEnemy = enemyData

		if not deadEnemy then
			for _, e in ipairs(_G.Enemies or {}) do
				if e.Humanoid == humanoid then
					deadEnemy = e
					break
				end
			end
		end

		if deadEnemy then
			print("💀 Enemy morreu → chamando OnKill")

			ModifierService:OnKill(player, deadEnemy)
		end
	end

	-------------------------------------------------
	-- ⚡ PIERCE (CHAIN DAMAGE)
	-------------------------------------------------
	if not isSplash then
		for _, enemy in ipairs(_G.Enemies or {}) do
			if enemy.Humanoid == humanoid then
				spawnPierceChain(enemy, player, damage)
				break
			end
		end
	end

	-------------------------------------------------
	-- 🌋 AREA DAMAGE (INSTANTÂNEO E LIMPO)
	-------------------------------------------------
	if not isSplash then

		local attrs = player:GetAttributes()
		local base = attrs.AreaDamage or 0
		local bonus = player:GetAttribute("AreaDamageBonus") or 0

		local areaPercent = base + bonus

		if areaPercent > 0 then

			local enemyModel = humanoid.Parent
			if not enemyModel then return end

			local originRoot = enemyModel:FindFirstChild("HumanoidRootPart")
			if not originRoot then return end

			local BASE_RADIUS = 3
			local attackSize = attrs.AttackSize or 1

			local radiusMultiplier = 1 + (areaPercent * 1.5)
			local radius = BASE_RADIUS * attackSize * radiusMultiplier

			-- 🔥 visual
			spawnAreaVisual(originRoot.Position, radius)

			-- 💣 splash
			local splashMultiplier = 0.5 + areaPercent
			local splashDamage = damage * splashMultiplier

			for _, otherEnemy in ipairs(_G.Enemies or {}) do
				if otherEnemy.Alive
					and otherEnemy.Humanoid
					and otherEnemy.Root
					and otherEnemy.Humanoid ~= humanoid then

					local dist =
						(otherEnemy.Root.Position - originRoot.Position).Magnitude

					if dist <= radius then
						otherEnemy.Humanoid:TakeDamage(splashDamage)
					end
				end
			end
		end
	end

	-------------------------------------------------
	-- ❄ FREEZE ON HIT
	-------------------------------------------------
	if ArtifactService:HasTag(player, "FreezeOnHit") then

		local data = ArtifactService:GetData(player)
		local chance = data and data.Chance or 0
		local freezeTime = data and data.FreezeTime or 0

		if math.random() <= chance then
			for _, enemy in ipairs(_G.Enemies or {}) do
				if enemy.Humanoid == humanoid then
					EnemyStatusService:Freeze(enemy, freezeTime)
					break
				end
			end
		end
	end

	-------------------------------------------------
	-- 💥 FRAGOR (EXPLOSÃO BASEADA EM AREA)
	-------------------------------------------------
	if not isSplash and ArtifactService:HasTag(player, "FragorExplosion") then

		local data = ArtifactService:GetData(player)
		if data and math.random() <= data.Chance then

			local attrs = player:GetAttributes()
			local base = attrs.AreaDamage or 0
			local bonus = player:GetAttribute("AreaDamageBonus") or 0

			local areaPercent = base + bonus
			local effectiveArea = math.max(areaPercent, 0.10) -- mínimo 10%

			local attackSize = attrs.AttackSize or 1

			local originRoot = humanoid.Parent:FindFirstChild("HumanoidRootPart")
			if not originRoot then return end

			local attrs = player:GetAttributes()
			local attackSize = attrs.AttackSize or 1
			local areaPercent = attrs.AreaDamage or 0
			local damageMultiplier = attrs.Damage or 1

			local BASE_RADIUS = 8

			local radius =
				BASE_RADIUS
				* attackSize
				* (1 + areaPercent * 2) -- escala forte com área

			local explosionDamage =
				damage
				* (1 + areaPercent * 2)
				* data.DamageBoost
				* damageMultiplier

			spawnExplosionVisual(originRoot.Position, radius)

			for _, enemy in ipairs(_G.Enemies or {}) do
				if enemy.Alive and enemy.Root and enemy.Humanoid then

					local dist =
						(enemy.Root.Position - originRoot.Position).Magnitude

					if dist <= radius then
						enemy.Humanoid:TakeDamage(explosionDamage)
					end
				end
			end

			print("💥 FRAGOR EXPLOSÃO!")
		end
	end

	-------------------------------------------------
	-- ⚡ FLUXUS ELETRICUS (CHAIN)
	-------------------------------------------------
	if ArtifactService:HasTag(player, "Electric") and not isSplash then

		local data = ArtifactService:GetData(player)
		local percent = data and data.DamagePercent or 0

		local chainDamage = damage * percent

		for _, enemy in ipairs(_G.Enemies or {}) do
			if enemy.Humanoid == humanoid then
				EnemyStatusService:ChainLightning(enemy, player, chainDamage)
				break
			end
		end
	end

	-------------------------------------------------
	-- 🩸 LIFE STEAL (SANGUIS)
	-------------------------------------------------
	if ArtifactService:HasTag(player, "LifeSteal") then

		local data = ArtifactService:GetData(player)
		local stealPercent = data and data.Percent or 0

		if stealPercent > 0 then

			local char = player.Character
			local ph = char and char:FindFirstChildOfClass("Humanoid")

			if ph then
				ph.Health = math.min(
					ph.MaxHealth,
					ph.Health + damage * stealPercent
				)
			end
		end
	end
end

return EnemyDamageService
