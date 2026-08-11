local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameState = ReplicatedStorage:WaitForChild("GameState")
local RunState = GameState:WaitForChild("RunState")
local RunActive = GameState:WaitForChild("RunActive")

local RunFlowService = {}

-------------------------------------------------
-- ESTADOS
-------------------------------------------------

RunFlowService.States = {
	Lobby = "Lobby",
	Starting = "Starting",
	Running = "Running",
	Ending = "Ending",
	Results = "Results"
}

-------------------------------------------------
-- EVENTOS
-------------------------------------------------

RunFlowService.Events = {
	OnRunStarting = Instance.new("BindableEvent"),
	OnRunRunning = Instance.new("BindableEvent"),
	OnRunEnding = Instance.new("BindableEvent"),
	OnRunResults = Instance.new("BindableEvent")
}

-------------------------------------------------
-- SET STATE
-------------------------------------------------

function RunFlowService:SetState(state)

	RunState.Value = state

	print("🎮 RunState →", state)

	if state == self.States.Starting then
		self.Events.OnRunStarting:Fire()
	end

	if state == self.States.Running then
		self.Events.OnRunRunning:Fire()
	end

	if state == self.States.Ending then
		self.Events.OnRunEnding:Fire()
	end

	if state == self.States.Results then
		self.Events.OnRunResults:Fire()
	end

end

-------------------------------------------------
-- GET STATE
-------------------------------------------------

function RunFlowService:GetState()
	return RunState.Value
end

-------------------------------------------------
-- START RUN
-------------------------------------------------

function RunFlowService:StartRun()

	if RunState.Value ~= self.States.Lobby then
		print("Run não pode iniciar:", RunState.Value)
		return
	end

	self:SetState(self.States.Starting)

	RunActive.Value = true

	task.wait(0.5)

	self:SetState(self.States.Running)

end
-------------------------------------------------
-- END RUN
-------------------------------------------------

function RunFlowService:EndRun(result)

	if RunState.Value ~= self.States.Running then
		return
	end

	self:SetState(self.States.Ending)

	RunActive.Value = false

	task.wait(1)

	self:SetState(self.States.Results)

end

-------------------------------------------------
-- RETURN LOBBY
-------------------------------------------------

function RunFlowService:ReturnToLobby()

	RunActive.Value = false

	self:SetState(self.States.Lobby)

end

return RunFlowService