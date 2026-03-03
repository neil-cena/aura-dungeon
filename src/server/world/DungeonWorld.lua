--[[
	DungeonWorld.lua
	Creates simple per-player dungeon arenas and returns spawn/exit points.
]]

local Workspace = game:GetService("Workspace")

local DungeonWorld = {}

local ROOT_NAME = "AuraDungeons"
local ARENA_SIZE = Vector3.new(100, 2, 100)

local function getRoot()
	local root = Workspace:FindFirstChild(ROOT_NAME)
	if not root then
		root = Instance.new("Folder")
		root.Name = ROOT_NAME
		root.Parent = Workspace
	end
	return root
end

local function arenaName(playerId)
	return string.format("DungeonArena_%s", playerId)
end

local function offsetFromPlayerId(playerId)
	local idNum = tonumber(playerId) or 0
	local bucket = (idNum % 30) + 1
	return Vector3.new(bucket * 240, 0, -320)
end

local function createWall(parent, name, size, cframe)
	local wall = parent:FindFirstChild(name)
	if not wall then
		wall = Instance.new("Part")
		wall.Name = name
		wall.Anchored = true
		wall.CanCollide = true
		wall.Parent = parent
	end
	wall.Size = size
	wall.CFrame = cframe
	wall.Material = Enum.Material.Slate
	wall.Color = Color3.fromRGB(42, 46, 58)
	return wall
end

function DungeonWorld.EnsureArena(playerId)
	local root = getRoot()
	local name = arenaName(playerId)
	local arena = root:FindFirstChild(name)
	if not arena then
		arena = Instance.new("Folder")
		arena.Name = name
		arena.Parent = root
	end

	local basePos = offsetFromPlayerId(playerId)
	local floor = arena:FindFirstChild("Floor")
	if not floor then
		floor = Instance.new("Part")
		floor.Name = "Floor"
		floor.Anchored = true
		floor.CanCollide = true
		floor.Parent = arena
	end
	floor.Size = ARENA_SIZE
	floor.CFrame = CFrame.new(basePos + Vector3.new(0, 0, 0))
	floor.Color = Color3.fromRGB(32, 36, 48)
	floor.Material = Enum.Material.Basalt

	local wallHeight = 20
	local wallThickness = 3
	local halfX = ARENA_SIZE.X / 2
	local halfZ = ARENA_SIZE.Z / 2

	createWall(arena, "WallNorth", Vector3.new(ARENA_SIZE.X, wallHeight, wallThickness), CFrame.new(basePos + Vector3.new(0, wallHeight / 2, -halfZ)))
	createWall(arena, "WallSouth", Vector3.new(ARENA_SIZE.X, wallHeight, wallThickness), CFrame.new(basePos + Vector3.new(0, wallHeight / 2, halfZ)))
	createWall(arena, "WallEast", Vector3.new(wallThickness, wallHeight, ARENA_SIZE.Z), CFrame.new(basePos + Vector3.new(halfX, wallHeight / 2, 0)))
	createWall(arena, "WallWest", Vector3.new(wallThickness, wallHeight, ARENA_SIZE.Z), CFrame.new(basePos + Vector3.new(-halfX, wallHeight / 2, 0)))

	local spawnPart = arena:FindFirstChild("Spawn")
	if not spawnPart then
		spawnPart = Instance.new("Part")
		spawnPart.Name = "Spawn"
		spawnPart.Anchored = true
		spawnPart.CanCollide = false
		spawnPart.Transparency = 1
		spawnPart.Parent = arena
	end
	spawnPart.Size = Vector3.new(8, 1, 8)
	spawnPart.CFrame = CFrame.new(basePos + Vector3.new(0, 3, 32))

	local bossPart = arena:FindFirstChild("BossSpawn")
	if not bossPart then
		bossPart = Instance.new("Part")
		bossPart.Name = "BossSpawn"
		bossPart.Anchored = true
		bossPart.CanCollide = false
		bossPart.Transparency = 1
		bossPart.Parent = arena
	end
	bossPart.Size = Vector3.new(8, 1, 8)
	bossPart.CFrame = CFrame.new(basePos + Vector3.new(0, 3, -30))

	return {
		folder = arena,
		spawn_cframe = spawnPart.CFrame + Vector3.new(0, 4, 0),
		boss_spawn_cframe = bossPart.CFrame + Vector3.new(0, 4, 0),
	}
end

return DungeonWorld
