local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

local ArtifactDropService = {}

-- ⚠️ Corrigindo nome da pasta
local templatesFolder = ReplicatedStorage:WaitForChild("ArtifactsModels")

-- ⏳ tempo para desaparecer se não for pego
local DROP_LIFETIME = 30

function ArtifactDropService:Spawn(artifactId, position)

	local template = templatesFolder:FindFirstChild(artifactId)
	if not template then
		warn("❌ Modelo não encontrado:", artifactId)
		return
	end

	-- garantir pasta workspace.Artifacts
	local artifactsFolder = workspace:FindFirstChild("Artifacts")
	if not artifactsFolder then
		artifactsFolder = Instance.new("Folder")
		artifactsFolder.Name = "Artifacts"
		artifactsFolder.Parent = workspace
	end

	local model = template:Clone()
	model:SetAttribute("ArtifactId", artifactId)

	-- garantir PrimaryPart antes de escalar
	if not model.PrimaryPart then
		model.PrimaryPart = model:FindFirstChildWhichIsA("BasePart")
	end

	if not model.PrimaryPart then
		warn("❌ Modelo sem BasePart:", artifactId)
		return
	end

	-------------------------------------------------
	-- 🔥 ESCALA ESPECÍFICA DO GARGANTUA (DROP MENOR)
	-------------------------------------------------
	if artifactId == "Gargantua" then
		model:ScaleTo(0.4) -- ajuste fino aqui
	end

	model.Parent = artifactsFolder

	model:SetPrimaryPartCFrame(
		CFrame.new(position + Vector3.new(0, 2, 0))
	)

	-------------------------------------------------
	-- ⏳ AUTO-DESTRUIR SE NÃO FOR PEGO
	-------------------------------------------------
	Debris:AddItem(model, DROP_LIFETIME)

	return model
end

return ArtifactDropService
