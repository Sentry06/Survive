local MainMenu = script.Parent.Parent
local catalogScreen = MainMenu:WaitForChild("CatalogScreen")
local TweenService = game:GetService("TweenService")

local ButtonsContainer = MainMenu:WaitForChild("ButtonsContainer")
local logoContainer = MainMenu:WaitForChild("LogoContainer")
local topBar = MainMenu:WaitForChild("TopBar")
local versionText = MainMenu:WaitForChild("VersionText")

local catalogButton = ButtonsContainer.CatalogButtonContainer:WaitForChild("CatalogButton")
local backButton = catalogScreen:WaitForChild("BackButton")

local categoryTabs = catalogScreen:WaitForChild("CategoryTabs")

-- carrosséis existentes
local attributesCarousel = catalogScreen:FindFirstChild("CatalogAttributesCarousel")
local weaponsCarousel = catalogScreen:FindFirstChild("CatalogWeaponsCarousel")
local synergiesCarousel = catalogScreen:FindFirstChild("CatalogSynergiesCarousel")
local artifactsCarousel = catalogScreen:FindFirstChild("CatalogArtifactsCarousel")


local function disableAllCarousels()

	local viewer = catalogScreen.ItemViewerContainer.ItemsFrame

	local mainItem = viewer.MainItem
	local nextItem = viewer.NextBlurItem
	local prevItem = viewer.PreviousBlurItem

	for _,item in pairs({mainItem,nextItem,prevItem}) do

		if item:IsA("ImageLabel") then
			item.ImageColor3 = Color3.new(1,1,1)
		end

		local noise = item:FindFirstChild("NoiseOverlay")
		if noise then
			noise:Destroy()
		end

		local rarity = item:FindFirstChild("RarityLabel")
		if rarity then
			rarity.Visible = false
		end

	end

	if attributesCarousel then attributesCarousel.Disabled = true end
	if weaponsCarousel then weaponsCarousel.Disabled = true end
	if synergiesCarousel then synergiesCarousel.Disabled = true end
	if artifactsCarousel then artifactsCarousel.Disabled = true end

	-- 🔧 FIX BUY BUTTON
	local info = catalogScreen:FindFirstChild("InfoPanel")

	if info then
		local buy = info:FindFirstChild("BuyButton")
		if buy then
			buy.Visible = false
		end
	end

end

-- fechar catálogo
backButton.MouseButton1Click:Connect(function()

	catalogScreen.Visible = false

	ButtonsContainer.Visible = true
	logoContainer.Visible = true
	topBar.Visible = true
	versionText.Visible = true

end)


-- highlight visual da categoria
local function highlightCategory(selected)

	for _,button in pairs(categoryTabs:GetChildren()) do

		if button:IsA("TextButton") then

			local stroke = button:FindFirstChildOfClass("UIStroke")

			if stroke then
				stroke.Transparency = 1
			end

		end

	end

	local stroke = selected:FindFirstChildOfClass("UIStroke")

	if stroke then
		stroke.Transparency = 0
	end

end

local viewer = catalogScreen.ItemViewerContainer.ItemsFrame

local mainItem = viewer.MainItem
local nextItem = viewer.NextBlurItem
local prevItem = viewer.PreviousBlurItem

local function animateCategoryChange(direction)

	local offset = 0.25

	if direction == "left" then
		offset = -offset
	end

	for _,item in pairs({mainItem,nextItem,prevItem}) do

		local tween = TweenService:Create(
			item,
			TweenInfo.new(
				0.15,
				Enum.EasingStyle.Quad,
				Enum.EasingDirection.Out
			),
			{Position = item.Position + UDim2.new(offset,0,0,0)}
		)

		tween:Play()

	end

end


catalogButton.MouseButton1Click:Connect(function()

	catalogScreen.Visible = true

	ButtonsContainer.Visible = false
	logoContainer.Visible = false
	topBar.Visible = false
	versionText.Visible = false

	highlightCategory(categoryTabs.AttributesTab)

	disableAllCarousels()

	attributesCarousel.Disabled = false

end)


-- ATTRIBUTES
categoryTabs.AttributesTab.MouseButton1Click:Connect(function()

	highlightCategory(categoryTabs.AttributesTab)

	animateCategoryChange("left")

	task.wait(0.15)

	disableAllCarousels()

	if attributesCarousel then
		attributesCarousel.Disabled = false
	end

end)


-- WEAPONS
categoryTabs.WeaponsTab.MouseButton1Click:Connect(function()

	highlightCategory(categoryTabs.WeaponsTab)

	animateCategoryChange("right")

	task.wait(0.15)

	disableAllCarousels()

	if weaponsCarousel then
		weaponsCarousel.Disabled = false
	end

end)

categoryTabs.SynergiesTab.MouseButton1Click:Connect(function()

	highlightCategory(categoryTabs.SynergiesTab)

	disableAllCarousels()

	if synergiesCarousel then
		synergiesCarousel.Disabled = false
	end

end)

categoryTabs.ArtifactsTab.MouseButton1Click:Connect(function()

	highlightCategory(categoryTabs.ArtifactsTab)

	disableAllCarousels()

	if artifactsCarousel then
		artifactsCarousel.Disabled = false
	end

end)


-- abrir Attributes por padrão quando abrir o catálogo
highlightCategory(categoryTabs.AttributesTab)

if attributesCarousel then
	attributesCarousel.Disabled = false
end

if weaponsCarousel then
	weaponsCarousel.Disabled = true
end