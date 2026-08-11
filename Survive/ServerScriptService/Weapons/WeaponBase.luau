-- WeaponBase.lua
-- VERSÃO ULTRA DEFENSIVA FINAL

local WeaponBase = {}
WeaponBase.__index = WeaponBase

local WeaponEffectService =
	require(game.ServerScriptService.Weapons.WeaponEffectService)

local ArtifactService =
	require(game.ServerScriptService.Artifacts.ArtifactService)

-- =====================
-- DEFAULT ATTRIBUTES
-- =====================

local DEFAULT_ATTRIBUTES = {
	Damage = 1,
	Cooldown = 1,
	Range = 1,
	MultiAttack = 1,
	AttackSize = 1,
	ProjectileSpeed = 1,
	ProjectilePierce = 0,
	AreaDamage = 0,
	Luck = 0,
}

local ATTRIBUTE_LIMITS = {
	Damage = {0.01, 1000},
	Cooldown = {0.01, 100},
	Range = {0.1, 200},
	MultiAttack = {1, 100},
	AttackSize = {0.1, 20},
	ProjectileSpeed = {0.01, 500},
	ProjectilePierce = {0, 100},
	AreaDamage = {0, 100},
	Luck = {0, 1000},
}

-- =====================
-- SAFE CLAMP
-- =====================

local function clamp(name, value)

	if typeof(value) ~= "number" then
		value = DEFAULT_ATTRIBUTES[name] or 1
	end

	local limits = ATTRIBUTE_LIMITS[name]
	if not limits then return value end

	return math.clamp(value, limits[1], limits[2])
end

-- =====================
-- SANITIZE BASESTATS
-- =====================

local function sanitizeBaseStats(config)

	return {
		Damage = tonumber(config.Damage) or 10,
		Cooldown = tonumber(config.Cooldown) or 1,
		Range = tonumber(config.Range) or 8,
		ProjectileSpeed = tonumber(config.ProjectileSpeed) or 20,
		AttackSize = tonumber(config.AttackSize) or 1,
		ProjectilePierce = tonumber(config.ProjectilePierce) or 0,
		AreaDamage = tonumber(config.AreaDamage) or 0,
	}
end

-- =====================
-- CONSTRUCTOR
-- =====================

function WeaponBase.new(config, player, projectileLimiter)

	local self = {}

	self.Player = player
	self.ProjectileLimiter = projectileLimiter
	self.Name = config.Name or "Weapon"

	self.BaseStats = sanitizeBaseStats(config)

	self.Level = 1
	self.Cooldown = 0

	-- 🔥 BACKWARD COMPATIBILITY AUTO-FIX
	self.DAMAGE_BASE = self.BaseStats.Damage
	self.RANGE_BASE = self.BaseStats.Range
	self.PROJECTILE_SPEED = self.BaseStats.ProjectileSpeed
	self.COOLDOWN_BASE = self.BaseStats.Cooldown

	return setmetatable(self, WeaponBase)
end

-- =====================
-- ROOT
-- =====================

function WeaponBase:GetRoot()
	local char = self.Player.Character
	return char and char:FindFirstChild("HumanoidRootPart")
end

-- =====================
-- FINAL ATTRIBUTES
-- =====================

function WeaponBase:GetFinalAttributes()

	local player = self.Player
	local ms = player:FindFirstChild("MatchStats")
	local gs = player:FindFirstChild("GlobalStats")

	local final = {}

	local function read(folder, attrName)
		if not folder then return nil end
		local v = folder:FindFirstChild(attrName)
		if v and typeof(v.Value) == "number" then
			return v.Value
		end
	end

	-- 🔥 TODOS OS ATRIBUTOS DO JOGO
	local ALL_ATTRIBUTES = {
		"Damage","Cooldown","Range","MultiAttack","MovementSpeed",
		"AttackSize","ProjectileSpeed","Luck","Shield","ShieldRegenDelay",
		"MaxHP","LifeRegen","ProjectilePierce","AreaDamage"
	}

	-- TIPOS
	local MULTIPLIER = {
		Damage=true, Range=true, ProjectileSpeed=true,
		AttackSize=true, MovementSpeed=true, MaxHP=true
	}

	local INVERSE = {
		Cooldown=true, ShieldRegenDelay=true
	}

	local ADDITIVE = {
		MultiAttack=true, ProjectilePierce=true, AreaDamage=true,
		LifeRegen=true, Shield=true, Luck=true
	}
	local INVERSE_TIME = {
		ShieldRegenDelay = true
	}


	for _, attrName in ipairs(ALL_ATTRIBUTES) do

		local run = read(ms and ms:FindFirstChild("Attributes"), attrName)
		local global = read(gs, attrName)
		local synergy = read(ms and ms:FindFirstChild("SynergyBonuses"), attrName)
		local modifier = read(ms and ms:FindFirstChild("ModifierBonuses"), attrName)

		-- FALLBACKS
		if MULTIPLIER[attrName] or INVERSE[attrName] then
			run = run or 1
			global = global or 1
			synergy = synergy or 1

			if synergy == 0 then synergy = 1 end
			if global == 0 then global = 1 end

		elseif ADDITIVE[attrName] then
			run = run or 0
			global = global or 0
			synergy = synergy or 0
		end

		local value

		-- 🔥 TEMPO ABSOLUTO (NÃO USA GLOBAL)
		if INVERSE_TIME[attrName] then

			value = run * synergy * modifier

			-- 🔥 MULTIPLICADORES
		elseif MULTIPLIER[attrName] or INVERSE[attrName] then

			value = run * global * synergy * modifier

			-- 🔥 ADITIVOS
		elseif ADDITIVE[attrName] then

			if attrName == "MultiAttack" then
				value = 1 + (run - 1) + (global - 1) + synergy
			else
				value = run + global + synergy + modifier
			end

			-- 🔥 FALLBACK
		else
			value = run + global + synergy + modifier
		end
	
		value = clamp(attrName, value)
		final[attrName] = value

	end

	final.Ignis = player:GetAttribute("Artifact_Ignis") == true

	return final
end

-- =====================
-- ENEMIES
-- =====================

function WeaponBase:GetEnemiesInRange(range)

	local root = self:GetRoot()
	if not root then return {} end

	local enemies = {}

	for _, enemy in ipairs(_G.Enemies or {}) do
		if enemy.Alive and enemy.Root then
			local d = (enemy.Root.Position - root.Position).Magnitude
			if d <= range then
				table.insert(enemies, enemy)
			end
		end
	end

	table.sort(enemies, function(a, b)
		return
			(a.Root.Position - root.Position).Magnitude <
			(b.Root.Position - root.Position).Magnitude
	end)

	return enemies
end

-- =====================
-- LOOP
-- =====================

function WeaponBase:Tick(dt)

	if typeof(self.Cooldown) ~= "number" then
		self.Cooldown = 0
	end

	if self.Cooldown > 0 then
		self.Cooldown -= dt
	end

	if self.Cooldown < 0 then
		self.Cooldown = 0
	end
end

function WeaponBase:TryAttack()

	if self.Cooldown > 0 then return end

	local root = self:GetRoot()
	if not root then return end

	local attrs = self:GetFinalAttributes()
	if not attrs then return end

	if typeof(self.Attack) ~= "function" then
		warn(self.Name .. " não implementou Attack()")
		return
	end

	self:Attack(root, attrs)
end

-- =====================
-- COOLDOWN SAFE
-- =====================

function WeaponBase:StartCooldown(attrs)

	local base = self.BaseStats.Cooldown or 1
	local modifier = math.max(0.01, attrs.Cooldown or 1)

	self.Cooldown = base / modifier

	if self.Cooldown < 0 then
		self.Cooldown = 0
	end
end

-- =====================
-- DAMAGE SAFE
-- =====================

function WeaponBase:ComputeFinalDamage(baseDamage, attrs)

	baseDamage = tonumber(baseDamage) or 1

	local dmg = baseDamage * (attrs.Damage or 1)

	if ArtifactService:HasTag(self.Player, "DamageMultiplier") then
		local data = ArtifactService:GetData(self.Player)
		if data and data.Multiplier then
			dmg *= data.Multiplier
		end
	end

	if self.ModifyDamage then
		dmg = self:ModifyDamage(dmg, attrs) or dmg
	end

	if dmg < 0 then dmg = 0 end

	return math.floor(dmg)
end

-------------------------------------------------
-- APPLY HIT EFFECTS (GLOBAL)
-------------------------------------------------

local ModifierService = require(
	game.ServerScriptService.Modifiers.ModifierService
)

function WeaponBase:ApplyHitEffects(enemyData, damageData)

	if not enemyData then return end

	-- 🔥 MODIFIER HOOK
	if damageData then
		ModifierService:OnHit(self.Player, enemyData, damageData)
	end

	local success, err = pcall(function()

		WeaponEffectService:ApplyOnHit(
			self.Player,
			enemyData
		)

	end)

	if not success then
		warn("WeaponEffectService error:", err)
	end

end

-------------------------------------------------
-- APPLY WEAPON AURA
-------------------------------------------------

function WeaponBase:ApplyWeaponAura(model)

	if not model then return end

	local success, err = pcall(function()

		WeaponEffectService:ApplyWeaponAura(
			self.Player,
			model
		)

	end)

	if not success then
		warn("Weapon aura error:", err)
	end

end

-- =====================
-- PROJECTILE LIMITER SAFE
-- =====================

function WeaponBase:CanSpawnProjectile()
	if not self.ProjectileLimiter then return true end
	return self.ProjectileLimiter.Active < self.ProjectileLimiter.Max
end

function WeaponBase:OnProjectileSpawn()
	if not self.ProjectileLimiter then return end
	self.ProjectileLimiter.Active =
		math.max(0, self.ProjectileLimiter.Active + 1)
end

function WeaponBase:OnProjectileDestroy()
	if not self.ProjectileLimiter then return end
	self.ProjectileLimiter.Active =
		math.max(0, self.ProjectileLimiter.Active - 1)
end

-- =====================
-- OVERRIDE
-- =====================

function WeaponBase:Attack()
	warn(self.Name .. " não implementou Attack()")
end


return WeaponBase
