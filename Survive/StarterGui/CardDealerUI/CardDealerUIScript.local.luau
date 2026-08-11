local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local CardUpdate = Remotes:WaitForChild("CardDealerUpdate")

local ui = script.Parent
local frame = ui:WaitForChild("CardDealerFrame")

local cardIcon = frame:WaitForChild("CardIcon")
local cardName = frame:WaitForChild("CardName")

ui.Enabled = false

-------------------------------------------------
-- CARD IMAGES
-------------------------------------------------

local CardImages = {

	Ace = "rbxassetid://83176381033818",
	King = "rbxassetid://137133956364316",
	Queen = "rbxassetid://90692022817505",
	Jack = "rbxassetid://126311395582728",
	Joker = "rbxassetid://123341847045953"

}

task.wait(0.5)

local current = player:GetAttribute("ActiveCard")

if current then
	ui.Enabled = true
	cardName.Text = current.." Active"
	cardIcon.Image = CardImages[current]
end

-------------------------------------------------
-- SHOW CARD
-------------------------------------------------

CardUpdate.OnClientEvent:Connect(function(cardNameValue,type)

	ui.Enabled = true

	cardName.Text = cardNameValue.." Active"

	local image = CardImages[cardNameValue]

	if image then
		cardIcon.Image = image
	end
	
end)