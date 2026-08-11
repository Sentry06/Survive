local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

local ArtifactService = require(
	game.ServerScriptService.Artifacts.ArtifactService
)

local artifactsFolder = workspace:WaitForChild("Artifacts")

local CHECK_INTERVAL = 0.2

local function setupModel(model)
	if not model:IsA("Model") then return end
	if not model.PrimaryPart then return end

	model:SetAttribute("Used", false)
	-- ⏳ Auto-destruir após 30s se não for coletado
	Debris:AddItem(model, 30)


	local connection
	connection = RunService.Heartbeat:Connect(function()
		if not model.Parent then
			connection:Disconnect()
			return
		end

		if model:GetAttribute("Used") then return end

		local parts = workspace:GetPartsInPart(model.PrimaryPart)

		for _, part in ipairs(parts) do
			local character = part:FindFirstAncestorOfClass("Model")
			if character then
				local player = Players:GetPlayerFromCharacter(character)
				if player then
					model:SetAttribute("Used", true)

					local artifactId = model:GetAttribute("ArtifactId")
					
					local dropScale = model:GetAttribute("DropScale")
					if dropScale then
						model:ScaleTo(dropScale)
					end

					if typeof(artifactId) == "string" then
						-- 🔥 PASSANDO O MODEL AQUI
						ArtifactService:Apply(player, artifactId, model)
					end

					model:Destroy()
					connection:Disconnect()
					return
				end
			end
		end
	end)
end

-- já existentes
for _, model in ipairs(artifactsFolder:GetChildren()) do
	setupModel(model)
end

-- novos drops
artifactsFolder.ChildAdded:Connect(setupModel)
