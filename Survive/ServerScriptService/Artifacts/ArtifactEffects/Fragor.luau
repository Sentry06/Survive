local Fragor = {}

Fragor.Id = "Fragor"
Fragor.Duration = 30

Fragor.Tags = { "FragorExplosion" }

Fragor.Data = {
	Chance = 0.70,
	DamageBoost = 2,
	RadiusBoost = 1.5
}

function Fragor:OnApply(player)
	print("💥 Fragor aplicado")
end

function Fragor:OnRemove(player)
	print("💥 Fragor removido")
end

return Fragor
