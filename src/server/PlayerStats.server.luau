local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

-- Create RemoteEvents for client-server communication
local remotes = Instance.new("Folder")
remotes.Name = "YapRemotes"
remotes.Parent = ReplicatedStorage

local yapEvent = Instance.new("RemoteEvent")
yapEvent.Name = "YapEvent"
yapEvent.Parent = remotes

-- Player stats management
local playerStats = {}

local function initPlayerStats(player)
	-- Create leaderstats
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	-- Create YapPoints stat
	local yapPoints = Instance.new("IntValue")
	yapPoints.Name = "YapPoints"
	yapPoints.Value = 0
	yapPoints.Parent = leaderstats

	-- Create YapPower stat (multiplier)
	local yapPower = Instance.new("IntValue")
	yapPower.Name = "YapPower"
	yapPower.Value = 1
	yapPower.Parent = player

	-- Store player data in memory
	playerStats[player.UserId] = {
		yapPoints = 0,
		yapPower = 1,
		yapLevel = 1,
		unlocks = {},
	}

	print(player.Name .. " joined with starting YapPoints: 0")
end

-- Handle player joining
Players.PlayerAdded:Connect(initPlayerStats)

-- Handle player leaving
Players.PlayerRemoving:Connect(function(player)
	playerStats[player.UserId] = nil
	print(player.Name .. " left the game. Stats cleared from memory.")
end)

-- Handle yapping event from client
yapEvent.OnServerEvent:Connect(function(player, yapAction)
	local stats = playerStats[player.UserId]
	if not stats then
		warn("No stats found for player: " .. player.Name)
		return
	end

	if yapAction == "yap" then
		-- Calculate points based on yap power and action
		local earnedPoints = stats.yapPower
		stats.yapPoints = stats.yapPoints + earnedPoints

		-- Update leaderstats
		player.leaderstats.YapPoints.Value = stats.yapPoints

		-- Create visual effect at player's position
		local character = player.Character
		if character then
			local head = character:FindFirstChild("Head")
			if head then
				local yapEffect = Instance.new("Part")
				yapEffect.Shape = Enum.PartType.Ball
				yapEffect.Material = Enum.Material.Neon
				yapEffect.Size = Vector3.new(1, 1, 1) * (stats.yapPower * 0.1 + 0.5)
				yapEffect.Position = head.Position + Vector3.new(0, 2, 0)
				yapEffect.Anchored = true
				yapEffect.CanCollide = false
				yapEffect.Transparency = 0.5
				yapEffect.Color = Color3.fromHSV(math.random(), 0.8, 1)
				yapEffect.Parent = workspace

				-- Animate the effect
				game:GetService("Debris"):AddItem(yapEffect, 1)
				local tween = game:GetService("TweenService"):Create(
					yapEffect,
					TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
					{ Size = Vector3.new(3, 3, 3), Transparency = 1 }
				)
				tween:Play()
			end
		end
	elseif yapAction == "upgrade" then
		-- Debug info
		print("Processing upgrade for " .. player.Name)
		print("Current Stats - Points: " .. stats.yapPoints .. ", Power: " .. stats.yapPower)

		-- Handle upgrade request
		local upgradeCost = stats.yapPower * 10
		print("Upgrade cost: " .. upgradeCost)

		if stats.yapPoints >= upgradeCost then
			-- Deduct points and increase power
			stats.yapPoints = stats.yapPoints - upgradeCost
			stats.yapPower = stats.yapPower + 1

			-- Update values for the client
			player.YapPower.Value = stats.yapPower
			player.leaderstats.YapPoints.Value = stats.yapPoints

			print("Upgrade successful! New power: " .. stats.yapPower .. ", Points remaining: " .. stats.yapPoints)

			-- Notify client
			local notifyEvent = remotes:FindFirstChild("NotifyClient")
			if notifyEvent then
				notifyEvent:FireClient(player, "Voice upgraded! New Yap Power: " .. stats.yapPower)
			end

			-- Show upgrade effect
			local character = player.Character
			if character then
				local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
				if humanoidRootPart then
					-- Create upgrade effect
					local upgradeEffect = Instance.new("Part")
					upgradeEffect.Shape = Enum.PartType.Ball
					upgradeEffect.Material = Enum.Material.Neon
					upgradeEffect.Size = Vector3.new(5, 5, 5)
					upgradeEffect.Position = humanoidRootPart.Position
					upgradeEffect.Anchored = true
					upgradeEffect.CanCollide = false
					upgradeEffect.Transparency = 0.5
					upgradeEffect.Color = Color3.fromRGB(255, 215, 0) -- Gold color
					upgradeEffect.Parent = workspace

					game:GetService("Debris"):AddItem(upgradeEffect, 1)
					local tween = game:GetService("TweenService"):Create(
						upgradeEffect,
						TweenInfo.new(1, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out),
						{ Size = Vector3.new(10, 10, 10), Transparency = 1 }
					)
					tween:Play()
				end
			end
		else
			-- Not enough points - notify the player
			print("Not enough points for upgrade. Has: " .. stats.yapPoints .. ", Needs: " .. upgradeCost)

			local notifyEvent = remotes:FindFirstChild("NotifyClient")
			if not notifyEvent then
				notifyEvent = Instance.new("RemoteEvent")
				notifyEvent.Name = "NotifyClient"
				notifyEvent.Parent = remotes
			end

			notifyEvent:FireClient(player, "Not enough Yap Points! You need " .. upgradeCost .. " points.")
		end
	end
end)
