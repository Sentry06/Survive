-- MovementSpeed.client
-- Responsável APENAS pelo WalkSpeed do personagem

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local GameState = ReplicatedStorage:WaitForChild("GameState")
local GamePaused = GameState:WaitForChild("GamePaused")

local BASE_SPEED = 18

local function setup(character)
	local humanoid = character:WaitForChild("Humanoid")

	local matchStats = player:WaitForChild("MatchStats")
	local attrs = matchStats:WaitForChild("Attributes")
	local speedAttr = attrs:WaitForChild("MovementSpeed")

	local function applySpeed()
		if GamePaused.Value or humanoid:GetAttribute("Frozen") then
			humanoid.WalkSpeed = 0
		else
			humanoid.WalkSpeed = BASE_SPEED * speedAttr.Value
		end
	end

	-- inicial
	applySpeed()

	-- reage a upgrades
	speedAttr.Changed:Connect(applySpeed)
	GamePaused.Changed:Connect(applySpeed)
end

player.CharacterAdded:Connect(setup)
if player.Character then
	setup(player.Character)
end
