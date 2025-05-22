local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")

-- Game Pass IDs (you'll need to create these in the Roblox Developer Hub)
local GAME_PASS_IDS = {
	VIP = 0000001, -- Replace with your actual Game Pass ID
	VoicePack = 0000002, -- Replace with your actual Game Pass ID
	AutoYapper = 0000003, -- Replace with your actual Game Pass ID
}

-- Developer Product IDs
local DEVELOPER_PRODUCT_IDS = {
	YapBooster = 0000001, -- Replace with your actual Developer Product ID
	VoiceColorPack = 0000002, -- Replace with your actual Developer Product ID
	ThunderEffect = 0000003, -- Replace with your actual Developer Product ID
}

-- Track which players have which game passes
local playerGamePasses = {}

-- Function to check if a player has a game pass
local function playerOwnsGamePass(player, gamePassId)
	-- Check cached result first
	if playerGamePasses[player.UserId] and playerGamePasses[player.UserId][gamePassId] ~= nil then
		return playerGamePasses[player.UserId][gamePassId]
	end

	-- If not cached, check with MarketplaceService
	local success, result = pcall(function()
		return MarketplaceService:UserOwnsGamePassAsync(player.UserId, gamePassId)
	end)

	-- Cache the result
	if not playerGamePasses[player.UserId] then
		playerGamePasses[player.UserId] = {}
	end

	if success then
		playerGamePasses[player.UserId][gamePassId] = result
		return result
	else
		warn("Error checking game pass: " .. result)
		return false
	end
end

-- Apply VIP benefits
local function applyVIPBenefits(player)
	if playerOwnsGamePass(player, GAME_PASS_IDS.VIP) then
		-- Set VIP tag
		local vipTag = Instance.new("StringValue")
		vipTag.Name = "VIPStatus"
		vipTag.Value = "VIP"
		vipTag.Parent = player

		-- Create VIP effect
		if player.Character then
			local vipEffect = Instance.new("Part")
			vipEffect.Name = "VIPEffect"
			vipEffect.Size = Vector3.new(1, 0.1, 1)
			vipEffect.Shape = Enum.PartType.Cylinder
			vipEffect.CFrame = CFrame.new(0, -3, 0) * CFrame.Angles(0, 0, math.rad(90))
			vipEffect.Color = Color3.fromRGB(255, 215, 0) -- Gold
			vipEffect.Material = Enum.Material.Neon
			vipEffect.Transparency = 0.3
			vipEffect.CanCollide = false

			local weld = Instance.new("WeldConstraint")
			weld.Part0 = vipEffect
			weld.Part1 = player.Character.HumanoidRootPart
			weld.Parent = vipEffect

			vipEffect.Parent = player.Character
		end

		-- Double yap points multiplier
		local stats = player:FindFirstChild("YapStats")
		if stats then
			stats:SetAttribute("VIPMultiplier", 2)
		end

		print("Applied VIP benefits to " .. player.Name)
	end
end

-- Handle game pass purchases
MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, gamePassId, wasPurchased)
	if wasPurchased then
		-- Clear cached game pass info to force refresh
		if playerGamePasses[player.UserId] then
			playerGamePasses[player.UserId][gamePassId] = nil
		end

		-- Apply benefits based on game pass
		if gamePassId == GAME_PASS_IDS.VIP then
			applyVIPBenefits(player)
		elseif gamePassId == GAME_PASS_IDS.VoicePack then
			-- Give voice pack access
			local voicePack = Instance.new("BoolValue")
			voicePack.Name = "HasVoicePack"
			voicePack.Value = true
			voicePack.Parent = player
		elseif gamePassId == GAME_PASS_IDS.AutoYapper then
			-- Enable auto-yapper
			local autoYapper = Instance.new("BoolValue")
			autoYapper.Name = "HasAutoYapper"
			autoYapper.Value = true
			autoYapper.Parent = player
		end
	end
end)

-- Handle developer product purchases
MarketplaceService.ProcessReceipt = function(receiptInfo)
	local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
	if not player then
		-- Player left, save for later processing
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	-- Handle different products
	if receiptInfo.ProductId == DEVELOPER_PRODUCT_IDS.YapBooster then
		-- Give temporary yap booster
		local booster = Instance.new("NumberValue")
		booster.Name = "YapBooster"
		booster.Value = 2 -- 2x multiplier
		booster.Parent = player

		-- Display notification
		game:GetService("ReplicatedStorage").YapRemotes.NotifyClient
			:FireClient(player, "Yap Booster activated! 2x Yap Points for 30 minutes!")

		-- Set expiry timer
		task.delay(1800, function() -- 30 minutes in seconds
			if booster and booster.Parent then
				booster:Destroy()
				game:GetService("ReplicatedStorage").YapRemotes.NotifyClient
					:FireClient(player, "Yap Booster has expired!")
			end
		end)
	end

	-- Mark as processed successfully
	return Enum.ProductPurchaseDecision.PurchaseGranted
end

-- Check game passes when players join
Players.PlayerAdded:Connect(function(player)
	-- Check for VIP status
	task.spawn(function()
		if playerOwnsGamePass(player, GAME_PASS_IDS.VIP) then
			applyVIPBenefits(player)
		end
	end)

	-- Check for other game passes
	task.spawn(function()
		if playerOwnsGamePass(player, GAME_PASS_IDS.VoicePack) then
			local voicePack = Instance.new("BoolValue")
			voicePack.Name = "HasVoicePack"
			voicePack.Value = true
			voicePack.Parent = player
		end
	end)

	task.spawn(function()
		if playerOwnsGamePass(player, GAME_PASS_IDS.AutoYapper) then
			local autoYapper = Instance.new("BoolValue")
			autoYapper.Name = "HasAutoYapper"
			autoYapper.Value = true
			autoYapper.Parent = player
		end
	end)
end)

-- Clean up when players leave
Players.PlayerRemoving:Connect(function(player)
	playerGamePasses[player.UserId] = nil
end)

print("Game pass system initialized!")
