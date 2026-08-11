local ReplicatedStorage = game:GetService("ReplicatedStorage")

local WeaponRegistry = require(
	ReplicatedStorage.Shared:WaitForChild("WeaponRegistry")
)

local ModifierUnlockService = {}

function ModifierUnlockService:UnlockFromWeapon(player)

	local global = player:FindFirstChild("GlobalStats")
	if not global then return end

	local selectedWeapon = global:FindFirstChild("SelectedWeapon")
	if not selectedWeapon then return end

	local weaponId = selectedWeapon.Value

	local weaponDef = WeaponRegistry.Definitions[weaponId]
	if not weaponDef then return end

	local modifierId = weaponDef.Modifier
	if not modifierId then return end

	local folder = global:FindFirstChild("UnlockedModifiers")
	if not folder then return end

	local flag = folder:FindFirstChild(modifierId)

	if flag then
		flag.Value = true
	end

	print("🔓 Modifier desbloqueado:", modifierId)

end

return ModifierUnlockService