local ChestSpawner = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local chestModels = ReplicatedStorage:WaitForChild("ChestsModels")

-- Pasta ativa
local chestsFolder = Workspace:FindFirstChild("Chests")
if not chestsFolder then
	chestsFolder = Instance.new("Folder")
	chestsFolder.Name = "Chests"
	chestsFolder.Parent = Workspace
end

-- =========================
-- CHANCES BASE
-- =========================
local BASE_CHANCES = {
	Bronze = 60,
	Silver = 25,
	Gold = 10,
	Diamond = 5
}

local function rollRarity(player)

	local global = player:FindFirstChild("GlobalStats")
	local luck = global and global:FindFirstChild("Luck") and global.Luck.Value or 0

	-- 🎯 BASE
	local weights = {
		Bronze = 60,
		Silver = 25,
		Gold = 10,
		Diamond = 5
	}

	-- 🔥 LUCK SHIFT
	local factor = luck * 100

	local bronzeLoss = factor * 0.5
	local silverLoss = factor * 0.3

	weights.Bronze = math.max(5, weights.Bronze - bronzeLoss)
	weights.Silver = math.max(5, weights.Silver - silverLoss)

	local gained = bronzeLoss + silverLoss

	weights.Gold += gained * 0.7
	weights.Diamond += gained * 0.3

	-- 🎲 ROLL
	local total = 0
	for _, v in pairs(weights) do
		total += v
	end

	local roll = math.random() * total
	local acc = 0

	for _, rarity in ipairs({"Bronze","Silver","Gold","Diamond"}) do
		acc += weights[rarity]
		if roll <= acc then
			return rarity
		end
	end

	return "Bronze"
end

-- =========================
-- SPAWN
-- =========================
function ChestSpawner:SpawnChest(position, player)

	local rarity = rollRarity(player)

	local modelName = "Chest_" .. rarity
	local template = chestModels:FindFirstChild(modelName)

	if not template then
		warn("Modelo não encontrado:", modelName)
		return
	end

	local chest = template:Clone()
	chest.Parent = chestsFolder
	chest:ScaleTo(4)

	if not chest.PrimaryPart then
		warn("Chest sem PrimaryPart:", chest.Name)
		return
	end

	chest:SetPrimaryPartCFrame(CFrame.new(position + Vector3.new(0, 0.5, 0)))
	chest:SetAttribute("Rarity", rarity)

	print("📦 Chest spawnado:", rarity)

	return chest
end

return ChestSpawner
