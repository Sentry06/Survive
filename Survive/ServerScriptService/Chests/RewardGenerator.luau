local WeaponRegistry = require(
	game.ServerScriptService.Weapons:WaitForChild("WeaponRegistry")
)

local SynergyService = require(
	game.ServerScriptService.Synergies:WaitForChild("SynergyService")
)

local UpgradePool = require(game.ServerScriptService.Upgrades.UpgradePool)
local ATTRIBUTE_BALANCE = UpgradePool.ATTRIBUTE_BALANCE

local RewardGenerator = {}

-------------------------------------------------
-- POSSIBLE ATTRIBUTES
-------------------------------------------------

local POSSIBLE_ATTRIBUTES = {
	"Damage","Cooldown","Range","MultiAttack","MovementSpeed",
	"AttackSize","ProjectileSpeed","Luck","Shield",
	"ShieldRegenDelay","MaxHP","LifeRegen",
	"ProjectilePierce","AreaDamage",
}

local MULTIPLIER_ATTRS = {
	Damage = true,
	Range = true,
	MaxHP = true,
	MovementSpeed = true,
	AttackSize = true,
	ProjectileSpeed = true,
	Cooldown = true,
}

local ADDITIVE_ATTRS = {
	MultiAttack = true,
	ProjectilePierce = true,
	Shield = true,
	LifeRegen = true,
	Luck = true,
	AreaDamage = true,
}

-------------------------------------------------
-- 🎲 ROLL ATTRIBUTE COM LUCK
-------------------------------------------------

local function rollAttributeWithLuck(luck, used)

	local pool = {}

	for _, attr in ipairs(POSSIBLE_ATTRIBUTES) do

		if not used[attr] then

			local weight = 1

			-- 🔥 atributos fortes ficam mais comuns
			if attr == "Damage"
				or attr == "AttackSize"
				or attr == "ProjectileSpeed"
				or attr == "MultiAttack" then

				weight += luck * 5

			elseif attr == "Luck" then
				weight += luck * 3
			end

			-- 🔻 atributos mais fracos
			if attr == "Range" or attr == "MovementSpeed" then
				weight -= luck * 2
			end

			-- nunca deixa peso zerar
			weight = math.max(0.1, weight)

			table.insert(pool, {
				Name = attr,
				Weight = weight
			})
		end
	end

	-- fallback
	if #pool == 0 then
		return POSSIBLE_ATTRIBUTES[1]
	end

	-- 🎲 roll ponderado
	local total = 0
	for _, item in ipairs(pool) do
		total += item.Weight
	end

	local roll = math.random() * total
	local acc = 0

	for _, item in ipairs(pool) do
		acc += item.Weight
		if roll <= acc then
			return item.Name
		end
	end

	return pool[1].Name
end

-------------------------------------------------
-- GENERATE REWARDS
-------------------------------------------------
function RewardGenerator:Generate(player, rarity, chestDef)

	local attrs = player:FindFirstChild("MatchStats")
		and player.MatchStats:FindFirstChild("Attributes")

	local luck = attrs and attrs:FindFirstChild("Luck") and attrs.Luck.Value or 0

	local rewards = {
		Gold = 0,
		Attributes = {},
		Weapon = nil,
		WeaponImage = nil,
		Synergy = nil
	}

	-------------------------------------------------
	-- 🪙 GOLD
	-------------------------------------------------
	rewards.Gold = math.random(chestDef.GoldMin, chestDef.GoldMax)

	-------------------------------------------------
	-- 🔮 CHECK SYNERGY
	-------------------------------------------------

	local SynergyRegistry = require(
		game.ServerScriptService.Synergies:WaitForChild("SynergyRegistry")
	)

	local bestSynergy = nil
	local bestTier = 0

	local available = SynergyService:GetAvailableSynergy(player)

	for id, def in pairs(SynergyRegistry.Definitions) do
		if available == id then
			if def.Tier > bestTier then
				bestTier = def.Tier
				bestSynergy = def
			end
		end
	end

	if bestSynergy then
		rewards.Synergy = bestSynergy.Id
		rewards.SynergyImage = bestSynergy.Image
		rewards.SynergyName = bestSynergy.DisplayName
		rewards.SynergyDescription = bestSynergy.Description
		rewards.SynergyTier = bestSynergy.Tier
	end

	-------------------------------------------------
	-- 📈 ATTRIBUTES COM LUCK
	-------------------------------------------------

	local used = {}

	for i = 1, chestDef.AttributeCount do

		local attributeName = rollAttributeWithLuck(luck, used)

		used[attributeName] = true

		local attrData = {
			Name = attributeName
		}

		local attrBalance = ATTRIBUTE_BALANCE[attributeName]

		if attrBalance and attrBalance[rarity] then
			attrData.Value = attrBalance[rarity]

		elseif MULTIPLIER_ATTRS[attributeName] then
			attrData.Value = chestDef.UpgradeMultiplier - 1

		else
			attrData.Value = 1
		end

		table.insert(rewards.Attributes, attrData)
	end

	-------------------------------------------------
	-- ⚔ WEAPON
	-------------------------------------------------

	local global = player:FindFirstChild("GlobalStats")

	if global then

		local selected = global:FindFirstChild("SelectedWeapon")
		local levels = global:FindFirstChild("WeaponLevels")

		if selected and levels then

			local weaponId = selected.Value
			local data = WeaponRegistry.Definitions[weaponId]

			if data then
				rewards.Weapon = weaponId
				rewards.WeaponImage = data.Image
			end
		end
	end

	return rewards
end

return RewardGenerator