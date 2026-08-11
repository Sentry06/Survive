local EnemyTimeController = {}

local freezeCount = 0
local slowMultiplier = 1

-- =========================
-- FREEZE
-- =========================
function EnemyTimeController:AddFreeze()
	freezeCount += 1
	print("AddFreeze →", freezeCount)
end

function EnemyTimeController:RemoveFreeze()
	freezeCount = math.max(0, freezeCount - 1)
	print("RemoveFreeze →", freezeCount)
end

function EnemyTimeController:IsFrozen()
	return freezeCount > 0
end

-- =========================
-- SLOW
-- =========================
function EnemyTimeController:SetSlow(mult)
	slowMultiplier = mult
	print("SlowMultiplier →", mult)
end

function EnemyTimeController:GetSlow()
	return slowMultiplier
end

return EnemyTimeController
