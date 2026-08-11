-- Bricks.lua
-- Arremessa tijolos clássicos do Roblox

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

local EnemyDamageService = require(
	game.ServerScriptService.Combat.EnemyDamageService
)

local WeaponBase = require(script.Parent:WaitForChild("WeaponBase"))

local Bricks = {}
Bricks.__index = Bricks
setmetatable(Bricks,{ __index = WeaponBase })

---

-- TEMPLATE

local BrickFolder =
	ReplicatedStorage
	:WaitForChild("Weapons")
	:WaitForChild("Bricks")
    :WaitForChild("Bricks")

local BrickTemplate = BrickFolder:WaitForChild("BrickProjectile")
local BrickSoundTemplate = BrickFolder:WaitForChild("Sound")

---

-- RANDOM COLORS (ROBLOX BRICK STYLE)

local BrickColors = {
	Color3.fromRGB(196, 40, 28), -- vermelho
	Color3.fromRGB(13, 105, 172), -- azul
	Color3.fromRGB(75, 151, 75), -- verde
	Color3.fromRGB(245, 205, 48), -- amarelo
	Color3.fromRGB(163, 162, 165), -- cinza
	Color3.fromRGB(255, 255, 255) -- branco
}

---

-- CONSTRUCTOR

function Bricks.new(player, limiter)

	local baseStats = {
		Name = "Bricks",

		Damage = 28,
		Cooldown = 1.6,
		Range = 18,
		ProjectileSpeed = 26,
		AttackSize = 1,
		ProjectilePierce = 1,
		AreaDamage = 0.15
	}

	local self = WeaponBase.new(baseStats, player, limiter)

	self.Level = 1

	self.Scaling = {
		Damage = 1.12,
		Cooldown = 0.94
	}

	setmetatable(self, Bricks)
	return self

end

---

-- UPGRADE

function Bricks:OnUpgrade(level)

	self.Level = level

	self.BaseStats.Damage *= self.Scaling.Damage
	self.BaseStats.Cooldown *= self.Scaling.Cooldown

end

---

-- IMPACT EFFECT

local function spawnImpact(position)

	local impact = Instance.new("Part")
	impact.Anchored = true
	impact.CanCollide = false
	impact.Shape = Enum.PartType.Ball
	impact.Material = Enum.Material.Neon
	impact.Color = Color3.fromRGB(255,80,80)
	impact.Size = Vector3.new(1,1,1)
	impact.CFrame = CFrame.new(position)
	impact.Parent = workspace

	TweenService:Create(
		impact,
		TweenInfo.new(0.2),
		{
			Size = Vector3.new(4,4,4),
			Transparency = 1
		}
	):Play()

	Debris:AddItem(impact,0.3)

end

---

-- PLAY HIT SOUND

local function playHitSound(position)

	local soundPart = Instance.new("Part")
	soundPart.Anchored = true
	soundPart.CanCollide = false
	soundPart.Transparency = 1
	soundPart.Size = Vector3.new(1,1,1)
	soundPart.CFrame = CFrame.new(position)
	soundPart.Parent = workspace

	local sound = BrickSoundTemplate:Clone()
	sound.Parent = soundPart
	sound:Play()

	Debris:AddItem(soundPart,3)

end

---

-- PROJECTILE

local function spawnBrick(self, origin, direction, range, speed, sizeMultiplier, enemyData, damage)

	if not self:CanSpawnProjectile() then return end
	self:OnProjectileSpawn()

	local brick = BrickTemplate:Clone()
	brick.Parent = workspace

	self:ApplyWeaponAura(brick)

	local part = brick
	if brick:IsA("Model") then
		part = brick.PrimaryPart
	end

	if not part then
		brick:Destroy()
		self:OnProjectileDestroy()
		return
	end

	part.Anchored = true
	part.CanCollide = false

	-------------------------------------------------
	-- RANDOM COLOR
	-------------------------------------------------

	part.Color = BrickColors[math.random(1,#BrickColors)]

	part.Size = part.Size * sizeMultiplier

	part.CFrame = CFrame.new(origin, origin + direction)

	local traveled = 0
	local lastPos = origin

	local hitEnemies = {}

	local conn
	conn = RunService.Heartbeat:Connect(function(dt)

		local step = speed * dt
		traveled += step

		local newPos = lastPos + direction * step

		part.CFrame =
			CFrame.new(newPos, newPos + direction)
			* CFrame.Angles(
				math.rad(traveled * 20),
				math.rad(traveled * 12),
				0
			)

		lastPos = newPos

		for _,enemy in ipairs(_G.Enemies or {}) do

			if enemy.Alive and enemy.Root and enemy.Humanoid then

				local dist =
					(enemy.Root.Position - newPos).Magnitude

				if dist <= 3 * sizeMultiplier then

					if not hitEnemies[enemy] then

						hitEnemies[enemy] = true

						EnemyDamageService:DamageEnemy(
							self.Player,
							enemy.Humanoid,
							damage
						)

						self:ApplyHitEffects(enemy)

						spawnImpact(newPos)

						-- 🔊 SOM DO TIJOLO
						playHitSound(newPos)

						conn:Disconnect()
						brick:Destroy()
						self:OnProjectileDestroy()
						return

					end
				end
			end
		end

		if traveled >= range then

			conn:Disconnect()
			brick:Destroy()
			self:OnProjectileDestroy()

		end

	end)

	Debris:AddItem(brick,5)

end

---

-- ATTACK

function Bricks:Attack(root, attrs)

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

		spawnBrick(
			self,
			origin,
			dir,
			finalRange,
			self.BaseStats.ProjectileSpeed * attrs.ProjectileSpeed,
			attackSize,
			enemy,
			finalDamage
		)

	end

end

return Bricks
