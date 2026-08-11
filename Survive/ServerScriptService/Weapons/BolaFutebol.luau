-- BolaFutebol.lua
-- Versão ARCADE (rápida, multi-projétil, baixo dano)

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

local WeaponBase = require(script.Parent:WaitForChild("WeaponBase"))
local EnemyDamageService = require(
	game.ServerScriptService.Combat.EnemyDamageService
)
local WeaponEffectService = require(
	game.ServerScriptService.Weapons:WaitForChild("WeaponEffectService")
)

local BolaFutebol = {}
BolaFutebol.__index = BolaFutebol
setmetatable(BolaFutebol, { __index = WeaponBase })

local ProjectileTemplate =
	ReplicatedStorage
	:WaitForChild("Weapons")
	:WaitForChild("BolaFutebol")
	:WaitForChild("BolaProjectile")

--------------------------------------------------
-- CONFIG ARCADE
--------------------------------------------------

local BASE_PROJECTILE_COUNT = 3
local PROJECTILE_LIFETIME = 2
local ROTATION_SPEED = 900

--------------------------------------------------
-- CONSTRUTOR
--------------------------------------------------

function BolaFutebol.new(player, limiter)

	local self = WeaponBase.new({
		Name = "BolaFutebol",
		Damage = 8,              -- baixo dano
		Range = 22,
		Cooldown = 0.8,          -- recarrega rápido
		ProjectileSpeed = 55     -- rápido
	}, player, limiter)

	self.Level = 1

	self.Scaling = {
		Damage = 1.08,
		ProjectileSpeed = 1.05,
	}

	setmetatable(self, BolaFutebol)
	return self
end

--------------------------------------------------
-- EVOLUÇÃO
--------------------------------------------------

function BolaFutebol:OnUpgrade(level)

	self.Level = level
	self.BaseStats.Damage *= self.Scaling.Damage
	self.BaseStats.ProjectileSpeed *= self.Scaling.ProjectileSpeed

	print("⚽ BolaFutebol nível:", level)
end

--------------------------------------------------
-- IMPACTO
--------------------------------------------------

local function spawnImpact(position)

	local impact = Instance.new("Part")
	impact.Shape = Enum.PartType.Ball
	impact.Anchored = true
	impact.CanCollide = false
	impact.Material = Enum.Material.Neon
	impact.Color = Color3.new(1,1,1)
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

	Debris:AddItem(impact, 0.25)
end

--------------------------------------------------
-- SPAWN BOLA ARCADE
--------------------------------------------------

local function spawnBall(self, origin, direction, speed, range, damage, attrs)

	if not self:CanSpawnProjectile() then return end
	self:OnProjectileSpawn()

	local model = ProjectileTemplate:Clone()
	model.Parent = workspace

	self:ApplyWeaponAura(model)
	

	model:ScaleTo(1.1 * (attrs.AttackSize or 1))

	local primary = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
	if not primary then
		model:Destroy()
		self:OnProjectileDestroy()
		return
	end

	model.PrimaryPart = primary
	primary.Anchored = true
	primary.CanCollide = false

	-- 🌟 Glow branco
	local glow = Instance.new("Highlight")
	glow.FillColor = Color3.new(1,1,1)
	glow.FillTransparency = 0.5
	glow.OutlineTransparency = 1
	glow.Parent = model

	-- ✨ Trail branco
	local a0 = Instance.new("Attachment", primary)
	local a1 = Instance.new("Attachment", primary)
	a1.Position = Vector3.new(0, 0, -1)

	local trail = Instance.new("Trail")
	trail.Attachment0 = a0
	trail.Attachment1 = a1
	trail.Color = ColorSequence.new(Color3.new(1,1,1))
	trail.LightEmission = 1
	trail.WidthScale = NumberSequence.new(0.7)
	trail.Lifetime = 0.2
	trail.Parent = primary

	local traveled = 0
	local lastPos = origin

	model:PivotTo(CFrame.new(origin))

	local conn
	conn = RunService.Heartbeat:Connect(function(dt)

		traveled += speed * dt
		if traveled >= range then
			conn:Disconnect()
			model:Destroy()
			self:OnProjectileDestroy()
			return
		end

		local newPos = lastPos + direction * speed * dt

		model:PivotTo(
			CFrame.new(newPos) *
			CFrame.Angles(math.rad(ROTATION_SPEED * dt), 0, 0)
		)

		lastPos = newPos

		-- 🎯 COLISÃO
		for _, enemy in ipairs(_G.Enemies or {}) do
			if enemy.Alive and enemy.Root and enemy.Humanoid then

				local dist =
					(enemy.Root.Position - newPos).Magnitude

				if dist <= 2.5 * (attrs.AttackSize or 1) then

					local finalDamage =
						self:ComputeFinalDamage(damage, attrs)

					EnemyDamageService:DamageEnemy(
						self.Player,
						enemy.Humanoid,
						finalDamage
					)

					self:ApplyHitEffects(enemyData)

					spawnImpact(newPos)

					conn:Disconnect()
					model:Destroy()
					self:OnProjectileDestroy()
					return
				end
			end
		end
	end)

	Debris:AddItem(model, PROJECTILE_LIFETIME)
end

--------------------------------------------------
-- ATAQUE
--------------------------------------------------

function BolaFutebol:Attack(root, attrs)

	local finalRange =
		self.BaseStats.Range * attrs.Range

	local enemies = self:GetEnemiesInRange(finalRange)
	if #enemies == 0 then return end

	self:StartCooldown(attrs)

	local multi = math.max(1, math.floor(attrs.MultiAttack or 1))
	local projectileCount =
		BASE_PROJECTILE_COUNT + (multi - 1)

	for i = 1, projectileCount do

		local enemy =
			enemies[((i - 1) % #enemies) + 1]

		if not enemy or not enemy.Root then continue end

		local dir =
			(enemy.Root.Position - root.Position).Unit

		local origin =
			root.Position
			+ dir * 2
			+ Vector3.new(0, 0.6, 0)

		local speed =
			self.BaseStats.ProjectileSpeed
			* attrs.ProjectileSpeed

		spawnBall(
			self,
			origin,
			dir,
			speed,
			finalRange,
			self.BaseStats.Damage,
			attrs
		)
		
		self:ApplyHitEffects(enemy)
		
	end
end

return BolaFutebol
