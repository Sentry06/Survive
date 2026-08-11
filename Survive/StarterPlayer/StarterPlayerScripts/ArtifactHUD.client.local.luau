-- ArtifactHUD.client.lua

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local gui = playerGui:WaitForChild("ArtifactHUD")
local container = gui:WaitForChild("Container")

local icon = container:WaitForChild("Icon")
local subtitle = container:WaitForChild("Subtitle")
local timerLabel = container:WaitForChild("Timer")
local stroke = container:WaitForChild("UIStroke")

--------------------------------------------------
-- 🎨 CONFIG POR ARTEFATO
--------------------------------------------------

local ArtifactThemes = {

	Aurum = {
		Color = Color3.fromRGB(255,215,0),
		Subtitle = "Victory turns into gold.",
		Icon = "rbxassetid://80249759309977"
	},

	Congelo = {
		Color = Color3.fromRGB(150,220,255),
		Subtitle = "Time slows within the frost.",
		Icon = "rbxassetid://134244647812302"
	},

	FluxusEletricus = {
		Color = Color3.fromRGB(100,200,255),
		Subtitle = "Energy flows between souls.",
		Icon = "rbxassetid://104580272677158"
	},

	Fragor = {
		Color = Color3.fromRGB(255,200,0),
		Subtitle = "Every impact echoes.",
		Icon = "rbxassetid://117803528100164"
	},

	Gargantua = {
		Color = Color3.fromRGB(140,0,255),
		Subtitle = "Gravity bends to you.",
		Icon = "rbxassetid://114063822471365"
	},

	Ignis = {
		Color = Color3.fromRGB(255,90,0),
		Subtitle = "The flames answer your call.",
		Icon = "rbxassetid://131890005138440"
	},

	Nebula = {
		Color = Color3.fromRGB(180,0,255),
		Subtitle = "The void embraces you.",
		Icon = "rbxassetid://130406486482594"
	},

	Sanguis = {
		Color = Color3.fromRGB(200,0,0),
		Subtitle = "The blood always returns to your body.",
		Icon = "rbxassetid://128312303589197"
	},

	TempusStans = {
		Color = Color3.fromRGB(200,220,255),
		Subtitle = "Only you move forward.",
		Icon = "rbxassetid://94268961835674"
	},
}

--------------------------------------------------
-- ✨ ANIMAÇÕES
--------------------------------------------------

local pulseTween
local iconGlowTween

local function startPulse()
	if pulseTween then return end

	pulseTween = TweenService:Create(
		stroke,
		TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
		{Thickness = 4}
	)

	pulseTween:Play()
end

local function stopPulse()
	if pulseTween then
		pulseTween:Cancel()
		pulseTween = nil
	end
	stroke.Thickness = 2
end

local function startIconGlow()
	if iconGlowTween then return end

	iconGlowTween = TweenService:Create(
		icon,
		TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
		{ImageTransparency = 0.25}
	)

	iconGlowTween:Play()
end

local function stopIconGlow()
	if iconGlowTween then
		iconGlowTween:Cancel()
		iconGlowTween = nil
	end
	icon.ImageTransparency = 0
end

--------------------------------------------------
-- 🔁 LOOP
--------------------------------------------------

RunService.RenderStepped:Connect(function()

	local artifactId = player:GetAttribute("ActiveArtifact")
	local endsAt = player:GetAttribute("ArtifactEndsAt")

	if not artifactId or not endsAt then
		container.Visible = false
		stopPulse()
		stopIconGlow()
		return
	end

	local remaining = math.max(0, endsAt - os.clock())

	if remaining <= 0 then
		container.Visible = false
		stopPulse()
		stopIconGlow()
		return
	end

	local theme = ArtifactThemes[artifactId]
	if not theme then return end

	container.Visible = true

	stroke.Color = theme.Color
	icon.Image = theme.Icon
	subtitle.Text = theme.Subtitle
	timerLabel.Text = string.format("%.1fs", remaining)

	--------------------------------------------------
	-- 🔴 Timer vermelho abaixo de 10s
	--------------------------------------------------
	if remaining <= 10 then
		timerLabel.TextColor3 = Color3.fromRGB(255,60,60)
	else
		timerLabel.TextColor3 = Color3.new(1,1,1)
	end

	--------------------------------------------------
	-- 💥 Stroke pulsando abaixo de 5s
	--------------------------------------------------
	if remaining <= 5 then
		startPulse()
	else
		stopPulse()
	end

	--------------------------------------------------
	-- ✨ Glow contínuo no ícone
	--------------------------------------------------
	startIconGlow()

end)
