local AttributeRegistry = {}

AttributeRegistry.Definitions = {

	Damage = {
		Type="Multiplier",
		DisplayName="Damage"
	},

	Range = {
		Type="Multiplier",
		DisplayName="Range"
	},

	ProjectileSpeed = {
		Type="Multiplier",
		DisplayName="Projectile Speed"
	},

	AttackSize = {
		Type="Multiplier",
		DisplayName="Attack Size"
	},

	MovementSpeed = {
		Type="Multiplier",
		DisplayName="Movement Speed"
	},

	MaxHP = {
		Type="Multiplier",
		DisplayName="Max HP"
	},

	Cooldown = {
		Type="InverseMultiplier",
		DisplayName="Attack Speed"
	},

	ShieldRegenDelay = {
		Type="InverseMultiplier",
		DisplayName="Shield Regen Speed"
	},

	MultiAttack = {
		Type="Additive",
		DisplayName="Multi Attack"
	},

	ProjectilePierce = {
		Type="Additive",
		DisplayName="Projectile Pierce"
	},

	AreaDamage = {
		Type="Additive",
		DisplayName="Area Damage"
	},

	LifeRegen = {
		Type="Additive",
		DisplayName="Life Regen"
	},

	Shield = {
		Type="Additive",
		DisplayName="Shield"
	},

	Luck = {
		Type="Additive",
		DisplayName="Luck"
	}

}

function AttributeRegistry:Get(id)
	return self.Definitions[id]
end

return AttributeRegistry