local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local globalStats = player:WaitForChild("GlobalStats")
local selectedModifier = globalStats:WaitForChild("SelectedModifier")

-------------------------------------------------
-- UI
-------------------------------------------------

local gui = Instance.new("ScreenGui")
gui.Name = "RetaliationUI"
gui.ResetOnSpawn = false
gui.Parent = playerGui

local text = Instance.new("TextLabel")
text.Size = UDim2.new(0.2,0,0.05,0)
text.Position = UDim2.new(0.4,0,0.85,0)
text.BackgroundColor3 = Color3.fromRGB(20,20,20)
text.TextColor3 = Color3.fromRGB(255,255,255)
text.Font = Enum.Font.Merriweather
text.TextScaled = true
text.Text = "0"
text.Parent = gui

-------------------------------------------------
-- VISIBILIDADE
-------------------------------------------------

local function updateVisibility()
	gui.Enabled = (selectedModifier.Value == "Retaliation")
end

selectedModifier:GetPropertyChangedSignal("Value"):Connect(updateVisibility)
updateVisibility()

-------------------------------------------------
-- STACK TRACK
-------------------------------------------------

local function getStacks()
	return player:GetAttribute("RetaliationStacks") or 0
end

-------------------------------------------------
-- UPDATE LOOP
-------------------------------------------------

task.spawn(function()

	while player and player.Parent do

		if selectedModifier.Value == "Retaliation" then

			local stacks = getStacks()
			
			local intensity = math.clamp(stacks / 10, 0, 1)
			text.TextColor3 = Color3.fromRGB(255, 255 * (1 - intensity), 255 * (1 - intensity))

			-- feedback visual simples
			if stacks == 0 then
				text.TextColor3 = Color3.fromRGB(150,150,150)
			else
				text.TextColor3 = Color3.fromRGB(255,255,255)
			end
			
			if stacks >= 30 then
				text.Text = "MAX FLOW"
			else
				text.Text = "Hits: " .. stacks
			end
		end

		task.wait(0.1)
	end

end)