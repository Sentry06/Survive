-- GoldService.server
-- Autoridade única sobre ouro

local ArtifactService = require(
	game.ServerScriptService.Artifacts.ArtifactService
)

local GoldService = {}

-- =========================
-- CALCULA MULTIPLICADOR
-- =========================
function GoldService:GetMultiplier(player)
	local mult = 1

	-- 🧿 Aurum
	if player:GetAttribute("Artifact_Aurum") == true then
		mult *= 3
	end

	return mult
end

-- =========================
-- CONCEDER OURO NA RUN
-- =========================
function GoldService:GiveRunGold(player, baseAmount, source)
	local ms = player:FindFirstChild("MatchStats")
	if not ms then return end

	local gold = ms:FindFirstChild("Gold")
	if not gold then return end

	local final = math.floor(baseAmount * self:GetMultiplier(player))
	gold.Value += final

	print(("💰 Ouro +%d (%s) → %s")
		:format(final, source or "?", player.Name))
end

-- =========================
-- FINAL DA RUN
-- =========================
function GoldService:CommitRunGold(player)
	local ms = player:FindFirstChild("MatchStats")
	local gs = player:FindFirstChild("GlobalStats")
	if not ms or not gs then return end

	local runGold = ms:FindFirstChild("Gold")
	local totalGold = gs:FindFirstChild("Gold")

	if runGold and totalGold then
		totalGold.Value += runGold.Value
		print("🏦 Ouro salvo:", runGold.Value, "→", player.Name)
	end
	
end

return GoldService
