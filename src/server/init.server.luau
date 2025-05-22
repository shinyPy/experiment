print("Hello world, from server!")

-- Import necessary services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Create a notification function to let players know about the game
local function notifyPlayer(player)
	-- Wait for the client to set up remote events
	task.wait(2)

	-- Find or create the remote event
	local yapRemotes = ReplicatedStorage:FindFirstChild("YapRemotes")
	if not yapRemotes then
		return
	end

	local notifyEvent = yapRemotes:FindFirstChild("NotifyClient")
	if not notifyEvent then
		notifyEvent = Instance.new("RemoteEvent")
		notifyEvent.Name = "NotifyClient"
		notifyEvent.Parent = yapRemotes
	end

	-- Send welcome message
	notifyEvent:FireClient(player, "Welcome to Yapping Simulator! Click, tap or press Space to yap!")
end

-- When players join, welcome them
Players.PlayerAdded:Connect(function(player)
	notifyPlayer(player)

	-- Create a spawn function to handle player respawn
	player.CharacterAdded:Connect(function(character)
		-- Place player at a nice spawn location
		local spawnPoint = workspace:FindFirstChild("SpawnLocation") or workspace:FindFirstChild("WhisperPlaza")
		if spawnPoint then
			local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
			humanoidRootPart.CFrame = CFrame.new(spawnPoint.Position + Vector3.new(0, 5, 0))
		end
	end)
end)

print("Yapping Simulator server initialized!")
