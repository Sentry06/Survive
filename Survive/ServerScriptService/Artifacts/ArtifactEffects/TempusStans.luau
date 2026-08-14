local EnemyTimeController = require(
	game.ServerScriptService.Combat.EnemyTimeController
)

local TempusStans = {}

TempusStans.Id = "TempusStans"
TempusStans.Duration = 20
TempusStans.Tags = { "TimeStop" }
TempusStans.Data = {}

function TempusStans:OnApply(player)
	print("TempusStans aplicado")
	EnemyTimeController:AddFreeze(self.Id)
end

function TempusStans:OnRemove(player)
	print("TempusStans removido")
	EnemyTimeController:RemoveFreeze(self.Id)
end

return TempusStans
