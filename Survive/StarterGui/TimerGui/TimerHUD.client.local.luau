-- TimerHUD.client
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local TimeRemote = Remotes:WaitForChild("MatchTimeUpdate")

-- 🔥 TimerLabel está DIRETO no ScreenGui
local gui = script.Parent
local label = gui:WaitForChild("TimerLabel")

local function formatTime(seconds)
	local m = math.floor(seconds / 60)
	local s = seconds % 60
	return string.format("%02d:%02d", m, s)
end

-- 🧪 TESTE VISUAL IMEDIATO
label.Text = "00:00"

TimeRemote.OnClientEvent:Connect(function(time)
	label.Text = formatTime(time)
end)

print("⏱️ TimerHUD FINAL — ScreenGui direto")
