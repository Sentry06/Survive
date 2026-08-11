local Targeting = {}

function Targeting.GetClosestEnemy(origin, enemies, maxRange)
	local closest = nil
	local closestDist = maxRange or math.huge

	for _, enemy in ipairs(enemies) do
		if enemy.Alive and enemy.Root then
			local dist = (enemy.Root.Position - origin).Magnitude
			if dist < closestDist then
				closest = enemy
				closestDist = dist
			end
		end
	end

	return closest
end

return Targeting
