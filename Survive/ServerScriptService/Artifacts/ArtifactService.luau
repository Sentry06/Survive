-- ArtifactService.lua
-- Gerencia estado e duração dos artefatos da RUN

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local ArtifactRegistry = require(script.Parent:WaitForChild("ArtifactRegistry"))

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameState = ReplicatedStorage:WaitForChild("GameState")
local RunActive = GameState:WaitForChild("RunActive")

local event = ReplicatedStorage
	:WaitForChild("Remotes")
	:WaitForChild("ArtifactScreenEffect")

local ArtifactService = {}


-- estado por jogador
-- player -> { Id, EndsAt, Data }
local activeArtifacts = {}

-- =========================
-- ATIVAR ARTEFATO
-- =========================
function ArtifactService:Apply(player, artifactId, pickupModel)

	artifactId = tostring(artifactId)

	local def = ArtifactRegistry:Get(artifactId)
	if not def then
		warn("❌ Artefato inválido:", artifactId)
		return
	end

	-- PRIMEIRO remove
	self:Remove(player)

	-- DEPOIS cria o novo
	activeArtifacts[player] = {
		Id = artifactId,
		Data = def.Data,
		EndsAt = def.Duration and (os.clock() + def.Duration) or nil
	}

	-- AGORA seta atributo UMA VEZ só
	player:SetAttribute("ActiveArtifact", artifactId)
	player:SetAttribute("ArtifactEndsAt", activeArtifacts[player].EndsAt)

	if def.OnApply then
		def:OnApply(player, pickupModel)
	end

	print("[Artifact] Ativado:", artifactId, "→", player.Name)

	event:FireClient(player, "Activate", artifactId)
	
	local ms = player:FindFirstChild("MatchStats")
	if ms and ms:FindFirstChild("ArtifactsActivated") then
		ms.ArtifactsActivated.Value += 1
	end
end

-- =========================
-- REMOVER
function ArtifactService:Remove(player)

	local current = activeArtifacts[player]
	if not current then return end

	local def = ArtifactRegistry:Get(current.Id)

	if def and def.OnRemove then
		def:OnRemove(player)
	end

	activeArtifacts[player] = nil
	player:SetAttribute("ActiveArtifact", nil)
	player:SetAttribute("ArtifactEndsAt", nil)

	print("[Artifact] Removido de", player.Name)

	event:FireClient(player, "Clear")

end

-- =========================
-- CONSULTAS
-- =========================
function ArtifactService:Get(player)
	return activeArtifacts[player]
end

function ArtifactService:HasTag(player, tag)
	local art = activeArtifacts[player]
	if not art then return false end

	local def = ArtifactRegistry:Get(art.Id)
	if not def or not def.Tags then return false end

	for _, t in ipairs(def.Tags) do
		if t == tag then
			return true
		end
	end

	return false
end

function ArtifactService:GetData(player)
	local art = activeArtifacts[player]
	return art and art.Data
end

-- =========================
-- LOOP DE DURAÇÃO
-- =========================
RunService.Heartbeat:Connect(function()

	if not RunActive.Value then
		return
	end

	local now = os.clock()

	for player, art in pairs(activeArtifacts) do
		if art.EndsAt and now >= art.EndsAt then
			ArtifactService:Remove(player)
		end
	end
end)

-- =========================
-- LIMPEZA
-- =========================
Players.PlayerRemoving:Connect(function(player)
	activeArtifacts[player] = nil
end)

print("Registry contém:")
for k in pairs(ArtifactRegistry.Definitions) do
	print(" -", k)
end


return ArtifactService
