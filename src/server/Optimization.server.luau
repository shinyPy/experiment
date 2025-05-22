local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

-- Performance tracking
local performanceStats = {
	frameRateLog = {},
	serverLoad = 0,
}

-- Monitor server performance
local function monitorPerformance()
	local lastTime = tick()

	RunService.Heartbeat:Connect(function()
		local currentTime = tick()
		local deltaTime = currentTime - lastTime
		lastTime = currentTime

		-- Log frame rate (inverse of deltaTime)
		local frameRate = 1 / deltaTime
		table.insert(performanceStats.frameRateLog, frameRate)

		-- Keep only the last 100 samples
		if #performanceStats.frameRateLog > 100 then
			table.remove(performanceStats.frameRateLog, 1)
		end

		-- Calculate average frame rate
		local sum = 0
		for _, rate in ipairs(performanceStats.frameRateLog) do
			sum = sum + rate
		end

		local averageFrameRate = sum / #performanceStats.frameRateLog
		performanceStats.serverLoad = math.clamp(60 / averageFrameRate, 0, 1)
	end)
end

-- Optimize distant objects
local function optimizeDistance()
	-- Set up network ownership for better performance
	for _, player in pairs(Players:GetPlayers()) do
		if player.Character then
			for _, part in pairs(player.Character:GetDescendants()) do
				if part:IsA("BasePart") then
					part:SetNetworkOwner(player)
				end
			end
		end
	end
end

-- Optimize particle effects
local function optimizeParticles()
	-- Find all particle emitters
	local emitters = {}

	for _, descendant in pairs(workspace:GetDescendants()) do
		if descendant:IsA("ParticleEmitter") then
			table.insert(emitters, descendant)
		end
	end

	-- Adjust particle count based on player count
	local function adjustParticles()
		local playerCount = #Players:GetPlayers()
		local particleFactor = math.clamp(1 - (playerCount / 20), 0.1, 1)

		for _, emitter in ipairs(emitters) do
			-- Store original rate if we haven't already
			if not emitter:GetAttribute("OriginalRate") then
				emitter:SetAttribute("OriginalRate", emitter.Rate)
			end

			-- Adjust rate based on player count
			local originalRate = emitter:GetAttribute("OriginalRate")
			emitter.Rate = originalRate * particleFactor
		end
	end

	Players.PlayerAdded:Connect(adjustParticles)
	Players.PlayerRemoving:Connect(adjustParticles)
	adjustParticles() -- Initial adjustment
end

-- Load optimization modules
monitorPerformance()
optimizeDistance()
optimizeParticles()

-- Run distance optimization periodically
RunService.Heartbeat:Connect(function()
	-- Run every 5 seconds
	if tick() % 5 < 0.1 then
		optimizeDistance()
	end
end)

print("Optimization systems initialized!")
