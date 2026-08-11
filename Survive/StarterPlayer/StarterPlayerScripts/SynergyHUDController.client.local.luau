local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local SynergiesUpdated = ReplicatedStorage.Remotes:WaitForChild("SynergiesUpdated")

local playerGui = player:WaitForChild("PlayerGui")
local combatGui = playerGui:WaitForChild("CombatGUI")
local root = combatGui:WaitForChild("Root")
local topRight = root:WaitForChild("TopRight")
local panel = topRight:WaitForChild("SynergiesPanel")

local SynergyRegistry = require(
	ReplicatedStorage.Shared:WaitForChild("SynergyRegistry")
)

local TierColors = {
	[1] = Color3.fromRGB(120,200,255),
	[2] = Color3.fromRGB(180,100,255),
	[3] = Color3.fromRGB(255,120,60)
}

--------------------------------------------------
-- STORAGE
--------------------------------------------------

local slotsUI = {}
local glowSlots = {}

--------------------------------------------------
-- SLOT CREATION
--------------------------------------------------

local function createSlot(data)

	local slot = Instance.new("Frame")
	slot.Size = UDim2.fromOffset(50,50)
	slot.BackgroundColor3 = Color3.fromRGB(20,20,20)
	slot.BackgroundTransparency = 0.2
	slot.Parent = panel

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0,8)
	corner.Parent = slot

	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 2
	stroke.Color = TierColors[data.Tier] or Color3.new(1,1,1)
	stroke.Parent = slot

	local icon = Instance.new("ImageLabel")
	icon.Size = UDim2.fromScale(1,1)
	icon.BackgroundTransparency = 1
	icon.Image = SynergyRegistry.Definitions[data.Id].Image
	icon.Parent = slot

	local level = Instance.new("TextLabel")
	level.Size = UDim2.fromScale(1,0.35)
	level.Position = UDim2.fromScale(0,0.65)
	level.BackgroundTransparency = 1
	level.TextScaled = true
	level.Font = Enum.Font.Merriweather
	level.TextColor3 = Color3.new(1,1,1)
	level.Text = "Lv " .. data.Level
	level.Parent = slot

	--------------------------------------------------
	-- ANIMAÇÃO DE ENTRADA
	--------------------------------------------------

	if data.Level == 1 then

		slot.Size = UDim2.fromOffset(0,0)

		TweenService:Create(
			slot,
			TweenInfo.new(0.3, Enum.EasingStyle.Back),
			{Size = UDim2.fromOffset(50,50)}
		):Play()

	end

	return slot, stroke, level
end

--------------------------------------------------
-- UPDATE SLOT
--------------------------------------------------

local function updateSlot(slotData, ui)

	ui.level.Text = "Lv " .. slotData.Level

	if slotData.Level == slotData.MaxLevel then
		glowSlots[ui.stroke] = true
	else
		glowSlots[ui.stroke] = nil
		ui.stroke.Transparency = 0
	end

end

--------------------------------------------------
-- GLOBAL GLOW LOOP (1 LOOP APENAS)
--------------------------------------------------

RunService.RenderStepped:Connect(function()

	local t = tick()

	for stroke,_ in pairs(glowSlots) do

		if stroke.Parent then
			stroke.Transparency = 0.2 + math.abs(math.sin(t*3))*0.3
		end

	end

end)

--------------------------------------------------
-- UPDATE HUD
--------------------------------------------------

local function updateHUD(activeSynergies)

	--------------------------------------------------
	-- LIMPA SE NÃO HOUVER
	--------------------------------------------------

	if #activeSynergies == 0 then

		for _,ui in pairs(slotsUI) do
			ui.frame:Destroy()
		end

		slotsUI = {}
		glowSlots = {}

		panel.Visible = false
		return
	end

	panel.Visible = true

	--------------------------------------------------
	-- CRIA OU ATUALIZA
	--------------------------------------------------

	for i,data in ipairs(activeSynergies) do

		local ui = slotsUI[i]

		if not ui then

			local frame, stroke, level = createSlot(data)

			ui = {
				frame = frame,
				stroke = stroke,
				level = level
			}

			slotsUI[i] = ui

		end

		updateSlot(data, ui)

	end

	--------------------------------------------------
	-- REMOVE SLOTS EXTRAS
	--------------------------------------------------

	for i = #activeSynergies + 1, #slotsUI do

		local ui = slotsUI[i]

		if ui then
			ui.frame:Destroy()
			slotsUI[i] = nil
		end

	end

end

--------------------------------------------------
-- EVENT
--------------------------------------------------

SynergiesUpdated.OnClientEvent:Connect(updateHUD)