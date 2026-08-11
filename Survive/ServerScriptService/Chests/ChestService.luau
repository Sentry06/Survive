local Players = game:GetService("Players")

local ChestRegistry = require(script.Parent:WaitForChild("ChestRegistry"))
local GoldService = require(game.ServerScriptService:WaitForChild("GoldService"))
local RewardGenerator = require(script.Parent:WaitForChild("RewardGenerator"))

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectEvent = ReplicatedStorage.Remotes:WaitForChild("ChestCollect")
local RewardEvent = ReplicatedStorage.Remotes:WaitForChild("ChestReward")
local GamePauseService = require(
	game.ServerScriptService:WaitForChild("GamePauseService")
)
local SynergyService = require(
	game.ServerScriptService.Synergies:WaitForChild("SynergyService")
)

local UpgradePool = require(game.ServerScriptService.Upgrades.UpgradePool)
local ATTRIBUTE_BALANCE = UpgradePool.ATTRIBUTE_BALANCE

-------------------------------------------------
-- 📊 TIPOS DE ATRIBUTOS
-------------------------------------------------

local MULTIPLIER_ATTRS = {
	Damage = true,
	Cooldown = true,
	Range = true,
	ProjectileSpeed = true,
	AttackSize = true,
	MovementSpeed = true,
	MaxHP = true,
	
}

local ADDITIVE_ATTRS = {
	MultiAttack = true,
	ProjectilePierce = true,
	Shield = true,
	LifeRegen = true,
	Luck = true,
	AreaDamage = true,
}

local ChestService = {}

-- 🔐 Cache seguro de reward por player
local pendingRewards = {}

-------------------------------------------------
-- ABRIR CHEST
-------------------------------------------------
function ChestService:OpenChest(player, chest)

	GamePauseService:AddPause("Chest")

	if not chest then return end

	local rarity = chest:GetAttribute("Rarity")
	if not rarity then return end

	local chestDef = ChestRegistry:Get(rarity)
	if not chestDef then return end

	local rewards = RewardGenerator:Generate(player, rarity, chestDef)

	-- Salva no servidor
	pendingRewards[player] = {
		Data = rewards,
		Rarity = rarity
	}

	RewardEvent:FireClient(player, rewards, rarity)

	chest:Destroy()
end

-------------------------------------------------
-- COLETAR RECOMPENSA
-------------------------------------------------
CollectEvent.OnServerEvent:Connect(function(player)

	local package = pendingRewards[player]
	if not package then return end

	local rewards = package.Data
	local rarity = package.Rarity
	if not rewards then return end

	pendingRewards[player] = nil

	local matchStats = player:FindFirstChild("MatchStats")
	if not matchStats then return end

	local attrs = matchStats:FindFirstChild("Attributes")
	if not attrs then return end

	-------------------------------------------------
	-- 🪙 GOLD
	-------------------------------------------------
	GoldService:GiveRunGold(player, rewards.Gold or 0, "Chest")

	-------------------------------------------------
	-- 🔮 SINERGIA
	-------------------------------------------------
	if rewards.Synergy then
		SynergyService:ApplyOrUpgrade(player, rewards.Synergy)

		print("🌟 Sinergia aplicada:", rewards.Synergy)

		GamePauseService:RemovePause("Chest")
		return
	end

	-------------------------------------------------
	-- 📈 ATTRIBUTES
	-------------------------------------------------

	-- 💎 COMPOSIÇÃO CORRETA DE FORÇA
	local CHEST_COMPOSITION = {
		Bronze = {"Bronze"},
		Silver = {"Bronze", "Bronze"},
		Gold = {"Silver", "Silver", "Gold"},
		Diamond = {"Silver", "Silver", "Gold", "Gold", "Diamond"}
	}

	for _, attr in ipairs(rewards.Attributes or {}) do

		local stat = attrs:FindFirstChild(attr.Name)
		if not stat then
			warn("⚠ Atributo não encontrado:", attr.Name)
			continue
		end

		local levels = matchStats:FindFirstChild("AttributeLevels")
		local levelStat = levels and levels:FindFirstChild(attr.Name)

		local beforeValue = stat.Value
		local beforeLevel = (levelStat and levelStat.Value) or 0

		local sequence = CHEST_COMPOSITION[rarity] or {"Bronze"}

		for i, tier in ipairs(sequence) do

			local beforeStep = stat.Value

			local valueToApply
			local attrBalance = ATTRIBUTE_BALANCE[attr.Name]

			if attrBalance and attrBalance[tier] then
				valueToApply = attrBalance[tier]
			else
				valueToApply = 0.02
			end

			-----------------------------------------
			-- APLICAR
			-----------------------------------------

			if attr.Name == "Cooldown" then

				stat.Value *= (1 - valueToApply)

			elseif attr.Name == "ShieldRegenDelay" then

				stat.Value -= valueToApply
				stat.Value = math.max(stat.Value, 1)

			elseif MULTIPLIER_ATTRS[attr.Name] then

				stat.Value *= (1 + valueToApply)

			elseif ADDITIVE_ATTRS[attr.Name] then

				if attr.Name == "Shield" then
					stat.Value += (ATTRIBUTE_BALANCE.Shield[tier] or 10)
				else
					stat.Value += valueToApply
				end
			end

			local afterStep = stat.Value

			-- 📊 LOG DETALHADO
			print(string.format(
				"   ↳ [%d] %s (%s) → %.4f → %.4f",
				i,
				attr.Name,
				tier,
				beforeStep,
				afterStep
				))

			-- LEVEL
			if levelStat then
				levelStat.Value += 1
			end
		end

		local afterValue = stat.Value
		local afterLevel = (levelStat and levelStat.Value) or beforeLevel

		print(string.format(
			"📈 %s (%s) | Level: %d → %d | Valor: %.4f → %.4f",
			attr.Name,
			rarity,
			beforeLevel,
			afterLevel,
			beforeValue,
			afterValue
			))

		-- Atualizar CurrentShield
		if attr.Name == "Shield" then
			local currentShield = attrs:FindFirstChild("CurrentShield")
			if currentShield then
				currentShield.Value = stat.Value
			end
		end
	end
	
	-------------------------------------------------
	-- ⚔ WEAPON UPGRADE
	-------------------------------------------------

	if rewards.Weapon and _G.WeaponController then
		_G.WeaponController:UpgradeWeapon(player)
	end

	print("🎁 Rewards applied to", player.Name)

	GamePauseService:RemovePause("Chest")
end)

-------------------------------------------------
-- LIMPEZA
-------------------------------------------------
Players.PlayerRemoving:Connect(function(player)
	pendingRewards[player] = nil
end)

return ChestService
