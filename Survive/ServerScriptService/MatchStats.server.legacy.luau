-- MatchStats.server
-- Cria stats e atributos da RUN (resetam a cada entrada)

local Players = game:GetService("Players")
local XPService = require(game.ServerScriptService:WaitForChild("XPService"))

-- =========================
-- HELPERS
-- =========================
local function createInt(parent, name, value)
	local v = Instance.new("IntValue")
	v.Name = name
	v.Value = value
	v.Parent = parent
	return v
end

local function createNumber(parent, name, value)
	local v = Instance.new("NumberValue")
	v.Name = name
	v.Value = value
	v.Parent = parent
	return v
end

Players.PlayerAdded:Connect(function(player)

	local matchStats = Instance.new("Folder")
	matchStats.Name = "MatchStats"
	matchStats.Parent = player

	-------------------------------------------------
	-- 📊 RUN PROGRESSION
	-------------------------------------------------

	createInt(matchStats, "Level", 1)
	createInt(matchStats, "XP", 0)
	createInt(matchStats, "XPToNext", XPService:GetXPRequired(1))

	-------------------------------------------------
	-- 💰 ECONOMIA
	-------------------------------------------------

	createInt(matchStats, "Gold", 0)
	createInt(matchStats, "Banish", 1)
	createInt(matchStats, "Reroll", 1)

	-------------------------------------------------
	-- ⚔️ BASE ATTRIBUTES
	-------------------------------------------------

	local attributes = Instance.new("Folder")
	attributes.Name = "Attributes"
	attributes.Parent = matchStats

	createNumber(attributes, "Damage", 1)
	createNumber(attributes, "Cooldown", 1)
	createNumber(attributes, "Range", 1)
	createNumber(attributes, "ProjectileSpeed", 1)
	createNumber(attributes, "AttackSize", 1)
	createNumber(attributes, "MovementSpeed", 1)

	createNumber(attributes, "AreaDamage", 0)
	createNumber(attributes, "Luck", 0)

	createNumber(attributes, "MultiAttack", 1)
	createNumber(attributes, "ProjectilePierce", 0)

	createNumber(attributes, "Shield", 20)
	createNumber(attributes, "CurrentShield", 20)
	createNumber(attributes, "LifeRegen", 0)

	createNumber(attributes, "ShieldRegenDelay", 60)
	createNumber(attributes, "MaxHP", 1)
	
	-------------------------------------------------
	-- 📊 RUN STATISTICS
	-------------------------------------------------

	createInt(matchStats, "EnemiesKilled", 0)
	createInt(matchStats, "BossesKilled", 0)
	createInt(matchStats, "ArtifactsActivated", 0)
	createInt(matchStats, "WeaponsEquipped", 0)
	createInt(matchStats, "SynergiesUnlocked", 0)
	createNumber(matchStats, "RunDuration", 0)
	
	-------------------------------------------------
	-- 📊 STAT LIST (ÚNICA DEFINIÇÃO)
	-------------------------------------------------

	local STAT_LIST = {
		"Damage","Cooldown","Range","ProjectileSpeed","AttackSize","MovementSpeed",
		"MultiAttack","ProjectilePierce","AreaDamage",
		"Shield","ShieldRegenDelay",
		"MaxHP","LifeRegen","Luck"
	}

	-------------------------------------------------
	-- 📊 ATTRIBUTE LEVELS
	-------------------------------------------------

	local attributeLevels = Instance.new("Folder")
	attributeLevels.Name = "AttributeLevels"
	attributeLevels.Parent = matchStats

	for _, stat in ipairs(STAT_LIST) do
		createInt(attributeLevels, stat, 0)
	end

	-------------------------------------------------
	-- 🔮 SYNERGY BONUSES
	-------------------------------------------------

	local synergyBonuses = Instance.new("Folder")
	synergyBonuses.Name = "SynergyBonuses"
	synergyBonuses.Parent = matchStats

	local MULTIPLIER_ATTRS = {
		Damage = true,
		Range = true,
		ProjectileSpeed = true,
		AttackSize = true,
		MovementSpeed = true,
		MaxHP = true,
	}

	local INVERSE_ATTRS = {
		Cooldown = true,
		ShieldRegenDelay = true,
	}

	for _, stat in ipairs(STAT_LIST) do

		if MULTIPLIER_ATTRS[stat] or INVERSE_ATTRS[stat] then
			createNumber(synergyBonuses, stat, 1)
		else
			createNumber(synergyBonuses, stat, 0)
		end

	end
	
	-------------------------------------------------
	-- 🧩 MODIFIER BONUSES
	-------------------------------------------------

	local modifierBonuses = Instance.new("Folder")
	modifierBonuses.Name = "ModifierBonuses"
	modifierBonuses.Parent = matchStats

	local MULTIPLIER_ATTRS = {
		Damage = true,
		Range = true,
		ProjectileSpeed = true,
		AttackSize = true,
		MovementSpeed = true,
		MaxHP = true,
	}

	local INVERSE_ATTRS = {
		Cooldown = true,
		ShieldRegenDelay = true,
	}

	local STAT_LIST = {
		"Damage","Cooldown","Range","ProjectileSpeed","AttackSize","MovementSpeed",
		"MultiAttack","ProjectilePierce","AreaDamage",
		"Shield","ShieldRegenDelay",
		"MaxHP","LifeRegen","Luck"
	}

	for _, stat in ipairs(STAT_LIST) do

		if MULTIPLIER_ATTRS[stat] or INVERSE_ATTRS[stat] then
			createNumber(modifierBonuses, stat, 1)
		else
			createNumber(modifierBonuses, stat, 0)
		end

	end

	-------------------------------------------------
	-- 🌟 ACTIVE SYNERGIES
	-------------------------------------------------

	local activeSynergies = Instance.new("Folder")
	activeSynergies.Name = "ActiveSynergies"
	activeSynergies.Parent = matchStats

	print("📊 MatchStats criado para", player.Name)
	
	-------------------------------------------------
	-- 🧬 APPLY CHARACTER BASE (FUTURO)
	-------------------------------------------------

	local function applyCharacterBase(player)

		local attrs = player.MatchStats:FindFirstChild("Attributes")
		if not attrs then return end

		-- TEMPORÁRIO (DEFAULT CHARACTER)
		-- depois isso vem de um CharacterRegistry

		attrs.Damage.Value = 1
		attrs.Cooldown.Value = 1
		attrs.Range.Value = 1
		attrs.ProjectileSpeed.Value = 1
		attrs.AttackSize.Value = 1
		attrs.MovementSpeed.Value = 1

		attrs.MaxHP.Value = 1
		attrs.Shield.Value = 20
		attrs.CurrentShield.Value = 20
		
	end
	
end)

