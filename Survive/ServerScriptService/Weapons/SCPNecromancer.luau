local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

local EnemyDamageService =
	require(game.ServerScriptService.Combat.EnemyDamageService)

local WeaponBase =
	require(script.Parent:WaitForChild("WeaponBase"))

local GamePaused =
	game.ReplicatedStorage.GameState:WaitForChild("GamePaused")

local TargetReservations = {}

local ModelRotationFix = {
	["SCP-173"] = 180,
	["SCP-096"] = 90,
	["SCP-106"] = 45,
	["SCP-087"] = 90,
	["SCP-093"] = 180,
}
-------------------------------------------------
-- MODELO
-------------------------------------------------

local SCP_FOLDER =
	ReplicatedStorage.Weapons.SCPNecromancer

-------------------------------------------------
-- CONFIG
-------------------------------------------------

local BASE_SPEED = 18
local BASE_ATTACK_RANGE = 4
local HIT_COOLDOWN = 0.6
local MAX_HITS = 5
local LIFETIME = 20
local MAX_SUMMONS = 25

-------------------------------------------------
-- CLASSE
-------------------------------------------------

local SCPNecromancer = {}
SCPNecromancer.__index = SCPNecromancer
setmetatable(SCPNecromancer,{__index = WeaponBase})

-------------------------------------------------
-- CONSTRUTOR
-------------------------------------------------

function SCPNecromancer.new(player, limiter)

	local baseStats = {
		Name = "SCPNecromancer",
		Damage = 20,
		Cooldown = 5,
		Range = 20
	}

	local self = WeaponBase.new(baseStats, player, limiter)

	self.ActiveSummons = {}

	setmetatable(self, SCPNecromancer)

	return self
end

-------------------------------------------------
-- ENEMY
-------------------------------------------------

local function getClosestEnemy(pos)

	local best
	local dist = math.huge

	for _,enemy in ipairs(_G.Enemies or {}) do

		if enemy.Alive and enemy.Root and enemy.Humanoid then

			local reserved = TargetReservations[enemy]

			if not reserved or reserved < tick() then

				local d = (enemy.Root.Position - pos).Magnitude

				if d < dist then
					dist = d
					best = enemy
				end

			end

		end

	end

	if best then
		TargetReservations[best] = tick() + 1.2
	end

	return best
end

-------------------------------------------------
-- GROUND
-------------------------------------------------

local function getGround(pos)

	local ray = workspace:Raycast(
		pos + Vector3.new(0,40,0),
		Vector3.new(0,-100,0)
	)

	if ray then
		return ray.Position
	end

	return pos
end

-------------------------------------------------
-- SPAWN EFFECT
-------------------------------------------------

local function spawnSummonEffect(pos)

	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.Transparency = 1
	part.Size = Vector3.new(6,0.2,6)
	part.Position = pos
	part.Parent = workspace

	local gui = Instance.new("SurfaceGui")
	gui.Adornee = part
	gui.Face = Enum.NormalId.Top
	gui.AlwaysOnTop = true
	gui.LightInfluence = 0
	gui.Parent = part

	local img = Instance.new("ImageLabel")
	img.Size = UDim2.fromScale(1,1)
	img.BackgroundTransparency = 1
	img.Image = "rbxassetid://168099671"
	img.Parent = gui

	local emitter = Instance.new("ParticleEmitter")
	emitter.Color = ColorSequence.new(Color3.fromRGB(180,0,255))
	emitter.Rate = 80
	emitter.Lifetime = NumberRange.new(0.4,0.7)
	emitter.Speed = NumberRange.new(2,4)
	emitter.Parent = part

	Debris:AddItem(part,1.2)

end

-------------------------------------------------
-- SPAWN POS
-------------------------------------------------

local function findSpawnPos(center)

	for i=1,8 do

		local angle = math.random()*math.pi*2
		local radius = math.random(6,10)

		local pos =
			center +
			Vector3.new(
				math.cos(angle)*radius,
				0,
				math.sin(angle)*radius
			)

		local blocked = false

		for _,enemy in ipairs(_G.Enemies or {}) do

			if enemy.Alive and enemy.Root then

				if (enemy.Root.Position - pos).Magnitude < 6 then
					blocked = true
					break
				end

			end

		end

		if not blocked then
			return getGround(pos)
		end
	end

	return getGround(center)
end

-------------------------------------------------
-- IA (CORRIGIDA)
-------------------------------------------------

local function runAI(self, model, attrs, attackRange, speed, isSalvation)

	local hits = isSalvation and math.huge or MAX_HITS
	local lastHit = 0

	local damage =
		self:ComputeFinalDamage(
			self.BaseStats.Damage,
			attrs
		)

	-- escolhe alvo inicial
	local target = getClosestEnemy(model.PrimaryPart.Position)

	local conn
	conn = RunService.Heartbeat:Connect(function(dt)

		if not model.Parent then
			conn:Disconnect()
			return
		end

		if GamePaused.Value then
			return
		end

		-- atualiza root sempre
		local root = model.PrimaryPart
		if not root then
			conn:Disconnect()
			return
		end

		-- se alvo morreu ou sumiu, pega outro
		if not target
			or not target.Alive
			or not target.Root
			or target.Humanoid.Health <= 0 then

			target = getClosestEnemy(root.Position)

			if not target then
				return
			end
		end

		local targetPos = target.Root.Position

		local dir = targetPos - root.Position
		local dist = dir.Magnitude

		if dist > 0 then
			dir = dir.Unit
		end

		if dist > attackRange + 2 then

			local move =
				Vector3.new(dir.X,0,dir.Z) * speed * dt

			local groundY = model:GetAttribute("GroundY")

			local newPos = Vector3.new(
				root.Position.X + move.X,
				groundY,
				root.Position.Z + move.Z
			)

			local look =
				Vector3.new(targetPos.X, newPos.Y, targetPos.Z)

			local cf = CFrame.lookAt(newPos, look)

			-- corrigir orientação de uns SCP
			if model.Name == "SCP-173" or model.Name == "SCP-093" or model.Name == "SCP-106" then
				cf = cf * CFrame.Angles(0, math.rad(180), 0)
			end
			local cf = CFrame.lookAt(newPos, look)

			local rot = ModelRotationFix[model.Name]
			if rot then
				cf = cf * CFrame.Angles(0, math.rad(rot), 0)
			end

			model:PivotTo(cf)

		else

			if tick() - lastHit >= HIT_COOLDOWN then

				lastHit = tick()

				local enemyHumanoid = target.Humanoid

				if not enemyHumanoid then
					enemyHumanoid = target.Root.Parent:FindFirstChildOfClass("Humanoid")
				end

				if enemyHumanoid and enemyHumanoid.Health > 0 then

					EnemyDamageService:DamageEnemy(
						self.Player,
						enemyHumanoid,
						damage
					)

				end

				-- 👇 empurra o SCP para trás para evitar sobreposição
				local root = model.PrimaryPart

				local away =
					(root.Position - target.Root.Position)

				if away.Magnitude > 0 then
					away = away.Unit
				end

				local pushDistance = 2

				local groundY = model:GetAttribute("GroundY")

				local pushPos = Vector3.new(
					root.Position.X + away.X * pushDistance,
					groundY,
					root.Position.Z + away.Z * pushDistance
				)

				local cf = CFrame.lookAt(
					pushPos,
					target.Root.Position
				)

				local rot = ModelRotationFix[model.Name]
				if rot then
					cf = cf * CFrame.Angles(0, math.rad(rot), 0)
				end

				model:PivotTo(cf)

				hits -= 1

				if hits <= 0 then
					conn:Disconnect()
					model:Destroy()
				end

			end

		end

	end)

	local lifetime = isSalvation and 30 or LIFETIME
	Debris:AddItem(model, lifetime)

end

-------------------------------------------------
-- SPAWN SCP
-------------------------------------------------

function SCPNecromancer:SpawnSCP(pos, attrs, forcedTemplate)
	
	local isSalvation = self.Player:GetAttribute("SCP_SalvationActive")

	if #self.ActiveSummons >= MAX_SUMMONS then
		return
	end

	local templates = SCP_FOLDER:GetChildren()
	local template = forcedTemplate or templates[math.random(1,#templates)]

	local model = template:Clone()

	local root = model:FindFirstChild("HumanoidRootPart")

	if not root then
		root = model:FindFirstChildWhichIsA("BasePart")
	end

	if not root then
		model:Destroy()
		return
	end

	model.PrimaryPart = root

	-------------------------------------------------
	-- PREPARAR PARTES
	-------------------------------------------------

	for _,p in ipairs(model:GetDescendants()) do
		if p:IsA("BasePart") then
			p.Anchored = true
			p.CanCollide = false
		end
	end

	-------------------------------------------------
	-- ATTRIBUTES
	-------------------------------------------------

	local scale = (attrs and attrs.AttackSize) or 1

	if template.Name == "SCP-3008" then
		scale = scale * 0.6
	end

	if template.Name == "SCP-173" then
		scale = scale * 0.7
	end

	if template.Name == "SCP-096" then
		scale = scale * 1.2
	end
	
	if template.Name == "SCP-087" then
		scale = scale * 1.1
	end
	
	if template.Name == "SCP-093" then
		scale = scale * 0.25
	end
	
	if template.Name == "SCP-106" then
		scale = scale * 1.15
	end

	pcall(function()
		model:ScaleTo(scale)
	end)

	local attackRange =
		BASE_ATTACK_RANGE * scale
	
	if template.Name == "SCP-173" then
		attackRange = attackRange * 0.8
	end
	
	if template.Name == "SCP-096" then
		attackRange = attackRange * 1.3
	end
	
	if template.Name == "SCP-087" then
		attackRange = attackRange * 1.4
	end
	
	if template.Name == "SCP-093" then
		attackRange = attackRange * 1.1
	end
	
	if template.Name == "SCP-106" then
		attackRange = attackRange * 1.35
	end
	
	local _, size = model:GetBoundingBox()
	attackRange = attackRange + size.Z * 0.25

	local speed =
		BASE_SPEED * (attrs.MovementSpeed or 1)

	if template.Name == "SCP-173" then
		speed = speed * 1.6
	end

	if template.Name == "SCP-096" then
		speed = speed * 2.2
	end
	
	if template.Name == "SCP-087" then
		speed = speed * 0.75
	end
	
	if template.Name == "SCP-093" then
		speed = speed * 1.15
	end
	
	if template.Name == "SCP-106" then
		speed = speed * 0.85
	end

	-------------------------------------------------

	local spawnPos = findSpawnPos(pos)

	local angle = math.random() * math.pi * 2
	local radius = math.random(2,4)

	spawnPos = spawnPos + Vector3.new(
		math.cos(angle) * radius,
		0,
		math.sin(angle) * radius
	)

	spawnSummonEffect(spawnPos)

	local _, size = model:GetBoundingBox()

	local spawnHeight = size.Y/2 + 0.5

	-- ajuste específico do SCP-096
	if template.Name == "SCP-096" then
		spawnHeight = spawnHeight + 2.5
	end
	
	if template.Name == "SCP-087" then
		spawnHeight = spawnHeight + 0.5
	end
	
	if template.Name == "SCP-106" then
		spawnHeight = spawnHeight + 2
	end
	
	model:PivotTo(
		CFrame.new(
			spawnPos + Vector3.new(0, spawnHeight, 0)
		)
	)

	model:SetAttribute("GroundY", model.PrimaryPart.Position.Y)
	
	model.Parent = workspace

	runAI(self, model, attrs, attackRange, speed, isSalvation)

	table.insert(self.ActiveSummons, model)

	model.Destroying:Connect(function()

		for i,v in ipairs(self.ActiveSummons) do
			if v == model then
				table.remove(self.ActiveSummons,i)
				break
			end
		end

	end)

end

-------------------------------------------------
-- ATAQUE
-------------------------------------------------

function SCPNecromancer:Attack(root,attrs)

	local enemies =
		self:GetEnemiesInRange(
			self.BaseStats.Range * (attrs.Range or 1)
		)

	if #enemies == 0 then return end

	self:StartCooldown(attrs)

	local multi =
		math.max(1, math.floor(1 + ((attrs.MultiAttack or 1) - 1) * 0.5))

	for i=1,multi do

		self:SpawnSCP(
			root.Position,
			attrs
		)

	end

end

return SCPNecromancer