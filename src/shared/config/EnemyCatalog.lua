--[[
	EnemyCatalog.lua
	Placeholder enemy definitions for arena combat.
]]

local EnemyCatalog = {}

EnemyCatalog.Wave = {
	{ id = "grunt_a", health = 30, damage = 5, speed = 10 },
	{ id = "grunt_b", health = 35, damage = 6, speed = 10 },
	{ id = "grunt_c", health = 40, damage = 7, speed = 9 },
}

EnemyCatalog.Boss = {
	id = "rift_boss_v1",
	health = 180,
	damage = 18,
	speed = 7,
}

return EnemyCatalog
