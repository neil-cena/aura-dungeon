--[[
	EnemyCatalog.lua
	Placeholder enemy definitions for arena combat.
]]

local EnemyCatalog = {}

EnemyCatalog.Wave = {
	{ id = "grunt_a", display_name = "Neon Striker", health = 30, damage = 5, speed = 10 },
	{ id = "grunt_b", display_name = "Pulse Raider", health = 35, damage = 6, speed = 10 },
	{ id = "grunt_c", display_name = "Rift Hunter", health = 40, damage = 7, speed = 9 },
}

EnemyCatalog.Boss = {
	id = "rift_boss_v1",
	display_name = "Rift Tyrant",
	health = 180,
	damage = 18,
	speed = 7,
}

return EnemyCatalog
