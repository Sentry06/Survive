local Sanguis = {}

Sanguis.Id = "Sanguis"
Sanguis.Duration = 30

-- 🔥 ESSA PARTE É OBRIGATÓRIA
Sanguis.Tags = { "LifeSteal" }

Sanguis.Data = {
	Percent = 0.20 -- 20% de roubo de vida
}

function Sanguis:OnApply(player)
	print("🩸 Sanguis aplicado")
end

function Sanguis:OnRemove(player)
	print("🩸 Sanguis removido")
end

return Sanguis
