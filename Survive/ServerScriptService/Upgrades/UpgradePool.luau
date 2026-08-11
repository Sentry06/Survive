-- UpgradePool.lua
-- Pool de upgrades com RARIDADE + LUCK
-- (atributos agora, armas depois via baú)

local UpgradePool = {}
UpgradePool.__index = UpgradePool

-- =====================
-- RARIDADES
-- =====================
local RARITIES = {
	{
		Name = "Bronze",
		Chance = 65,
		Multiplier = 0.02
	},
	{
		Name = "Silver",
		Chance = 25,
		Multiplier = 0.05
	},
	{
		Name = "Gold",
		Chance = 9,
		Multiplier = 0.10
	},
	{
		Name = "Diamond",
		Chance = 1,
		Multiplier = 0.25
	}
}

-------------------------------------------------
-- ATTRIBUTE BALANCE TABLE
-------------------------------------------------

local ATTRIBUTE_BALANCE = {

	Damage = {
		Bronze = 0.02,
		Silver = 0.05,
		Gold = 0.10,
		Diamond = 0.25
	},

	Range = {
		Bronze = 0.02,
		Silver = 0.05,
		Gold = 0.10,
		Diamond = 0.25
	},

	ProjectileSpeed = {
		Bronze = 0.02,
		Silver = 0.05,
		Gold = 0.10,
		Diamond = 0.25
	},

	AttackSize = {
		Bronze = 0.03,
		Silver = 0.07,
		Gold = 0.12,
		Diamond = 0.25
	},

	Cooldown = {
		Bronze = 0.02,
		Silver = 0.05,
		Gold = 0.08,
		Diamond = 0.15
	},

	MultiAttack = {
		Bronze = 1,
		Silver = 2,
		Gold = 3,
		Diamond = 5
	},

	ProjectilePierce = {
		Bronze = 1,
		Silver = 2,
		Gold = 3,
		Diamond = 5
	},

	LifeRegen = {
		Bronze = 0.25,
		Silver = 0.5,
		Gold = 1,
		Diamond = 2
	},

	AreaDamage = {
		Bronze = 0.05,
		Silver = 0.10,
		Gold = 0.15,
		Diamond = 0.30
	},

	Shield = {
		Bronze = 10,
		Silver = 20,
		Gold = 30,
		Diamond = 50,
	},

	Luck = {
		Bronze = 0.01,
		Silver = 0.03,
		Gold = 0.06,
		Diamond = 0.12
	},

	ShieldRegenDelay = {
		Bronze = 2,
		Silver = 5,
		Gold = 8,
		Diamond = 15
	},

	MaxHP = {
		Bronze = 0.05,
		Silver = 0.10,
		Gold = 0.20,
		Diamond = 0.40
	},

	MovementSpeed = {
		Bronze = 0.02,
		Silver = 0.05,
		Gold = 0.10,
		Diamond = 0.25
	},

}

-- =====================
-- CONSTRUTOR
-- =====================
function UpgradePool.new(_, allAttributes)
	local self = setmetatable({}, UpgradePool)

	self.AllAttributes = allAttributes or {}
	self.Banned = {}

	return self
end

-- =====================
-- BANISH
-- =====================
function UpgradePool:Ban(upgradeId)
	if upgradeId then
		self.Banned[upgradeId] = true
	end
end

function UpgradePool:IsBanned(upgradeId)
	return self.Banned[upgradeId] == true
end

function UpgradePool:RollRarity(luck)

	luck = luck or 0

	-- 🔥 BASE
	local weights = {
		Bronze = 65,
		Silver = 25,
		Gold = 9,
		Diamond = 1
	}

	-- =========================
	-- 🎲 LUCK SHIFT SYSTEM
	-- =========================

	-- quanto Luck afeta (ajustável)
	local factor = luck * 100

	-- 🔻 remove das tiers baixas
	local bronzeLoss = factor * 0.6
	local silverLoss = factor * 0.3

	weights.Bronze = math.max(5, weights.Bronze - bronzeLoss)
	weights.Silver = math.max(5, weights.Silver - silverLoss)

	-- 🔺 distribui nas altas
	local gained = bronzeLoss + silverLoss

	weights.Gold += gained * 0.7
	weights.Diamond += gained * 0.3

	-- =========================
	-- 🎯 ROLL FINAL
	-- =========================

	local total = 0
	for _, v in pairs(weights) do
		total += v
	end

	local roll = math.random() * total
	local acc = 0

	for _, r in ipairs(RARITIES) do
		acc += weights[r.Name]
		if roll <= acc then
			return r
		end
	end

	return RARITIES[1]
end

-- =====================
-- ATRIBUTOS DISPONÍVEIS
-- =====================
function UpgradePool:GetAvailableAttributes()
	local result = {}

	for _, attrId in ipairs(self.AllAttributes) do
		if not self:IsBanned(attrId) then
			table.insert(result, attrId)
		end
	end

	return result
end

-- =====================
-- ROLL DE ATRIBUTOS
-- =====================
function UpgradePool:RollAttributeOptions(count, luck)
	count = count or 3

	local options = {}
	local pool = self:GetAvailableAttributes()

	for i = 1, math.min(count, #pool) do
		local idx = math.random(#pool)
		local attrId = table.remove(pool, idx)

		local rarity = self:RollRarity(luck)

		table.insert(options, {
			Type = "Attribute",
			Id = attrId,
			Rarity = rarity.Name,
			-- Value só é usado quando fizer sentido (Damage, Range, AreaDamage, etc)
			Value = ATTRIBUTE_BALANCE[attrId] and ATTRIBUTE_BALANCE[attrId][rarity.Name] or rarity.Multiplier
		})
	end

	return options
end

UpgradePool.ATTRIBUTE_BALANCE = ATTRIBUTE_BALANCE

return UpgradePool
