local ReplicatedStorage = game:GetService("ReplicatedStorage")

local WeaponRegistry = require(
	ReplicatedStorage.Shared:WaitForChild("WeaponRegistry")
)

local PurchaseWeapon =
	ReplicatedStorage.Remotes:WaitForChild("PurchaseWeapon")

-------------------------------------------------
-- PREÇOS TEMPORÁRIOS
-------------------------------------------------

local PRICES = {
	BolaFutebol = 500,
	Chinelo = 500,
	Pancadao = 1200,
	TungTungTungSahurBat = 1200,
	Bricks = 600,
	Boomerang = 800,
	Molotov = 1200,
	CardDealer = 2000,
	SCPNecromancer = 3000,
}

-------------------------------------------------
-- COMPRA
-------------------------------------------------

PurchaseWeapon.OnServerInvoke = function(player, weaponId)

	local price = PRICES[weaponId]
	if not price then
		return false, "Invalid weapon"
	end

	local global = player:FindFirstChild("GlobalStats")
	if not global then return false end

	local gold = global:FindFirstChild("Gold")
	local unlocked = global:FindFirstChild("UnlockedWeapons")

	if not gold or not unlocked then return false end

	-- já possui?
	if unlocked:FindFirstChild(weaponId) then
		return false, "Already unlocked"
	end

	-- ouro suficiente?
	if gold.Value < price then
		return false, "Not enough gold"
	end

	-------------------------------------------------
	-- COMPRA
	-------------------------------------------------

	gold.Value -= price

	local flag = Instance.new("BoolValue")
	flag.Name = weaponId
	flag.Value = true
	flag.Parent = unlocked

	print(player.Name.." desbloqueou arma "..weaponId)

	return true
end