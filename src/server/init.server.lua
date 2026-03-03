--[[
	init.server.lua
	Bootstrap: ensures RollRemotes exist and RollController is loaded.
]]

local server = script.Parent
local network = server:FindFirstChild("network") or server
local Remotes = require(network:WaitForChild("Remotes"))
-- Remotes creates RollRemotes folder in ReplicatedStorage; RollController connects in its own script
-- This init just ensures Remotes is loaded early so folder exists for clients
print("[Aura Dungeon] Day 2 roll system initialized")
