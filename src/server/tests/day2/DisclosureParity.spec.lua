--[[
	DisclosureParity.spec.lua
	Group D: Disclosure text matches live config.
	Maps to day2-roll-system-test-checklist Group D.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RollConfig = require(ReplicatedStorage.shared.config.RollConfig)

local function runDisclosureTests()
	local passed, failed = 0, 0

	-- D1-D4: Disclosure text contains correct values
	local text = RollConfig.GetDisclosureText()
	for _, r in ipairs({ "60.0", "30.0", "9.1", "0.9" }) do
		if text:find(r) then passed = passed + 1 end
	end
	for _, p in ipairs({ "10", "50", "250" }) do
		if text:find(p) then passed = passed + 1 end
	end
	if text:find("Aura") and text:find("Weapon") then passed = passed + 1 end

	return passed, 8 - passed
end

return { run = runDisclosureTests }
