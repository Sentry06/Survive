-- Nebula.lua
-- Campo cósmico que pulsa dano ao redor do jogador

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")

local Nebula = {}

Nebula.Id = "Nebula"
Nebula.Duration = 15

Nebula.Tags = { "NebulaField" }

Nebula.Data = {
	BaseRadius = 22,       -- área inicial maior
	PulseSpeed = 2.5,      -- velocidade do pulso
	PulseStrength = 6,     -- intensidade visual do pulso
	BaseDamage = 50,       -- dano base forte
	Scaling = 60           -- escala com AreaDamage
}

-- armazenamento interno
local activeNebulas = {}

-------------------------------------------------
-- APPLY
-------------------------------------------------
function Nebula:OnApply(player)

	print("🌌 Nebula ativada")
	
	-- 🌌 Ajustes de iluminação cósmica
	Lighting.Brightness = 1.5
	Lighting.ClockTime = 20
	Lighting.OutdoorAmbient = Color3.fromRGB(80, 0, 120)
	Lighting.Ambient = Color3.fromRGB(60, 0, 100)
	Lighting.ShadowSoftness = 0.2

	local character = player.Character
	if not character then return end

	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then return end

	-------------------------------------------------
	-- SKYBOX
	-------------------------------------------------

	local skyFolder = ReplicatedStorage:FindFirstChild("Skyboxes")
	local skyInstance = nil

	if skyFolder then
		local skyTemplate = skyFolder:FindFirstChild("NebulaSky")
		if skyTemplate then
			skyInstance = skyTemplate:Clone()
			skyInstance.Name = "NebulaSkyActive"
			skyInstance.Parent = Lighting
		end
	end

	-------------------------------------------------
	-- CÍRCULO VISUAL
	-------------------------------------------------

	local circle = Instance.new("Part")
	circle.Shape = Enum.PartType.Cylinder
	circle.Anchored = true
	circle.CanCollide = false
	circle.Material = Enum.Material.Neon
	circle.Color = Color3.fromRGB(170, 0, 255)
	circle.Transparency = 0.45
	circle.Name = "NebulaField"
	circle.Parent = workspace

	-------------------------------------------------
	-- LOOP
	-------------------------------------------------

	local time = 0

	local connection
	connection = RunService.Heartbeat:Connect(function(dt)

		if not player.Parent or not root.Parent then
			connection:Disconnect()
			if circle then circle:Destroy() end
			return
		end

		time += dt

		local attrs = player:GetAttributes()
		local attackSize = attrs.AttackSize or 1
		local base = attrs.AreaDamage or 0
		local bonus = player:GetAttribute("AreaDamageBonus") or 0

		local areaPercent = base + bonus
		local damageMultiplier = attrs.Damage or 1

		-- pulso visível
		local pulse =
			math.sin(time * Nebula.Data.PulseSpeed)
			* Nebula.Data.PulseStrength

		local radius =
			(Nebula.Data.BaseRadius + pulse)
			* attackSize
			* (1 + areaPercent * 1.8)

		-- segue jogador suavemente no chão
		local pos = root.Position
		circle.CFrame =
			CFrame.new(pos.X, pos.Y - 3, pos.Z)
			* CFrame.Angles(0, 0, math.rad(90))

		circle.Size = Vector3.new(0.6, radius * 2, radius * 2)

		-------------------------------------------------
		-- DANO A CADA 0.5s
		-------------------------------------------------

		if math.floor(time * 2) ~= math.floor((time - dt) * 2) then

			local damage =
				(Nebula.Data.BaseDamage + (areaPercent * Nebula.Data.Scaling))
				* damageMultiplier

			for _, enemy in ipairs(_G.Enemies or {}) do
				if enemy.Alive and enemy.Root and enemy.Humanoid then

					local dist =
						(enemy.Root.Position - root.Position).Magnitude

					if dist <= radius then
						local EnemyDamageService = require(
							game.ServerScriptService.Combat.EnemyDamageService
						)

						EnemyDamageService:DamageEnemy(
							player,
							enemy.Humanoid,
							damage,
							true -- isSplash
						)
					end
				end
			end
		end
	end)

	player:SetAttribute("NebulaActive", true)

	activeNebulas[player] = {
		Connection = connection,
		Circle = circle,
		Sky = skyInstance
	}
end

-------------------------------------------------
-- REMOVE
-------------------------------------------------
function Nebula:OnRemove(player)

	local data = activeNebulas[player]
	if not data then return end

	if data.Connection then
		data.Connection:Disconnect()
	end

	if data.Circle then
		data.Circle:Destroy()
	end

	if data.Sky then
		data.Sky:Destroy()
	end

	activeNebulas[player] = nil
	player:SetAttribute("NebulaActive", false)
	player:SetAttribute("AreaDamageBonus", 0)

	-- 🌤 Restaurar iluminação padrão
	Lighting.Brightness = 2
	Lighting.ClockTime = 14
	Lighting.OutdoorAmbient = Color3.fromRGB(128,128,128)
	Lighting.Ambient = Color3.fromRGB(128,128,128)
	Lighting.ShadowSoftness = 0.5

	print("🌌 Nebula removida")
end

return Nebula
