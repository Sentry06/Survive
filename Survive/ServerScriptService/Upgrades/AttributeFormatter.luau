local AttributeFormatter = {}

local MULTIPLIER_BASE_1 = {
	Damage = true,
	Range = true,
	ProjectileSpeed = true,
	AttackSize = true,
	MovementSpeed = true,
	MaxHP = true,
}

local ADDITIVE_PERCENT = {
	AreaDamage = true,
	Luck = true,
}

local INVERSE_PERCENT = {
	Cooldown = true,

}

local INTEGER_ATTRS = {
	MultiAttack = true,
	ProjectilePierce = true,
	Shield = true,
	LifeRegen = true,
}

-------------------------------------------------
-- NAME
-------------------------------------------------

function AttributeFormatter.FormatName(name)
	return name:gsub("(%l)(%u)", "%1 %2")
end

-------------------------------------------------
-- FORMAT
-------------------------------------------------

function AttributeFormatter.Format(attr, value)

	-- MULTIPLICADOR (base 1)
	if MULTIPLIER_BASE_1[attr] then

		local percent = (value - 1) * 100
		return string.format("+%d%%", math.floor(percent + 0.5))

		-- ADITIVO %
	elseif ADDITIVE_PERCENT[attr] then

		return string.format("+%d%%", math.floor(value * 100 + 0.5))

		-- INVERTIDO (MENOR MELHOR)
	elseif INVERSE_PERCENT[attr] then

		local percent = math.abs(value * 100)
		return string.format("-%d%%", percent)

		-- TEMPO
	elseif attr == "ShieldRegenDelay" then
		return string.format("%.0fs", value)

		-- INTEIRO
	elseif INTEGER_ATTRS[attr] then

		return tostring(math.floor(value))

	end

	return tostring(value)
end

return AttributeFormatter