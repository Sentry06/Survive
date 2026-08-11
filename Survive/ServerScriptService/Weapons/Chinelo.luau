-- Chinelo.lua
-- Versão Física com Impacto Real + Glow Azul + Trail Azul

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

local EnemyDamageService = require(
	game.ServerScriptService.Combat.EnemyDamageService
)

local WeaponEffectService = require(
	script.Parent:WaitForChild("WeaponEffectService")
)

local WeaponBase = require(script.Parent:WaitForChild("WeaponBase"))

local Chinelo = {}
Chinelo.__index = Chinelo
setmetatable(Chinelo, { __index = WeaponBase })

local ProjectileTemplate =
	ReplicatedStorage
	:WaitForChild("Weapons")
	:WaitForChild("Chinelo")
	:WaitForChild("ChineloProjectile")

--------------------------------------------------
-- CONSTRUTOR
--------------------------------------------------

function Chinelo.new(player, limiter)

	local self = WeaponBase.new({
		Name = "Chinelo",
		Damage = 40,
		Range = 11,
		Cooldown = 2.2,
		ProjectileSpeed = 18
	}, player, limiter)

	self.Level = 1

	self.Scaling = {
		Damage = 1.15,
		Range = 1.05,
	}

	setmetatable(self, Chinelo)
	return self
end

--------------------------------------------------
-- EVOLUÇÃO
--------------------------------------------------

function Chinelo:OnUpgrade(level)

	self.Level = level

	self.BaseStats.Damage *= self.Scaling.Damage
	self.BaseStats.Range *= self.Scaling.Range

	print("🩴 Chinelo nível:", level)
end

--------------------------------------------------
-- IMPACT EFFECT
--------------------------------------------------

local function spawnImpact(position)

	local p = Instance.new("Part")
	p.Anchored = true
	p.CanCollide = false
	p.Shape = Enum.PartType.Ball
	p.Material = Enum.Material.Neon
	p.Color = Color3.fromRGB(80,170,255)
	p.Size = Vector3.new(1,1,1)
	p.CFrame = CFrame.new(position)
	p.Parent = workspace

	local tween = TweenService:Create(
		p,
		TweenInfo.new(0.25),
		{
			Size = Vector3.new(5,5,5),
			Transparency = 1
		}
	)

	tween:Play()
	Debris:AddItem(p, 0.3)
end

--------------------------------------------------
-- SPAWN CHINELO PROJETIL REAL
--------------------------------------------------

local function spawnChinelo(self, origin, direction, range, speed, sizeMultiplier, enemyData, damage)

	if not self:CanSpawnProjectile() then return end
	self:OnProjectileSpawn()

	local model = ProjectileTemplate:Clone()
	model.Parent = workspace
	
	self:ApplyWeaponAura(model)


	if not model.PrimaryPart then
		model.PrimaryPart = model:FindFirstChildWhichIsA("BasePart")
	end

	local primary = model.PrimaryPart
	if not primary then
		model:Destroy()
		return
	end

	-- Garantir soldagem correta
	for _, part in ipairs(model:GetDescendants()) do
		if part:IsA("BasePart") and part ~= primary then
			local weld = Instance.new("WeldConstraint")
			weld.Part0 = primary
			weld.Part1 = part
			weld.Parent = primary
			part.Anchored = false
			part.CanCollide = false
			part.Massless = true
		end
	end

	primary.Anchored = true
	primary.CanCollide = false
	model:ScaleTo(sizeMultiplier)

	-- 🔵 Glow Azul (sem alterar material)
	local light = Instance.new("PointLight")
	light.Color = Color3.fromRGB(80,170,255)
	light.Brightness = 2.5
	light.Range = 8
	light.Parent = primary

	-- 🔵 Trail Azul
	local att0 = Instance.new("Attachment", primary)
	local att1 = Instance.new("Attachment", primary)

	att0.Position = Vector3.new(0,0.4,0)
	att1.Position = Vector3.new(0,-0.4,0)

	local trail = Instance.new("Trail")
	trail.Attachment0 = att0
	trail.Attachment1 = att1
	trail.Lifetime = 0.25
	trail.Color = ColorSequence.new(Color3.fromRGB(80,170,255))
	trail.Parent = primary

	model:PivotTo(CFrame.new(origin, origin + direction))

	local traveled = 0
	local lastPos = origin
	local hit = false

	local conn
	conn = RunService.Heartbeat:Connect(function(dt)

		local step = speed * dt
		traveled += step

		local newPos = lastPos + direction * step

		model:PivotTo(
			CFrame.new(newPos, newPos + direction)
				* CFrame.Angles(
					math.rad(traveled * 40),
					math.rad(traveled * 25),
					0
				)
		)

		lastPos = newPos

		-- 🎯 IMPACTO REAL
		if not hit
			and enemyData
			and enemyData.Alive
			and enemyData.Root then

			local dist =
				(enemyData.Root.Position - newPos).Magnitude

			if dist <= 3 * sizeMultiplier then

				hit = true

				EnemyDamageService:DamageEnemy(
					self.Player,
					enemyData.Humanoid,
					damage
				)

				self:ApplyHitEffects(enemyData)

				spawnImpact(newPos)

				conn:Disconnect()
				model:Destroy()
				self:OnProjectileDestroy()
				return
			end
		end

		if traveled >= range then
			conn:Disconnect()
			model:Destroy()
			self:OnProjectileDestroy()
		end
	end)

	Debris:AddItem(model, 6)
end

--------------------------------------------------
-- ATAQUE
--------------------------------------------------

function Chinelo:Attack(root, attrs)

	local finalRange =
		self.BaseStats.Range * attrs.Range

	local enemies = self:GetEnemiesInRange(finalRange)
	if #enemies == 0 then return end

	self:StartCooldown(attrs)

	local multi = math.max(1, math.floor(attrs.MultiAttack or 1))

	for i = 1, math.min(multi, #enemies) do

		local enemy = enemies[i]
		if not enemy or not enemy.Alive then continue end

		local finalDamage =
			self:ComputeFinalDamage(self.BaseStats.Damage, attrs)

		local dir =
			(enemy.Root.Position - root.Position).Unit

		local origin =
			root.Position
			+ dir * 2
			+ Vector3.new(0, 1.6, 0)

		spawnChinelo(
			self,
			origin,
			dir,
			finalRange,
			self.BaseStats.ProjectileSpeed * attrs.ProjectileSpeed,
			attrs.AttackSize or 1,
			enemy,
			finalDamage
		)
		
		self:ApplyHitEffects(enemyData)
		
	end
end

return Chinelo
