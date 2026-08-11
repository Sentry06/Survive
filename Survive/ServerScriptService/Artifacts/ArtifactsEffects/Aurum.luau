local Aurum = {}

Aurum.Id = "Aurum"
Aurum.Duration = 30
Aurum.GoldMultiplier = 3

function Aurum:OnApply(player)
	player:SetAttribute("Artifact_Aurum", true)
end

function Aurum:OnRemove(player)
	player:SetAttribute("Artifact_Aurum", false)
end

return Aurum
