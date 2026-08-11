-- SynergyDiscoveryService.lua
-- Agora usa GlobalStats como storage permanente

local SynergyDiscoveryService = {}

-------------------------------------------------
-- REGISTRA DESCOBERTA
-------------------------------------------------
function SynergyDiscoveryService:Register(player, synergyId)

	local global = player:FindFirstChild("GlobalStats")
	if not global then return end

	local folder = global:FindFirstChild("DiscoveredSynergies")
	if not folder then return end

	-- Já existe?
	if folder:FindFirstChild(synergyId) then
		return
	end

	local flag = Instance.new("BoolValue")
	flag.Name = synergyId
	flag.Value = true
	flag.Parent = folder

	print("📖 Nova sinergia descoberta:", synergyId)
end

-------------------------------------------------
-- RETORNA TODAS DESCOBERTAS
-------------------------------------------------
function SynergyDiscoveryService:Get(player)

	local result = {}

	local global = player:FindFirstChild("GlobalStats")
	if not global then return result end

	local folder = global:FindFirstChild("DiscoveredSynergies")
	if not folder then return result end

	for _, value in ipairs(folder:GetChildren()) do
		result[value.Name] = true
	end

	return result
end

return SynergyDiscoveryService