-- DifficultyService (VERSÃO REESCRITA - CURVA EXPONENCIAL)

local DifficultyService = {}

-------------------------------------------------
-- CONFIG
-------------------------------------------------

local TOTAL_RUN_TIME = 1200 -- 20 minutos
local currentTime = 0

-------------------------------------------------
-- SET TIME (chamado pelo MatchTime)
-------------------------------------------------

function DifficultyService:SetTime(seconds)
	currentTime = seconds
end

function DifficultyService:GetTime()
	return currentTime
end

-------------------------------------------------
-- PROGRESSO NORMALIZADO
-------------------------------------------------

local function getProgress()
	return math.clamp(currentTime / TOTAL_RUN_TIME, 0, 1)
end

-------------------------------------------------
-- CURVA EXPONENCIAL
-------------------------------------------------

local function getCurve()
	local progress = getProgress()
	return progress ^ 1.8
end

-------------------------------------------------
-- STATS PRINCIPAIS
-------------------------------------------------

function DifficultyService:GetStats()

	local curve = getCurve()

	return {

		-- Vida escala agressivamente
		HealthMultiplier = 1 + (curve * 8),

		-- Velocidade escala moderado
		SpeedMultiplier = 1 + (curve * 1.5),

		-- Spawn cresce forte
		SpawnMultiplier = 1 + (curve * 4),

		-- Dano cresce progressivamente
		DamageMultiplier = 1 + (curve * 3),

		-- XP cresce junto para manter ritmo saudável
		XPMultiplier = 1 + (curve * 5),

		-- Boss recebe escala adicional
		BossMultiplier = 1 + (curve * 10)
	}
end

return DifficultyService
