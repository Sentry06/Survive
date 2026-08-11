local player = game.Players.LocalPlayer

local goldLabel = script.Parent:WaitForChild("GoldText")

local globalStats = player:WaitForChild("GlobalStats")
local gold = globalStats:WaitForChild("Gold")

local function updateGold()

	goldLabel.Text = tostring(gold.Value)

end

updateGold()

gold.Changed:Connect(updateGold)