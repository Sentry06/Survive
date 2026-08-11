local ChestService = require(script.Parent:WaitForChild("ChestService"))

local chestsFolder = workspace:WaitForChild("Chests")

local function setupChest(chest)

	if not chest:IsA("Model") then
		return
	end

	if not chest.PrimaryPart then
		warn("Chest sem PrimaryPart:", chest.Name)
		return
	end

	local prompt = chest.PrimaryPart:FindFirstChildOfClass("ProximityPrompt")

	if not prompt then
		warn("Chest sem ProximityPrompt:", chest.Name)
		return
	end

	prompt.Triggered:Connect(function(player)
		ChestService:OpenChest(player, chest)
	end)
end

-- Conectar existentes
for _, chest in ipairs(chestsFolder:GetChildren()) do
	setupChest(chest)
end

-- Conectar novos
chestsFolder.ChildAdded:Connect(function(chest)
	setupChest(chest)
end)

print("📦 ChestInteraction pronto")
