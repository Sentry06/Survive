local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local EnemyDamageService = require(
	game.ServerScriptService.Combat.EnemyDamageService
)

local WeaponEffectService = require(
	game.ServerScriptService.Weapons:WaitForChild("WeaponEffectService")
)

local WeaponBase = require(script.Parent:WaitForChild("WeaponBase"))

-------------------------------------------------
-- TEMPLATE
-------------------------------------------------

local BatTemplate =
	ReplicatedStorage
	:WaitForChild("Weapons")
	:WaitForChild("TungTungTungSahurBat")
	:WaitForChild("TungTungTungSahurBat")

-------------------------------------------------
-- CLASS
-------------------------------------------------

local TungTungTungSahurBat = {}
TungTungTungSahurBat.__index = TungTungTungSahurBat
setmetatable(TungTungTungSahurBat,{__index = WeaponBase})

-------------------------------------------------
-- CONSTRUCTOR
-------------------------------------------------

function TungTungTungSahurBat.new(player, limiter)

	local baseStats = {
		Name = "TungTungTungSahurBat",
		Damage = 30,
		Cooldown = 1.9,
		Range = 10,
		AttackSize = 3,
		ProjectileSpeed = 1,
		ProjectilePierce = 0,
		AreaDamage = 0
	}

	local self = WeaponBase.new(baseStats, player, limiter)

	self.Level = 1

	self.Scaling = {
		Damage = 1.18,
		Cooldown = 0.95
	}

	setmetatable(self, TungTungTungSahurBat)
	return self
end

-------------------------------------------------
-- UPGRADE
-------------------------------------------------

function TungTungTungSahurBat:OnUpgrade(level)

	self.Level = level

	self.BaseStats.Damage *= self.Scaling.Damage
	self.BaseStats.Cooldown *= self.Scaling.Cooldown

end

-------------------------------------------------
-- HIT EFFECT
-------------------------------------------------

local function spawnHitEffect(self, root, enemy, size)

	if not enemy or not enemy.Root then
		return
	end

	local bat = BatTemplate:Clone()
	bat.Parent = workspace

	if not bat.PrimaryPart then
		bat.PrimaryPart = bat:FindFirstChildWhichIsA("BasePart")
	end

	local primary = bat.PrimaryPart
	if not primary then
		bat:Destroy()
		return
	end

	local pos =
		root.Position
		+ (enemy.Root.Position - root.Position).Unit * 2

	local cf =
		CFrame.new(pos, enemy.Root.Position)
		* CFrame.Angles(0,0,math.rad(240))

	bat:PivotTo(cf)

	bat:ScaleTo(size)

	local punch = primary:FindFirstChild("Punch")
	if punch then
		punch:Play()
	end

	local emitter = primary:FindFirstChildOfClass("ParticleEmitter")
	if emitter then
		emitter:Emit(8 * size)
	end

	self:ApplyWeaponAura(bat)

	Debris:AddItem(bat,0.35)

end

-------------------------------------------------
-- ATTACK
-------------------------------------------------

function TungTungTungSahurBat:Attack(root, attrs)

	local finalRange =
		self.BaseStats.Range * attrs.Range

	local enemies = self:GetEnemiesInRange(finalRange)

	if #enemies == 0 then
		return
	end

	self:StartCooldown(attrs)

	local multi =
		math.max(1, math.floor(attrs.MultiAttack or 1))

	local pierce =
		math.floor(attrs.ProjectilePierce or 0)

	local attackSize =
		attrs.AttackSize or 1

	local damage =
		self:ComputeFinalDamage(self.BaseStats.Damage, attrs)

	for i = 1, math.min(multi, #enemies) do

		local enemy = enemies[i]

		if enemy and enemy.Humanoid then

			spawnHitEffect(self, root, enemy, attackSize)

			EnemyDamageService:DamageEnemy(
				self.Player,
				enemy.Humanoid,
				damage
			)

			self:ApplyHitEffects(enemy)

			-- pierce hit additional enemies
			if pierce > 0 then

				for j = 1, pierce do

					local extraEnemy = enemies[i + j]

					if extraEnemy and extraEnemy.Humanoid then

						EnemyDamageService:DamageEnemy(
							self.Player,
							extraEnemy.Humanoid,
							damage
						)

					end
				end

			end

		end
	end

end

return TungTungTungSahurBat