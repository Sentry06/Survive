local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CatalogRegistry = {}

CatalogRegistry.Categories = {

	Attributes = {
		Registry = require(ReplicatedStorage.Shared.AttributeCardRegistry),
		AspectRatio = 9/16
	},

	Weapons = {
		Registry = require(ReplicatedStorage.Shared.WeaponRegistry),
		AspectRatio = 1
	},

	Artifacts = {
		Registry = nil,
		AspectRatio = 1
	},

	Synergies = {
		Registry = require(ReplicatedStorage.Shared.SynergyRegistry),
		AspectRatio = 1
	},

	Enemies = {
		Registry = nil,
		AspectRatio = 1
	},

	Characters = {
		Registry = nil,
		AspectRatio = 1
	},

	Maps = {
		Registry = nil,
		AspectRatio = 16/9
	}

}

return CatalogRegistry