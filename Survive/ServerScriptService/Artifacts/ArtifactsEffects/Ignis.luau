-- Ignis.lua
-- Artefato: fogo – dano aumentado

local Ignis = {}

Ignis.Id = "Ignis"
Ignis.DamageMultiplier = 5
Ignis.Duration = 30

function Ignis:ModifyDamage(player, baseDamage)
	if self:IsActive(player) then
		return baseDamage * self.DamageMultiplier
	end
	return baseDamage
end

function Ignis:IsActive(player)
	return player:GetAttribute("Artifact_Ignis") == true
end

function Ignis:OnApply(player)
	player:SetAttribute("Artifact_Ignis", true)
end

function Ignis:OnRemove(player)
	player:SetAttribute("Artifact_Ignis", false)
end

return Ignis
