local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local ShowEndScreen = Remotes:WaitForChild("ShowEndScreen")
local RequestSummary = Remotes:WaitForChild("RequestSummary")
local ReturnToMenu = Remotes:WaitForChild("ReturnToMenu")

local playerGui = player:WaitForChild("PlayerGui")

local victoryGui = playerGui:WaitForChild("VictoryEndScreenGui")
local defeatGui = playerGui:WaitForChild("DefeatEndScreenGui")

local GameState = ReplicatedStorage:WaitForChild("GameState")
local GamePaused = GameState:WaitForChild("GamePaused")



-- começa tudo desligado
victoryGui.Enabled = false
defeatGui.Enabled = false


ShowEndScreen.OnClientEvent:Connect(function(result, stats)

	print("CLIENT RECEIVED END SCREEN")

	victoryGui.Enabled = false
	defeatGui.Enabled = false
	GamePaused.Value = true
	playerGui.MainMenu.Enabled = false

	if result == "Victory" then
		victoryGui.Enabled = true

		local bonusLabel = victoryGui.MainFrame:WaitForChild("BonusText")

		if stats.VictoryBonus and stats.VictoryBonus > 0 then
			bonusLabel.Text = "BONUS COINS: +"..stats.VictoryBonus
			bonusLabel.Visible = true
		else
			bonusLabel.Visible = false
		end

	else
		defeatGui.Enabled = true
	end
	
	print("DEFEAT GUI ENABLED:", defeatGui.Enabled)
	print("VICTORY GUI ENABLED:", victoryGui.Enabled)

end)

local function connectSummaryButton(gui)

	local summaryButton = gui.MainFrame.ButtonsFrame:WaitForChild("SummaryButton")

	summaryButton.MouseButton1Click:Connect(function()

		gui.Enabled = false
		RequestSummary:FireServer()

	end)
end

connectSummaryButton(victoryGui)
connectSummaryButton(defeatGui)

local function connectMainMenuButton(gui)

	local mainMenuButton = gui.MainFrame.ButtonsFrame:WaitForChild("MainMenuButton")

	mainMenuButton.MouseButton1Click:Connect(function()

		local playerGui = player:WaitForChild("PlayerGui")

		local ScreenFader = require(playerGui.ScreenFader.ScreenFaderController)

		task.spawn(function()

			ScreenFader.FadeOut()

			gui.Enabled = false
			ReturnToMenu:FireServer()

			task.wait(0.2)

			playerGui.MainMenu.Enabled = true

			ScreenFader.FadeIn()

		end)

	end)
end

connectMainMenuButton(victoryGui)
connectMainMenuButton(defeatGui)