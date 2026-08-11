local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local WeaponsUpdated = ReplicatedStorage.Remotes:WaitForChild("WeaponsUpdated")

--------------------------------------------------
-- GUI REFERENCES
--------------------------------------------------

local playerGui = player:WaitForChild("PlayerGui")
local combatGui = playerGui:WaitForChild("CombatGUI")
local root = combatGui:WaitForChild("Root")
local topRight = root:WaitForChild("TopRight")
local panel = topRight:WaitForChild("WeaponsPanel")

--------------------------------------------------
-- CONSTANTS
--------------------------------------------------

local BASE_SLOTS = 1
local SLOT_SIZE = 50
local PADDING = 6

--------------------------------------------------
-- STATE
--------------------------------------------------

local slotsUI = {}
local currentMaxSlots = 0
local previousWeapons = {}

--------------------------------------------------
-- MAX SLOT CALCULATION
--------------------------------------------------

local function getMaxSlots()
	local stats = player:FindFirstChild("GlobalStats")
	if stats and stats:FindFirstChild("ExtraWeaponSlots") then
		return BASE_SLOTS + stats.ExtraWeaponSlots.Value
	end
	return BASE_SLOTS
end

--------------------------------------------------
-- CLEAR SLOTS
--------------------------------------------------

local function clearSlots()
	for _, slot in ipairs(slotsUI) do
		if slot.Frame then
			slot.Frame:Destroy()
		end
	end
	slotsUI = {}
end

--------------------------------------------------
-- BUILD SLOTS (DYNAMIC)
--------------------------------------------------

local function buildSlots(maxSlots)

	clearSlots()
	currentMaxSlots = maxSlots

	for i = 1, maxSlots do

		local slot = Instance.new("Frame")
		slot.Size = UDim2.fromOffset(SLOT_SIZE, SLOT_SIZE)
		slot.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
		slot.BackgroundTransparency = 0.15
		slot.BorderSizePixel = 2
		slot.BorderColor3 = Color3.fromRGB(255, 255, 255)
		slot.Parent = panel

		local icon = Instance.new("ImageLabel")
		icon.Size = UDim2.fromScale(1, 1)
		icon.BackgroundTransparency = 1
		icon.ImageTransparency = 0.8
		icon.Parent = slot

		local levelLabel = Instance.new("TextLabel")
		levelLabel.Size = UDim2.new(1, 0, 0, 18)
		levelLabel.Position = UDim2.new(0, 0, 1, -18)
		levelLabel.BackgroundTransparency = 1
		levelLabel.TextScaled = true
		levelLabel.TextColor3 = Color3.new(1, 1, 1)
		levelLabel.Font = Enum.Font.Merriweather
		levelLabel.Text = ""
		levelLabel.Parent = slot

		slotsUI[i] = {
			Frame = slot,
			Icon = icon,
			Level = levelLabel
		}
	end

	-- Ajustar largura automática do painel
	local totalWidth = (SLOT_SIZE * maxSlots) + (PADDING * (maxSlots - 1))
	panel.Size = UDim2.fromOffset(totalWidth, 60)
end

--------------------------------------------------
-- INITIAL BUILD
--------------------------------------------------

buildSlots(getMaxSlots())

--------------------------------------------------
-- UPDATE HUD
--------------------------------------------------

local WeaponRegistry = require(
	ReplicatedStorage.Shared:WaitForChild("WeaponRegistry")
)

local function updateHUD(weapons)

	for i = 1, currentMaxSlots do

		local slotUI = slotsUI[i]
		local weaponData = weapons[i]

		if weaponData then

			local def = WeaponRegistry.Definitions[weaponData.Name]

			if def then
				slotUI.Icon.Image = def.Image
			end

			slotUI.Icon.ImageTransparency = 0
			slotUI.Level.Text = "LVL " .. weaponData.Level

			-- 🔥 Animação só se antes estava vazio
			if not previousWeapons[i] then

				slotUI.Frame.Size = UDim2.fromOffset(0, 0)

				TweenService:Create(
					slotUI.Frame,
					TweenInfo.new(0.25, Enum.EasingStyle.Back),
					{Size = UDim2.fromOffset(SLOT_SIZE, SLOT_SIZE)}
				):Play()
			end

		else
			slotUI.Icon.Image = ""
			slotUI.Icon.ImageTransparency = 0.8
			slotUI.Level.Text = ""
		end
	end

	previousWeapons = table.clone(weapons)
end

WeaponsUpdated.OnClientEvent:Connect(function(weapons)
	updateHUD(weapons or {})
end)