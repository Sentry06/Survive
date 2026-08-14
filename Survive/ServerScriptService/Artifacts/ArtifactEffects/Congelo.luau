local EnemyTimeController = require(
	game.ServerScriptService.Combat.EnemyTimeController
)

local Congelo = {}

Congelo.Id = "Congelo"
Congelo.Duration = 15
Congelo.Tags = { "GlobalSlow" }

function Congelo:OnApply(player)
	print("🧊 Congelo aplicado")
	EnemyTimeController:SetSlow(0.25) -- 75% slow
end

function Congelo:OnRemove(player)
	print("🧊 Congelo removido")
	EnemyTimeController:SetSlow(1)
end

return Congelo
