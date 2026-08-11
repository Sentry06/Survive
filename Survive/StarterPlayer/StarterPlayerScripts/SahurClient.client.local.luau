local player = game.Players.LocalPlayer
local cam = workspace.CurrentCamera
local rs = game:GetService("RunService")

local remotes = game.ReplicatedStorage:WaitForChild("Remotes")

local globalStats = player:WaitForChild("GlobalStats")
local selectedModifier = globalStats:WaitForChild("SelectedModifier")

local uiEvent = remotes:WaitForChild("SahurUI")
local hitFX = remotes:WaitForChild("SahurHitFX")

-------------------------------------------------
-- UI
-------------------------------------------------

local playerGui = player:WaitForChild("PlayerGui")

local gui = Instance.new("ScreenGui")
gui.Name = "SahurUI"
gui.ResetOnSpawn = false
gui.Parent = playerGui

local bar = Instance.new("Frame")
bar.Size = UDim2.new(0.3,0,0.035,0)
bar.Position = UDim2.new(0.35,0,0.9,0)
bar.BackgroundColor3 = Color3.fromRGB(20,20,20)
bar.BorderSizePixel = 0
bar.Parent = gui

local fill = Instance.new("Frame")
fill.Size = UDim2.new(0,0,1,0)
fill.BorderSizePixel = 0
fill.Parent = bar

local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new{
	ColorSequenceKeypoint.new(0, Color3.fromRGB(0,255,100)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(255,0,0))
}
gradient.Parent = fill

local text = Instance.new("TextLabel")
text.Size = UDim2.new(1,0,1,0)
text.BackgroundTransparency = 1
text.TextColor3 = Color3.new(1,1,1)
text.TextScaled = true
text.Font = Enum.Font.Merriweather
text.Text = "0%"
text.Parent = bar

gui.Enabled = (selectedModifier.Value == "SahurRage")

-------------------------------------------------
-- STATE
-------------------------------------------------

local isRage = false
local shaking = false
local aura = nil
local rageThread = nil

-------------------------------------------------
-- SHAKE
-------------------------------------------------

local function startShake()
	if shaking then return end
	shaking = true

	rs:BindToRenderStep("SahurShake", Enum.RenderPriority.Camera.Value + 1, function()
		if not shaking then return end

		local offset = Vector3.new(
			math.random(-3,3)/12,
			math.random(-3,3)/12,
			0
		)

		cam.CFrame = cam.CFrame * CFrame.new(offset)
	end)
end

local function stopShake()
	shaking = false
	rs:UnbindFromRenderStep("SahurShake")
end

-------------------------------------------------
-- AURA
-------------------------------------------------

local tungAuraThread = nil

local function startTungAura()

	if tungAuraThread then return end

	tungAuraThread = task.spawn(function()

		while isRage do

			local char = player.Character
			if not char then break end

			local root = char:FindFirstChild("HumanoidRootPart")
			if not root then break end

			local part = Instance.new("Part")
			part.Anchored = true
			part.CanCollide = false
			part.Transparency = 1

			part.CFrame = root.CFrame * CFrame.new(
				math.random(-3,3),
				math.random(2,4),
				math.random(-3,3)
			)

			part.Parent = workspace

			local billboard = Instance.new("BillboardGui")
			billboard.Size = UDim2.new(3,0,3,0)
			billboard.Parent = part

			local img = Instance.new("ImageLabel")
			img.Size = UDim2.new(1,0,1,0)
			img.BackgroundTransparency = 1
			img.Image = "rbxassetid://111313563783403"
			img.Parent = billboard

			game:GetService("Debris"):AddItem(part,0.5)

			task.wait(0.12) -- frequência da aura
		end

		tungAuraThread = nil
	end)
end
-------------------------------------------------
-- RAGE VISUAL LOOP
-------------------------------------------------

local function startRageVisual()

	if rageThread then return end

	rageThread = task.spawn(function()

		while isRage do

			fill.BackgroundTransparency = 0
			task.wait(0.08)

			fill.BackgroundTransparency = 0.4
			task.wait(0.08)

		end

		rageThread = nil
	end)
end

-------------------------------------------------
-- UI EVENT
-------------------------------------------------

uiEvent.OnClientEvent:Connect(function(percent, rage)

	if selectedModifier.Value ~= "SahurRage" then return end

	-- 🔄 sempre atualiza barra corretamente
	fill.Size = UDim2.new(percent,0,1,0)
	text.Text = math.floor(percent * 100) .. "%"

	-- 🔥 reset visual garantido
	if percent <= 0 then
		fill.Size = UDim2.new(0,0,1,0)
		text.Text = "0%"
	end

	-------------------------------------------------
	-- STATE CHANGE
	-------------------------------------------------

	if rage and not isRage then
		-- 🔥 entrou em rage

		isRage = true

		startShake()
		startTungAura()
		startRageVisual()

	elseif not rage and isRage then
		-- 🧊 saiu do rage

		isRage = false

		stopShake()
	end
end)

-------------------------------------------------
-- HIT FX (TUNG!)
-------------------------------------------------

hitFX.OnClientEvent:Connect(function()

	if selectedModifier.Value ~= "SahurRage" then return end

	local char = player.Character
	if not char then return end

	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return end

	-- 🔊 SOM (sempre toca)
	local sound = Instance.new("Sound")
	sound.SoundId = "rbxassetid://119936943126736"
	sound.Volume = 1
	sound.PlayOnRemove = true
	sound.Parent = root
	sound:Destroy()

	-- 🖼️ TUNG VISUAL (stackável)
	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.Transparency = 1
	part.CFrame = root.CFrame * CFrame.new(
		math.random(-2,2),
		3 + math.random(),
		math.random(-2,2)
	)
	part.Parent = workspace

	local billboard = Instance.new("BillboardGui")
	billboard.Size = UDim2.new(4,0,4,0)
	billboard.StudsOffset = Vector3.new(0,2,0)
	billboard.Parent = part

	local img = Instance.new("ImageLabel")
	img.Size = UDim2.new(1,0,1,0)
	img.BackgroundTransparency = 1
	img.Image = "rbxassetid://111313563783403"
	img.Parent = billboard

	game:GetService("Debris"):AddItem(part,0.35)
end)

selectedModifier:GetPropertyChangedSignal("Value"):Connect(function()

	if selectedModifier.Value == "SahurRage" then
		gui.Enabled = true
	else
		gui.Enabled = false

		-- reset visual
		fill.Size = UDim2.new(0,0,1,0)
		text.Text = "0%"

		stopShake()
	end

end)