-- WeaponEffectService.lua
-- Efeitos visuais avançados baseados no artefato ativo

local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

local ArtifactService = require(
	game.ServerScriptService.Artifacts:WaitForChild("ArtifactService")
)

local WeaponEffectService = {}

--------------------------------------------------
-- UTIL
--------------------------------------------------

local function attachParticles(part, config)

	local emitter = Instance.new("ParticleEmitter")
	emitter.Texture = config.Texture or "rbxasset://textures/particles/sparkles_main.dds"
	emitter.Color = ColorSequence.new(config.Color)
	emitter.LightEmission = config.LightEmission or 1
	emitter.Size = config.Size or NumberSequence.new(0.6)
	emitter.Lifetime = config.Lifetime or NumberRange.new(0.4)
	emitter.Rate = config.Rate or 40
	emitter.Speed = config.Speed or NumberRange.new(0)
	emitter.Parent = part

	return emitter
end

--------------------------------------------------
-- AURA CONTÍNUA NA ARMA
--------------------------------------------------

function WeaponEffectService:ApplyWeaponAura(player, model)

	local artifact = ArtifactService:Get(player)
	if not artifact then return end
	if not model or not model.Parent then return end

	local root

	if model:IsA("Model") then
		root = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
	elseif model:IsA("BasePart") then
		root = model
	end

	if not root then return end

	local id = artifact.Id

	--------------------------------------------------
	-- 🔥 IGNIS
	--------------------------------------------------
	if id == "Ignis" then

		attachParticles(root,{
			Color = Color3.fromRGB(255,100,0),
			Texture = "rbxasset://textures/particles/fire_main.dds",
			Size = NumberSequence.new(0.8),
			Rate = 60,
			Lifetime = NumberRange.new(0.5),
			Speed = NumberRange.new(0,1)
		})

		--------------------------------------------------
		-- ❄️ CONGELO
		--------------------------------------------------
	elseif id == "Congelo" then

		attachParticles(root,{
			Color = Color3.fromRGB(150,220,255),
			Texture = "rbxasset://textures/particles/sparkles_main.dds",
			Size = NumberSequence.new(0.4),
			Rate = 30,
			Lifetime = NumberRange.new(0.8)
		})

		--------------------------------------------------
		-- ⚡ FLUXUS
		--------------------------------------------------
	elseif id == "FluxusEletricus" then

		attachParticles(root,{
			Color = Color3.fromRGB(100,200,255),
			Texture = "rbxasset://textures/particles/sparkles_main.dds",
			Size = NumberSequence.new(0.5),
			Rate = 90,
			Lifetime = NumberRange.new(0.2),
			Speed = NumberRange.new(0,2)
		})

		--------------------------------------------------
		-- 💥 FRAGOR
		--------------------------------------------------
	elseif id == "Fragor" then

		attachParticles(root,{
			Color = Color3.fromRGB(255,200,0),
			Texture = "rbxasset://textures/particles/explosion_main.dds",
			Size = NumberSequence.new(0.7),
			Rate = 50,
			Lifetime = NumberRange.new(0.3)
		})

		--------------------------------------------------
		-- 🌀 GARGANTUA
		--------------------------------------------------
	elseif id == "Gargantua" then

		attachParticles(root,{
			Color = Color3.fromRGB(120,0,200),
			Texture = "rbxasset://textures/particles/sparkles_main.dds",
			Size = NumberSequence.new(0.6),
			Rate = 80,
			Lifetime = NumberRange.new(0.6)
		})

		--------------------------------------------------
		-- 🌌 NEBULA
		--------------------------------------------------
	elseif id == "Nebula" then

		attachParticles(root,{
			Color = Color3.fromRGB(180,0,255),
			Texture = "rbxasset://textures/particles/sparkles_main.dds",
			Size = NumberSequence.new(1),
			Rate = 70,
			Lifetime = NumberRange.new(0.7)
		})

		--------------------------------------------------
		-- 🩸 SANGUIS
		--------------------------------------------------
	elseif id == "Sanguis" then

		attachParticles(root,{
			Color = Color3.fromRGB(200,0,0),
			Texture = "rbxasset://textures/particles/smoke_main.dds",
			Size = NumberSequence.new(0.5),
			Rate = 40,
			Lifetime = NumberRange.new(0.5)
		})

		--------------------------------------------------
		-- 🪙 AURUM
		--------------------------------------------------
	elseif id == "Aurum" then

		attachParticles(root,{
			Color = Color3.fromRGB(255,215,0),
			Texture = "rbxassetid://80249759309977",
			Size = NumberSequence.new(0.6),
			Rate = 60,
			Lifetime = NumberRange.new(0.5)
		})

		--------------------------------------------------
		-- ⏳ TEMPUS STANS
		--------------------------------------------------
	elseif id == "TempusStans" then

		attachParticles(root,{
			Color = Color3.fromRGB(180,220,255),
			Texture = "rbxasset://textures/particles/sparkles_main.dds",
			Size = NumberSequence.new(0.5),
			Rate = 35,
			Lifetime = NumberRange.new(0.8)
		})
	end
end

--------------------------------------------------
-- IMPACTO TEMÁTICO
--------------------------------------------------

function WeaponEffectService:ApplyOnHit(player, enemyData)

	local artifact = ArtifactService:Get(player)
	if not artifact then return end
	if not enemyData or not enemyData.Root then return end

	local pos = enemyData.Root.Position
	local id = artifact.Id

	local sphere = Instance.new("Part")
	sphere.Shape = Enum.PartType.Ball
	sphere.Anchored = true
	sphere.CanCollide = false
	sphere.Material = Enum.Material.Neon
	sphere.Size = Vector3.new(1,1,1)
	sphere.CFrame = CFrame.new(pos)
	sphere.Parent = workspace

	if id == "Ignis" then
		sphere.Color = Color3.fromRGB(255,80,0)
	elseif id == "Congelo" then
		sphere.Color = Color3.fromRGB(150,220,255)
	elseif id == "FluxusEletricus" then
		sphere.Color = Color3.fromRGB(100,200,255)
	elseif id == "Fragor" then
		sphere.Color = Color3.fromRGB(255,200,0)
	elseif id == "Gargantua" then
		sphere.Color = Color3.fromRGB(120,0,200)
	elseif id == "Nebula" then
		sphere.Color = Color3.fromRGB(180,0,255)
	elseif id == "Sanguis" then
		sphere.Color = Color3.fromRGB(200,0,0)
	elseif id == "Aurum" then
		sphere.Color = Color3.fromRGB(255,215,0)
	elseif id == "TempusStans" then
		sphere.Color = Color3.fromRGB(180,220,255)
	end

	TweenService:Create(
		sphere,
		TweenInfo.new(0.25),
		{
			Size = Vector3.new(6,6,6),
			Transparency = 1
		}
	):Play()

	Debris:AddItem(sphere,0.3)
end

return WeaponEffectService
