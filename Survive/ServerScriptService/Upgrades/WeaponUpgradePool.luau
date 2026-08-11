-- WeaponUpgradePool.lua
-- Pool EXCLUSIVO de upgrades de ARMAS (via BAÚ)
-- Usa raridade + respeita WeaponSlots

local WeaponUpgradePool = {}
WeaponUpgradePool.__index = WeaponUpgradePool

-- =====================
-- RARIDADES DE ARMA
-- =====================
local RARITIES = {
	{
		Name = "Bronze",
		Chance = 65,
		Values = {
			Cooldown = 0.98,
			ProjectileSpeed = 1.02
		}
	},
	{
		Name = "Silver",
		Chance = 25,
		Values = {
			Cooldown = 0.95,
			ProjectileSpeed = 1.05
		}
	},
	{
		Name = "Gold",
		Chance = 9,
		Values = {
			Cooldown = 0.90,
			ProjectileSpeed = 1.10
		}
	},
	{
		Name = "Diamond",
		Chance = 1,
		Values = {
			Cooldown = 0.85,
			ProjectileSpeed = 1.15
		}
	}
}

-- =====================
-- CONSTRUTOR
-- =====================
function WeaponUpgradePool.new()
	local self = setmetatable({}, WeaponUpgradePool)
	return self
end

-- =====================
-- ROLL DE RARIDADE (COM LUCK)
-- =====================
function WeaponUpgradePool:RollRarity(luck)
	luck = luck or 0

	local roll = math.random() * 100
	local acc = 0

	for _, r in ipairs(RARITIES) do
		local chance = r.Chance

		if r.Name ~= "Bronze" then
			chance += luck * 0.5
		end

		acc += chance
		if roll <= acc then
			return r
		end
	end

	return RARITIES[1]
end

-- =====================
-- UPGRADE DISPONÍVEL
-- =====================
function WeaponUpgradePool:RollWeaponUpgrade(weaponSlots, luck)
	if not weaponSlots then return nil end
	if #weaponSlots.Weapons == 0 then return nil end

	-- escolhe arma equipada
	local weapon = weaponSlots.Weapons[
	math.random(#weaponSlots.Weapons)
	]

	if not weapon or not weapon.WeaponUpgrades then
		return nil
	end

	-- raridade
	local rarity = self:RollRarity(luck)

	-- filtra atributos permitidos pela arma
	local values = {}
	for stat, mult in pairs(rarity.Values) do
		if weapon.WeaponUpgrades[stat] then
			values[stat] = mult
		end
	end

	if next(values) == nil then
		return nil
	end

	return {
		Type = "Weapon",
		WeaponName = weapon.Name,
		Rarity = rarity.Name,
		Values = values
	}
end

-- =====================
-- APLICAR UPGRADE
-- =====================
function WeaponUpgradePool:ApplyUpgrade(weaponSlots, data)
	if not data or data.Type ~= "Weapon" then return false end

	local weapon = weaponSlots:GetWeapon(data.WeaponName)
	if not weapon then return false end

	if weapon.ApplyWeaponUpgrade then
		weapon:ApplyWeaponUpgrade(data.Values)
		return true
	end

	return false
end

return WeaponUpgradePool
