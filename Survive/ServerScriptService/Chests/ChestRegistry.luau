local ChestRegistry = {}

ChestRegistry.Definitions = {
	Bronze = {
		GoldMin = 10,
		GoldMax = 20,
		AttributeCount = 1,
		WeaponChance = 1,
		UpgradeMultiplier = 1.02, -- +2%
	},

	Silver = {
		GoldMin = 20,
		GoldMax = 35,
		AttributeCount = 2,
		WeaponChance = 1,
		UpgradeMultiplier = 1.05, -- +5%
	},

	Gold = {
		GoldMin = 40,
		GoldMax = 60,
		AttributeCount = 3,
		WeaponChance = 1,
		UpgradeMultiplier = 1.10, -- +10%
	},

	Diamond = {
		GoldMin = 70,
		GoldMax = 100,
		AttributeCount = 4,
		WeaponChance = 1,
		UpgradeMultiplier = 1.25, -- +25%
	}
}

function ChestRegistry:Get(rarity)
	return self.Definitions[rarity]
end

return ChestRegistry
