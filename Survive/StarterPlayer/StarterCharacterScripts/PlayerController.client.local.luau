local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CombatTarget = ReplicatedStorage.Remotes.CombatTarget

local player = Players.LocalPlayer

-- CONFIGURAÇÕES
local ROTATION_SMOOTHNESS = 0.2
local TARGET_LOST_DISTANCE = 80
local MOVEMENT_PRIORITY_THRESHOLD = 0.2 -- Intensidade de movimento para ter prioridade sobre o alvo
local TARGET_LOCK_MODE = "auto" -- "auto", "manual", ou "hybrid"

local humanoid
local root
local moveVector = Vector3.zero
local isTargetLocked = false
local lastTargetUpdateTime = 0
local currentTargetPosition = nil

-- Setup personagem
local function onCharacterAdded(character)
	humanoid = character:WaitForChild("Humanoid")
	root = character:WaitForChild("HumanoidRootPart")
end

player.CharacterAdded:Connect(onCharacterAdded)
if player.Character then
	onCharacterAdded(player.Character)
end

-- Conectar evento de combate fora do loop
CombatTarget.OnClientEvent:Connect(function(targetPos)
	currentTargetPosition = targetPos
	lastTargetUpdateTime = tick()
	isTargetLocked = false -- Começa sem lock, movimento tem prioridade
end)

-- Input
local inputMap = {
	[Enum.KeyCode.W] = Vector3.new(0, 0, -1),
	[Enum.KeyCode.S] = Vector3.new(0, 0, 1),
	[Enum.KeyCode.A] = Vector3.new(-1, 0, 0),
	[Enum.KeyCode.D] = Vector3.new(1, 0, 0),
}

local pressedKeys = {}

UserInputService.InputBegan:Connect(function(input, gp)
	if gp then return end
	if inputMap[input.KeyCode] then
		pressedKeys[input.KeyCode] = true
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if inputMap[input.KeyCode] then
		pressedKeys[input.KeyCode] = nil
	end
end)

-- Loop principal
RunService.RenderStepped:Connect(function()
	if not humanoid or not root then return end

	-- (opcional, mas recomendado)
	if humanoid:GetAttribute("Frozen") then
		return
	end

	-- Movimento
	moveVector = Vector3.zero
	for key in pairs(pressedKeys) do
		moveVector += inputMap[key]
	end

	if moveVector.Magnitude > 0 then
		moveVector = moveVector.Unit
	end

	-- ✅ USA WalkSpeed CALCULADO PELO MovementSpeed
	humanoid:Move(moveVector * humanoid.WalkSpeed, true)

	-- resto da lógica de rotação continua igual…
end)

