local Artifact = {}

Artifact.Id = "FluxusEletricus"
Artifact.Duration = 30

Artifact.Tags = { "Electric" }

Artifact.Data = {
	Duration = 3,
	Tick = 0.5,
	DamagePercent = 0.3,
	Radius = 12
}

function Artifact:OnApply(player)
	print("⚡ FluxusEletricus aplicado")
end

function Artifact:OnRemove(player)
	print("⚡ FluxusEletricus removido")
end

return Artifact
