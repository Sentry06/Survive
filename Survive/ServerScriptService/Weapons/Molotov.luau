-- Molotov.lua

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

local EnemyDamageService = require(
	game.ServerScriptService.Combat.EnemyDamageService
)

local WeaponBase = require(script.Parent:WaitForChild("WeaponBase"))

local WeaponEffectService = require(
	game.ServerScriptService.Weapons:WaitForChild("WeaponEffectService")
)

local Molotov = {}
Molotov.__index = Molotov
setmetatable(Molotov,{ __index = WeaponBase })

-------------------------------------------------
-- TEMPLATE
-------------------------------------------------

local MolotovTemplate =
	ReplicatedStorage
	:WaitForChild("Weapons")
	:WaitForChild("Molotov")
	:WaitForChild("Molotov")

-------------------------------------------------
-- CONFIG
-------------------------------------------------

local FIRE_DURATION = 4
local FIRE_TICK = 0.5

-------------------------------------------------
-- CONSTRUCTOR
-------------------------------------------------

function Molotov.new(player, limiter)

	local baseStats = {
		Name = "Molotov",

		Damage = 25,
		Cooldown = 4,
		Range = 16,
		AreaDamage = 2,
		ProjectileSpeed = 20,
		AttackSize = 1.2
	}

	local self = WeaponBase.new(baseStats, player, limiter)

	self.Level = 1

	self.Scaling = {
		AttackSize = 1.2,
		AreaDamage = 1.15,
	}

	setmetatable(self, Molotov)
	return self

end

-------------------------------------------------
-- UPGRADE
-------------------------------------------------

function Molotov:OnUpgrade(level)

	self.Level = level

	self.BaseStats.AttackSize *= self.Scaling.AttackSize
	self.BaseStats.AreaDamage *= self.Scaling.AreaDamage

end

-------------------------------------------------
-- FIRE AREA
-------------------------------------------------

local function spawnFireArea(self, position, sizeMultiplier)

	local groundPos = Vector3.new(position.X, position.Y - 3.35, position.Z)

	local fireModel = MolotovTemplate:Clone()
	local fireArea = fireModel:FindFirstChild("FireArea")

	if not fireArea then
		fireModel:Destroy()
		return
	end

	fireArea.Parent = workspace
	fireArea.Anchored = true
	fireArea.CFrame = CFrame.new(groundPos)

	local baseSize = fireArea.Size
	fireArea.Size = baseSize * sizeMultiplier

	WeaponEffectService:ApplyWeaponAura(
		self.Player,
		fireArea
	)

	-------------------------------------------------
	-- FIRE POOL (visual)
	-------------------------------------------------
	
	local firePool = Instance.new("Part")

	firePool.Shape = Enum.PartType.Cylinder
	firePool.Anchored = true
	firePool.CanCollide = false

	firePool.Size = Vector3.new(
		0.2,
		fireArea.Size.X,
		fireArea.Size.X
	)

	firePool.Material = Enum.Material.Neon
	firePool.Color = Color3.fromRGB(120,40,0)
	firePool.Transparency = 0.35

	firePool.CFrame =
		CFrame.new(groundPos)
		* CFrame.Angles(0,0,math.rad(90))

	firePool.Parent = workspace

	Debris:AddItem(firePool,FIRE_DURATION)
	
	WeaponEffectService:ApplyWeaponAura(
		self.Player,
		firePool
	)

	-------------------------------------------------
	-- PARTICLES
	-------------------------------------------------

	local flames = fireArea:FindFirstChild("Flames")
	local sparks = fireArea:FindFirstChild("Sparks")
	
	if flames then
		WeaponEffectService:ApplyWeaponAura(self.Player, flames)
	end

	if sparks then
		WeaponEffectService:ApplyWeaponAura(self.Player, sparks)
	end
	
	local explosion = fireArea:FindFirstChild("Explosion")

	if flames then
		flames.Size = NumberSequence.new(2 * sizeMultiplier)
	end

	if sparks then
		sparks.Size = NumberSequence.new(0.8 * sizeMultiplier)
	end

	if explosion then
		explosion:Emit(25)
	end

	for _,p in ipairs(fireArea:GetDescendants()) do
		if p:IsA("ParticleEmitter") then
			p.Enabled = true
		end
	end

	-------------------------------------------------
	-- SOUND
	-------------------------------------------------

	local explode = fireArea:FindFirstChild("Explode")
	local impact = fireArea:FindFirstChild("Impact")

	if explode then explode:Play() end
	if impact then impact:Play() end

	-------------------------------------------------
	-- DAMAGE
	-------------------------------------------------

	local attrs = self:GetFinalAttributes()

	local fireDamage =
		self:ComputeFinalDamage(
			self.BaseStats.AreaDamage,
			attrs
		)

	task.spawn(function()

		while fireArea.Parent do

			for _,enemy in ipairs(_G.Enemies or {}) do

				if enemy.Alive and enemy.Root and enemy.Humanoid then

					local dist =
						(enemy.Root.Position - fireArea.Position).Magnitude

					if dist <= fireArea.Size.X / 2 then

						EnemyDamageService:DamageEnemy(
							self.Player,
							enemy.Humanoid,
							fireDamage
						)

						self:ApplyHitEffects(enemy)

					end
				end
			end

			task.wait(FIRE_TICK)

		end

	end)

	Debris:AddItem(fireArea,FIRE_DURATION)

end

-------------------------------------------------
-- PROJECTILE
-------------------------------------------------

local function spawnMolotov(self, origin, direction, range, speed, sizeMultiplier, damage)

	if not self:CanSpawnProjectile() then return end
	self:OnProjectileSpawn()

	local model = MolotovTemplate:Clone()
	model.Parent = workspace

	self:ApplyWeaponAura(model)

	local bottle = model.PrimaryPart
	local fireArea = model:FindFirstChild("FireArea")

	if fireArea then
		fireArea:Destroy()
	end

	bottle.Anchored = true
	bottle.CanCollide = false
	bottle.Size *= sizeMultiplier

	model:PivotTo(CFrame.new(origin, origin + direction))

	local swing = bottle:FindFirstChild("Swing")
	if swing then swing:Play() end

	local traveled = 0
	local lastPos = origin

	local conn
	conn = RunService.Heartbeat:Connect(function(dt)

		local step = speed * dt
		traveled += step

		local newPos = lastPos + direction * step

		model:PivotTo(
			CFrame.new(newPos, newPos + direction)
				* CFrame.Angles(math.rad(traveled * 25),0,0)
		)

		lastPos = newPos

		for _,enemy in ipairs(_G.Enemies or {}) do

			if enemy.Alive and enemy.Root and enemy.Humanoid then

				local dist =
					(enemy.Root.Position - newPos).Magnitude

				if dist <= 3 * sizeMultiplier then

					EnemyDamageService:DamageEnemy(
						self.Player,
						enemy.Humanoid,
						damage
					)

					self:ApplyHitEffects(enemy)

					conn:Disconnect()
					model:Destroy()

					spawnFireArea(self,newPos,sizeMultiplier)

					self:OnProjectileDestroy()
					return

				end
			end
		end

		if traveled >= range then

			conn:Disconnect()
			model:Destroy()
			self:OnProjectileDestroy()

		end

	end)

	Debris:AddItem(model,5)

end

-------------------------------------------------
-- ATTACK
-------------------------------------------------

function Molotov:Attack(root, attrs)

	local finalRange =
		self.BaseStats.Range * attrs.Range

	local enemies = self:GetEnemiesInRange(finalRange)
	if #enemies == 0 then return end

	self:StartCooldown(attrs)

	local multi = math.max(1, math.floor(attrs.MultiAttack or 1))
	local attackSize = attrs.AttackSize or 1

	for i = 1, math.min(multi,#enemies) do

		local enemy = enemies[i]

		local finalDamage =
			self:ComputeFinalDamage(self.BaseStats.Damage, attrs)

		local dir =
			(enemy.Root.Position - root.Position).Unit

		local origin =
			root.Position
			+ dir * 2
			+ Vector3.new(0,1.5,0)

		spawnMolotov(
			self,
			origin,
			dir,
			finalRange,
			self.BaseStats.ProjectileSpeed * attrs.ProjectileSpeed,
			attackSize,
			finalDamage
		)

	end

end

return Molotov