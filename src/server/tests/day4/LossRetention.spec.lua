--[[
	LossRetention.spec.lua
	Day 4: Loss state preserves partial progress via retention reward floor.
]]

local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local server = ServerScriptService.server

local DungeonService = require(server.domain.DungeonService)
local ProfileStore = require(server.persistence.ProfileStore)
local DungeonConfig = require(ReplicatedStorage.shared.config.DungeonConfig)

local function runLossRetentionTests()
	local passed, failed = 0, 0

	ProfileStore.ClearCache()
	local playerId = "day4-loss-001"
	local beforeProfile = ProfileStore.GetProfile(playerId)
	local coinsBefore = beforeProfile.currencies.coins
	local tokensBefore = beforeProfile.currencies.tokens

	DungeonService.StartRun(playerId)
	local result = DungeonService.CompleteRun(playerId, DungeonConfig.Status.Lost, 160)
	local afterProfile = ProfileStore.GetProfile(playerId)
	local coinsDelta = afterProfile.currencies.coins - coinsBefore
	local tokensDelta = afterProfile.currencies.tokens - tokensBefore

	if result and result.loss_retention_applied == true then
		passed = passed + 1
	else
		failed = failed + 1
	end

	if coinsDelta >= DungeonConfig.Rewards.Loss.minCoins and tokensDelta >= DungeonConfig.Rewards.Loss.minTokens then
		passed = passed + 1
	else
		failed = failed + 1
	end

	if coinsDelta < DungeonConfig.Rewards.Win.coins and tokensDelta < DungeonConfig.Rewards.Win.tokens then
		passed = passed + 1
	else
		failed = failed + 1
	end

	return passed, failed
end

return { run = runLossRetentionTests }

