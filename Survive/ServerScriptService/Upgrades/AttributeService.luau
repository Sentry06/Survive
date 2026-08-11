local AttributeRegistry = require(
	game.ServerScriptService.Upgrades.AttributeRegistry
)

local AttributeService = {}

function AttributeService:Apply(player, attributeId, value)

	local attrs = player.MatchStats.Attributes
	local stat = attrs:FindFirstChild(attributeId)
	if not stat then return end

	local def = AttributeRegistry:Get(attributeId)
	if not def then return end

	if def.Type == "Multiplier" then
		stat.Value *= (1 + value)

	elseif attributeId == "ShieldRegenDelay" then
		stat.Value -= value
		stat.Value = math.max(stat.Value, 1)

	elseif def.Type == "InverseMultiplier" then
		stat.Value *= (1 + value)

	elseif def.Type == "Additive" then
		stat.Value += value
	end

end

return AttributeService