local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RunFlowService = require(game.ServerScriptService.RunFlowService)

local EventRegistry = require(script.Parent.RunEventRegistry)

local GameState = ReplicatedStorage:WaitForChild("GameState")
local elapsed = GameState:WaitForChild("ElapsedTime")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local EventRemote = Remotes:WaitForChild("RunEventAnnouncement")

-------------------------------------------------
-- MODIFIERS
-------------------------------------------------

_G.RunModifiers = {

	EnemySpeed = 1,
	EnemyXP = 1,
	EnemyDamage = 1,
	SpawnRate = 1,
	BossCount = 1

}

-------------------------------------------------
-- EVENTOS
-------------------------------------------------

local triggered = {}

local function resetModifiers()

	_G.RunModifiers = {

		EnemySpeed = 1,
		EnemyXP = 1,
		EnemyDamage = 1,
		SpawnRate = 1,
		BossCount = 1

	}

end

local function runEvent(event)

	if event.Type == "EnemyFrenzy" then

		EventRemote:FireAllClients("ENEMY FRENZY")
		print("🔥 EVENTO: Enemy Frenzy")

		_G.RunModifiers.SpawnRate = 1.8
		_G.RunModifiers.EnemySpeed = 1.4
		_G.RunModifiers.EnemyXP = 1.6

		task.delay(event.Duration,function()

			resetModifiers()
			print("🔥 Frenzy terminou")

		end)

	elseif event.Type == "EnemyOverdrive" then

		EventRemote:FireAllClients("ENEMY OVERDRIVE")
		print("⚡ EVENTO: Enemy Overdrive")

		_G.RunModifiers.EnemyDamage = 1.6
		_G.RunModifiers.EnemySpeed = 1.5
		_G.RunModifiers.BossCount = 2

		task.delay(event.Duration,function()

			resetModifiers()

		end)

	elseif event.Type == "DoubleBoss" then

		EventRemote:FireAllClients("ENEMY OVERDRIVE")
		print("👑 EVENTO: Double Boss")

		_G.RunModifiers.BossCount = 2

	elseif event.Type == "BossRush" then

		EventRemote:FireAllClients("DOUBLE BOSS")
		print("💀 EVENTO: Boss Rush")

		_G.RunModifiers.BossCount = 5

	end

end

-------------------------------------------------
-- LOOP
-------------------------------------------------

RunService.Heartbeat:Connect(function()

	if RunFlowService:GetState() ~= RunFlowService.States.Running then
		return
	end

	local time = elapsed.Value

	for i,event in ipairs(EventRegistry) do

		if not triggered[i] and time >= event.Time then

			triggered[i] = true
			runEvent(event)

		end

	end

end)

-------------------------------------------------
-- RESET RUN
-------------------------------------------------

RunFlowService.Events.OnRunStarting.Event:Connect(function()

	triggered = {}
	resetModifiers()

end)