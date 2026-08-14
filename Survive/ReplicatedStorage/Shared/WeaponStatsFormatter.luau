local WeaponStatsFormatter = {}

-------------------------------------------------
-- CONFIG
-------------------------------------------------

local PERCENT_ATTRS = {
	AttackSize = true,
	AreaDamage = true,
}

local MULTIPLIER_ATTRS = {
	AttackSize = true,
}

local INTEGER_ATTRS = {
	ProjectilePierce = true,
}

-------------------------------------------------
-- HELPERS
-------------------------------------------------

local function round(n)
	return math.floor(n + 0.5)
end

local function formatSignedPercent(value)
	local rounded = round(value)

	if rounded > 0 then
		return "+" .. rounded .. "%"
	elseif rounded < 0 then
		return rounded .. "%"
	else
		return "0%"
	end
end

-------------------------------------------------
-- FORMAT VALUE
-------------------------------------------------

function WeaponStatsFormatter.Format(attr, value)

	-------------------------------------------------
	-- DAMAGE (valor direto)
	-------------------------------------------------
	if attr == "Damage" then
		return tostring(round(value))

		-------------------------------------------------
		-- COOLDOWN (tempo)
		-------------------------------------------------
	elseif attr == "Cooldown" then
		return string.format("%.2fs", value)

		-------------------------------------------------
		-- RANGE
		-------------------------------------------------
	elseif attr == "Range" then
		return tostring(round(value))

		-------------------------------------------------
		-- PROJECTILE SPEED
		-------------------------------------------------
	elseif attr == "ProjectileSpeed" then
		return tostring(round(value))

		-------------------------------------------------
		-- ATTACK SIZE (multiplicador visual)
		-------------------------------------------------
	elseif attr == "AttackSize" then

		local percent = (value - 1) * 100

		if math.abs(percent) < 0.01 then
			return "Normal"
		end

		return formatSignedPercent(percent)

		-------------------------------------------------
		-- PROJECTILE PIERCE (inteiro)
		-------------------------------------------------
	elseif attr == "ProjectilePierce" then
		return tostring(round(value))

		-------------------------------------------------
		-- AREA DAMAGE (% direto)
		-------------------------------------------------
	elseif attr == "AreaDamage" then

		if value == 0 then
			return "0%"
		end

		return formatSignedPercent(value * 100)

		-------------------------------------------------
		-- FALLBACK
		-------------------------------------------------
	end

	return tostring(value)
end

-------------------------------------------------
-- FORMAT NAME
-------------------------------------------------

function WeaponStatsFormatter.FormatName(name)
	return name:gsub("(%l)(%u)", "%1 %2")
end

-------------------------------------------------
-- OPTIONAL: COLORED TEXT (FUTURO UI RICH)
-------------------------------------------------

function WeaponStatsFormatter.GetColor(attr, value)

	-- positivo = verde
	if attr == "AttackSize" then
		if value > 1 then
			return Color3.fromRGB(100,255,100)
		elseif value < 1 then
			return Color3.fromRGB(255,120,120)
		end
	end

	if attr == "AreaDamage" then
		if value > 0 then
			return Color3.fromRGB(100,255,100)
		end
	end

	return Color3.fromRGB(255,255,255)
end

return WeaponStatsFormatter