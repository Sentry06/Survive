-- Knife.lua
-- Versão com Glow, Trail, Impact e integração com WeaponEffectService

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

local EnemyDamageService = require(
	game.ServerScriptService.Combat.EnemyDamageService
)

local WeaponEffectService = require(
	game.ServerScriptService.Weapons:WaitForChild("WeaponEffectService")
)

local WeaponBase = require(script.Parent:WaitForChild("WeaponBase"))

local Knife = {}
Knife.__index = Knife
setmetatable(Knife,{ __index = WeaponBase })

-------------------------------------------------
-- TEMPLATE
-------------------------------------------------

local KnifeTemplate =
	ReplicatedStorage
	:WaitForChild("Weapons")
	:WaitForChild("Knife")
	:WaitForChild("KnifeProjectile")

-------------------------------------------------
-- CONSTRUTOR
-------------------------------------------------

function Knife.new(player, limiter)

	local baseStats = {
		Name = "Knife",
		Damage = 20,
		Cooldown = 1.3,
		Range = 16,
		ProjectileSpeed = 22,
		AttackSize = 1,
		ProjectilePierce = 0,
		AreaDamage = 0
	}

	local self = WeaponBase.new(baseStats, player, limiter)

	self.Level = 1

	self.Scaling = {
		Damage = 1.10,
		Cooldown = 0.94
	}

	setmetatable(self, Knife)
	return self
end

-------------------------------------------------
-- EVOLUÇÃO
-------------------------------------------------

function Knife:OnUpgrade(level)
	self.Level = level
	self.BaseStats.Damage *= self.Scaling.Damage
	self.BaseStats.Cooldown *= self.Scaling.Cooldown
end

-------------------------------------------------
-- VISUAL HELPERS
-------------------------------------------------

local function addGlow(knife)

	local blade = knife:FindFirstChildWhichIsA("BasePart")
	if not blade then return end

	local light = Instance.new("PointLight")
	light.Color = Color3.fromRGB(255, 240, 180)
	light.Brightness = 2
	light.Range = 8
	light.Parent = blade

	blade.Material = Enum.Material.Neon
end

local function addTrail(knife)

	local part = knife:FindFirstChildWhichIsA("BasePart")
	if not part then return end

	local att0 = Instance.new("Attachment", part)
	local att1 = Instance.new("Attachment", part)

	att0.Position = Vector3.new(0, 0.5, 0)
	att1.Position = Vector3.new(0, -0.5, 0)

	local trail = Instance.new("Trail")
	trail.Attachment0 = att0
	trail.Attachment1 = att1
	trail.Lifetime = 0.15
	trail.MinLength = 0.1
	trail.Color = ColorSequence.new(Color3.fromRGB(255,255,255))
	trail.Parent = part
end

local function spawnImpact(position)

	local p = Instance.new("Part")
	p.Anchored = true
	p.CanCollide = false
	p.Shape = Enum.PartType.Ball
	p.Material = Enum.Material.Neon
	p.Color = Color3.fromRGB(255, 255, 255)
	p.Transparency = 0.65
	p.Size = Vector3.new(1,1,1)
	p.CFrame = CFrame.new(position)
	p.Parent = workspace

	local tween = TweenService:Create(
		p,
		TweenInfo.new(0.2),
		{
			Size = Vector3.new(4,4,4),
			Transparency = 1
		}
	)

	tween:Play()
	Debris:AddItem(p, 0.3)
end

-------------------------------------------------
-- PROJÉTIL
-------------------------------------------------

local function spawnKnife(self, origin, direction, range, speed, sizeMultiplier, enemyData, damage)

	local knife = KnifeTemplate:Clone()
	knife.Parent = workspace

	self:ApplyWeaponAura(knife)

	local part = knife
	if knife:IsA("Model") then
		part = knife.PrimaryPart
	end

	if not part then
		knife:Destroy()
		return
	end

	part.Anchored = true
	part.CanCollide = false
	-- Escala correta baseada em AttackSize
	if knife:IsA("BasePart") then
		knife.Size = knife.Size * sizeMultiplier
	elseif knife:IsA("Model") and knife.PrimaryPart then
		knife:ScaleTo(sizeMultiplier)
	end

	local mesh = knife:FindFirstChildWhichIsA("SpecialMesh") 
		or knife:FindFirstChildWhichIsA("FileMesh")

	if mesh then
		if not mesh:GetAttribute("OriginalScale") then
			mesh:SetAttribute("OriginalScaleX", mesh.Scale.X)
			mesh:SetAttribute("OriginalScaleY", mesh.Scale.Y)
			mesh:SetAttribute("OriginalScaleZ", mesh.Scale.Z)
		end

		local originalScale = Vector3.new(
			mesh:GetAttribute("OriginalScaleX"),
			mesh:GetAttribute("OriginalScaleY"),
			mesh:GetAttribute("OriginalScaleZ")
		)

		mesh.Scale = originalScale * 1.2 * sizeMultiplier
	end


	-- 🔥 Glow SUAVE (sem mudar cor)
	local light = Instance.new("PointLight")
	light.Color = Color3.fromRGB(255, 220, 150)
	light.Brightness = 2
	light.Range = 6
	light.Parent = part

	-- 🔥 Trail (já funcionando)
	local att0 = Instance.new("Attachment", part)
	local att1 = Instance.new("Attachment", part)

	att0.Position = Vector3.new(0, 0.4, 0)
	att1.Position = Vector3.new(0, -0.4, 0)

	local trail = Instance.new("Trail")
	trail.Attachment0 = att0
	trail.Attachment1 = att1
	trail.Lifetime = 0.25
	trail.Parent = part

	part.CFrame = CFrame.new(origin, origin + direction)

	local traveled = 0
	local lastPos = origin
	local hit = false

	local conn
	conn = RunService.Heartbeat:Connect(function(dt)

		local step = speed * dt
		traveled += step

		local newPos = lastPos + direction * step

		part.CFrame =
			CFrame.new(newPos, newPos + direction)
			* CFrame.Angles(0, math.rad(90), math.rad(traveled * 30))

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

				local WeaponEffectService =
					require(script.Parent:WaitForChild("WeaponEffectService"))

				self:ApplyHitEffects(enemyData)

				spawnImpact(newPos)

				conn:Disconnect()
				knife:Destroy()
				self:OnProjectileDestroy()
				return
			end
		end

		if traveled >= range then
			conn:Disconnect()
			knife:Destroy()
			self:OnProjectileDestroy()
		end
		
		if not knife or not knife.Parent then
			conn:Disconnect()
			return
		end
	end)

	task.delay(5, function()
		if conn then conn:Disconnect() end
		if knife then knife:Destroy() end
	end)
	
	Debris:AddItem(knife, 5)
end

-------------------------------------------------
-- ATAQUE
-------------------------------------------------

function Knife:Attack(root, attrs)

	if not self:CanSpawnProjectile() then return end

	local finalRange =
		self.BaseStats.Range * attrs.Range

	local enemies = self:GetEnemiesInRange(finalRange)
	if #enemies == 0 then return end

	self:StartCooldown(attrs)

	local multi = math.max(1, math.floor(attrs.MultiAttack or 1))
	local attackSize = attrs.AttackSize or 1

	for i = 1, multi do

		local enemy = enemies[(i - 1) % #enemies + 1]

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
			+ Vector3.new(0, 1.5, 0)

		spawnKnife(
			self,
			origin,
			dir,
			finalRange,
			self.BaseStats.ProjectileSpeed * attrs.ProjectileSpeed,
			attackSize,
			enemy,
			finalDamage
		)
		self:OnProjectileSpawn()
		self:ApplyHitEffects(enemy)
		
	end
end

return Knife
