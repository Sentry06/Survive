local RunService = game:GetService("RunService")
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
-- TEMPLATES
-------------------------------------------------

local PancadaoFolder =
	ReplicatedStorage
	:WaitForChild("Weapons")
	:WaitForChild("Pancadao")

local SpeakerTemplate = PancadaoFolder:WaitForChild("Pancadao")
local WaveTemplate = SpeakerTemplate:WaitForChild("SoundWave")

-------------------------------------------------
-- CLASS
-------------------------------------------------

local Pancadao = {}
Pancadao.__index = Pancadao
setmetatable(Pancadao,{__index = WeaponBase})

-------------------------------------------------
-- CONSTRUCTOR
-------------------------------------------------

function Pancadao.new(player, limiter)

	local baseStats = {
		Name = "Pancadao",
		Damage = 18,
		Cooldown = 2.2,
		Range = 12,
		AttackSize = 1,
		ProjectileSpeed = 30,
		ProjectilePierce = 0,
		AreaDamage = 0
	}

	local self = WeaponBase.new(baseStats, player, limiter)

	self.Level = 1

	self.Scaling = {
		Damage = 1.12,
		Cooldown = 0.94
	}

	setmetatable(self, Pancadao)
	return self
end

-------------------------------------------------
-- UPGRADE
-------------------------------------------------

function Pancadao:OnUpgrade(level)

	self.Level = level

	self.BaseStats.Damage *= self.Scaling.Damage
	self.BaseStats.Cooldown *= self.Scaling.Cooldown

end

-------------------------------------------------
-- SOUND WAVE
-------------------------------------------------

local function spawnSoundWave(self, origin, direction, range, attrs, damage)

	local wave = WaveTemplate:Clone()
	wave.Parent = workspace

	if wave:IsA("BasePart") then
		wave.Transparency = 1
	end

	local emitter = wave:FindFirstChildOfClass("ParticleEmitter")
	if emitter then
		emitter:Emit(20 * (attrs.AttackSize or 1))
	end

	local sound = wave:FindFirstChildOfClass("Sound")
	if sound then
		sound:Play()
	end

	local speed =
		self.BaseStats.ProjectileSpeed * attrs.ProjectileSpeed

	local traveled = 0
	local lastPos = origin

	local pierce =
		math.floor(attrs.ProjectilePierce or 0)

	local hitEnemies = {}

	local conn
	conn = RunService.Heartbeat:Connect(function(dt)

		local step = speed * dt
		traveled += step

		local newPos = lastPos + direction * step
		lastPos = newPos

		wave.CFrame = CFrame.new(newPos, newPos + direction)

		for _,enemy in ipairs(_G.Enemies or {}) do

			if enemy.Alive and enemy.Root and enemy.Humanoid then

				local dist =
					(enemy.Root.Position - newPos).Magnitude

				if dist <= 4 * (attrs.AttackSize or 1) then

					if not hitEnemies[enemy] then

						hitEnemies[enemy] = true

						EnemyDamageService:DamageEnemy(
							self.Player,
							enemy.Humanoid,
							damage
						)

						self:ApplyHitEffects(enemy)

						if pierce <= 0 then
							conn:Disconnect()
							wave:Destroy()
							return
						else
							pierce -= 1
						end

					end
				end
			end
		end

		if traveled >= range then
			conn:Disconnect()
			wave:Destroy()
		end

	end)

	Debris:AddItem(wave,4)

end

-------------------------------------------------
-- SPEAKER
-------------------------------------------------

local function spawnSpeaker(self, root, attrs)

	local speaker = SpeakerTemplate:Clone()
	speaker.Parent = workspace

	if not speaker.PrimaryPart then
		speaker.PrimaryPart = speaker:FindFirstChildWhichIsA("BasePart")
	end

	local pos = root.Position + Vector3.new(0,0,-3)

	speaker:PivotTo(CFrame.new(pos))

	local lifeTime = 4
	local fireRate = 0.35
	
	self:ApplyWeaponAura(speaker)

	task.delay(lifeTime,function()
		if speaker then
			speaker:Destroy()
		end
	end)

	task.spawn(function()

		while speaker.Parent do

			local enemies =
				self:GetEnemiesInRange(
					self.BaseStats.Range * attrs.Range
				)

			if #enemies > 0 then

				local enemy = enemies[1]

				local speakerPos =
					speaker.PrimaryPart.Position

				local dir =
					(enemy.Root.Position - speakerPos).Unit

				speaker:PivotTo(
					CFrame.new(speakerPos, enemy.Root.Position)
				)

				local damage =
					self:ComputeFinalDamage(
						self.BaseStats.Damage,
						attrs
					)

				local multi =
					math.max(1, math.floor(attrs.MultiAttack or 1))

				for i = 1, multi do

					spawnSoundWave(
						self,
						speakerPos,
						dir,
						self.BaseStats.Range * attrs.Range,
						attrs,
						damage
					)

				end

			end

			task.wait(fireRate)

		end

	end)

end

-------------------------------------------------
-- ATTACK
-------------------------------------------------

function Pancadao:Attack(root, attrs)

	local finalRange =
		self.BaseStats.Range * attrs.Range

	local enemies = self:GetEnemiesInRange(finalRange)

	if #enemies == 0 then
		return
	end

	self:StartCooldown(attrs)

	spawnSpeaker(self, root, attrs)

end

return Pancadao