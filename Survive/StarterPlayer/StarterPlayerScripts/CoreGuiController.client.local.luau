local StarterGui = game:GetService("StarterGui")

-- Espera o jogo carregar completamente
task.wait()

-- Remove Chat
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false)

-- Remove Leaderboard
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)

-- Remove botão do Roblox (menu)
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)

-- Remove outros GUIs padrãos
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu, false)
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, false)
