print("Hello world, from client!")

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")
local RunService = game:GetService("RunService")
local ContextActionService = game:GetService("ContextActionService")

local player = Players.LocalPlayer
local yapRemotes = ReplicatedStorage:WaitForChild("YapRemotes")
local yapEvent = yapRemotes:WaitForChild("YapEvent")

print("Hello world, from Yapping Simulator client!")

-- Create the yapping UI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "YappingGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = player.PlayerGui

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 200, 0, 250)
mainFrame.Position = UDim2.new(0.85, 0, 0.5, -125)
mainFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title"
titleLabel.Size = UDim2.new(1, 0, 0, 40)
titleLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Text = "Yapping Simulator"
titleLabel.TextSize = 18
titleLabel.Parent = mainFrame

local yapButton = Instance.new("TextButton")
yapButton.Name = "YapButton"
yapButton.Size = UDim2.new(0.8, 0, 0, 50)
yapButton.Position = UDim2.new(0.1, 0, 0.3, 0)
yapButton.BackgroundColor3 = Color3.fromRGB(85, 170, 255)
yapButton.TextColor3 = Color3.fromRGB(255, 255, 255)
yapButton.Font = Enum.Font.GothamBold
yapButton.Text = "YAP!"
yapButton.TextSize = 24
yapButton.Parent = mainFrame

local upgradeButton = Instance.new("TextButton")
upgradeButton.Name = "UpgradeButton"
upgradeButton.Size = UDim2.new(0.8, 0, 0, 40)
upgradeButton.Position = UDim2.new(0.1, 0, 0.5, 0)
upgradeButton.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
upgradeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
upgradeButton.Font = Enum.Font.GothamBold
upgradeButton.Text = "Upgrade Voice"
upgradeButton.TextSize = 16
upgradeButton.Parent = mainFrame

local statsFrame = Instance.new("Frame")
statsFrame.Name = "StatsFrame"
statsFrame.Size = UDim2.new(0.9, 0, 0, 80)
statsFrame.Position = UDim2.new(0.05, 0, 0.7, 0)
statsFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
statsFrame.BorderSizePixel = 0
statsFrame.Parent = mainFrame

local statsYapPower = Instance.new("TextLabel")
statsYapPower.Name = "YapPowerStat"
statsYapPower.Size = UDim2.new(1, 0, 0.5, 0)
statsYapPower.BackgroundTransparency = 1
statsYapPower.TextColor3 = Color3.fromRGB(255, 255, 255)
statsYapPower.Font = Enum.Font.Gotham
statsYapPower.Text = "Yap Power: 1"
statsYapPower.TextSize = 14
statsYapPower.Parent = statsFrame

local statsNextUpgrade = Instance.new("TextLabel")
statsNextUpgrade.Name = "NextUpgradeStat"
statsNextUpgrade.Size = UDim2.new(1, 0, 0.5, 0)
statsNextUpgrade.Position = UDim2.new(0, 0, 0.5, 0)
statsNextUpgrade.BackgroundTransparency = 1
statsNextUpgrade.TextColor3 = Color3.fromRGB(200, 200, 200)
statsNextUpgrade.Font = Enum.Font.Gotham
statsNextUpgrade.Text = "Next Upgrade: 10 YP"
statsNextUpgrade.TextSize = 14
statsNextUpgrade.Parent = statsFrame

-- Add notification system
local notificationFrame = Instance.new("Frame")
notificationFrame.Name = "NotificationFrame"
notificationFrame.Size = UDim2.new(0, 250, 0, 40)
notificationFrame.Position = UDim2.new(0.5, -125, 0.2, 0)
notificationFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
notificationFrame.BorderColor3 = Color3.fromRGB(255, 200, 0)
notificationFrame.BorderSizePixel = 2
notificationFrame.Visible = false
notificationFrame.Parent = screenGui

local notificationText = Instance.new("TextLabel")
notificationText.Name = "NotificationText"
notificationText.Size = UDim2.new(1, 0, 1, 0)
notificationText.BackgroundTransparency = 1
notificationText.TextColor3 = Color3.fromRGB(255, 255, 255)
notificationText.Font = Enum.Font.GothamBold
notificationText.Text = ""
notificationText.TextSize = 14
notificationText.TextWrapped = true
notificationText.Parent = notificationFrame

-- Replace the clickAnywhere button code with this approach

-- REMOVE the old clickAnywhere button completely
-- Instead, use a camera control override approach

-- This function will be called when mouse input happens in the 3D world
local function handleWorldClick(raycastResult, mousePosition)
	if not raycastResult then
		return
	end

	-- We clicked in the 3D world (not on UI), so yap
	yap()

	-- Create visual effect at click position
	local yapClickEffect = Instance.new("ImageLabel")
	yapClickEffect.Size = UDim2.new(0, 30, 0, 30)
	yapClickEffect.Position = UDim2.new(0, mousePosition.X - 15, 0, mousePosition.Y - 15)
	yapClickEffect.BackgroundTransparency = 1
	yapClickEffect.Image = "rbxassetid://6337354996" -- Sound wave image
	yapClickEffect.ImageColor3 = Color3.fromHSV(math.random(), 1, 1)
	yapClickEffect.Parent = screenGui

	-- Animate and remove
	local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local tween = game:GetService("TweenService"):Create(yapClickEffect, tweenInfo, {
		Size = UDim2.new(0, 60, 0, 60),
		ImageTransparency = 1,
	})
	tween:Play()
	tween.Completed:Connect(function()
		yapClickEffect:Destroy()
	end)
end

-- Create a better mouse input handler
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end

	-- Handle mouse clicks
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		-- Get mouse position and check what was clicked
		local mouse = player:GetMouse()

		-- Use a raycast to determine if we clicked UI or world
		local guiObjectsAtPosition = player.PlayerGui:GetGuiObjectsAtPosition(mouse.X, mouse.Y)
		local clickedNonUIObject = #guiObjectsAtPosition == 0

		-- Check if we clicked any meaningful UI element
		for _, obj in ipairs(guiObjectsAtPosition) do
			-- If this is an important UI element that should handle the click
			if obj:IsA("TextButton") or obj:IsA("ImageButton") then
				clickedNonUIObject = false
				break
			end
		end

		-- If we didn't click on UI, handle it as a world click
		if clickedNonUIObject then
			handleWorldClick(mouse.Target, Vector2.new(mouse.X, mouse.Y))

			-- Start auto-yapping if mouse is held down
			startMouseAutoYapping()
		end
	elseif input.UserInputType == Enum.UserInputType.Touch then
		-- Mobile touch handling
		local touchPosition = input.Position
		local guiObjectsAtPosition = player.PlayerGui:GetGuiObjectsAtPosition(touchPosition.X, touchPosition.Y)
		local touchedNonUIObject = #guiObjectsAtPosition == 0

		-- Check if we touched any meaningful UI element
		for _, obj in ipairs(guiObjectsAtPosition) do
			-- If this is an important UI element that should handle the touch
			if obj:IsA("TextButton") or obj:IsA("ImageButton") then
				touchedNonUIObject = false
				break
			end
		end

		-- If we didn't touch UI, handle it as a world touch
		if touchedNonUIObject then
			handleWorldClick(nil, touchPosition)

			-- Start auto-yapping if touch is held
			startMouseAutoYapping()
		end
	end

	-- Handle keyboard input
	if input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.E or input.KeyCode == Enum.KeyCode.F then
		yap()
	elseif input.KeyCode == Enum.KeyCode.X then
		startAutoYapping()
	end
end)

-- Handle input ending
UserInputService.InputEnded:Connect(function(input, gameProcessed)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		stopMouseAutoYapping()
	elseif input.KeyCode == Enum.KeyCode.X then
		stopAutoYapping()
	end
end)

-- Function to create yap sound
local function playYapSound()
	local yapSound = Instance.new("Sound")
	yapSound.SoundId = "rbxassetid://6895079853" -- Replace with your desired sound ID
	yapSound.Volume = 0.5
	yapSound.Parent = player.Character:FindFirstChild("Head") or player.Character.PrimaryPart
	yapSound:Play()
	game:GetService("Debris"):AddItem(yapSound, 2)
end

-- Debounce for yapping (to prevent spamming)
local yapDebounce = false
local yapDebounceTime = 0.1 -- 100ms cooldown between yaps

-- Function to send yap event to server
local function yap()
	if yapDebounce then
		return
	end
	yapDebounce = true

	yapEvent:FireServer("yap")
	playYapSound()

	-- Add visual feedback for button press
	local originalColor = yapButton.BackgroundColor3
	yapButton.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
	task.delay(0.1, function()
		yapButton.BackgroundColor3 = originalColor
	end)

	-- Create a visual effect at mouse position for screen clicks
	local mouse = player:GetMouse()
	local yapClickEffect = Instance.new("ImageLabel")
	yapClickEffect.Size = UDim2.new(0, 30, 0, 30)
	yapClickEffect.Position = UDim2.new(0, mouse.X - 15, 0, mouse.Y - 15)
	yapClickEffect.BackgroundTransparency = 1
	yapClickEffect.Image = "rbxassetid://6337354996" -- Sound wave image
	yapClickEffect.ImageColor3 = Color3.fromHSV(math.random(), 1, 1)
	yapClickEffect.Parent = screenGui

	-- Animate and remove the effect
	local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local tween = game:GetService("TweenService"):Create(yapClickEffect, tweenInfo, {
		Size = UDim2.new(0, 60, 0, 60),
		ImageTransparency = 1,
	})
	tween:Play()
	tween.Completed:Connect(function()
		yapClickEffect:Destroy()
	end)

	-- Reset debounce after cooldown
	task.delay(yapDebounceTime, function()
		yapDebounce = false
	end)
end

-- Auto-yapping features
local isAutoYapping = false
local isMouseAutoYapping = false

-- Function for keyboard auto-yapping
local function startAutoYapping()
	if isAutoYapping then
		return
	end
	isAutoYapping = true

	-- Create auto-yap loop
	task.spawn(function()
		while isAutoYapping do
			yap()
			task.wait(yapDebounceTime + 0.01) -- Slightly longer than debounce time
		end
	end)
end

local function stopAutoYapping()
	isAutoYapping = false
end

-- Function for mouse auto-yapping
local function startMouseAutoYapping()
	if isMouseAutoYapping then
		return
	end
	isMouseAutoYapping = true

	-- Create auto-yap loop for mouse
	task.spawn(function()
		while isMouseAutoYapping do
			yap()
			task.wait(yapDebounceTime + 0.01) -- Slightly longer than debounce time
		end
	end)
end

local function stopMouseAutoYapping()
	isMouseAutoYapping = false
end

-- Connect button to yap function
yapButton.MouseButton1Click:Connect(yap)

-- Replace all input handling with this CAS approach

-- AFTER your other code, but BEFORE the InputBegan/InputEnded connections

-- Remove any existing input connections
-- Leave only the yapButton.MouseButton1Click connection

-- Set up mouse click and auto-yap system with ContextActionService
ContextActionService:UnbindAction("YapClick") -- Unbind if it exists
ContextActionService:BindAction("YapClick", function(actionName, inputState, inputObject)
	-- Handle mouse button or touch
	if
		inputObject.UserInputType == Enum.UserInputType.MouseButton1
		or inputObject.UserInputType == Enum.UserInputType.Touch
	then
		-- Get position
		local position = inputObject.Position

		-- Check if we clicked UI
		local guiObjects = player.PlayerGui:GetGuiObjectsAtPosition(position.X, position.Y)
		local clickedUI = false

		for _, obj in pairs(guiObjects) do
			if obj:IsA("TextButton") or obj:IsA("ImageButton") then
				clickedUI = true
				break
			end
		end

		if not clickedUI then
			-- Handle initial press
			if inputState == Enum.UserInputState.Begin then
				yap()
				startMouseAutoYapping()

				-- Create click effect
				local yapClickEffect = Instance.new("ImageLabel")
				yapClickEffect.Size = UDim2.new(0, 30, 0, 30)
				yapClickEffect.Position = UDim2.new(0, position.X - 15, 0, position.Y - 15)
				yapClickEffect.BackgroundTransparency = 1
				yapClickEffect.Image = "rbxassetid://6337354996"
				yapClickEffect.ImageColor3 = Color3.fromHSV(math.random(), 1, 1)
				yapClickEffect.Parent = screenGui

				-- Animate effect
				local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
				local tween = game:GetService("TweenService"):Create(yapClickEffect, tweenInfo, {
					Size = UDim2.new(0, 60, 0, 60),
					ImageTransparency = 1,
				})
				tween:Play()
				tween.Completed:Connect(function()
					yapClickEffect:Destroy()
				end)
			elseif inputState == Enum.UserInputState.End or inputState == Enum.UserInputState.Cancel then
				stopMouseAutoYapping()
			end

			return Enum.ContextActionResult.Sink -- We handled this input
		end

		-- If clicked on UI, let it pass through
		return Enum.ContextActionResult.Pass
	end

	-- Let other inputs pass through
	return Enum.ContextActionResult.Pass
end, false, Enum.UserInputType.MouseButton1, Enum.UserInputType.Touch)

-- -- Set up keyboard controls
-- ContextActionService:UnbindAction("YapKeyboard") -- Unbind if it exists
-- ContextActionService:BindAction("YapKeyboard", function(actionName, inputState, inputObject)
-- 	-- Only handle key presses, not releases
-- 	if inputState == Enum.UserInputState.Begin then
-- 		yap()
-- 		return Enum.ContextActionResult.Sink
-- 	end
-- 	return Enum.ContextActionResult.Pass
-- end, false, Enum.KeyCode.Space, Enum.KeyCode.E, Enum.KeyCode.F)

-- -- Set up auto-yap key
-- ContextActionService:UnbindAction("AutoYapKey") -- Unbind if it exists
-- ContextActionService:BindAction("AutoYapKey", function(actionName, inputState, inputObject)
-- 	if inputState == Enum.UserInputState.Begin then
-- 		startAutoYapping()
-- 	elseif inputState == Enum.UserInputState.End or inputState == Enum.UserInputState.Cancel then
-- 		stopAutoYapping()
-- 	end
-- 	return Enum.ContextActionResult.Sink
-- end, false, Enum.KeyCode.X)

-- Show notifications
local function showNotification(message, duration)
	duration = duration or 3

	notificationText.Text = message
	notificationFrame.Visible = true

	-- Fade in
	notificationFrame.BackgroundTransparency = 1
	local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local tween = game:GetService("TweenService"):Create(notificationFrame, tweenInfo, { BackgroundTransparency = 0 })
	tween:Play()

	-- Hide after duration
	task.delay(duration, function()
		-- Fade out
		local fadeOut = game:GetService("TweenService")
			:Create(notificationFrame, tweenInfo, { BackgroundTransparency = 1 })
		fadeOut:Play()
		fadeOut.Completed:Connect(function()
			notificationFrame.Visible = false
		end)
	end)
end

-- Update stats display with debug info
local function updateStats()
	local yapPower = player:WaitForChild("YapPower")
	statsYapPower.Text = "Yap Power: " .. yapPower.Value
	statsNextUpgrade.Text = "Next Upgrade: " .. (yapPower.Value * 10) .. " YP"

	-- Debug points display
	local leaderstats = player:WaitForChild("leaderstats")
	local yapPoints = leaderstats:WaitForChild("YapPoints")
	showNotification("Current YP: " .. yapPoints.Value .. ", Upgrade Cost: " .. (yapPower.Value * 10))
end

-- Connect upgrade button with improved feedback
upgradeButton.MouseButton1Click:Connect(function()
	-- Send upgrade request to server
	yapEvent:FireServer("upgrade")

	-- Visual feedback for button press
	local originalColor = upgradeButton.BackgroundColor3
	upgradeButton.BackgroundColor3 = Color3.fromRGB(255, 220, 100)
	task.delay(0.1, function()
		upgradeButton.BackgroundColor3 = originalColor
	end)

	-- Immediate update attempt in case server has already processed
	task.delay(0.2, updateStats)
end)

-- Listen for notification events
if not yapRemotes:FindFirstChild("NotifyClient") then
	local notifyEvent = Instance.new("RemoteEvent")
	notifyEvent.Name = "NotifyClient"
	notifyEvent.Parent = yapRemotes
end

yapRemotes.NotifyClient.OnClientEvent:Connect(showNotification)

-- Update stats when values change
player.ChildAdded:Connect(function(child)
	if child.Name == "YapPower" then
		child:GetPropertyChangedSignal("Value"):Connect(updateStats)
	end
end)

-- Initialize stats if YapPower already exists
if player:FindFirstChild("YapPower") then
	updateStats()
end

-- Show tips to the player
task.delay(2, function()
	showNotification("Click anywhere to yap", 5)
end)
task.delay(6, function()
	showNotification("Hold click for auto-yapping!", 5)
end)
