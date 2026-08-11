-- CardDealer.lua
-- Weapon that throws cards and changes active card every 60 seconds

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

local EnemyDamageService = require(
	game.ServerScriptService.Combat.EnemyDamageService
)

local WeaponBase = require(script.Parent:WaitForChild("WeaponBase"))

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local CardUpdate = Remotes:WaitForChild("CardDealerUpdate")

local CardDealer = {}
CardDealer.__index = CardDealer
setmetatable(CardDealer,{ __index = WeaponBase })

-------------------------------------------------
-- CARD MODELS
-------------------------------------------------

local CardFolder =
	ReplicatedStorage
	:WaitForChild("Weapons")
	:WaitForChild("CardDealer")

local CardModels = {

	Ace = CardFolder:WaitForChild("AceCardModel"),
	King = CardFolder:WaitForChild("KingCardModel"),
	Queen = CardFolder:WaitForChild("QueenCardModel"),
	Jack = CardFolder:WaitForChild("JackCardModel"),
	Joker = CardFolder:WaitForChild("JokerCardModel")

}

local SlotMachineSound = CardFolder:WaitForChild("SlotMachine")

-------------------------------------------------
-- CARD EFFECTS
-------------------------------------------------

local Cards = {

	Ace = { Stat = "Damage", Multiplier = 2 },
	King = { Stat = "AttackSize", Multiplier = 2 },
	Queen = { Stat = "Range", Multiplier = 2 },
	Jack = { Stat = "ProjectileSpeed", Multiplier = 2 },
	Joker = { Stat = "MultiAttack", Add = 2 }

}

local CARD_DURATION = 60

-------------------------------------------------
-- CONSTRUCTOR
-------------------------------------------------

function CardDealer.new(player, limiter)

	local baseStats = {

		Name = "CardDealer",
		Damage = 14,
		Cooldown = 2,
		Range = 18,
		ProjectileSpeed = 30,
		AttackSize = 1,
		ProjectilePierce = 0,
		AreaDamage = 0

	}

	local self = WeaponBase.new(baseStats, player, limiter)

	self.Level = 1

	self.Scaling = {
		Damage = 1.12,
		Cooldown = 0.95
	}

	self.ActiveCard = nil
	self.CardStat = nil

	setmetatable(self, CardDealer)

	self:StartCardRotation()

	return self

end

-------------------------------------------------
-- UPGRADE
-------------------------------------------------

function CardDealer:OnUpgrade(level)

	self.Level = level

	self.BaseStats.Damage *= self.Scaling.Damage
	self.BaseStats.Cooldown *= self.Scaling.Cooldown

end

-------------------------------------------------
-- APPLY CARD BUFF
-------------------------------------------------

function CardDealer:ApplyCard(cardName)

	local card = Cards[cardName]
	if not card then return end

	local attrs = self.Player.MatchStats.Attributes

	-- remove buff antigo
	if self.CardStat then

		local attr = attrs:FindFirstChild(self.CardStat)

		if attr then

			if self.CardType == "Multiplier" then
				attr.Value /= self.CardApplied
			elseif self.CardType == "Add" then
				attr.Value -= self.CardApplied
			end

		end
	end

	local stat = card.Stat
	local attr = attrs:FindFirstChild(stat)
	if not attr then return end

	self.CardStat = stat

	if card.Multiplier then

		attr.Value *= card.Multiplier
		self.CardApplied = card.Multiplier
		self.CardType = "Multiplier"

	elseif card.Add then

		attr.Value += card.Add
		self.CardApplied = card.Add
		self.CardType = "Add"

	end

	self.ActiveCard = cardName

	self.Player:SetAttribute("ActiveCard", cardName)
	self.ActiveCard = cardName

	CardUpdate:FireClient(self.Player, cardName, "Final")

end

-------------------------------------------------
-- SLOT MACHINE SPIN
-------------------------------------------------

function CardDealer:SpinCards(finalCard)

	local keys = {}

	for name,_ in pairs(Cards) do
		table.insert(keys,name)
	end

	local sound = SlotMachineSound:Clone()
	sound.Parent = workspace
	sound:Play()

	for i = 1,14 do

		local random = keys[math.random(1,#keys)]

		CardUpdate:FireClient(self.Player,random,"Spin")

		task.wait(0.07)

	end

	sound:Stop()
	sound:Destroy()

	CardUpdate:FireClient(self.Player,finalCard,"Final")

end

-------------------------------------------------
-- ROTATION SYSTEM
-------------------------------------------------

function CardDealer:StartCardRotation()

	task.spawn(function()

		local keys = {}

		for name,_ in pairs(Cards) do
			table.insert(keys,name)
		end

		local first = keys[math.random(1,#keys)]
		self:ApplyCard(first)

		while self.Player and self.Player.Parent do

			task.wait(CARD_DURATION - 1)

			local newCard = keys[math.random(1,#keys)]

			self:SpinCards(newCard)

			task.wait(0.15)

			self:ApplyCard(newCard)

		end

	end)

end

-------------------------------------------------
-- SPAWN CARD PROJECTILE
-------------------------------------------------

local function spawnCard(self, cardName, origin, direction, range, speed, sizeMultiplier, damage)

	if not self:CanSpawnProjectile() then return end
	self:OnProjectileSpawn()

	local template = CardModels[cardName]
	if not template then return end

	local model = template:Clone()
	model.Parent = workspace
	model.Name = cardName.."Card"

	self:ApplyWeaponAura(model)

	local part = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
	if not part then
		model:Destroy()
		self:OnProjectileDestroy()
		return
	end

	part.Anchored = true
	part.CanCollide = false
	part.Size *= sizeMultiplier

	model:PivotTo(CFrame.new(origin,origin + direction))
	
	local trail = part:FindFirstChildWhichIsA("Trail")

	if trail then

		local att0 = Instance.new("Attachment")
		local att1 = Instance.new("Attachment")

		att0.Position = Vector3.new(0, 0.5, 0)
		att1.Position = Vector3.new(0, -0.5, 0)

		att0.Parent = part
		att1.Parent = part

		trail.Attachment0 = att0
		trail.Attachment1 = att1
		trail.Enabled = true

	end
	

	local traveled = 0
	local lastPos = origin

	local conn
	conn = RunService.Heartbeat:Connect(function(dt)

		local step = speed * dt
		traveled += step

		local newPos = lastPos + direction * step

		model:PivotTo(
			CFrame.new(newPos,newPos + direction)
				* CFrame.Angles(
					math.rad(traveled*30),
					math.rad(traveled*15),
					math.rad(traveled*40)
				)
		)

		lastPos = newPos

		for _,enemy in ipairs(_G.Enemies or {}) do

			if enemy.Alive and enemy.Root and enemy.Humanoid then

				local dist =
					(enemy.Root.Position - newPos).Magnitude

				if dist <= 3 * sizeMultiplier then

					EnemyDamageService:DamageEnemy(
						self.Player,
						enemy.Humanoid,
						damage
					)

					self:ApplyHitEffects(enemy)

					conn:Disconnect()
					model:Destroy()
					self:OnProjectileDestroy()
					return

				end
			end
		end

		if traveled >= range then

			conn:Disconnect()
			model:Destroy()
			self:OnProjectileDestroy()

		end

	end)

	Debris:AddItem(model,5)

end

-------------------------------------------------
-- ATTACK
-------------------------------------------------

function CardDealer:Attack(root, attrs)

	local activeCard = self.Player:GetAttribute("ActiveCard")

	if not activeCard then return end

	local finalRange =
		self.BaseStats.Range * attrs.Range

	local enemies = self:GetEnemiesInRange(finalRange)
	if #enemies == 0 then return end

	self:StartCooldown(attrs)

	local attackSize = attrs.AttackSize or 1
	local multi = math.max(1, math.floor(attrs.MultiAttack or 1))

	for i = 1, math.min(multi,#enemies) do

		local enemy = enemies[i]
		if not enemy or not enemy.Alive then continue end

		local finalDamage =
			self:ComputeFinalDamage(self.BaseStats.Damage, attrs)

		local dir =
			(enemy.Root.Position - root.Position).Unit

		local origin =
			root.Position
			+ dir * 2
			+ Vector3.new(0,1.5,0)

		spawnCard(
			self,
			activeCard,
			origin,
			dir,
			finalRange,
			self.BaseStats.ProjectileSpeed * attrs.ProjectileSpeed,
			attackSize,
			finalDamage
		)

	end

end

return CardDealer