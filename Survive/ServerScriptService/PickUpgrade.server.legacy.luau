-- PickUpgrade.server
-- APLICA ATRIBUTOS + SOBE ATTRIBUTE LEVEL

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local PickUpgrade = Remotes:WaitForChild("PickUpgrade")

-- 📈 atributos multiplicativos
local MULTIPLIER_ATTRS = {
	Damage = true,
	Range = true,
	MaxHP = true,
}

-- ⏱️ atributos onde MENOR é melhor
local INVERT_MULTIPLIER = {
	Cooldown = true,
}

-------------------------------------------------
-- SOBE NÍVEL DO ATRIBUTO
-------------------------------------------------
local function increaseAttributeLevel(player, attributeName)

	local matchStats = player:FindFirstChild("MatchStats")
	if not matchStats then return end

	local levels = matchStats:FindFirstChild("AttributeLevels")
	if not levels then return end

	local levelStat = levels:FindFirstChild(attributeName)
	if levelStat then
		levelStat.Value += 1
	end
end

-------------------------------------------------
-- EVENTO
-------------------------------------------------
PickUpgrade.OnServerEvent:Connect(function(player, data)

	if data.Action ~= "PICK" then return end
	if data.Type ~= "Attribute" then return end

	local attrs = player:FindFirstChild("MatchStats")
		and player.MatchStats:FindFirstChild("Attributes")
	if not attrs then return end

	local stat = attrs:FindFirstChild(data.Id)
	if not stat then
		warn("⚠️ Upgrade inválido recebido:", data.Id)
		return
	end

	local value = data.Value or 0

	-------------------------------------------------
	-- APLICA UPGRADE (UNIFICADO)
	-------------------------------------------------

	-- 🔥 FLAT ATTRIBUTES
	if data.Id == "Shield" then

		stat.Value += value

		local current = attrs:FindFirstChild("CurrentShield")
		if current then
			current.Value = math.min(current.Value + value, stat.Value)
		end

	elseif data.Id == "LifeRegen" then
		stat.Value += value

	elseif data.Id == "MultiAttack" then

		local gainByRarity = {
			Bronze = 1,
			Silver = 2,
			Gold = 3,
			Diamond = 5,
		}

		local gain = gainByRarity[data.Rarity] or 1
		stat.Value += gain

	elseif data.Id == "ProjectilePierce" then
		stat.Value += value
		
	elseif data.Id == "ShieldRegenDelay" then

		stat.Value -= value
		stat.Value = math.max(stat.Value, 1)

		-- 🔥 AREA DAMAGE (continua com atributo global)
	elseif data.Id == "AreaDamage" then

		stat.Value += value
		player:SetAttribute("AreaDamage", stat.Value)

		-- 🔥 MULTIPLICADOR INVERTIDO
	elseif INVERT_MULTIPLIER[data.Id] then

		stat.Value *= (1 - value)
		stat.Value = math.max(stat.Value, 0.1)

		-- 🔥 MULTIPLICADOR NORMAL
	elseif MULTIPLIER_ATTRS[data.Id] then

		stat.Value *= (1 + value)

		-- 🔥 PADRÃO (fallback seguro)
	else
		stat.Value += value
	end

	-------------------------------------------------
	-- SOBE LEVEL (SEMPRE)
	-------------------------------------------------

	increaseAttributeLevel(player, data.Id)

	-------------------------------------------------
	-- LOG
	-------------------------------------------------

	local valueStr =
		(data.Id == "MultiAttack" or data.Id == "Shield" or data.Id == "ProjectilePierce")
		and tostring(stat.Value)
		or string.format("%.2f", stat.Value)

	print(string.format(
		"⬆️ %s (%s) aplicado → %s | Level: %d",
		data.Id,
		data.Rarity or "?",
		valueStr,
		player.MatchStats.AttributeLevels[data.Id].Value
		))
end)

print("📩 PickUpgrade FINAL (COM LEVEL SYSTEM)")