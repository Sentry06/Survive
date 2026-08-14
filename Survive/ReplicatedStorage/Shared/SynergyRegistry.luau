local SynergyRegistry = {}

SynergyRegistry.Definitions = {

	-------------------------------------------------
	-- 🔥 TIER 1 — FUNDAMENTAIS
	-------------------------------------------------

	IgniferAeternum = {
		Id = "IgniferAeternum",
		DisplayName = "Ignifer Aeternum",
		Description = "The fire never goes out.",
		Image = "rbxassetid://91162558778149",
		Tier = 1,
		MaxLevel = 5,
		Requires = { Damage = 10, Cooldown = 10 },
		BonusId = "BONUS_IGNIFER_AETERNUM",
		Bonuses = {
			Damage = 0.15,
			Cooldown = -0.08
		},
	},

	MareVastum = {
		Id = "MareVastum",
		DisplayName = "Mare Vastum",
		Description = "The power spreads like the ocean.",
		Image = "rbxassetid://121249455201424",
		Tier = 1,
		MaxLevel = 5,
		Requires = { Range = 10, AreaDamage = 10 },
		BonusId = "BONUS_MARE_VASTUM",
		Bonuses = {
			Range = 0.15,
			AreaDamage = 0.10
		},

	},

	AstrumPenetratio = {
		Id = "AstrumPenetratio",
		DisplayName = "Astrum Penetratio",
		Description = "Stars pass through everything.",
		Image = "rbxassetid://72370251149507",
		Tier = 1,
		MaxLevel = 5,
		Requires = { ProjectilePierce = 10, Damage = 10 },
		BonusId = "BONUS_ASTRUM_PENETRATIO",
		Bonuses = {
			ProjectilePierce = 3,
			Damage = 0.15
		},
	},

	CeleritasDivina = {
		Id = "CeleritasDivina",
		DisplayName = "Celeritas Divina",
		Description = "Speed ​​beyond mortals.",
		Image = "rbxassetid://122567577156539",
		Tier = 1,
		MaxLevel = 5,
		Requires = { MovementSpeed = 10, MultiAttack = 10 },
		BonusId = "BONUS_CELERITAS_DIVINA",
		Bonuses = {
			MovementSpeed = 0.10,
			MultiAttack = 1
		},
	},

	UmbraVitalis = {
		Id = "UmbraVitalis",
		DisplayName = "Umbra Vitalis",
		Description = "The moon's shadow sustains life.",
		Image = "rbxassetid://111257649502134",
		Tier = 1,
		MaxLevel = 5,
		Requires = { LifeRegen = 10, MaxHP = 10 },
		BonusId = "BONUS_UMBRA_VITALIS",
		Bonuses = {
			MaxHP = 0.50,
			LifeRegen = 2
		},

	},

	AegisPerpetua = {
		Id = "AegisPerpetua",
		DisplayName = "Aegis Perpetua",
		Description = "Eternal defense.",
		Image = "rbxassetid://120780219447290",
		Tier = 1,
		MaxLevel = 5,
		Requires = { Shield = 10, ShieldRegenDelay = 10 },
		BonusId = "BONUS_AEGIS_PERPETUA",
		Bonuses = {
			Shield = 25,
			ShieldRegenDelay = -0.15
		},
	},

	FortunaMajor = {
		Id = "FortunaMajor",
		DisplayName = "Fortuna Major",
		Description = "Fortune favors the bold.",
		Image = "rbxassetid://139435688193283",
		Tier = 1,
		MaxLevel = 5,
		Requires = { Luck = 10, MultiAttack = 10 },
		BonusId = "BONUS_FORTUNA_MAJOR",
		Bonuses = {
			Luck = 0.20,
			MultiAttack = 5
		},
	},

	MagnusOrbis = {
		Id = "MagnusOrbis",
		DisplayName = "Magnus Orbis",
		Description = "The world grows under your dominion.",
		Image = "rbxassetid://104011568230413",
		Tier = 1,
		MaxLevel = 5,
		Requires = { AttackSize = 10, AreaDamage = 10 },
		BonusId = "BONUS_MAGNUS_ORBIS",
		Bonuses = {
			AttackSize = 0.20,
			AreaDamage = 0.20
		},
	},

	VelocitasAstra = {
		Id = "VelocitasAstra",
		DisplayName = "Velocitas Astra",
		Description = "Projectiles like comets.",
		Image = "rbxassetid://83538128972591",
		Tier = 1,
		MaxLevel = 5,
		Requires = { ProjectileSpeed = 10, Range = 10 },
		BonusId = "BONUS_VELOCITAS_ASTRA",
		Bonuses = {
			ProjectileSpeed = 0.25,
			Range = 0.25
		},
	},

	TempusDominus = {
		Id = "TempusDominus",
		DisplayName = "Tempus Dominus",
		Description = "Time bends before you.",
		Image = "rbxassetid://138047786154989",
		Tier = 1,
		MaxLevel = 5,
		Requires = { Cooldown = 10, MovementSpeed = 10 },
		BonusId = "BONUS_TEMPUS_DOMINUS",
		Bonuses = {
			Cooldown = -0.08,
			MovementSpeed = 0.15
		},

	},

	-------------------------------------------------
	-- 🌌 TIER 2 — AVANÇADAS
	-------------------------------------------------

	Cataclysmus = {
		Id = "Cataclysmus",
		DisplayName = "Cataclysmus",
		Description = "Large-scale destruction.",
		Image = "rbxassetid://94437819645815",
		Tier = 2,
		MaxLevel = 3,
		Requires = { Damage = 15, AreaDamage = 15, AttackSize = 15 },
		BonusId = "BONUS_CATACLYSMUS",
		Bonuses = {
			Damage = 0.50,
			AreaDamage = 0.50,
			AttackSize = 0.20
		},

	},

	Hypernova = {
		Id = "Hypernova",
		DisplayName = "Hypernova",
		Description = "Unstoppable stellar explosion.",
		Image = "rbxassetid://91743565909880",
		Tier = 2,
		MaxLevel = 3,
		Requires = { ProjectileSpeed = 15, ProjectilePierce = 15, Damage = 15 },
		BonusId = "BONUS_HYPERNOVA",
		Bonuses = {
			ProjectileSpeed = 0.70,
			ProjectilePierce = 3,
			Damage = 0.60
		},
	},

	Eternitas = {
		Id = "Eternitas",
		DisplayName = "Eternitas",
		Description = "Perhaps there's life after end, but the end takes a long time.",
		Image = "rbxassetid://122610702111966",
		Tier = 2,
		MaxLevel = 3,
		Requires = { LifeRegen = 15, Shield = 15, MaxHP = 15 },
		BonusId = "BONUS_ETERNITAS",
		Bonuses = {
			MaxHP = 0.50,
			Shield = 60,
			LifeRegen = 7
		},
	},

	ChaosFortuna = {
		Id = "ChaosFortuna",
		DisplayName = "Chaos Fortuna",
		Description = "Power driven by randomness.",
		Image = "rbxassetid://122280237655941",
		Tier = 2,
		MaxLevel = 3,
		Requires = { Luck = 15, AreaDamage = 15, MultiAttack = 15 },
		BonusId = "BONUS_CHAOS_FORTUNA",
		Bonuses = {
			Luck = 0.80,
			AreaDamage = 0.60,
			MultiAttack = 4
		},
	},

	Tempestas = {
		Id = "Tempestas",
		DisplayName = "Tempestas",
		Description = "The storm incarnate.",
		Image = "rbxassetid://137043402336734",
		Tier = 2,
		MaxLevel = 3,
		Requires = { MovementSpeed = 15, AttackSize = 15, ProjectileSpeed = 15 },
		BonusId = "BONUS_TEMPESTAS",
		Bonuses = {
			MovementSpeed = 0.50,
			ProjectileSpeed = 0.70,
			AttackSize = 0.30
		},
	},

	-------------------------------------------------
	-- 🌑 TIER 3 — SUPREMAS
	-------------------------------------------------

	DeusExMachina = {
		Id = "DeusExMachina",
		DisplayName = "Deus Ex Machina",
		Description = "The divine machine of destruction.",
		Image = "rbxassetid://107824477052710",
		Tier = 3,
		MaxLevel = 2,
		Requires = { Damage = 20, Cooldown = 20, ProjectilePierce = 20 },
		BonusId = "BONUS_DEUS_EX_MACHINA",
		Bonuses = {
			Damage = 1.50,
			Cooldown = -0.05,
			ProjectilePierce = 5
		},
	},

	Singularitas = {
		Id = "Singularitas",
		DisplayName = "Singularitas",
		Description = "Everything converges to one point.",
		Image = "rbxassetid://119126001389903",
		Tier = 3,
		MaxLevel = 2,
		Requires = { Range = 20, AttackSize = 20, AreaDamage = 20 },
		BonusId = "BONUS_SINGULARITAS",
		Bonuses = {
			Range = 1.50,
			AreaDamage = 1.20,
			AttackSize = 0.60
		},
	},

	ApexPredator = {
		Id = "ApexPredator",
		DisplayName = "Apex Predator",
		Description = "The ultimate hunter.",
		Image = "rbxassetid://75343799119861",
		Tier = 3,
		MaxLevel = 2,
		Requires = { MovementSpeed = 20, Damage = 20, MultiAttack = 20 },
		BonusId = "BONUS_APEX_PREDATOR",
		Bonuses = {
			Damage = 1.80,
			MovementSpeed = 1.00,
			MultiAttack = 10
		},
	},

	Immortalis = {
		Id = "Immortalis",
		DisplayName = "Immortalis",
		Description = "Immortal as long as there is battle.",
		Image = "rbxassetid://93132827162502",
		Tier = 3,
		MaxLevel = 2,
		Requires = { LifeRegen = 20, Shield = 20, ShieldRegenDelay = 20 },
		BonusId = "BONUS_IMMORTALIS",
		Bonuses = {
			LifeRegen = 15,
			ShieldRegenDelay = -0.05,
			Shield = 80
		},
	},

	CosmosAbsolutum = {
		Id = "CosmosAbsolutum",
		DisplayName = "Cosmos Absolutum",
		Description = "The absolute power of the universe.",
		Image = "rbxassetid://117699671545548",
		Tier = 3,
		MaxLevel = 2,
		Requires = { Damage = 20, AreaDamage = 20, ProjectilePierce = 20, AttackSize = 20 },
		BonusId = "BONUS_COSMOS_ABSOLUTUM",
		Bonuses = {
			Damage = 2.00,
			AreaDamage = 2.00,
			ProjectilePierce = 12,
			AttackSize = 2.00
		},
	},
}

return SynergyRegistry	