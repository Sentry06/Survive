local WeaponRegistry = {}

WeaponRegistry.Definitions = {

	Knife = {
		Id = "Knife",
		DisplayName = "Knife",
		Rarity = "Uncommon",
		Price = 0,

		Image = "rbxassetid://74628167448561",

		Description = "A regular knife. That's all (It's strong).",

		BaseStats = {
			Damage = 20,
			Cooldown = 1.3,
			Range = 16,
			ProjectileSpeed = 22,
			AttackSize = 1,
			ProjectilePierce = 0,
			AreaDamage = 0
		},

		UpgradeableStats = {
			"Damage",
			"Cooldown"
		},

		Scaling = {
			Damage = 1.10,
			Cooldown = 0.94
		}
	},


	BolaFutebol = {
		Id = "BolaFutebol",
		DisplayName = "Football",
		Rarity = "Common",
		Price = 500,

		Image = "rbxassetid://100241031910897",

		Description = "Kick powerful shots to score goals (or defeat your enemies).",

		BaseStats = {
			Damage = 8,
			Cooldown = 0.8,
			Range = 22,
			ProjectileSpeed = 55,
			AttackSize = 1,
			ProjectilePierce = 0,
			AreaDamage = 0
		},

		UpgradeableStats = {
			"Damage",
			"ProjectileSpeed"
		},

		Scaling = {
			Damage = 1.08,
			ProjectileSpeed = 1.05
		}
	},


	Chinelo = {
		Id = "Chinelo",
		DisplayName = "Chinelo",
		Rarity = "Common",
		Price = 500,

		Image = "rbxassetid://96137138854827",

		Description = "A powerful flip-flop with an aim just like your mom's.",

		BaseStats = {
			Damage = 40,
			Cooldown = 2.2,
			Range = 11,
			ProjectileSpeed = 18,
			AttackSize = 1,
			ProjectilePierce = 0,
			AreaDamage = 0
		},

		UpgradeableStats = {
			"Damage",
			"Range"
		},

		Scaling = {
			Damage = 1.15,
			Range = 1.05
		}
	},

	Pancadao = {

		Id = "Pancadao",
		DisplayName = "Pancadão",
		Rarity = "Rare",
		Price = 1200,

		Image = "rbxassetid://117203398756190",

		Description = "Massive sound waves that control the battlefield.",

		BaseStats = {
			Damage = 18,
			Cooldown = 2.2,
			Range = 12,
			ProjectileSpeed = 30,
			AttackSize = 1,
			ProjectilePierce = 0,
			AreaDamage = 0
		},

		UpgradeableStats = {
			"Damage",
			"Cooldown"
		},

		Scaling = {
			Damage = 1.12,
			Cooldown = 0.94
		}
	},

	TungTungTungSahurBat = {
		Id = "TungTungTungSahurBat",
		DisplayName = "Tung Tung Tung Sahur Bat",
		Rarity = "Rare",
		Price = 1200,

		Image = "rbxassetid://111819566271953",

		Description = "The legendary Tung Tung Tung Sahur bat.",

		BaseStats = {
			Damage = 30,
			Cooldown = 1.9,
			Range = 10,
			ProjectileSpeed = 1,
			AttackSize = 3,
			ProjectilePierce = 0,
			AreaDamage = 0
		},

		UpgradeableStats = {
			"Damage",
			"Cooldown"
		},

		Scaling = {
			Damage = 1.18,
			Cooldown = 0.95
		}
	},

	Bricks = {
		Id = "Bricks",
		DisplayName = "Bricks",
		Rarity = "Common",
		Price = 600,

		Image = "rbxassetid://123013239158545",

		Description = "Throws classic Roblox bricks that smash enemies.",

		BaseStats = {
			Damage = 28,
			Cooldown = 1.6,
			Range = 18,
			ProjectileSpeed = 26,
			AttackSize = 1,
			ProjectilePierce = 1,
			AreaDamage = 0.15
		},

		UpgradeableStats = {
			"Damage",
			"Cooldown"
		},

		Scaling = {
			Damage = 1.12,
			Cooldown = 0.94
		}

	},

	Boomerang = {
		Id = "Boomerang",
		DisplayName = "Boomerang",
		Rarity = "Uncommon",
		Price = 800,

		Image = "rbxassetid://104902964368794",

		Description = "A flying blade that returns to its owner.",

		BaseStats = {
			Damage = 16,
			Cooldown = 1.2,
			Range = 14,
			ProjectileSpeed = 24,
			AttackSize = 1,
			ProjectilePierce = 0,
			AreaDamage = 0
		},

		UpgradeableStats = {
			"ProjectileSpeed",
			"Range"
		},

		Scaling = {
			ProjectileSpeed = 1.10,
			Range = 1.10
		}
	},

	Molotov = {
		Id = "Molotov",
		DisplayName = "Molotov",
		Rarity = "Rare",
		Price = 1200,

		Image = "rbxassetid://139459687738436",

		Description = "Breaks on impact creating a burning area.",

		BaseStats = {
			Damage = 25,
			Cooldown = 4,
			Range = 16,
			ProjectileSpeed = 20,
			AttackSize = 1.2,
			ProjectilePierce = 0,
			AreaDamage = 2
		},

		UpgradeableStats = {
			"AttackSize",
			"AreaDamage"
		},

		Scaling = {
			AttackSize = 1.2,
			AreaDamage = 1.15,
		}
	},

	CardDealer = {

		Id = "CardDealer",
		DisplayName = "Card Dealer",
		Rarity = "Epic",
		Price = 2000,

		Image = "rbxassetid://77775009622684",

		Description = "Throws magical cards that empower the player.",

		BaseStats = {
			Damage = 14,
			Cooldown = 2,
			Range = 18,
			ProjectileSpeed = 30,
			AttackSize = 1,
			ProjectilePierce = 0,
			AreaDamage = 0
		},

		UpgradeableStats = {
			"Damage",
			"Cooldown"
		},

		CardEffects = {

			Ace = "Damage x2",
			King = "Attack Size x2",
			Queen = "Range x2",
			Jack = "Projectile Speed x2",
			Joker = "Multi Attack +2"

		},

		Scaling = {
			Damage = 1.12,
			Cooldown = 0.95
		}

	},

	SCPNecromancer = {

		Id = "SCPNecromancer",
		DisplayName = "Anomalous Summoning Artifact",
		Rarity = "Legendary",
		Price = 3000,

		Image = "rbxassetid://83634313620083",

		Description = [[
         Item Classification: ███████
        Item Clearance Required: LEVEL 4

        Special Containment Notice:

        The anomalous weapon system designated "SCP Necromancer" is capable of summoning hostile entities originating from ████████████.

         Entities appear to obey the wielder and pursue nearby targets until termination.

        Due to the unstable nature of the anomaly, some details remain partially classified.

        Known Manifestations:

         • SCP-049
         • SCP-173
         • SCP-3008
         • SCP-096
         • SCP-087
         • SCP-093
         • SCP-106
         • ███████

         Additional subjects remain ███████████████.

         WARNING:
         Use of this weapon may result in ██████████████████████.

         Foundation authorization required.
         ]],

		BaseStats = {
			Damage = 22,
			Cooldown = 5,
			Range = 20,
			ProjectileSpeed = 1,
			AttackSize = 1,
			ProjectilePierce = 0,
			AreaDamage = 0
		},

		UpgradeableStats = {
			"Damage",
			"Cooldown"
		},

		Scaling = {
			Damage = 1.12,
			Cooldown = 0.95
		}

	},

}

function WeaponRegistry:GetRandomWeaponId(player)

	local list = {}

	for id,_ in pairs(self.Definitions) do
		table.insert(list,id)
	end

	return list[math.random(1,#list)]

end


function WeaponRegistry:GetAll()

	return self.Definitions

end

return WeaponRegistry