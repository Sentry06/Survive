-- Boomerang.lua
-- Projétil que vai e volta atingindo inimigos

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

local EnemyDamageService = require(
	game.ServerScriptService.Combat.EnemyDamageService
)

local WeaponBase = require(script.Parent:WaitForChild("WeaponBase"))

local Boomerang = {}
Boomerang.__index = Boomerang
setmetatable(Boomerang,{ __index = WeaponBase })

---

-- TEMPLATE

local BoomerangTemplate =
	ReplicatedStorage
	:WaitForChild("Weapons")
	:WaitForChild("Boomerang")
	:WaitForChild("Boomerang")

---

-- CONSTRUCTOR

function Boomerang.new(player, limiter)

	local baseStats = {
		Name = "Boomerang",

		Damage = 16,
		Cooldown = 1.2,
		Range = 14,
		ProjectileSpeed = 24,
		AttackSize = 1,
		ProjectilePierce = 0,
		AreaDamage = 0
	}

	local self = WeaponBase.new(baseStats, player, limiter)

	self.Level = 1

	self.Scaling = {
		ProjectileSpeed = 1.10,
		Range = 1.10
	}

	setmetatable(self, Boomerang)
	return self

end

---

-- UPGRADE

function Boomerang:OnUpgrade(level)

	self.Level = level

	self.BaseStats.ProjectileSpeed *= self.Scaling.ProjectileSpeed
	self.BaseStats.Range *= self.Scaling.Range

end

---

-- PROJECTILE

local function spawnBoomerang(self, origin, direction, range, speed, sizeMultiplier, damage)

	if not self:CanSpawnProjectile() then return end
	self:OnProjectileSpawn()

	local model = BoomerangTemplate:Clone()
	model.Parent = workspace

	self:ApplyWeaponAura(model)

	local part = model.PrimaryPart
	if not part then
		model:Destroy()
		self:OnProjectileDestroy()
		return
	end

	part.Anchored = true
	part.CanCollide = false
	part.Size *= sizeMultiplier

	model:PivotTo(CFrame.new(origin, origin + direction))

	-------------------------------------------------
	-- SOUND
	-------------------------------------------------

	local sound = part:FindFirstChild("Spinning")
	if sound then
		sound:Play()
	end

	-------------------------------------------------
	-- TRAIL
	-------------------------------------------------

	local trail = part:FindFirstChild("Trail")
	if trail then
		trail.Enabled = true
	end

	local traveled = 0
	local lastPos = origin
	local returning = false

	local hitEnemies = {}

	local conn
	conn = RunService.Heartbeat:Connect(function(dt)

		local root = self:GetRoot()
		if not root then return end

		local step = speed * dt
		traveled += step

		local moveDir

		if not returning then

			moveDir = direction

			if traveled >= range/2 then
				returning = true
			end

		else

			moveDir =
				(root.Position - lastPos).Unit

			if (root.Position - lastPos).Magnitude < 2 then

				conn:Disconnect()
				model:Destroy()
				self:OnProjectileDestroy()
				return

			end

		end

		local newPos = lastPos + moveDir * step

		model:PivotTo(
			CFrame.new(newPos, newPos + moveDir)
				* CFrame.Angles(math.rad(traveled * 40),0,0)
		)

		lastPos = newPos

		-------------------------------------------------
		-- DISTANCE SOUND ATTENUATION
		-------------------------------------------------

		if sound then
			local dist =
				(root.Position - newPos).Magnitude

			sound.Volume =
				math.clamp(1 - (dist / 40),0,1)
		end

		-------------------------------------------------
		-- DAMAGE
		-------------------------------------------------

		for _,enemy in ipairs(_G.Enemies or {}) do

			if enemy.Alive and enemy.Root and enemy.Humanoid then

				local dist =
					(enemy.Root.Position - newPos).Magnitude

				if dist <= 3 * sizeMultiplier then

					if not hitEnemies[enemy] then

						hitEnemies[enemy] = 1

						EnemyDamageService:DamageEnemy(
							self.Player,
							enemy.Humanoid,
							damage
						)

						self:ApplyHitEffects(enemy)

					elseif returning and hitEnemies[enemy] == 1 then

						hitEnemies[enemy] = 2

						EnemyDamageService:DamageEnemy(
							self.Player,
							enemy.Humanoid,
							damage
						)

						self:ApplyHitEffects(enemy)

					end

				end
			end
		end

	end)

	Debris:AddItem(model,6)

end

---

-- ATTACK

function Boomerang:Attack(root, attrs)

	local finalRange =
		self.BaseStats.Range * attrs.Range

	local enemies = self:GetEnemiesInRange(finalRange)
	if #enemies == 0 then return end

	self:StartCooldown(attrs)

	local multi = math.max(1, math.floor(attrs.MultiAttack or 1))
	local attackSize = attrs.AttackSize or 1

	for i = 1, math.min(multi, #enemies) do

		local enemy = enemies[i]
		if not enemy or not enemy.Alive then
			continue
		end

		local finalDamage =
			self:ComputeFinalDamage(self.BaseStats.Damage, attrs)

		local dir =
			(enemy.Root.Position - root.Position).Unit

		local origin =
			root.Position
			+ dir * 2
			+ Vector3.new(0,1.5,0)

		spawnBoomerang(
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

return Boomerang
