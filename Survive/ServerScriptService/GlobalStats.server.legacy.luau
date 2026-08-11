-- GlobalStats.server
-- Stats permanentes do jogador (META / fora da run)

local Players = game:GetService("Players")

local function createNumber(parent, name, value)
	local v = Instance.new("NumberValue")
	v.Name = name
	v.Value = value
	v.Parent = parent
	return v
end

local function createInt(parent, name, value)
	local v = Instance.new("IntValue")
	v.Name = name
	v.Value = value
	v.Parent = parent
	return v
end

Players.PlayerAdded:Connect(function(player)
	local global = Instance.new("Folder")
	global.Name = "GlobalStats"
	global.Parent = player

	-- ======================
	-- 🪙 ECONOMIA
	-- ======================
	createInt(global, "Gold", 0)

	-- COMBATE
	createNumber(global, "Damage", 1)
	createNumber(global, "Cooldown", 1)
	createNumber(global, "Range", 1)
	createNumber(global, "ProjectileSpeed", 1)
	createNumber(global, "AttackSize", 1)

	-- MOBILIDADE
	createNumber(global, "MovementSpeed", 1)
	createNumber(global, "MaxHP", 1)

	-- ⚠️ BASE ZERO (IMPORTANTE)
	createNumber(global, "LifeRegen", 0)
	createNumber(global, "Shield", 0)
	createInt(global, "MultiAttack", 1)

	-- AVANÇADOS
	createNumber(global, "Luck", 0)
	createNumber(global, "GoldMultiplier", 1)
	
	createNumber(global, "AreaDamage", 0)
	createInt(global, "ProjectilePierce", 0)
	createNumber(global, "ShieldRegenDelay", 60)

	-- ======================
	-- ⚔ SLOTS DE ARMAS
	-- ======================
	createInt(global, "ExtraWeaponSlots", 0)

	-- ======================
	-- 📖 SINERGIAS DESCOBERTAS
	-- ======================
	local discoveredFolder = Instance.new("Folder")
	discoveredFolder.Name = "DiscoveredSynergies"
	discoveredFolder.Parent = global
	
	-- ======================
	-- ⚔ WEAPONS UNLOCKED
	-- ======================

	local weaponsFolder = Instance.new("Folder")
	weaponsFolder.Name = "UnlockedWeapons"
	weaponsFolder.Parent = global

	-- arma inicial
	local knife = Instance.new("BoolValue")
	knife.Name = "Knife"
	knife.Value = true
	knife.Parent = weaponsFolder

	local selectedWeapon = Instance.new("StringValue")
	selectedWeapon.Name = "SelectedWeapon"
	selectedWeapon.Value = "Knife"
	selectedWeapon.Parent = global
	
	local weaponLevels = Instance.new("Folder")
	weaponLevels.Name = "WeaponLevels"
	weaponLevels.Parent = global
	
	-- ======================
	-- 🧩 MODIFIERS
	-- ======================

	local modifiersFolder = Instance.new("Folder")
	modifiersFolder.Name = "UnlockedModifiers"
	modifiersFolder.Parent = global

	local selectedModifier = Instance.new("StringValue")
	selectedModifier.Name = "SelectedModifier"
	selectedModifier.Value = "Gambler"
	selectedModifier.Parent = global

	print("🌍 GlobalStats criados para", player.Name)
end)
