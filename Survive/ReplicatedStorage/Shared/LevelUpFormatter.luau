local LevelUpFormatter = {}

-------------------------------------------------
-- CONFIG
-------------------------------------------------

local NEGATIVE_ATTRS = {
	Cooldown = true,
	ShieldRegenDelay = true,
}

local FLAT_ATTRS = {
	MultiAttack = true,
	ProjectilePierce = true,
	LifeRegen = true,
	Shield = true,
}

-------------------------------------------------
-- FORMAT (DELTA REAL)
-------------------------------------------------

function LevelUpFormatter.Format(attr, value)

	-------------------------------------------------
	-- FLAT
	-------------------------------------------------
	-- PRIMEIRO TRATAR CASOS ESPECIAIS

	if attr == "ShieldRegenDelay" then
		return "-" .. math.floor(value + 0.5) .. "s"
	end

	if attr == "LifeRegen" then
		return "+" .. string.format("%.2f", value) .. "/s"
	end

	-- DEPOIS FLAT

	if FLAT_ATTRS[attr] then
		local v = math.floor(value + 0.5)
		return "+" .. v
	end

	-------------------------------------------------
	-- PERCENTUAL
	-------------------------------------------------
	local percent = value * 100
	local rounded = math.floor(percent + 0.5)

	-------------------------------------------------
	-- NEGATIVOS (Cooldown etc)
	-------------------------------------------------
	if NEGATIVE_ATTRS[attr] then
		return "-" .. math.abs(rounded) .. "%"
	end

	-------------------------------------------------
	-- PADRÃO (sempre positivo)
	-------------------------------------------------
	return "+" .. rounded .. "%"
end

return LevelUpFormatter