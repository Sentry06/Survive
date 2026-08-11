-- XPService
local XPService = {}

-- =========================
-- 📈 CURVA DE LEVEL
-- =========================

function XPService:GetXPRequired(level)

	-- Curva suavizada
	local base = 40
	local growth = 8

	local xp = base + (level ^ 1.15) * growth

	return math.floor(xp)
end

-- =========================
-- 🎯 REWARD DINÂMICO
-- =========================

function XPService:GetXPReward(baseXP, difficultyMultiplier, level)

	-- Bonus menor por level (evita snowball absurdo)
	local levelBonus = 1 + (level * 0.02)

	return math.floor(baseXP * difficultyMultiplier * levelBonus)
end

return XPService