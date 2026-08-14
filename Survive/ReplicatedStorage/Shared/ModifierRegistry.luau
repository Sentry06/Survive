local ModifierRegistry = {}

local DamageService = require(game.ServerScriptService.Combat.DamageService)

local GamePauseService = require(game.ServerScriptService:WaitForChild("GamePauseService"))

ModifierRegistry.Definitions = {

	BossSlayer = {
		Id = "BossSlayer",
		DisplayName = "Boss Slayer",
		Description = "+35% damage against bosses",
		Type = "ON_HIT",

		OnHit = function(player, enemy, damageData)

			if not enemy then return end

			local isBoss =
				enemy:GetAttribute("IsBoss")
				or enemy:GetAttribute("IsFinalBoss")

			-- fallback (caso você use tabela interna também)
			if not isBoss and enemy:FindFirstChild("Humanoid") then
				if enemy.Name:lower():find("boss") then
					isBoss = true
				end
			end

			if isBoss then
				damageData.Multiplier *= 1.35
				print("🗡️ Boss Slayer ATIVADO!")
				print("IS BOSS?", enemy:GetAttribute("IsBoss"), enemy.Name)
			end

		end
	},

	FastBuilder = {
		Id = "FastBuilder",
		DisplayName = "Fast Builder",
		Description = "+50% Projectile Speed",
		Type = "STAT",

		Apply = function(player)

			local stats = player:FindFirstChild("MatchStats")
			if not stats then return end

			local attrs = stats:FindFirstChild("Attributes")
			if not attrs then return end

			local proj = attrs:FindFirstChild("ProjectileSpeed")
			if not proj then return end

			proj.Value = proj.Value * 1.5

			print("🧱 Fast Builder aplicado! ProjectileSpeed:", proj.Value)

		end
	},

	MomAim = {
		Id = "MomAim",
		DisplayName = "Mom Aim",
		Description = "+50% damage on low HP enemies",
		Type = "ON_HIT",

		OnHit = function(player, enemy, damageData)

			if not enemy or not enemy.Humanoid then return end

			local hp = enemy.Humanoid.Health
			local max = enemy.Humanoid.MaxHealth

			if max > 0 and (hp / max) <= 0.5 then

				-- 💀 EXECUTA
				damageData.Amount = hp

				local ReplicatedStorage = game:GetService("ReplicatedStorage")
				local Remotes = ReplicatedStorage:WaitForChild("Remotes")
				local MomAimEffect = Remotes:WaitForChild("MomAimEffect")

				print("🩴 Mom Aim aplicado!")

				MomAimEffect:FireClient(player)

			end

		end
	},
	
	BaileDeFavela = {
		Id = "BaileDeFavela",
		DisplayName = "Baile de Favela",
		Description = "Combo increases AreaDamage. Taking damage resets.",
		Type = "ON_HIT",

		Apply = function(player)
			player:SetAttribute("BaileStacks", 0)
			player:SetAttribute("BaileExpire", 0)

			local ReplicatedStorage = game:GetService("ReplicatedStorage")
			local model = ReplicatedStorage.Weapons.Pancadao.Pancadao:Clone()
			model.Parent = workspace

			local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
			if root and model.PrimaryPart then
				model:PivotTo(root.CFrame * CFrame.new(3,0,0))
			end

			-- garantir PrimaryPart
			if not model.PrimaryPart then
				model.PrimaryPart = model:FindFirstChildWhichIsA("BasePart")
			end

			if not model.PrimaryPart then
				warn("❌ Pancadao sem PrimaryPart")
				return
			end

			-- 🔊 SOM (FIX REAL)
			local sound = Instance.new("Sound")
			sound.SoundId = "rbxassetid://140616909380324"
			sound.Looped = true
			sound.Volume = 1
			sound.RollOffMaxDistance = 100
			sound.Parent = model.PrimaryPart

			task.spawn(function()
				sound:Play()
				print("🔊 SOM INICIADO")
			end)
			local conn

			conn = game:GetService("RunService").Heartbeat:Connect(function()

				if not player.Character or not model.Parent then
					conn:Disconnect()
					return
				end

				local root = player.Character:FindFirstChild("HumanoidRootPart")
				if root then
					model:PivotTo(root.CFrame * CFrame.new(3,0,0))
				end

			end)
		end,

		OnHit = function(player)

			print("💥 HIT DETECTADO")
			local now = tick()

			local stacks = player:GetAttribute("BaileStacks") or 0
			local expire = player:GetAttribute("BaileExpire") or 0

			if now > expire then
				stacks = 0
			end

			stacks += 1
			stacks = math.min(stacks, 100)

			player:SetAttribute("BaileStacks", stacks)
			player:SetAttribute("BaileExpire", now + 5)

			-- aplica no Attributes (CORRETO)
			local attrs = player.MatchStats.Attributes
			local area = attrs.AreaDamage

			local bonus = stacks * 0.12
			player:SetAttribute("AreaDamageBonus", bonus)

			print("📡 ENVIANDO COMBO:", stacks)

			-- 🔥 envia pro client (UI)
			local Remotes = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")
			local BaileCombo = Remotes:WaitForChild("BaileCombo")

			BaileCombo:FireClient(player, stacks)

		end,
		
		OnKill = function(player)

			local stacks = player:GetAttribute("BaileStacks") or 0

			stacks += 1
			stacks = math.min(stacks, 50)

			player:SetAttribute("BaileStacks", stacks)
			player:SetAttribute("BaileExpire", tick() + 4)

			-- aplica bônus
			local attrs = player.MatchStats.Attributes
			attrs.AreaDamage.Value = 0.5 + (stacks * 0.05)

			print("🔊 Baile (KILL):", stacks)

			game.ReplicatedStorage.Remotes.BaileCombo:FireClient(player, stacks)

		end
	},

	-------------------------------------------------
	-- SAHUR BAT → SAHUR RAGE
	-------------------------------------------------
	SahurRage = {
		Id = "SahurRage",
		DisplayName = "Sahur Rage",
		Description = "Build rage and unleash TUNG MODE.",
		Type = "ON_HIT",

		Apply = function(player)

			player:SetAttribute("SahurPower", 0)
			player:SetAttribute("SahurActive", false)
			player:SetAttribute("SahurExpire", 0)
			player:SetAttribute("SahurBuffApplied", false)

			game.ReplicatedStorage.Remotes.SahurUI:FireClient(player, 0, false)
		end,

		OnHit = function(player, enemy, damageData)

			local GameState = game.ReplicatedStorage:WaitForChild("GameState")
			local ElapsedTime = GameState:WaitForChild("ElapsedTime")

			local now = ElapsedTime.Value

			local power = player:GetAttribute("SahurPower") or 0
			local active = player:GetAttribute("SahurActive") or false
			local expire = player:GetAttribute("SahurExpire") or 0
			local buffApplied = player:GetAttribute("SahurBuffApplied") or false

			-------------------------------------------------
			-- 🔥 RAGE ATIVO
			-------------------------------------------------

			if active then

				-- ⏱ terminou o rage
				if now > expire then

					player:SetAttribute("SahurActive", false)
					player:SetAttribute("SahurExpire", 0)
					player:SetAttribute("SahurPower", 0)

					-- ✅ REMOVER BUFF CORRETAMENTE
					if buffApplied then
						local stats = player.MatchStats.ModifierBonuses

						stats.Damage.Value = player:GetAttribute("Sahur_Damage") or 1
						stats.AttackSize.Value = player:GetAttribute("Sahur_AttackSize") or 1
						stats.Cooldown.Value = player:GetAttribute("Sahur_Cooldown") or 1

						player:SetAttribute("SahurBuffApplied", false)
					end

					game.ReplicatedStorage.Remotes.SahurUI:FireClient(player, 0, false)

					-- 🔇 parar música
					local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
					if root then
						local music = root:FindFirstChild("SahurMusic")
						if music then
							music:Destroy()
						end
					end

					return
				end

				-- ✅ APLICA BUFF UMA VEZ (SALVANDO ESTADO)
				if not buffApplied then

					local stats = player.MatchStats.ModifierBonuses

					-- 💾 SALVAR VALORES ATUAIS
					player:SetAttribute("Sahur_Damage", stats.Damage.Value)
					player:SetAttribute("Sahur_AttackSize", stats.AttackSize.Value)
					player:SetAttribute("Sahur_Cooldown", stats.Cooldown.Value)

					-- 💥 APLICAR BUFF
					stats.Damage.Value *= 1.4
					stats.AttackSize.Value *= 1.25
					stats.Cooldown.Value *= 0.7

					player:SetAttribute("SahurBuffApplied", true)
				end

				-- 🔊 FX por hit
				game.ReplicatedStorage.Remotes.SahurHitFX:FireClient(player)

				return
			end

			-------------------------------------------------
			-- 📈 BUILDUP
			-------------------------------------------------

			power += 1
			player:SetAttribute("SahurPower", power)

			local percent = math.clamp(power / 20, 0, 1)

			game.ReplicatedStorage.Remotes.SahurUI:FireClient(player, percent, false)

			-------------------------------------------------
			-- 🚀 ATIVAR RAGE
			-------------------------------------------------

			if power >= 20 then

				if active then
					return
				end

				player:SetAttribute("SahurPower", 0)
				player:SetAttribute("SahurActive", true)
				player:SetAttribute("SahurExpire", now + 10)

				game.ReplicatedStorage.Remotes.SahurUI:FireClient(player, 1, true)

				-- 🎵 música
				local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")

				if root and not root:FindFirstChild("SahurMusic") then

					local music = Instance.new("Sound")
					music.Name = "SahurMusic"
					music.SoundId = "rbxassetid://127986736802075"
					music.Looped = true
					music.Volume = 1
					music.Parent = root
					music:Play()
				end
			end
		end,
	},
	
	-------------------------------------------------
	-- 🪃 BOOMERANG → RETALIATION
	-------------------------------------------------
	Retaliation = {
		Id = "Retaliation",
		DisplayName = "Retaliation",
		Description = "Build momentum by chaining hits",
		Type = "ON_HIT",

		Apply = function(player)

			player:SetAttribute("RetaliationStacks", 0)
			player:SetAttribute("RetaliationExpire", 0)
			player:SetAttribute("RetaliationActive", false)

			local GameState = game.ReplicatedStorage:WaitForChild("GameState")
			local ElapsedTime = GameState:WaitForChild("ElapsedTime")

			-- 🧠 LOOP DE DECAY (CORRIGIDO)
			task.spawn(function()

				while player and player.Parent do

					local now = ElapsedTime.Value
					local expire = player:GetAttribute("RetaliationExpire") or 0
					local active = player:GetAttribute("RetaliationActive")

					-- 🔴 só executa UMA VEZ quando termina
					if active and now > expire then

						player:SetAttribute("RetaliationStacks", 0)
						player:SetAttribute("RetaliationActive", false)

						local stats = player.MatchStats.ModifierBonuses
						stats.ProjectileSpeed.Value = 1

					end

					task.wait(0.2)
				end

			end)

		end,

		OnHit = function(player, enemy, damageData)

			local GameState = game.ReplicatedStorage:WaitForChild("GameState")
			local ElapsedTime = GameState:WaitForChild("ElapsedTime")

			local now = ElapsedTime.Value

			local stacks = player:GetAttribute("RetaliationStacks") or 0

			-------------------------------------------------
			-- 📈 STACK
			-------------------------------------------------

			stacks += 1
			stacks = math.clamp(stacks, 0, 30)

			player:SetAttribute("RetaliationStacks", stacks)
			player:SetAttribute("RetaliationExpire", now + 2)
			player:SetAttribute("RetaliationActive", true)

			-------------------------------------------------
			-- 💥 SCALING (NOVA CURVA)
			-------------------------------------------------

			local bonus =
				1
				+ (stacks * 0.05)
				+ ((stacks ^ 1.2) * 0.01)

			damageData.Multiplier *= bonus

			-------------------------------------------------
			-- ⚡ VELOCIDADE (MAIS FORTE)
			-------------------------------------------------

			local stats = player.MatchStats.ModifierBonuses

			stats.ProjectileSpeed.Value =
				1 + (stacks * 0.03)

			if stacks >= 30 then
				damageData.Multiplier *= 1.5
			end

		end
	},
	
	-- 🍾 MOLOTOV → GREAT COMBUSTION
	-------------------------------------------------

	GreatCombustion = {
		Id = "GreatCombustion",
		DisplayName = "Great Combustion",
		Description = "Kills trigger volatile fire reactions",
		Type = "ON_KILL",

		OnKill = function(player, enemy)

			if not enemy then return end

			local root = enemy.Root
			if not root then return end

			local pos = root.Position

			local EnemyDamageService = require(game.ServerScriptService.Combat.EnemyDamageService)
			local DamageService = require(game.ServerScriptService.Combat.DamageService)

			-------------------------------------------------
			-- 🔥 ZONA DE FOGO
			-------------------------------------------------

			local radius = 4
			local duration = 3
			local tickRate = 0.5
			local damage = 12
			local playerDamage = 15 -- 🔥 NERF

			local part = Instance.new("Part")
			part.Anchored = true
			part.CanCollide = false
			part.Size = Vector3.new(6, 0.2, 6)
			part.Position = pos
			part.Color = Color3.fromRGB(30, 10, 10)
			part.Material = Enum.Material.SmoothPlastic
			part.Transparency = 0.2

			local decal = Instance.new("Decal")
			decal.Texture = "rbxassetid://130207099"
			decal.Face = Enum.NormalId.Top
			decal.Parent = part

			part.Parent = workspace

			-- 🔥 FIRE
			local fire = Instance.new("ParticleEmitter")
			fire.Texture = "rbxasset://textures/particles/fire_main.dds"
			fire.Rate = 40
			fire.Lifetime = NumberRange.new(0.6, 1.2)
			fire.Speed = NumberRange.new(2, 4)
			fire.Rotation = NumberRange.new(0, 360)
			fire.RotSpeed = NumberRange.new(-50, 50)
			fire.Size = NumberSequence.new{
				NumberSequenceKeypoint.new(0, 1),
				NumberSequenceKeypoint.new(1, 0)
			}
			fire.Color = ColorSequence.new{
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255,170,0)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(255,0,0))
			}
			fire.Transparency = NumberSequence.new{
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(1, 1)
			}
			fire.Parent = part

			-- 💨 SMOKE
			local smoke = Instance.new("ParticleEmitter")
			smoke.Texture = "rbxasset://textures/particles/smoke_main.dds"
			smoke.Rate = 30
			smoke.Lifetime = NumberRange.new(1.5, 2.5)
			smoke.Speed = NumberRange.new(1, 2)
			smoke.Size = NumberSequence.new{
				NumberSequenceKeypoint.new(0, 1.5),
				NumberSequenceKeypoint.new(1, 3)
			}
			smoke.Transparency = NumberSequence.new{
				NumberSequenceKeypoint.new(0, 0.3),
				NumberSequenceKeypoint.new(1, 1)
			}
			smoke.Color = ColorSequence.new(Color3.fromRGB(50,50,50))
			smoke.Parent = part

			-- 💡 LIGHT
			local light = Instance.new("PointLight")
			light.Color = Color3.fromRGB(255,120,0)
			light.Range = 10
			light.Brightness = 2
			light.Parent = part

			game:GetService("Debris"):AddItem(part, duration)

			-------------------------------------------------
			-- 🔁 LOOP DE DANO
			-------------------------------------------------

			task.spawn(function()

				local start = tick()

				while tick() - start < duration do

					-- 🔥 INIMIGOS
					for _, e in ipairs(_G.Enemies or {}) do
						if e.Alive and e.Root and e.Humanoid then
							local dist = (e.Root.Position - pos).Magnitude

							if dist <= radius then
								EnemyDamageService:DamageEnemy(player, e.Humanoid, damage)
							end
						end
					end

					-- 🧨 PLAYER (NERF)
					DamageService:TryDamagePlayer(part, playerDamage, radius)

					task.wait(tickRate)
				end

			end)

			-------------------------------------------------
			-- 💥 EXPLOSÃO
			-------------------------------------------------

			if math.random() < 0.45 then

				local explosionRadius = 6
				local explosionDamage = 35

				for _, e in ipairs(_G.Enemies or {}) do

					if e.Alive and e.Root and e.Humanoid then

						local dist = (e.Root.Position - pos).Magnitude

						if dist <= explosionRadius then

							EnemyDamageService:DamageEnemy(player, e.Humanoid, explosionDamage)

							-------------------------------------------------
							-- 🔁 MINI CHAIN
							-------------------------------------------------

							if math.random() < 0.25 then

								local subPos = e.Root.Position

								for _, sub in ipairs(_G.Enemies or {}) do

									if sub.Alive and sub.Root and sub.Humanoid then

										local d = (sub.Root.Position - subPos).Magnitude

										if d <= 4 then
											EnemyDamageService:DamageEnemy(player, sub.Humanoid, 15)
										end
									end
								end
							end
						end
					end
				end
			end
		end,
	},

	-------------------------------------------------
	-- 🃏 Gambler
	-------------------------------------------------

	Gambler = {
		Id = "Gambler",
		DisplayName = "Gambler",
		Description = "Bet your kills for permanent buffs",
		Type = "SYSTEM",

		Apply = function(player)

			player:SetAttribute("GamblerKills", 0)
			player:SetAttribute("GamblerTarget", 50)
			player:SetAttribute("GamblerRolling", false)

		end,

		OnKill = function(player)

			if player:GetAttribute("GamblerRolling") then return end

			local kills = (player:GetAttribute("GamblerKills") or 0) + 1
			local target = player:GetAttribute("GamblerTarget") or 50

			player:SetAttribute("GamblerKills", kills)

			-------------------------------------------------
			-- 📊 UPDATE UI
			-------------------------------------------------
			game.ReplicatedStorage.Remotes.GamblerUI:FireClient(player, kills, target)

			-------------------------------------------------
			-- 🎰 ATIVA ROLETA
			-------------------------------------------------
			if kills >= target then

				GamePauseService:AddPause("Gambler")

				player:SetAttribute("GamblerRolling", true)

				local Remotes = game.ReplicatedStorage.Remotes
				local rollRemote = Remotes:WaitForChild("GamblerRoll")

				-------------------------------------------------
				-- 🎴 CARTAS
				-------------------------------------------------

				local cards = {
					"Ace",
					"King",
					"Queen",
					"Jack",
					"Joker"
				}

				local chosenCard = cards[math.random(1,#cards)]

				-------------------------------------------------
				-- 💎 VALORES
				-------------------------------------------------

				local multipliers = {1.15,1.25,1.35,1.5,1.75,2,3}
				local additives = {5,10,15,20,40,50}

				local isAdd = (chosenCard == "Joker")

				local value = isAdd
					and additives[math.random(1,#additives)]
					or multipliers[math.random(1,#multipliers)]

				-------------------------------------------------
				-- 🎰 ENVIA PRO CLIENT (ANIMAÇÃO)
				-------------------------------------------------

				rollRemote:FireClient(player, chosenCard, value, isAdd)

				-------------------------------------------------
				-- ⏳ ESPERA ANIMAÇÃO
				-------------------------------------------------

				local finishedRemote = Remotes:WaitForChild("GamblerFinished")

				finishedRemote.OnServerEvent:Connect(function(playerWhoFinished)

					if playerWhoFinished ~= player then return end

					local stats = player.MatchStats.Attributes

					local map = {
						Ace = "Damage",
						King = "AttackSize",
						Queen = "Range",
						Jack = "ProjectileSpeed",
						Joker = "MultiAttack"
					}

					local stat = map[chosenCard]
					local attr = stats:FindFirstChild(stat)

					if attr then
						if isAdd then
							attr.Value += value
						else
							attr.Value *= value
						end
					end

					-- reset
					player:SetAttribute("GamblerKills", 0)
					player:SetAttribute("GamblerTarget", target * 2)
					player:SetAttribute("GamblerRolling", false)

					game.ReplicatedStorage.Remotes.GamblerUI:FireClient(player, 0, target * 2)

					-- ▶️ DESPAUSA AQUI (CORRETO)
					GamePauseService:RemovePause("Gambler")

				end)
			end
		end
	},

	-------------------------------------------------
	-- 🧪 SCP → THE ███████ ARE YOUR SALVATION
	-------------------------------------------------

	THEAREYOURSALVATION = {
		Id = "THEAREYOURSALVATION",
		DisplayName = "THE ███████ ARE YOUR SALVATION",
		Description = "WHEN YOU NEED THE MOST, THE ███████ WILL SAVE YOU",
		Type = "PASSIVE",

		Apply = function(player)

			player:SetAttribute("SCP_SalvationCooldown", 0)
			player:SetAttribute("SCP_SalvationActive", false)

			local GameState = game.ReplicatedStorage:WaitForChild("GameState")
			local ElapsedTime = GameState:WaitForChild("ElapsedTime")

			task.spawn(function()

				while player and player.Parent do

					task.wait(0.2)

					local char = player.Character
					local humanoid = char and char:FindFirstChildOfClass("Humanoid")

					if not humanoid or humanoid.Health <= 0 then
						continue
					end

					local hp = humanoid.Health

					local now = ElapsedTime.Value
					local cd = player:GetAttribute("SCP_SalvationCooldown") or 0
					local active = player:GetAttribute("SCP_SalvationActive")

					-------------------------------------------------
					-- ATIVAÇÃO
					-------------------------------------------------

					if hp <= 30 and not active and now >= cd then

						player:SetAttribute("SCP_SalvationActive", true)
						game.ReplicatedStorage.Remotes.SCPAlert:FireClient(player)
						player:SetAttribute("SCP_SalvationCooldown", now + 120) -- 2 min

						local SCPModule = require(
							game.ServerScriptService.Weapons:WaitForChild("SCPNecromancer")
						)

						-- cria uma instância fake da arma
						local fakeWeapon = SCPModule.new(player, nil)

						-- attrs básicos (IMPORTANTE)
						local attrs = player.MatchStats.Attributes

						local root = char:FindFirstChild("HumanoidRootPart")

						if root then

							local folder = game.ReplicatedStorage.Weapons.SCPNecromancer:GetChildren()

							local radius = 6
							local total = #folder
							local index = 0

							for _,template in ipairs(folder) do

								index += 1

								local angle = (index / total) * math.pi * 2

								local offset = Vector3.new(
									math.cos(angle) * radius,
									0,
									math.sin(angle) * radius
								)

								local spawnPos = root.Position + offset

								fakeWeapon:SpawnSCP(spawnPos, {
									Damage = attrs.Damage.Value,
									Range = attrs.Range.Value,
									AttackSize = attrs.AttackSize.Value,
									MovementSpeed = attrs.MovementSpeed.Value,
									MultiAttack = attrs.MultiAttack.Value
								}, template)

							end

						end

						-------------------------------------------------
						-- DURAÇÃO (30s)
						-------------------------------------------------

						task.delay(30, function()
							if player then
								player:SetAttribute("SCP_SalvationActive", false)
							end
						end)

					end

				end

			end)

		end
	},

	EliteStriker = {
		Id = "EliteStriker",
		DisplayName = "Elite Striker",
		Description = "Keep your streak to deal massive damage",
		Type = "ON_KILL",

		Apply = function(player)

			player:SetAttribute("StrikerCombo", 0)
			player:SetAttribute("StrikerGoals", 0)
			player:SetAttribute("HasEliteStriker", true)

		end,

		OnKill = function(player)

			local combo = (player:GetAttribute("StrikerCombo") or 0) + 1
			local goals = (player:GetAttribute("StrikerGoals") or 0) + 1

			player:SetAttribute("StrikerCombo", combo)
			player:SetAttribute("StrikerGoals", goals)

			local stats = player.MatchStats.ModifierBonuses

			-------------------------------------------------
			-- ⚽ DAMAGE (APENAS MULTIPLICADOR)
			-------------------------------------------------

			local multiplier = 1 + (combo * 0.02)
			stats.Damage.Value = multiplier

			print("⚽ DAMAGE BONUS:")
			print("Combo:", combo)
			print("Multiplier:", multiplier)
			print("------------------------")

			-------------------------------------------------
			-- ⚽ GOAL SYSTEM (PERMANENTE)
			-------------------------------------------------

			if goals >= 50 then

				player:SetAttribute("StrikerGoals", 0)

				local oldMulti = stats.MultiAttack.Value
				local newMulti = oldMulti + 2

				stats.MultiAttack.Value = newMulti

				-- aplica também nos Attributes (porque sua arma usa isso)
				local attr = player.MatchStats.Attributes
				if attr and attr:FindFirstChild("MultiAttack") then
					attr.MultiAttack.Value += 2
				end

				print("🥅 GOAL! MULTI ATTACK UPGRADE:")
				print("Player:", player.Name)
				print("Old Multi:", oldMulti)
				print("New Multi:", newMulti)
				print("========================")

				game.ReplicatedStorage.Remotes.StrikerGoal:FireClient(player)

			end

			-------------------------------------------------
			-- UI
			-------------------------------------------------

			game.ReplicatedStorage.Remotes.StrikerUI:FireClient(
				player,
				combo,
				goals
			)

		end
	},

}

-------------------------------------------------
-- GET
-------------------------------------------------

function ModifierRegistry:Get(id)
	return self.Definitions[id]
end

return ModifierRegistry