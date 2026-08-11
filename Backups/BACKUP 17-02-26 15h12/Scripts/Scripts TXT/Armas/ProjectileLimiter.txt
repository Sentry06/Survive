-- ProjectileLimiter.lua
-- Limita projéteis ativos POR JOGADOR

local ProjectileLimiter = {}
ProjectileLimiter.__index = ProjectileLimiter

function ProjectileLimiter.new(maxProjectiles)
	local self = setmetatable({}, ProjectileLimiter)

	self.Max = maxProjectiles or 30
	self.Active = 0

	return self
end

function ProjectileLimiter:CanSpawn()
	return self.Active < self.Max
end

function ProjectileLimiter:GetAvailable()
	return math.max(0, self.Max - self.Active)
end

-- 🔥 ADICIONAR
function ProjectileLimiter:OnSpawn()
	self.Active += 1
end

-- 🔥 ADICIONAR
function ProjectileLimiter:OnDestroy()
	self.Active = math.max(0, self.Active - 1)
end

return ProjectileLimiter
