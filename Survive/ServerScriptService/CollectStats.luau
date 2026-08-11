local function collectStats(player)

	local ms = player:FindFirstChild("MatchStats")
	if not ms then return {} end

	return {
		Gold = ms.Gold.Value,
		EnemiesKilled = ms.EnemiesKilled.Value,
		BossesKilled = ms.BossesKilled.Value,
		ArtifactsActivated = ms.ArtifactsActivated.Value,
		WeaponsEquipped = ms.WeaponsEquipped.Value,
		SynergiesUnlocked = ms.SynergiesUnlocked.Value,
		Level = ms.Level.Value,
		Duration = ms.RunDuration.Value
	}
end