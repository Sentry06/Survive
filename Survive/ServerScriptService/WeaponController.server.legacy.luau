-- WeaponController.server
-- Sistema de arma única (preparado para modificadores)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local WeaponController = {}

local GameState = ReplicatedStorage:WaitForChild("GameState")
local GamePaused = GameState:WaitForChild("GamePaused")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local WeaponsUpdated = Remotes:WaitForChild("WeaponsUpdated")
local GetCurrentWeapons = Remotes:WaitForChild("GetCurrentWeapons")

local WeaponsFolder = game.ServerScriptService:WaitForChild("Weapons")

local WeaponSlots = require(WeaponsFolder:WaitForChild("WeaponSlots"))
local ProjectileLimiter = require(WeaponsFolder:WaitForChild("ProjectileLimiter"))

local MAX_PROJECTILES_PER_PLAYER = 30

local playerSlots = {}
_G.PlayerWeaponSlots = playerSlots

-------------------------------------------------
-- STARTING WEAPON
-------------------------------------------------

local function getStartingWeapon(player)

	local stats = player:FindFirstChild("GlobalStats")

	if stats and stats:FindFirstChild("SelectedWeapon") then
		return stats.SelectedWeapon.Value
	end

	return 

end

-------------------------------------------------
-- UPDATE CLIENT HUD
-------------------------------------------------

local function updateClient(player, slots)

	if not player or not slots then return end

	local data = {}

	for _,slot in ipairs(slots.Weapons) do

		table.insert(data,{
			Name = slot.Name,
			Level = slot.Level
		})

	end

	WeaponsUpdated:FireClient(player,data)

end

-------------------------------------------------
-- CLEAR PLAYER WEAPONS
-------------------------------------------------

local function clearPlayer(player)

	local slots = playerSlots[player]

	if not slots then return end

	for _,slot in ipairs(slots.Weapons) do

		local weapon = slot.Instance

		if weapon and weapon.Destroy then
			pcall(function()
				weapon:Destroy()
			end)
		end

	end

	playerSlots[player] = nil

end

-------------------------------------------------
-- SETUP PLAYER
-------------------------------------------------

local function setupPlayer(player)

	clearPlayer(player)

	local slots = WeaponSlots.new(1)

	local limiter = ProjectileLimiter.new(MAX_PROJECTILES_PER_PLAYER)
	slots.ProjectileLimiter = limiter

	playerSlots[player] = slots

	local startingWeaponName = getStartingWeapon(player)

	local module = WeaponsFolder:FindFirstChild(startingWeaponName)

	if not module then

		warn("⚠ Weapon module not found:", startingWeaponName)
		return

	end

	local weaponClass = require(module)

	local weapon = weaponClass.new(player, limiter)

	local success = slots:AddWeapon(weapon)

	if success then
		updateClient(player,slots)
	end

end

-------------------------------------------------
-- PLAYER CONNECTION
-------------------------------------------------

Players.PlayerAdded:Connect(function(player)

	player.CharacterAdded:Connect(function()

		task.defer(function()
			setupPlayer(player)
		end)

	end)

end)

Players.PlayerRemoving:Connect(function(player)

	clearPlayer(player)

end)

-------------------------------------------------
-- MAIN WEAPON LOOP
-------------------------------------------------

RunService.Heartbeat:Connect(function(dt)

	if GamePaused.Value then return end
	if not _G.GameStarted then return end

	for player,slots in pairs(playerSlots) do

		if not player or not player.Parent then
			playerSlots[player] = nil
			continue
		end

		local slot = slots.Weapons[1]

		if slot then

			local weapon = slot.Instance

			if weapon then

				weapon:Tick(dt)
				weapon:TryAttack()

			end

		end

	end

end)

-------------------------------------------------
-- UPGRADE WEAPON
-------------------------------------------------

function WeaponController:GiveWeapon(player,weaponName,rarity)

	local slots = playerSlots[player]

	if not slots then return false end

	local slot = slots.Weapons[1]

	if not slot then return false end

	local rarityLevels = {

		Bronze = 1,
		Silver = 2,
		Gold = 3,
		Diamond = 5

	}

	local levelIncrease = rarityLevels[rarity] or 1

	slot.Level += levelIncrease

	local weapon = slot.Instance

	if weapon and weapon.OnUpgrade then

		weapon:OnUpgrade(slot.Level)

	end

	updateClient(player,slots)

	return true

end

-------------------------------------------------
-- UPGRADE WEAPON LEVEL (CHEST)
-------------------------------------------------

function WeaponController:UpgradeWeapon(player)

	local slots = playerSlots[player]
	if not slots then return end

	local slot = slots.Weapons[1]
	if not slot then return end

	local weapon = slot.Instance
	if not weapon then return end

	slot.Level += 1

	if weapon.OnUpgrade then
		weapon:OnUpgrade(slot.Level)
	end

	updateClient(player, slots)

	print("⚔ Weapon upgraded →", slot.Name, "Level:", slot.Level)

end

-------------------------------------------------
-- GET CURRENT WEAPON
-------------------------------------------------

GetCurrentWeapons.OnServerInvoke = function(player)

	local slots = playerSlots[player]

	if not slots then return {} end

	local slot = slots.Weapons[1]

	if not slot then return {} end

	return {
		{
			Name = slot.Name,
			Level = slot.Level
		}
	}

end

-------------------------------------------------

print("⚔ WeaponController (Single Weapon System Loaded)")

_G.WeaponController = WeaponController

return WeaponController