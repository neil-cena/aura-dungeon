--[[
	DungeonArenaBuilder.lua
	Compatibility wrapper matching planned naming.
]]

local DungeonWorld = require(script.Parent.DungeonWorld)

local DungeonArenaBuilder = {}

function DungeonArenaBuilder.EnsureArena(playerId)
	return DungeonWorld.EnsureArena(playerId)
end

return DungeonArenaBuilder
