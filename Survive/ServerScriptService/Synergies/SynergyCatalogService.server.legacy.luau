-- SynergyCatalogService.server.lua

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local GetDiscoveredSynergies = Remotes:WaitForChild("GetDiscoveredSynergies")

local SynergyDiscoveryService = require(
	game.ServerScriptService.Synergies:WaitForChild("SynergyDiscoveryService")
)

GetDiscoveredSynergies.OnServerInvoke = function(player)
	return SynergyDiscoveryService:Get(player)
end

print("📖 SynergyCatalogService carregado.")