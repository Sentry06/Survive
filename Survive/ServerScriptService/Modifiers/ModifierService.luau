local ModifierRegistry = require(
	game.ReplicatedStorage.Shared:WaitForChild("ModifierRegistry")
)

local ModifierService = {}

local activeModifiers = {}

-------------------------------------------------
-- APPLY (START OF RUN)
-------------------------------------------------

function ModifierService:ApplyModifier(player)

	local global = player:FindFirstChild("GlobalStats")
	if not global then return end

	local selected = global:FindFirstChild("SelectedModifier")
	if not selected then return end

	local modifierId = selected.Value
	local modifier = ModifierRegistry:Get(modifierId)

	if not modifier then
		warn("Modifier not found:", modifierId)
		return
	end

	activeModifiers[player] = modifier
	
	player:SetAttribute("ActiveModifier", modifierId)

	print("🧩 Modifier aplicado:", modifierId)

	if modifier.Apply then
		modifier.Apply(player)
	end

end

-------------------------------------------------
-- GET
-------------------------------------------------

function ModifierService:GetActive(player)
	return activeModifiers[player]
end

-------------------------------------------------
-- ON HIT
-------------------------------------------------

function ModifierService:OnHit(player, enemy, damageData)

	local mod = activeModifiers[player]
	if not mod then return end

	if mod.OnHit then
		mod.OnHit(player, enemy, damageData)
	end

end

-------------------------------------------------
-- ON KILL
-------------------------------------------------

function ModifierService:OnKill(player, enemy)

	local mod = activeModifiers[player]
	if not mod then return end

	if mod.OnKill then
		mod.OnKill(player, enemy)
	end

end

-------------------------------------------------
-- CLEAR
-------------------------------------------------

function ModifierService:Clear(player)
	activeModifiers[player] = nil
end

return ModifierService