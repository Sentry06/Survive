local Players = game:GetService("Players")
local SynergyRegistry = require(script.Parent:WaitForChild("SynergyRegistry"))
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local SynergiesUpdated = Remotes:WaitForChild("SynergiesUpdated")

local SynergyDiscoveryService = require(
	game.ServerScriptService.Synergies:WaitForChild("SynergyDiscoveryService")
)

local SynergyService = {}

-------------------------------------------------
-- RETORNA NÍVEL ATUAL DA SINERGIA
-------------------------------------------------
local function getLevel(player, synergyId)

	local matchStats = player:FindFirstChild("MatchStats")
	if not matchStats then return 0 end

	local activeFolder = matchStats:FindFirstChild("ActiveSynergies")
	if not activeFolder then return 0 end

	local valueObj = activeFolder:FindFirstChild(synergyId)
	return valueObj and valueObj.Value or 0
end

-------------------------------------------------
-- DEFINE NÍVEL DA SINERGIA
-------------------------------------------------
local function setLevel(player, synergyId, level)

	local matchStats = player:FindFirstChild("MatchStats")
	if not matchStats then return end

	local activeFolder = matchStats:FindFirstChild("ActiveSynergies")
	if not activeFolder then return end

	local valueObj = activeFolder:FindFirstChild(synergyId)

	if not valueObj then
		valueObj = Instance.new("IntValue")
		valueObj.Name = synergyId
		valueObj.Parent = activeFolder
	end

	valueObj.Value = level
end

-------------------------------------------------
-- VERIFICA REQUISITOS (USA ATTRIBUTE LEVELS)
-------------------------------------------------
local function requirementsMet(player, def)

	local matchStats = player:FindFirstChild("MatchStats")
	if not matchStats then return false end

	local levels = matchStats:FindFirstChild("AttributeLevels")
	if not levels then return false end

	for attrName, requiredValue in pairs(def.Requires) do
		local stat = levels:FindFirstChild(attrName)
		if not stat or stat.Value < requiredValue then
			return false
		end
	end

	return true
end

-------------------------------------------------
-- RETORNA MELHOR SINERGIA DISPONÍVEL
-------------------------------------------------
function SynergyService:GetAvailableSynergy(player)

	local newSynergy = nil
	local upgradableSynergy = nil

	for id, def in pairs(SynergyRegistry.Definitions) do

		if requirementsMet(player, def) then

			local level = getLevel(player, id)

			-- Nova sinergia
			if level == 0 then
				newSynergy = id

				-- Já ativa, mas pode evoluir
			elseif level < def.MaxLevel then
				upgradableSynergy = id
			end
		end
	end

	-- Prioridade: nova > upgrade
	return newSynergy or upgradableSynergy
end

-------------------------------------------------
-- ENVIA DADOS PARA HUD
-------------------------------------------------
local function sendSynergies(player)

	local active = {}

	local matchStats = player:FindFirstChild("MatchStats")
	if not matchStats then return end

	local data = matchStats:FindFirstChild("ActiveSynergies")
	if not data then return end

	for _, value in ipairs(data:GetChildren()) do
		table.insert(active, {
			Id = value.Name,
			Level = value.Value
		})
	end

	SynergiesUpdated:FireClient(player, active)
end

-------------------------------------------------
-- APLICA OU EVOLUI
-------------------------------------------------
local SynergyUnlocked = Remotes:WaitForChild("SynergyUnlocked")

function SynergyService:ApplyOrUpgrade(player, synergyId)

	local def = SynergyRegistry.Definitions[synergyId]
	if not def then return end

	local currentLevel = getLevel(player, synergyId)
	if currentLevel >= def.MaxLevel then return end

	local newLevel = currentLevel + 1
	setLevel(player, synergyId, newLevel)

	local bonusesFolder = player.MatchStats:FindFirstChild("SynergyBonuses")

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

	local ADDITIVE_ATTRS = {
		MultiAttack = true,
		ProjectilePierce = true,
		AreaDamage = true,
		LifeRegen = true,
		Shield = true,
		Luck = true,
	}

	print("[SYNERGY DEBUG]", synergyId, def.Bonuses)

	for attr, value in pairs(def.Bonuses or {}) do

		local stat = bonusesFolder:FindFirstChild(attr)

		if not stat then
			stat = Instance.new("NumberValue")
			stat.Name = attr
			stat.Parent = bonusesFolder

			-- 🔥 BASE CORRETA
			if MULTIPLIER_ATTRS[attr] or INVERSE_ATTRS[attr] then
				stat.Value = 1
			else
				stat.Value = 0
			end

			print("[SYNERGY FIX] Criado atributo:", attr)
		end

		local before = stat.Value

		if MULTIPLIER_ATTRS[attr] then

			stat.Value *= (1 + value)

		elseif INVERSE_ATTRS[attr] then

			stat.Value *= (1 + value)
			stat.Value = math.max(stat.Value, 0.01) -- segurança

		elseif ADDITIVE_ATTRS[attr] then

			stat.Value += value

		else
			stat.Value += value
		end

		local after = stat.Value

		print(string.format(
			"[SYNERGY APPLY] %s | %s: %.4f → %.4f (Δ %.4f) TYPE=%s",
			synergyId,
			attr,
			before,
			after,
			value,
			MULTIPLIER_ATTRS[attr] and "MULT" or
				INVERSE_ATTRS[attr] and "INV" or
				"ADD"
			))
	end
	
	sendSynergies(player)

	-- 🌟 PRIMEIRA VEZ DESBLOQUEADA
	if currentLevel == 0 then

		SynergyDiscoveryService:Register(player, synergyId)

		SynergyUnlocked:FireClient(player, {
			Id = def.Id,
			DisplayName = def.DisplayName,
			Description = def.Description,
			Image = def.Image,
			Tier = def.Tier
		})
	end

	print("🌟 Sinergia:", synergyId, "→ Nível", newLevel)
	local ms = player:FindFirstChild("MatchStats")
	if ms and ms:FindFirstChild("SynergiesUnlocked") then
		ms.SynergiesUnlocked.Value += 1
	end
end

function SynergyService:ResetPlayer(player)

	local matchStats = player:FindFirstChild("MatchStats")
	if not matchStats then return end

	local activeFolder = matchStats:FindFirstChild("ActiveSynergies")
	local bonusesFolder = matchStats:FindFirstChild("SynergyBonuses")

	-- TIPOS (MESMOS DO WEAPONBASE)
	local MULTIPLIER_ATTRS = {
		Damage=true, Range=true, ProjectileSpeed=true,
		AttackSize=true, MovementSpeed=true, MaxHP=true
	}

	local INVERSE_ATTRS = {
		Cooldown=true, ShieldRegenDelay=true
	}

	-------------------------------------------------
	-- REMOVE ATIVAS
	-------------------------------------------------

	if activeFolder then
		for _, value in ipairs(activeFolder:GetChildren()) do
			value:Destroy()
		end
	end

	-------------------------------------------------
	-- RESET CORRETO
	-------------------------------------------------

	if bonusesFolder then
		for _, bonus in ipairs(bonusesFolder:GetChildren()) do

			local attr = bonus.Name

			if MULTIPLIER_ATTRS[attr] or INVERSE_ATTRS[attr] then
				bonus.Value = 1
			else
				bonus.Value = 0
			end

			print("[SYNERGY RESET]", attr, "=", bonus.Value)
		end
	end

	SynergiesUpdated:FireClient(player, {})

	print("🔄 Synergies resetadas para", player.Name)
end

return SynergyService
