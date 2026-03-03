--[[
	ThumbReachability.spec.lua
	Day 5: Core controls stay inside right-thumb reach zone in landscape.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PolishConfig = require(ReplicatedStorage.shared.config.PolishConfig)
local PolishTypes = require(ReplicatedStorage.shared.types.PolishTypes)

local function runThumbReachabilityTests()
	local passed, failed = 0, 0

	local layout = {
		main = {
			xScale = PolishConfig.ThumbLayout.ActionPanel.PositionScale.X
				- PolishConfig.ThumbLayout.ActionPanel.SizeScale.X
				+ PolishConfig.ThumbLayout.CoreButtons.Main.PositionScale.X * PolishConfig.ThumbLayout.ActionPanel.SizeScale.X,
			yScale = PolishConfig.ThumbLayout.ActionPanel.PositionScale.Y
				- PolishConfig.ThumbLayout.ActionPanel.SizeScale.Y
				+ PolishConfig.ThumbLayout.CoreButtons.Main.PositionScale.Y * PolishConfig.ThumbLayout.ActionPanel.SizeScale.Y,
			widthScale = PolishConfig.ThumbLayout.CoreButtons.Main.SizeScale.X * PolishConfig.ThumbLayout.ActionPanel.SizeScale.X,
			heightScale = PolishConfig.ThumbLayout.CoreButtons.Main.SizeScale.Y * PolishConfig.ThumbLayout.ActionPanel.SizeScale.Y,
		},
		win = {
			xScale = PolishConfig.ThumbLayout.ActionPanel.PositionScale.X
				- PolishConfig.ThumbLayout.ActionPanel.SizeScale.X
				+ PolishConfig.ThumbLayout.CoreButtons.Win.PositionScale.X * PolishConfig.ThumbLayout.ActionPanel.SizeScale.X,
			yScale = PolishConfig.ThumbLayout.ActionPanel.PositionScale.Y
				- PolishConfig.ThumbLayout.ActionPanel.SizeScale.Y
				+ PolishConfig.ThumbLayout.CoreButtons.Win.PositionScale.Y * PolishConfig.ThumbLayout.ActionPanel.SizeScale.Y,
			widthScale = PolishConfig.ThumbLayout.CoreButtons.Win.SizeScale.X * PolishConfig.ThumbLayout.ActionPanel.SizeScale.X,
			heightScale = PolishConfig.ThumbLayout.CoreButtons.Win.SizeScale.Y * PolishConfig.ThumbLayout.ActionPanel.SizeScale.Y,
		},
		loss = {
			xScale = PolishConfig.ThumbLayout.ActionPanel.PositionScale.X
				- PolishConfig.ThumbLayout.ActionPanel.SizeScale.X
				+ PolishConfig.ThumbLayout.CoreButtons.Loss.PositionScale.X * PolishConfig.ThumbLayout.ActionPanel.SizeScale.X,
			yScale = PolishConfig.ThumbLayout.ActionPanel.PositionScale.Y
				- PolishConfig.ThumbLayout.ActionPanel.SizeScale.Y
				+ PolishConfig.ThumbLayout.CoreButtons.Loss.PositionScale.Y * PolishConfig.ThumbLayout.ActionPanel.SizeScale.Y,
			widthScale = PolishConfig.ThumbLayout.CoreButtons.Loss.SizeScale.X * PolishConfig.ThumbLayout.ActionPanel.SizeScale.X,
			heightScale = PolishConfig.ThumbLayout.CoreButtons.Loss.SizeScale.Y * PolishConfig.ThumbLayout.ActionPanel.SizeScale.Y,
		},
	}

	if PolishConfig.ThumbLayout.LandscapeOnly == true then
		passed = passed + 1
	else
		failed = failed + 1
	end

	if PolishTypes.IsThumbReachableLayout(layout) then
		passed = passed + 1
	else
		failed = failed + 1
	end

	if PolishConfig.ThumbLayout.ThumbReachZone.MinX >= 0.6 and PolishConfig.ThumbLayout.ThumbReachZone.MaxX <= 1 then
		passed = passed + 1
	else
		failed = failed + 1
	end

	return passed, failed
end

return { run = runThumbReachabilityTests }
