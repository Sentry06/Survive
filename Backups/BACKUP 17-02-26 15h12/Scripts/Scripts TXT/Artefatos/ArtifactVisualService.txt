-- ArtifactVisualService.lua

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local ArtifactVisualController = require(
	script.Parent:WaitForChild("ArtifactVisualController")
)

local ArtifactVisualService = {}

local ModelsFolder =
	ReplicatedStorage:WaitForChild("ArtifactsModels")

function ArtifactVisualService:Spawn(artifactId, position)

	local template = ModelsFolder:FindFirstChild(artifactId)
	if not template then
		warn("Modelo não encontrado para:", artifactId)
		return
	end

	local artifactsFolder = Workspace:FindFirstChild("Artifacts")
	if not artifactsFolder then
		artifactsFolder = Instance.new("Folder")
		artifactsFolder.Name = "Artifacts"
		artifactsFolder.Parent = Workspace
	end

	for _, part in ipairs(model:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Anchored = true
			part.CanCollide = false
		end
	end

	local model = template:Clone()
	model.Parent = artifactsFolder
	model:SetAttribute("ArtifactId", artifactId)

	if not model.PrimaryPart then
		model.PrimaryPart = model:FindFirstChild("Core")
			or model:FindFirstChildWhichIsA("BasePart", true)
	end

	if not model.PrimaryPart then
		warn("Modelo sem PrimaryPart:", artifactId)
		return
	end

	model:PivotTo(CFrame.new(position))

	-- aplicar animação automática
	ArtifactVisualController:Attach(model)

	return model
end

return ArtifactVisualService
