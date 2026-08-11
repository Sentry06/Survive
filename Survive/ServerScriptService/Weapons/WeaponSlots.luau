	-- WeaponSlots.lua
	-- Controla armas da RUN (limite, banimento e evolução)

	local WeaponSlots = {}
	WeaponSlots.__index = WeaponSlots

	-- =====================
	-- CONSTRUTOR
	-- =====================
	function WeaponSlots.new(maxSlots)
		local self = setmetatable({}, WeaponSlots)

		self.MaxSlots = 1
		self.Weapons = {}             -- { {Name, Level, Instance} }
		self.BannedWeapons = {}       -- [weaponName] = true

		return self
	end

	-- =====================
	-- CONSULTAS
	-- =====================
	function WeaponSlots:IsWeaponEquipped(name)
		for _, slot in ipairs(self.Weapons) do
			if slot.Name == name then
				return true
			end
		end
		return false
	end

	function WeaponSlots:GetWeapon(name)
		for _, slot in ipairs(self.Weapons) do
			if slot.Name == name then
				return slot
			end
		end
		return nil
	end

	function WeaponSlots:IsWeaponBanned(name)
		return self.BannedWeapons[name] == true
	end

	function WeaponSlots:HasFreeSlot()
		return #self.Weapons < self.MaxSlots
	end

	-- =====================
	-- REGRAS DE ADIÇÃO
	-- =====================
	function WeaponSlots:CanAddWeapon(name)

		if self:IsWeaponEquipped(name) then
			return false, "already_equipped"
		end

		if self:IsWeaponBanned(name) then
			return false, "weapon_banned"
		end

		if not self:HasFreeSlot() then
			return false, "no_free_slot"
		end

		return true
	end

	-- =====================
	-- ADIÇÃO DE ARMA
	-- =====================
	function WeaponSlots:AddWeapon(weapon)

		local canAdd, reason = self:CanAddWeapon(weapon.Name)
		if not canAdd then
			return false, reason
		end

		local slotData = {
			Name = weapon.Name,
			Level = 1,
			Instance = weapon
		}

		table.insert(self.Weapons, slotData)

		return true
	end

	-- =====================
	-- EVOLUÇÃO DE ARMA
	-- =====================
	function WeaponSlots:UpgradeWeapon(name)

		local slot = self:GetWeapon(name)
		if not slot then
			return false, "not_equipped"
		end

		slot.Level += 1

		if slot.Instance and slot.Instance.OnUpgrade then
			slot.Instance:OnUpgrade(slot.Level)
		end

		return true
	end

	-- =====================
	-- BANIMENTO (UPGRADE FUTURO)
	-- =====================
	function WeaponSlots:BanWeapon(name)
		self.BannedWeapons[name] = true
	end

	return WeaponSlots
