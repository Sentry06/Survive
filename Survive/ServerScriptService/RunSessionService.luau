local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameState = ReplicatedStorage:WaitForChild("GameState")

local RunSessionService = {}

-------------------------------------------------
-- RESET MATCH STATS
-------------------------------------------------

local function resetMatchStats(player)

	local ms = player:FindFirstChild("MatchStats")
	if not ms then return end

	-- PROGRESSÃO
	ms.Level.Value = 1
	ms.XP.Value = 0
	ms.XPToNext.Value = 10
	ms.Gold.Value = 0

	-- RUN STATS
	ms.EnemiesKilled.Value = 0
	ms.BossesKilled.Value = 0
	ms.ArtifactsActivated.Value = 0
	ms.WeaponsEquipped.Value = 0
	ms.SynergiesUnlocked.Value = 0
	ms.RunDuration.Value = 0

	local attrs = ms:FindFirstChild("Attributes")
	if attrs then

		attrs.Damage.Value = 1
		attrs.Cooldown.Value = 1
		attrs.Range.Value = 1
		attrs.ProjectileSpeed.Value = 1
		attrs.AttackSize.Value = 1
		attrs.MovementSpeed.Value = 1

		attrs.MultiAttack.Value = 1
		attrs.ProjectilePierce.Value = 0
		attrs.AreaDamage.Value = 0

		attrs.Shield.Value = 20
		attrs.CurrentShield.Value = 20
		attrs.ShieldRegenDelay.Value = 60

		attrs.MaxHP.Value = 1
		attrs.LifeRegen.Value = 0
		attrs.Luck.Value = 0
	end
	
	local levels = ms:FindFirstChild("AttributeLevels")
	if levels then
		for _,v in ipairs(levels:GetChildren()) do
			if v:IsA("IntValue") then
				v.Value = 0
			end
		end
	end

	local active = ms:FindFirstChild("ActiveSynergies")
	if active then
		active:ClearAllChildren()
	end
	
	local equipped = ms:FindFirstChild("EquippedWeapons")
	if equipped then
		equipped:ClearAllChildren()
	end
	
	local equipped = ms:FindFirstChild("EquippedArtifacts")
	if equipped then
		equipped:ClearAllChildren()
	end

end

-------------------------------------------------
-- LIMPAR INIMIGOS
-------------------------------------------------

local function clearEnemies()

	for _,enemy in ipairs(_G.Enemies or {}) do

		if enemy.Model and enemy.Model.Parent then
			enemy.Model:Destroy()
		end

	end

	table.clear(_G.Enemies)

end

-------------------------------------------------
-- RESET RUN
-------------------------------------------------

function RunSessionService:ResetRun()

	print("♻ Resetando RunSession")

	GameState.RunActive.Value = false
	GameState.GamePaused.Value = false

	GameState.ElapsedTime.Value = 0
	GameState.FinalBattleActive.Value = false

	clearEnemies()

	-- 🔥 LIMPAR ARMAS DA RUN
	if _G.PlayerWeaponSlots then
		for player,_ in pairs(_G.PlayerWeaponSlots) do
			_G.PlayerWeaponSlots[player] = nil
		end
	end

	for _,player in ipairs(Players:GetPlayers()) do

		resetMatchStats(player)

		-- limpa HUD
		ReplicatedStorage.Remotes.WeaponsUpdated:FireClient(player, {})

		-- respawn
		player:LoadCharacter()

	end

end

return RunSessionService