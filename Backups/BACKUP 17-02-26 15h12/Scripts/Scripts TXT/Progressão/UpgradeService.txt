-- UpgradeService.server
-- Apenas define QUAIS upgrades existem na RUN
-- Aplicação real acontece no PickUpgrade.server

local UpgradeService = {}

-- 📊 DEFINIÇÃO ÚNICA DE UPGRADES
local UPGRADE_POOL = {
	{ Id = "Damage", Name = "Dano +" , MaxLevel = 50 },
	{ Id = "Cooldown", Name = "Recarga -" , MaxLevel = 30 },
	{ Id = "Range", Name = "Alcance +" , MaxLevel = 30 },
	{ Id = "AttackSize", Name = "Tamanho do Ataque +" , MaxLevel = 30 },
	{ Id = "MultiAttack", Name = "Ataque Múltiplo +" , MaxLevel = math.huge },

	-- 🛡️ DEFESA
	{ Id = "Shield", Name = "Escudo +" , MaxLevel = 50 },
	{ Id = "ShieldRegenDelay", Name = "Recarga do Escudo -" , MaxLevel = 20 },
	{ Id = "MaxHP", Name = "Vida Máxima +" , MaxLevel = 30 },
	{ Id = "LifeRegen", Name = "Regeneração de Vida +" , MaxLevel = 30 },

	-- 🏃 MOBILIDADE
	{ Id = "MovementSpeed", Name = "Velocidade de Movimento +" , MaxLevel = 25 },

	-- 🔫 PROJÉTIL
	{ Id = "ProjectileSpeed", Name = "Velocidade do Projétil +" , MaxLevel = 25 },
	{ Id = "ProjectilePierce", Name = "Perfuração +" , MaxLevel = 20 },
	{ Id = "AreaDamage", Name = "Dano em Área +" , MaxLevel = 20 },
}

-- =========================
-- RETORNA UPGRADES VÁLIDOS
-- =========================
function UpgradeService:GetAvailableUpgrades(player)
	local result = {}

	local matchStats = player:FindFirstChild("MatchStats")
	if not matchStats then return result end

	local attrs = matchStats:FindFirstChild("Attributes")
	if not attrs then return result end

	for _, upgrade in ipairs(UPGRADE_POOL) do
		local stat = attrs:FindFirstChild(upgrade.Id)
		if stat then
			if upgrade.MaxLevel == math.huge or stat.Value < upgrade.MaxLevel then
				table.insert(result, upgrade.Id)
			end
		end
	end

	return result
end

return UpgradeService
