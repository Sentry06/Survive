-- MatchTime.server
-- Timer oficial da partida (APENAS GamePaused controla)

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local GoldService = require(game.ServerScriptService:WaitForChild("GoldService"))
local DifficultyService = require(game.ServerScriptService:WaitForChild("DifficultyService"))

-- Remotes
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local TimeRemote = Remotes:WaitForChild("MatchTimeUpdate")

-- GameState
local GameState = ReplicatedStorage:WaitForChild("GameState")
local GamePaused = GameState:WaitForChild("GamePaused")
local RunActive = GameState:WaitForChild("RunActive")

-------------------------------------------------
-- ELAPSED TIME (NumberValue oficial)
-------------------------------------------------

local elapsedValue = GameState:FindFirstChild("ElapsedTime")

if not elapsedValue then
	elapsedValue = Instance.new("NumberValue")
	elapsedValue.Name = "ElapsedTime"
	elapsedValue.Value = 0
	elapsedValue.Parent = GameState
end

-------------------------------------------------
-- STATE
-------------------------------------------------

local lastSecondSent = -1
local goldGranted = false

-------------------------------------------------
-- BROADCAST
-------------------------------------------------

local function broadcastTime()
	for _, player in ipairs(Players:GetPlayers()) do
		TimeRemote:FireClient(player, elapsedValue.Value)
		local ms = player:FindFirstChild("MatchStats")
		if ms and ms:FindFirstChild("RunDuration") then
			ms.RunDuration.Value = elapsedValue.Value
		end
	end
end

-------------------------------------------------
-- LOOP
-------------------------------------------------

RunService.Heartbeat:Connect(function(dt)

	if not RunActive.Value then
		elapsedValue.Value = 0
		lastSecondSent = -1
		goldGranted = false
		return
	end

	if GamePaused.Value then
		return
	end

	-- ⏱️ Atualiza tempo oficial
	elapsedValue.Value += dt

	-- Atualiza dificuldade
	DifficultyService:SetTime(elapsedValue.Value)

	-------------------------------------------------
	-- 🪙 OURO POR SOBREVIVÊNCIA (20 MIN)
	-------------------------------------------------
	if not goldGranted and elapsedValue.Value >= 1200 then
		goldGranted = true

		for _, player in ipairs(Players:GetPlayers()) do

			if player and player.Parent then

				local amount = 200

				if player:GetAttribute("Artifact_Aurum") then
					amount *= 3
				end

				GoldService:GiveRunGold(player, amount, "Survival")
			end
		end

		print("🪙 Ouro de sobrevivência concedido")
	end
	-------------------------------------------------
	-- Atualização por segundo (HUD)
	-------------------------------------------------

	local whole = math.floor(elapsedValue.Value)

	if whole ~= lastSecondSent then
		lastSecondSent = whole
		broadcastTime()
	end
end)

print("⏱️ MatchTime FINAL CORRIGIDO")