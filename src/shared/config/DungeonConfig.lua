--[[
	DungeonConfig.lua
	Day 4: Dungeon runtime, boss, and failure-state tunables.
	Source: milestone-acceptance-matrix Day 4, pillars-v2 §2, economy-sheet.md
]]

local DungeonConfig = {}

DungeonConfig.Run = {
	TargetMinSeconds = 120,
	TargetMaxSeconds = 180,
	SampleSize = 20,
	WindowPassRateMin = 0.80,
}

DungeonConfig.Phases = {
	WaveCount = 2,
	WaveDurationSeconds = 45,
	BossDurationSeconds = 60,
	BossGuaranteed = true,
}

DungeonConfig.Rewards = {
	Win = {
		coins = 200,
		tokens = 50,
	},
	Loss = {
		retentionPercent = 0.25,
		minCoins = 25,
		minTokens = 5,
	},
}

DungeonConfig.Telegraph = {
	PreHitSeconds = 1.2,
	PromptText = "Boss attack incoming - dodge now!",
	BossSpawnText = "Boss has spawned!",
	MuteReadable = true,
}

DungeonConfig.Status = {
	Idle = "idle",
	Wave = "wave",
	Boss = "boss",
	Won = "won",
	Lost = "lost",
}

return DungeonConfig

