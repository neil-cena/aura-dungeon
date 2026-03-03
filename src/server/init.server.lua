--[[
	init.server.lua
	Bootstrap: ensure remotes are created early.
	Controller scripts under server/network run on their own as Scripts.
]]

local server = script.Parent
local network = server:FindFirstChild("network") or server
require(network:WaitForChild("Remotes"))

print("[Aura Dungeon] Day 2 roll + Day 3 onboarding + Day 4 dungeon initialized")

