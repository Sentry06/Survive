-- MovementScript.client
-- Bloqueia input do jogador quando o jogo está pausado
-- Usa ReplicatedStorage.GameState.GamePaused (padrão oficial)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService("ContextActionService")

local player = Players.LocalPlayer

-- =========================
-- GAME STATE (OFICIAL)
-- =========================
local GameState = ReplicatedStorage:WaitForChild("GameState")
local GamePaused = GameState:WaitForChild("GamePaused")

local BLOCK_ACTION = "BlockMovement"

-- =========================
-- BLOQUEIO DE INPUT
-- =========================
local function blockMovement(_, inputState)
	if inputState == Enum.UserInputState.Begin
		or inputState == Enum.UserInputState.Change then
		return Enum.ContextActionResult.Sink
	end
	return Enum.ContextActionResult.Pass
end

local function applyPause(paused)
	if paused then
		-- Bloqueia movimentação e pulo
		ContextActionService:BindAction(
			BLOCK_ACTION,
			blockMovement,
			false,
			Enum.PlayerActions.CharacterForward,
			Enum.PlayerActions.CharacterBackward,
			Enum.PlayerActions.CharacterLeft,
			Enum.PlayerActions.CharacterRight,
			Enum.PlayerActions.CharacterJump
		)
	else
		ContextActionService:UnbindAction(BLOCK_ACTION)
	end
end

-- =========================
-- INIT
-- =========================
applyPause(GamePaused.Value)
GamePaused.Changed:Connect(applyPause)

print("🚫 MovementScript FINAL (respeita GameState.GamePaused)")
