-- DamageService.lua
-- Serviço centralizado de dano no PLAYER (shield + vida)

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local DamageService = {}

-- =========================
-- SHIELD REGEN LOOP
-- =========================
RunService.Heartbeat:Connect(function()
	for _, player in ipairs(Players:GetPlayers()) do
		local char = player.Character
		local humanoid = char and char:FindFirstChildOfClass("Humanoid")
		if not humanoid then continue end

		local ms = player:FindFirstChild("MatchStats")
		if not ms then continue end

		local attrs = ms:FindFirstChild("Attributes")
		if not attrs then continue end

		local shield = attrs:FindFirstChild("Shield")
		local current = attrs:FindFirstChild("CurrentShield")
		local delay = attrs:FindFirstChild("ShieldRegenDelay")

		if not shield or not current or not delay then continue end
		if shield.Value <= 0 then continue end
		if current.Value >= shield.Value then continue end

		local lastHit = humanoid:GetAttribute("LastShieldHit")
		if not lastHit then continue end

		-- regen instantâneo após delay (design intencional)
		if os.clock() - lastHit >= delay.Value then
			current.Value = shield.Value
		end
	end
end)

-- =========================
-- DANO NO PLAYER
-- =========================
function DamageService:TryDamagePlayer(enemyRoot, damage, range)
	if not enemyRoot or damage <= 0 then
		return
	end

	for _, player in ipairs(Players:GetPlayers()) do
		local char = player.Character
		local humanoid = char and char:FindFirstChildOfClass("Humanoid")
		local root = char and char:FindFirstChild("HumanoidRootPart")

		if not humanoid or not root or humanoid.Health <= 0 then
			continue
		end

		local dist = (root.Position - enemyRoot.Position).Magnitude
		if dist > range then
			continue
		end

		local ms = player:FindFirstChild("MatchStats")
		local attrs = ms and ms:FindFirstChild("Attributes")

		local remainingDamage = damage

		-- 🛡️ SHIELD
		if attrs then
			local shield = attrs:FindFirstChild("CurrentShield")
			local maxShield = attrs:FindFirstChild("Shield")

			if shield and maxShield and shield.Value > 0 then
				humanoid:SetAttribute("LastShieldHit", os.clock())

				if shield.Value >= remainingDamage then
					shield.Value -= remainingDamage
					remainingDamage = 0
				else
					remainingDamage -= shield.Value
					shield.Value = 0
				end
			end
		end

		-- ❤️ VIDA
		if remainingDamage > 0 then
			humanoid:TakeDamage(remainingDamage)
		end
		
		local stacks = player:GetAttribute("BaileStacks") or 0

		if stacks > 0 then

			player:SetAttribute("BaileStacks", 0)
			player:SetAttribute("BaileExpire", 0)

			local attrs = player.MatchStats.Attributes
			player:SetAttribute("AreaDamageBonus", 0)

			print("💥 Baile RESET (player tomou dano)")

			game.ReplicatedStorage.Remotes.BaileCombo:FireClient(player, 0)

		end
		
		-- 🔥 SAHUR RESET (SÓ FORA DO RAGE)
		local isSahurActive = player:GetAttribute("SahurActive")

		if not isSahurActive then

			player:SetAttribute("SahurPower", 0)

			local stats = player.MatchStats.ModifierBonuses

			if player:GetAttribute("SahurBuffApplied") then

				stats.Damage.Value = player:GetAttribute("Sahur_Damage") or 1
				stats.AttackSize.Value = player:GetAttribute("Sahur_AttackSize") or 1
				stats.Cooldown.Value = player:GetAttribute("Sahur_Cooldown") or 1

				player:SetAttribute("SahurBuffApplied", false)
			end

			game.ReplicatedStorage.Remotes.SahurUI:FireClient(player, 0, false)

		end
		
		-------------------------------------------------
		-- ⚽ STRIKER RESET
		-------------------------------------------------

		player:SetAttribute("StrikerCombo", 0)

		local stats = player.MatchStats.ModifierBonuses

		-- reset apenas do BONUS
		stats.Damage.Value = 1

		print("⚽ STRIKER RESET (tomou dano)")
		
	end
end

return DamageService
