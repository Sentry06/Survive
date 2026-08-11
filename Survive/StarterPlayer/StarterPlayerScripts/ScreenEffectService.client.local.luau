print("ScreenEffectService iniciado (Balanced)")

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera


local remote = ReplicatedStorage:WaitForChild("Remotes")
	:WaitForChild("ArtifactScreenEffect")

--------------------------------------------------
-- BASE EFFECTS
--------------------------------------------------

local blur = Instance.new("BlurEffect")
blur.Size = 0
blur.Parent = Lighting

local color = Instance.new("ColorCorrectionEffect")
color.Parent = Lighting

local bloom = Instance.new("BloomEffect")
bloom.Intensity = 0
bloom.Size = 24
bloom.Threshold = 1
bloom.Parent = Lighting

local gargantuaSky = nil
local originalSky = nil
local gargantuaEmitter = nil
local gargantuaAttachment = nil
local lensFrame = nil
local lensGradient = nil

local snowPart = nil
local snowEmitter = nil

local lightningFolder = nil
local lightningConnection = nil
local lightningFlashConnection = nil
local lightningActive = false
local lightningTask = nil
local electricLight = nil
local lightningSound
local thunderSound
local deepThunder

local sanguisEmitter = nil
local sanguisAttachment = nil
local sanguisLight = nil
local sanguisFogPart = nil
local sanguisFogEmitter = nil
local sanguisDrainFolder = nil
local heartbeatSound = nil
local sanguisDamageConnections = {}

local nebulaAttachment = nil
local nebulaEmitter = nil
local nebulaRing = nil
local nebulaPulse = nil

local nebulaStarFolder = nil
local nebulaDistortionFrame = nil
local nebulaDistortionGradient = nil
local nebulaAmbientSound = nil

local congeloSound = nil
local ignisSound = nil
local aurumSound = nil
local gargantuaSound = nil

local tempusSound = nil
local tempusPulseFolder = nil
local tempusGhostFolder = nil
local tempusSpiralImage = nil

local fragorSound = nil
local fragorMeteorFolder = nil

--------------------------------------------------
-- OVERLAY
--------------------------------------------------

local gui = Instance.new("ScreenGui")
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.Name = "ScreenEffectOverlay"
gui.Parent = player:WaitForChild("PlayerGui")

local overlay = Instance.new("Frame")
overlay.Size = UDim2.fromScale(1,1)
overlay.BackgroundTransparency = 1
overlay.BackgroundColor3 = Color3.new(1,1,1)
overlay.Parent = gui

local gradient = Instance.new("UIGradient")
gradient.Parent = overlay

--------------------------------------------------
-- STATE
--------------------------------------------------

local activeConnection = nil
local active = false

--------------------------------------------------
-- AURUM PARTICLE SYSTEM (WORLD RAIN STYLE)
--------------------------------------------------

local aurumEmitter = nil
local aurumPart = nil

local function startAurumParticles()

	local character = player.Character
	if not character then return end

	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then return end

	-- Parte invisível acima do mapa
	aurumPart = Instance.new("Part")
	aurumPart.Anchored = true
	aurumPart.CanCollide = false
	aurumPart.Transparency = 1
	aurumPart.Size = Vector3.new(1,1,1)

	-- 25 studs acima do jogador
	aurumPart.Position = root.Position + Vector3.new(0, 25, 0)
	aurumPart.Parent = workspace

	aurumEmitter = Instance.new("ParticleEmitter")
	aurumEmitter.Texture = "rbxassetid://80249759309977"

	-- 🔽 Frequência mais lenta
	aurumEmitter.Rate = 10

	-- Vida longa para cair até o chão
	aurumEmitter.Lifetime = NumberRange.new(3, 4)

	-- Velocidade moderada
	aurumEmitter.Speed = NumberRange.new(10, 14)

	-- Espalhamento GRANDE (chuva ampla)
	aurumEmitter.SpreadAngle = Vector2.new(120, 120)

	-- Cai para baixo
	aurumEmitter.EmissionDirection = Enum.NormalId.Bottom

	-- Gravidade natural
	aurumEmitter.Acceleration = Vector3.new(0, -25, 0)

	aurumEmitter.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(1, 0.7)
	})

	aurumEmitter.Rotation = NumberRange.new(0,360)
	aurumEmitter.RotSpeed = NumberRange.new(-60,60)

	aurumEmitter.Parent = aurumPart

	-- Atualiza posição suavemente enquanto player se move
	RunService.RenderStepped:Connect(function()
		if aurumPart and root then
			aurumPart.Position = root.Position + Vector3.new(0, 25, 0)
		end
	end)
end

local function stopAurumParticles()

	if aurumEmitter then
		aurumEmitter:Destroy()
		aurumEmitter = nil
	end

	if aurumPart then
		aurumPart:Destroy()
		aurumPart = nil
	end
end

--------------------------------------------------
-- IGNIS PARTICLE SYSTEM
--------------------------------------------------

local ignisEmitter = nil
local ignisAttachment = nil

local function startIgnisParticles()

	local character = player.Character
	if not character then return end

	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then return end

	ignisAttachment = Instance.new("Attachment")
	ignisAttachment.Position = Vector3.new(0, 2, 0)
	ignisAttachment.Parent = root

	ignisEmitter = Instance.new("ParticleEmitter")
	ignisEmitter.Texture = "rbxasset://textures/particles/sparkles_main.dds"

	ignisEmitter.Rate = 18
	ignisEmitter.Lifetime = NumberRange.new(0.8, 1.2)
	ignisEmitter.Speed = NumberRange.new(2, 5)

	ignisEmitter.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255,170,0)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255,60,0))
	})

	ignisEmitter.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.4),
		NumberSequenceKeypoint.new(1, 0)
	})

	ignisEmitter.SpreadAngle = Vector2.new(25,25)
	ignisEmitter.Acceleration = Vector3.new(0, 4, 0)

	ignisEmitter.Parent = ignisAttachment
end

local function stopIgnisParticles()

	if ignisEmitter then
		ignisEmitter:Destroy()
		ignisEmitter = nil
	end

	if ignisAttachment then
		ignisAttachment:Destroy()
		ignisAttachment = nil
	end
end

--------------------------------------------------
-- IGNIS EXTRA EFFECTS
--------------------------------------------------

local ignisLight = nil

--------------------------------------------------
-- RESET
--------------------------------------------------

local function resetEffects()

	active = false

	if activeConnection then
		activeConnection:Disconnect()
		activeConnection = nil
	end

	blur.Size = 0
	color.TintColor = Color3.new(1,1,1)
	color.Saturation = 0
	color.Contrast = 0
	color.Brightness = 0
	bloom.Intensity = 0

	overlay.BackgroundTransparency = 1
	gradient.Rotation = 0

	camera.FieldOfView = 70

	stopAurumParticles()
	stopIgnisParticles()
	if ignisLight then
		ignisLight:Destroy()
		ignisLight = nil
	end

	-- restaurar sky
	if gargantuaSky then
		gargantuaSky:Destroy()
		gargantuaSky = nil
	end

	if originalSky then
		originalSky.Parent = Lighting
		originalSky = nil
	end

	-- remover partículas
	if gargantuaEmitter then
		gargantuaEmitter:Destroy()
		gargantuaEmitter = nil
	end

	if gargantuaAttachment then
		gargantuaAttachment:Destroy()
		gargantuaAttachment = nil
	end

	-- remover lente
	if lensFrame then
		lensFrame:Destroy()
		lensFrame = nil
		lensGradient = nil
	end

	-- reset bloom
	bloom.Enabled = false
	bloom.Intensity = 0

	if snowEmitter then
		snowEmitter:Destroy()
		snowEmitter = nil
	end

	if snowPart then
		snowPart:Destroy()
		snowPart = nil
	end

	if lightningFolder then
		lightningFolder:Destroy()
		lightningFolder = nil
	end

	if lightningFlashConnection then
		lightningFlashConnection = nil
	end

	-- parar tempestade elétrica
	lightningActive = false

	if lightningSound then lightningSound:Stop() end
	if thunderSound then thunderSound:Stop() end
	if script:FindFirstChild("LightningSoundDeepThunder") then
		script.LightningSoundDeepThunder:Stop()
	end

	if electricLight then
		electricLight:Destroy()
		electricLight = nil
	end

	color.Brightness = 0
	bloom.Intensity = 0

	if sanguisEmitter then sanguisEmitter:Destroy() sanguisEmitter = nil end
	if sanguisAttachment then sanguisAttachment:Destroy() sanguisAttachment = nil end
	if sanguisLight then sanguisLight:Destroy() sanguisLight = nil end
	if sanguisFogEmitter then sanguisFogEmitter:Destroy() sanguisFogEmitter = nil end
	if sanguisFogPart then sanguisFogPart:Destroy() sanguisFogPart = nil end
	if sanguisDrainFolder then sanguisDrainFolder:Destroy() sanguisDrainFolder = nil end
	if heartbeatSound then heartbeatSound:Stop() heartbeatSound:Destroy() heartbeatSound = nil end
	
	for _, conn in ipairs(sanguisDamageConnections) do
		conn:Disconnect()
	end
	sanguisDamageConnections = {}
	
	if nebulaEmitter then nebulaEmitter:Destroy() nebulaEmitter = nil end
	if nebulaAttachment then nebulaAttachment:Destroy() nebulaAttachment = nil end
	if nebulaStarFolder then nebulaStarFolder:Destroy() nebulaStarFolder = nil end
	if nebulaDistortionFrame then nebulaDistortionFrame:Destroy() nebulaDistortionFrame = nil end
	if nebulaAmbientSound then nebulaAmbientSound:Stop() nebulaAmbientSound:Destroy() nebulaAmbientSound = nil end
	
	if congeloSound then
		congeloSound:Stop()
		congeloSound:Destroy()
		congeloSound = nil
	end

	if ignisSound then
		ignisSound:Stop()
		ignisSound:Destroy()
		ignisSound = nil
	end

	if aurumSound then
		aurumSound:Stop()
		aurumSound = nil
	end

	if gargantuaSound then
		gargantuaSound:Stop()
		gargantuaSound:Destroy()
		gargantuaSound = nil
	end
	
	if tempusSound then
		tempusSound:Stop()
		tempusSound:Destroy()
		tempusSound = nil
	end

	if tempusPulseFolder then
		tempusPulseFolder:Destroy()
		tempusPulseFolder = nil
	end

	if tempusGhostFolder then
		tempusGhostFolder:Destroy()
		tempusGhostFolder = nil
	end
	
	if tempusSpiralImage then
		tempusSpiralImage:Destroy()
		tempusSpiralImage = nil
	end

	if fragorSound then
		fragorSound:Stop()
		fragorSound:Destroy()
		fragorSound = nil
	end
	
	if fragorMeteorFolder then
		fragorMeteorFolder:Destroy()
		fragorMeteorFolder = nil
	end
	
end

--------------------------------------------------
-- EFFECTS
--------------------------------------------------

local function applyIgnis()

	color.TintColor = Color3.fromRGB(255,120,70)
	color.Contrast = 0.35
	color.Saturation = 0.25

	blur.Size = 4

	-- 🔥 Bloom cinematográfico
	bloom.Intensity = 1.2

	startIgnisParticles()

	activeConnection = RunService.RenderStepped:Connect(function(dt)
		if not active then return end

		local t = tick()

		-- Tremor suave orgânico
		local shakeX = math.sin(t*14) * 0.025
		local shakeY = math.cos(t*17) * 0.025
		camera.CFrame *= CFrame.new(shakeX, shakeY, 0)

		-- Pulsação de calor
		camera.FieldOfView = 70 + math.sin(t*2.5) * 1.5

		-- Distorção suave
		gradient.Rotation += dt * 15
	end)

	-- Heat distortion overlay
	overlay.BackgroundTransparency = 0.97
	overlay.BackgroundColor3 = Color3.fromRGB(255,120,60)

	gradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255,180,120)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255,90,40))
	}

	gradient.Transparency = NumberSequence.new{
		NumberSequenceKeypoint.new(0, 0.8),
		NumberSequenceKeypoint.new(1, 1)
	}

	activeConnection = RunService.RenderStepped:Connect(function(dt)
		if not active then return end

		gradient.Rotation += dt * 20

		-- Tremor suave
		local shakeX = math.sin(tick()*15) * 0.03
		local shakeY = math.cos(tick()*18) * 0.03

		camera.CFrame *= CFrame.new(shakeX, shakeY, 0)

		-- Leve pulsação de FOV
		camera.FieldOfView = 70 + math.sin(tick()*3) * 1.5
	end)
	
	--------------------------------------------------
	-- 🔥 Som de Fogo
	--------------------------------------------------

	local character = player.Character
	if character then
		local root = character:FindFirstChild("HumanoidRootPart")
		if root then
			ignisSound = Instance.new("Sound")
			ignisSound.SoundId = "rbxassetid://101541820780066" -- fogo ambiente
			ignisSound.Volume = 0.6
			ignisSound.Looped = true
			ignisSound.Parent = root
			ignisSound:Play()
		end
	end
end

-- ❄️ CONGELO SIMPLES E FORTE

local function applyCongelo()

	color.TintColor = Color3.fromRGB(180,220,255)
	color.Saturation = -0.35
	blur.Size = 3

	local character = player.Character
	if not character then return end

	local root = character:WaitForChild("HumanoidRootPart")

	--------------------------------------------------
	-- ❄️ NEVE GLOBAL CAINDO DO CÉU
	--------------------------------------------------

	snowPart = Instance.new("Part")
	snowPart.Anchored = true
	snowPart.CanCollide = false
	snowPart.CanQuery = false
	snowPart.CanTouch = false
	snowPart.Transparency = 1
	snowPart.Size = Vector3.new(600,1,600) -- área maior
	snowPart.Position = root.Position + Vector3.new(0, 80, 0)
	snowPart.Parent = workspace

	snowEmitter = Instance.new("ParticleEmitter")

	-- TEXTURA PADRÃO DO ROBLOX (100% FUNCIONA)
	snowEmitter.Texture = "rbxasset://textures/particles/sparkles_main.dds"

	snowEmitter.Rate = 300
	snowEmitter.Lifetime = NumberRange.new(5,6)

	-- IMPORTANTE
	snowEmitter.Speed = NumberRange.new(5,8)
	snowEmitter.EmissionDirection = Enum.NormalId.Bottom
	snowEmitter.SpreadAngle = Vector2.new(30,30)

	snowEmitter.Acceleration = Vector3.new(0,-20,0)

	snowEmitter.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 4),  -- começa maior
		NumberSequenceKeypoint.new(1, 3)   -- termina levemente menor
	})

	snowEmitter.Color = ColorSequence.new(Color3.new(1,1,1))

	snowEmitter.Parent = snowPart

	-- Atualiza posição para seguir o player
	activeConnection = RunService.RenderStepped:Connect(function()
		if snowPart and root then
			snowPart.Position = root.Position + Vector3.new(0, 80, 0)
		end
	end)
	
	--------------------------------------------------
	-- ❄️ Som de Nevasca
	--------------------------------------------------

	congeloSound = Instance.new("Sound")
	congeloSound.SoundId = "rbxassetid://4175285709" -- vento/nevasca (troque se quiser)
	congeloSound.Volume = 0.5
	congeloSound.Looped = true
	congeloSound.Parent = workspace
	congeloSound:Play()

end

local function spawnLightningStrike()

	local character = player.Character
	if not character then return end

	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then return end

	-- posição aleatória ao redor do player
	local radius = 120
	local randomOffset = Vector3.new(
		math.random(-radius, radius),
		0,
		math.random(-radius, radius)
	)

	local strikePosition = root.Position + randomOffset

	local beamPart = Instance.new("Part")
	beamPart.Anchored = true
	beamPart.CanCollide = false
	beamPart.Material = Enum.Material.Neon
	beamPart.Size = Vector3.new(1, 60, 1)
	beamPart.Color = Color3.fromRGB(150, 240, 255)
	beamPart.Transparency = 0.3
	beamPart.Position = strikePosition + Vector3.new(0, 40, 0)
	beamPart.Parent = lightningFolder

	-- flash de luz
	local light = Instance.new("PointLight")
	light.Brightness = 4
	light.Range = 35
	light.Color = Color3.fromRGB(150, 230, 255)
	light.Parent = beamPart

	-- fade rápido
	task.delay(0.15, function()
		if beamPart then
			beamPart:Destroy()
		end
	end)
end

local function applyFluxus()

	color.TintColor = Color3.fromRGB(80,180,255)
	color.Contrast = 0.4
	color.Saturation = 0.2
	blur.Size = 3

	-- pasta para organizar os raios
	lightningFolder = Instance.new("Folder")
	lightningFolder.Name = "FluxusLightning"
	lightningFolder.Parent = workspace

	-- luz elétrica no player
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")

	if root then
		electricLight = Instance.new("PointLight")
		electricLight.Color = Color3.fromRGB(120,220,255)
		electricLight.Range = 20
		electricLight.Brightness = 2
		electricLight.Parent = root
	end

	activeConnection = RunService.RenderStepped:Connect(function(dt)
		if not active then return end

		local t = tick()

		if electricLight then
			electricLight.Brightness = 3 + math.sin(t * 4) * 1.5
		end
	end)

	-- tempestade de raios
	lightningConnection = task.spawn(function()
		while active do
			spawnLightningStrike()
			task.wait(math.random(3,6))
		end
	end)

	-- ⚡ FLASH + TROVÃO CONTROLADO

	lightningSound = script:FindFirstChild("LightningSound")
	thunderSound = script:FindFirstChild("ThunderSound")
	deepThunder = script:FindFirstChild("LightningSoundDeepThunder")

	lightningActive = true

	lightningTask = task.spawn(function()
		while lightningActive do

			-- intervalo maior e mais natural
			task.wait(math.random(4,9))

			if not lightningActive then break end

			-- flash único forte
			bloom.Enabled = true
			bloom.Intensity = 3
			color.Brightness = 0.6

			task.wait(0.12)

			bloom.Intensity = 0
			color.Brightness = 0

			-- delay antes do som (efeito realista)
			local delayTime = math.random(2,5)
			task.wait(delayTime)

			if not lightningActive then break end

			if delayTime <= 3 then
				if lightningSound then lightningSound:Play() end
				if thunderSound then thunderSound:Play() end
			else
				if deepThunder then deepThunder:Play() end
			end
		end
	end)
end

local function applyFragor()

	color.Contrast = 0.5
	color.Saturation = -0.15
	color.Brightness = 0.05

	overlay.BackgroundColor3 = Color3.fromRGB(255, 200, 150)
	overlay.BackgroundTransparency = 0.97
	
	fragorMeteorFolder = Instance.new("Folder")
	fragorMeteorFolder.Name = "FragorMeteors"
	fragorMeteorFolder.Parent = workspace

	local character = player.Character
	if not character then return end
	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then return end
	
	--------------------------------------------------
	-- 💥 Meteoro Explosivo
	--------------------------------------------------

	local function spawnFallingExplosion()

		local meteor = Instance.new("Part")
		meteor.Size = Vector3.new(2,2,2)
		meteor.Shape = Enum.PartType.Ball
		meteor.Material = Enum.Material.Neon
		meteor.Color = Color3.fromRGB(255,170,100)
		meteor.Anchored = false
		meteor.CanCollide = false
		meteor.Position = root.Position + Vector3.new(
			math.random(-200,200),
			120,
			math.random(-200,200)
		)
		meteor.Parent = fragorMeteorFolder

		meteor.AssemblyLinearVelocity = Vector3.new(0,-120,0)

		local touched = false

		meteor.Touched:Connect(function(hit)
			if touched then return end
			touched = true

			--------------------------------------------------
			-- 💥 Flash de impacto
			--------------------------------------------------

			local flash = Instance.new("Part")
			flash.Anchored = true
			flash.CanCollide = false
			flash.Shape = Enum.PartType.Ball
			flash.Material = Enum.Material.Neon
			flash.Color = Color3.fromRGB(255,200,150)
			flash.Size = Vector3.new(1,1,1)
			flash.Position = meteor.Position
			flash.Parent = fragorMeteorFolder

			local duration = 0.3
			local startTime = tick()

			local conn
			conn = RunService.RenderStepped:Connect(function()
				if not flash then
					if conn then conn:Disconnect() end
					return
				end

				local alpha = (tick() - startTime) / duration
				if alpha >= 1 then
					flash:Destroy()
					if conn then conn:Disconnect() end
					return
				end

				local scale = 1 + alpha * 15
				flash.Size = Vector3.new(scale, scale, scale)
				flash.Transparency = alpha
			end)

			-- 🎥 Camera shake leve global
			camera.CFrame *= CFrame.new(
				math.random(-10,10)/200,
				math.random(-10,10)/200,
				0
			)

			meteor:Destroy()
		end)

		game.Debris:AddItem(meteor, 5)
	end
	
	--------------------------------------------------
	-- 🎧 Música do Fragor (loop começando em 17s)
	--------------------------------------------------

	fragorSound = Instance.new("Sound")
	fragorSound.SoundId = "rbxassetid://138658160401701"
	fragorSound.Volume = 0.5
	fragorSound.Looped = false

	fragorSound.Ended:Connect(function()
		if active and fragorSound then
			fragorSound.TimePosition = 17
			fragorSound:Play()
		end
	end)
	
	fragorSound.Parent = root

	-- esperar carregar
	fragorSound.Loaded:Wait()

	-- tocar
	fragorSound:Play()

	-- ir para 17 segundos
	fragorSound.TimePosition = 17

	--------------------------------------------------
	-- 💥 Disparos aleatórios enquanto ativo
	--------------------------------------------------

	activeConnection = RunService.RenderStepped:Connect(function()
		if not active then return end
		
		if math.random(1,6) == 1 then
			spawnFallingExplosion()
		end
		
	end)
end

local function applyNebula()

	color.TintColor = Color3.fromRGB(160, 100, 255)
	color.Saturation = 0.35
	color.Contrast = 0.3
	color.Brightness = -0.03

	blur.Size = 3

	overlay.BackgroundColor3 = Color3.fromRGB(30, 0, 60)
	overlay.BackgroundTransparency = 0.9

	local character = player.Character
	if not character then return end
	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then return end

	--------------------------------------------------
	-- ✨ Partículas estelares orbitais
	--------------------------------------------------

	nebulaAttachment = Instance.new("Attachment")
	nebulaAttachment.Parent = root

	nebulaEmitter = Instance.new("ParticleEmitter")
	nebulaEmitter.Texture = "rbxasset://textures/particles/sparkles_main.dds"

	nebulaEmitter.Rate = 40
	nebulaEmitter.Lifetime = NumberRange.new(2,3)
	nebulaEmitter.Speed = NumberRange.new(2,4)
	nebulaEmitter.SpreadAngle = Vector2.new(360,360)

	nebulaEmitter.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(170,100,255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(70,0,150))
	})

	nebulaEmitter.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.6),
		NumberSequenceKeypoint.new(1, 0)
	})

	nebulaEmitter.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.2),
		NumberSequenceKeypoint.new(1, 1)
	})

	nebulaEmitter.Parent = nebulaAttachment
	
	--------------------------------------------------
	-- ⭐ Estrelas sendo puxadas
	--------------------------------------------------

	nebulaStarFolder = Instance.new("Folder")
	nebulaStarFolder.Name = "NebulaStars"
	nebulaStarFolder.Parent = workspace

	local function spawnStar()

		local star = Instance.new("Part")
		star.Anchored = true
		star.CanCollide = false
		star.Material = Enum.Material.Neon
		star.Shape = Enum.PartType.Ball
		star.Size = Vector3.new(0.4,0.4,0.4)
		star.Color = Color3.fromRGB(200,150,255)

		local radius = math.random(15,25)
		local angle = math.random() * math.pi * 2

		star.Position = root.Position + Vector3.new(
			math.cos(angle) * radius,
			math.random(3,8),
			math.sin(angle) * radius
		)

		star.Parent = nebulaStarFolder

		local duration = 1.2
		local startTime = tick()

		local conn
		conn = RunService.RenderStepped:Connect(function()
			if not active or not star then
				if conn then conn:Disconnect() end
				return
			end

			local alpha = (tick() - startTime) / duration
			if alpha >= 1 then
				star:Destroy()
				if conn then conn:Disconnect() end
				return
			end

			star.Position = star.Position:Lerp(root.Position, 0.08)
		end)
	end

	--------------------------------------------------
	-- 💫 Pulsação espacial
	--------------------------------------------------

	activeConnection = RunService.RenderStepped:Connect(function(dt)
		if not active then return end

		local t = tick()

		camera.FieldOfView = 70 + math.sin(t * 2) * 2

		-- girar lente
		if nebulaDistortionGradient then
			nebulaDistortionGradient.Rotation += dt * 15
		end

		-- spawnar estrelas ocasionalmente
		if math.random(1,20) == 1 then
			spawnStar()
		end

	end)
	
	local function spawnPulse()

		local pulse = Instance.new("Part")
		pulse.Anchored = true
		pulse.CanCollide = false
		pulse.Material = Enum.Material.Neon
		pulse.Shape = Enum.PartType.Ball
		pulse.Size = Vector3.new(1,1,1)
		pulse.Color = Color3.fromRGB(170,100,255)
		pulse.Position = root.Position
		pulse.Transparency = 0.3
		pulse.Parent = workspace

		local duration = 0.6
		local startTime = tick()

		local conn
		conn = RunService.RenderStepped:Connect(function()
			if not pulse then
				if conn then conn:Disconnect() end
				return
			end

			local alpha = (tick() - startTime) / duration
			if alpha >= 1 then
				pulse:Destroy()
				if conn then conn:Disconnect() end
				return
			end

			local scale = 1 + alpha * 8
			pulse.Size = Vector3.new(scale, scale, scale)
			pulse.Transparency = alpha
			
			-- dentro do activeConnection do Nebula
			if math.random(1,120) == 1 then
				spawnPulse()
			end
		end)
		
	end
	
	--------------------------------------------------
	-- 🌀 Lente gravitacional
	--------------------------------------------------

	nebulaDistortionFrame = Instance.new("Frame")
	nebulaDistortionFrame.Size = UDim2.fromScale(0.5,0.5)
	nebulaDistortionFrame.Position = UDim2.fromScale(0.5,0.5)
	nebulaDistortionFrame.AnchorPoint = Vector2.new(0.5,0.5)
	nebulaDistortionFrame.BackgroundTransparency = 1
	nebulaDistortionFrame.Parent = gui

	nebulaDistortionGradient = Instance.new("UIGradient")
	nebulaDistortionGradient.Parent = nebulaDistortionFrame
	nebulaDistortionGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(170,100,255)),
		ColorSequenceKeypoint.new(0.5, Color3.new(0,0,0)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(170,100,255))
	})

	nebulaDistortionGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0,0.6),
		NumberSequenceKeypoint.new(0.5,1),
		NumberSequenceKeypoint.new(1,0.6)
	})
	
	--------------------------------------------------
	-- 🎧 Som ambiente
	--------------------------------------------------

	nebulaAmbientSound = Instance.new("Sound")
	nebulaAmbientSound.SoundId = "rbxassetid://1835556017" -- ambient space hum (troque se quiser)
	nebulaAmbientSound.Volume = 0.4
	nebulaAmbientSound.Looped = true
	nebulaAmbientSound.Parent = root
	nebulaAmbientSound:Play()
end

local function applyTempus()

	color.Saturation = -0.6
	color.Contrast = 0.15
	color.TintColor = Color3.fromRGB(170, 190, 255)
	blur.Size = 6

	overlay.BackgroundColor3 = Color3.fromRGB(120,120,160)
	overlay.BackgroundTransparency = 0.93

	local character = player.Character
	if not character then return end
	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then return end

	--------------------------------------------------
	-- ⏳ Pasta para pulsos
	--------------------------------------------------

	tempusPulseFolder = Instance.new("Folder")
	tempusPulseFolder.Name = "TempusPulses"
	tempusPulseFolder.Parent = workspace

	--------------------------------------------------
	-- 👻 Ghost Trail Leve
	--------------------------------------------------

	tempusGhostFolder = Instance.new("Folder")
	tempusGhostFolder.Name = "TempusGhosts"
	tempusGhostFolder.Parent = workspace

	local function spawnGhost()

		local character = player.Character
		if not character then return end
		if not character.PrimaryPart then return end

		local ghost = character:Clone()
		if not ghost then return end

		ghost.Parent = tempusGhostFolder

		-- garantir PrimaryPart
		if not ghost.PrimaryPart then
			local hrp = ghost:FindFirstChild("HumanoidRootPart")
			if hrp then
				ghost.PrimaryPart = hrp
			else
				ghost:Destroy()
				return
			end
		end

		ghost:SetPrimaryPartCFrame(character.PrimaryPart.CFrame)

		for _, v in pairs(ghost:GetDescendants()) do
			if v:IsA("BasePart") then
				v.Anchored = true
				v.CanCollide = false
				v.Material = Enum.Material.ForceField
				v.Transparency = 0.6
			elseif v:IsA("Script") or v:IsA("LocalScript") then
				v:Destroy()
			elseif v:IsA("Humanoid") then
				v:Destroy()
			end
		end

		task.delay(0.4, function()
			if ghost then
				ghost:Destroy()
			end
		end)
	end

	--------------------------------------------------
	-- 🌊 Pulso Temporal
	--------------------------------------------------

	local function spawnPulse()

		local pulse = Instance.new("Part")
		pulse.Anchored = true
		pulse.CanCollide = false
		pulse.Material = Enum.Material.Neon
		pulse.Shape = Enum.PartType.Ball
		pulse.Color = Color3.fromRGB(180,200,255)
		pulse.Size = Vector3.new(2,2,2)
		pulse.Transparency = 0.4
		pulse.Position = root.Position
		pulse.Parent = tempusPulseFolder

		local duration = 1
		local startTime = tick()

		local conn
		conn = RunService.RenderStepped:Connect(function()
			if not pulse then
				if conn then conn:Disconnect() end
				return
			end

			local alpha = (tick() - startTime) / duration
			if alpha >= 1 then
				pulse:Destroy()
				if conn then conn:Disconnect() end
				return
			end

			local scale = 2 + alpha * 15
			pulse.Size = Vector3.new(scale, scale, scale)
			pulse.Transparency = 0.4 + alpha
		end)
	end

	--------------------------------------------------
	-- 🎧 Som Temporal
	--------------------------------------------------

	tempusSound = Instance.new("Sound")
	tempusSound.SoundId = "rbxassetid://81548210874268" -- som ambiente etéreo
	tempusSound.Volume = 2
	tempusSound.Looped = true
	tempusSound.Parent = root
	tempusSound:Play()

	--------------------------------------------------
	-- 🌀 Espiral Temporal na Tela
	--------------------------------------------------

	tempusSpiralImage = Instance.new("ImageLabel")
	tempusSpiralImage.Size = UDim2.fromScale(3, 3)
	tempusSpiralImage.Position = UDim2.fromScale(0.5, 0.5)
	tempusSpiralImage.AnchorPoint = Vector2.new(0.5, 0.5)
	tempusSpiralImage.BackgroundTransparency = 1
	tempusSpiralImage.ImageTransparency = 0.7
	tempusSpiralImage.ImageColor3 = Color3.fromRGB(200,170,255)
	tempusSpiralImage.ZIndex = 999
	overlay.ZIndex = 1
	gui.DisplayOrder = 100
	tempusSpiralImage.Image = "rbxassetid://123908407494482"
	tempusSpiralImage.Parent = gui
	local baseSize = 3
	
	--------------------------------------------------
	-- 🔁 Loop Principal
	--------------------------------------------------

	activeConnection = RunService.RenderStepped:Connect(function(dt)
		if not active then return end

		local t = tick()

		-- FOV lento
		camera.FieldOfView = 70 + math.sin(t * 1.5) * 1.2

		-- leve distorção
		camera.CFrame *= CFrame.new(
			math.sin(t * 2) * 0.01,
			math.cos(t * 2) * 0.01,
			0
		)
		
		tempusSpiralImage.Rotation += dt * 20
		
		local pulse = 1 + math.sin(t * 1.5) * 0.03
		tempusSpiralImage.Size = UDim2.fromScale(baseSize * pulse, baseSize * pulse)

		-- spawnar ghost ocasional
		if math.random(1,35) == 1 then
			spawnGhost()
		end

		-- spawnar pulso ocasional
		if math.random(1,90) == 1 then
			spawnPulse()
		end
	end)
end

local function applyGargantua()

	color.Saturation = -0.4
	color.Contrast = 0.5
	color.TintColor = Color3.fromRGB(120,0,200)

	blur.Size = 8

	-- 🌌 Aplicar Skybox
	local skyFolder = ReplicatedStorage:WaitForChild("Skyboxes")
	local newSky = skyFolder:FindFirstChild("GargantuaSky")

	if newSky then
		-- salvar sky atual
		originalSky = Lighting:FindFirstChildOfClass("Sky")
		if originalSky then
			originalSky.Parent = nil
		end

		gargantuaSky = newSky:Clone()
		gargantuaSky.Parent = Lighting
	end

	-- ✨ Partículas gravitacionais

	local character = player.Character
	if character then
		local root = character:FindFirstChild("HumanoidRootPart")
		if root then
			gargantuaAttachment = Instance.new("Attachment")
			gargantuaAttachment.Parent = root

			gargantuaEmitter = Instance.new("ParticleEmitter")
			gargantuaEmitter.Texture = "rbxassetid://284205403" -- partícula suave (spark default)
			gargantuaEmitter.Rate = 25
			gargantuaEmitter.Lifetime = NumberRange.new(2,3)
			gargantuaEmitter.Speed = NumberRange.new(1,3)
			gargantuaEmitter.SpreadAngle = Vector2.new(180,180)
			gargantuaEmitter.Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0,0.2),
				NumberSequenceKeypoint.new(1,0)
			})
			gargantuaEmitter.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0,0.2),
				NumberSequenceKeypoint.new(1,1)
			})
			gargantuaEmitter.Color = ColorSequence.new(Color3.fromRGB(180,0,255))
			gargantuaEmitter.Parent = gargantuaAttachment
		end
	end

	-- 🌀 Lente gravitacional circular

	lensFrame = Instance.new("Frame")
	lensFrame.Size = UDim2.fromScale(0.6,0.6)
	lensFrame.Position = UDim2.fromScale(0.5,0.5)
	lensFrame.AnchorPoint = Vector2.new(0.5,0.5)
	lensFrame.BackgroundTransparency = 1
	lensFrame.Parent = gui

	lensGradient = Instance.new("UIGradient")
	lensGradient.Parent = lensFrame
	lensGradient.Rotation = 0
	lensGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(120,0,255)),
		ColorSequenceKeypoint.new(0.5, Color3.new(0,0,0)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(120,0,255))
	})
	lensGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0,0.7),
		NumberSequenceKeypoint.new(0.5,1),
		NumberSequenceKeypoint.new(1,0.7)
	})

	-- ✨ Bloom apocalíptico
	bloom.Enabled = true
	bloom.Intensity = 2
	bloom.Size = 60
	bloom.Threshold = 0.8

	-- 🌑 Vinheta escura
	overlay.BackgroundColor3 = Color3.fromRGB(10,0,25)
	overlay.BackgroundTransparency = 0.85

	-- 🌪 Pulsação gravitacional
	activeConnection = RunService.RenderStepped:Connect(function(dt)
		if not active then return end

		local t = tick()
		local endsAt = player:GetAttribute("ArtifactEndsAt")

		local intensity = 1

		if endsAt then
			local remaining = math.max(0, endsAt - os.clock())
			local duration = 12 -- coloque a duração real do Gargantua aqui
			intensity = 1 + (1 - (remaining / duration)) * 2
		end

		-- Pulsação FOV mais agressiva
		camera.FieldOfView = 70 + math.sin(t*3) * (6 * intensity)

		-- Tremor crescente
		camera.CFrame *= CFrame.new(
			math.sin(t*4) * 0.02 * intensity,
			math.cos(t*4) * 0.02 * intensity,
			math.sin(t*5) * 0.03 * intensity
		)

		-- Rotação lenta da lente
		if lensGradient then
			lensGradient.Rotation += dt * 20
		end
	end)
	
	--------------------------------------------------
	-- 🌑 Som Cósmico Intenso
	--------------------------------------------------

	local character = player.Character
	if character then
		local root = character:FindFirstChild("HumanoidRootPart")
		if root then
			gargantuaSound = Instance.new("Sound")
			gargantuaSound.SoundId = "rbxassetid://1841042445" -- impacto espacial profundo
			gargantuaSound.Volume = 0.7
			gargantuaSound.Looped = true
			gargantuaSound.Parent = root
			gargantuaSound:Play()
		end
	end
	
end

local function applyAurum()

	color.TintColor = Color3.fromRGB(255,230,150)
	color.Saturation = 0.25

	--------------------------------------------------
	-- 🪙 Som de Caixa Registradora
	--------------------------------------------------

	local character = player.Character
	if character then
		local root = character:FindFirstChild("HumanoidRootPart")
		if root then
			aurumSound = Instance.new("Sound")
			aurumSound.SoundId = "rbxassetid://101396758527961" -- cash register
			aurumSound.Volume = 0.7
			aurumSound.Looped = false
			aurumSound.Parent = root
			aurumSound:Play()

			game.Debris:AddItem(aurumSound, 3)
		end
	end

	startAurumParticles()
end

local function applySanguis()

	color.TintColor = Color3.fromRGB(110, 0, 40)
	color.Contrast = 0.4
	color.Saturation = 0.1
	color.Brightness = -0.05

	blur.Size = 2

	overlay.BackgroundColor3 = Color3.fromRGB(25, 0, 20)
	overlay.BackgroundTransparency = 0.88

	local character = player.Character
	if not character then return end
	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then return end

	--------------------------------------------------
	-- ✨ Aura carmesim elegante
	--------------------------------------------------

	sanguisAttachment = Instance.new("Attachment")
	sanguisAttachment.Parent = root

	sanguisEmitter = Instance.new("ParticleEmitter")
	sanguisEmitter.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	sanguisEmitter.Rate = 25
	sanguisEmitter.Lifetime = NumberRange.new(1.8, 2.4)
	sanguisEmitter.Speed = NumberRange.new(1, 2)
	sanguisEmitter.SpreadAngle = Vector2.new(360,360)

	sanguisEmitter.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(160,0,60)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(60,0,40))
	})

	sanguisEmitter.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.8),
		NumberSequenceKeypoint.new(1, 0)
	})

	sanguisEmitter.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.3),
		NumberSequenceKeypoint.new(1, 1)
	})

	sanguisEmitter.Parent = sanguisAttachment

	--------------------------------------------------
	-- 🌫 Névoa baixa no chão
	--------------------------------------------------

	sanguisFogPart = Instance.new("Part")
	sanguisFogPart.Anchored = true
	sanguisFogPart.CanCollide = false
	sanguisFogPart.Transparency = 1
	sanguisFogPart.Size = Vector3.new(20,1,20)
	sanguisFogPart.Position = root.Position - Vector3.new(0,2.5,0)
	sanguisFogPart.Parent = workspace

	sanguisFogEmitter = Instance.new("ParticleEmitter")
	sanguisFogEmitter.Texture = "rbxasset://textures/particles/smoke_main.dds"
	sanguisFogEmitter.Rate = 35
	sanguisFogEmitter.Lifetime = NumberRange.new(3,4)
	sanguisFogEmitter.Speed = NumberRange.new(0.5,1)
	sanguisFogEmitter.SpreadAngle = Vector2.new(360,360)
	sanguisFogEmitter.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 6),
		NumberSequenceKeypoint.new(1, 10)
	})
	sanguisFogEmitter.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.7),
		NumberSequenceKeypoint.new(1, 1)
	})
	sanguisFogEmitter.Color = ColorSequence.new(Color3.fromRGB(70,0,40))
	sanguisFogEmitter.Parent = sanguisFogPart

	--------------------------------------------------
	-- 🔴 Luz elegante
	--------------------------------------------------

	sanguisLight = Instance.new("PointLight")
	sanguisLight.Color = Color3.fromRGB(120, 0, 50)
	sanguisLight.Range = 14
	sanguisLight.Brightness = 1.8
	sanguisLight.Parent = root

	--------------------------------------------------
	-- ❤️ Som de batimento
	--------------------------------------------------

	heartbeatSound = Instance.new("Sound")
	heartbeatSound.SoundId = "rbxassetid://6556968450" -- heartbeat realista suave
	heartbeatSound.Volume = 0.4
	heartbeatSound.PlaybackSpeed = 1
	heartbeatSound.Looped = true
	heartbeatSound.Parent = root
	heartbeatSound:Play()

	--------------------------------------------------
	-- 🌌 Drenagem elegante ao causar dano
	--------------------------------------------------

	sanguisDrainFolder = Instance.new("Folder")
	sanguisDrainFolder.Name = "SanguisDrain"
	sanguisDrainFolder.Parent = workspace

	local function connectEnemy(enemy)

		local humanoid = enemy:FindFirstChildOfClass("Humanoid")
		local enemyRoot = enemy:FindFirstChild("HumanoidRootPart")

		if not humanoid or not enemyRoot then return end

		local lastHealth = humanoid.Health

		local connection = humanoid.HealthChanged:Connect(function(newHealth)

			if not active then return end
			if newHealth < lastHealth then

				local character = player.Character
				if not character then return end
				local root = character:FindFirstChild("HumanoidRootPart")
				if not root then return end

				local beam = Instance.new("Beam")

				local att0 = Instance.new("Attachment", enemyRoot)
				local att1 = Instance.new("Attachment", root)

				beam.Attachment0 = att0
				beam.Attachment1 = att1
				beam.Width0 = 0.3
				beam.Width1 = 0.1
				beam.Color = ColorSequence.new(Color3.fromRGB(150,0,70))
				beam.Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0.2),
					NumberSequenceKeypoint.new(1, 1)
				})
				beam.LightEmission = 1
				beam.Parent = sanguisDrainFolder

				task.delay(0.25, function()
					if beam then beam:Destroy() end
					if att0 then att0:Destroy() end
					if att1 then att1:Destroy() end
				end)
			end

			lastHealth = newHealth
		end)

		table.insert(sanguisDamageConnections, connection)
	end

	-- conectar inimigos existentes
	for _, obj in pairs(workspace:GetChildren()) do
		if obj:FindFirstChildOfClass("Humanoid") then
			connectEnemy(obj)
		end
	end

	-- conectar inimigos que spawnarem depois
	workspace.ChildAdded:Connect(function(obj)
		if active and obj:FindFirstChildOfClass("Humanoid") then
			connectEnemy(obj)
		end
	end)
end

--------------------------------------------------
-- APPLY
--------------------------------------------------

local function applyEffect(id)

	resetEffects()
	active = true

	if id == "Ignis" then
		applyIgnis()
	elseif id == "Congelo" then
		applyCongelo()
	elseif id == "FluxusEletricus" then
		applyFluxus()
	elseif id == "Fragor" then
		applyFragor()
	elseif id == "Nebula" then
		applyNebula()
	elseif id == "Gargantua" then
		applyGargantua()
	elseif id == "Aurum" then
		applyAurum()
	elseif id == "Sanguis" then
		applySanguis()
	elseif id == "TempusStans" then
		applyTempus()
	end
end

--------------------------------------------------
-- REMOTE
--------------------------------------------------

remote.OnClientEvent:Connect(function(action, artifactId)

	if action == "Activate" then
		applyEffect(artifactId)
	elseif action == "Clear" then
		resetEffects()
	end
end)