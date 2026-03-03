--[[
	DisclosureCoverage.spec.lua
	Day 7: verifies disclosure text remains visible/accurate contract source.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RollConfig = require(ReplicatedStorage.shared.config.RollConfig)

local function runDisclosureCoverageTests()
	local passed, failed = 0, 0

	local text = RollConfig.GetDisclosureText()
	if type(text) == "string" and #text > 0 then
		passed = passed + 1
	else
		failed = failed + 1
	end

	local hasRates = text:find("60.0%%") and text:find("30.0%%") and text:find("9.1%%") and text:find("0.9%%")
	local hasPity = text:find("10") and text:find("50") and text:find("250")
	if hasRates and hasPity then
		passed = passed + 1
	else
		failed = failed + 1
	end

	local hasLaneParity = text:find("Aura") and text:find("Weapon")
	if hasLaneParity and RollConfig.GetDisclosureChecksum() ~= nil then
		passed = passed + 1
	else
		failed = failed + 1
	end

	return passed, failed
end

return { run = runDisclosureCoverageTests }
