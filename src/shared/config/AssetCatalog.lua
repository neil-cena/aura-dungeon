--[[
    AssetCatalog.lua
    Centralized asset references.
]]

local AssetCatalog = {}

AssetCatalog.Hub = {
    ThemeName = "anime_neon_v1",
    GroundMaterial = Enum.Material.Slate,
    GroundColor = Color3.fromRGB(28, 31, 44),
    RollStationColor = Color3.fromRGB(79, 166, 255),
    PortalColor = Color3.fromRGB(161, 94, 255),
    AccentColor = Color3.fromRGB(255, 120, 234),
    SecondaryAccentColor = Color3.fromRGB(80, 255, 238),
}

AssetCatalog.Dungeon = {
    FloorMaterial = Enum.Material.Basalt,
    FloorColor = Color3.fromRGB(23, 24, 37),
    WallMaterial = Enum.Material.Slate,
    WallColor = Color3.fromRGB(34, 36, 54),
    AccentColor = Color3.fromRGB(106, 188, 255),
}

AssetCatalog.Models = {
    Enabled = false,
    RootFolder = "AuraAssets",
    WarnOnMissing = true,
    Hub = {
        DecorSet = nil,
        RollStation = nil,
        InventoryPedestal = nil,
        RiftPortal = nil,
    },
    Dungeon = {
        FloorSet = nil,
        WallSet = nil,
    },
    Enemies = {
        grunt_a = nil,
        grunt_b = nil,
        grunt_c = nil,
        rift_boss_v1 = nil,
    },
}

AssetCatalog.AuraVfx = {
    Common = { Color = Color3.fromRGB(180, 180, 180), LightRange = 5, Rate = 6 },
    Rare = { Color = Color3.fromRGB(82, 165, 255), LightRange = 8, Rate = 12 },
    Epic = { Color = Color3.fromRGB(188, 108, 255), LightRange = 10, Rate = 18 },
    Legendary = { Color = Color3.fromRGB(255, 205, 92), LightRange = 14, Rate = 24 },
}

AssetCatalog.Sounds = {
    UiClick = "rbxasset://sounds/button.wav",
    RollAnticipation = "rbxasset://sounds/electronicpingshort.wav",
    RollRevealCommon = "rbxasset://sounds/uuhhh.mp3",
    RollRevealRare = "rbxasset://sounds/bass.wav",
    RollRevealEpic = "rbxasset://sounds/electronicpingshort.wav",
    RollRevealLegendary = "rbxasset://sounds/electronicpingshort.wav",
    CombatHit = "rbxasset://sounds/swordlunge.wav",
    BossTelegraph = "rbxasset://sounds/electronicpingshort.wav",
    BossDeath = "rbxasset://sounds/bass.wav",
    LevelUp = "rbxasset://sounds/electronicpingshort.wav",
    Reward = "rbxasset://sounds/button.wav",
}

return AssetCatalog
--[[
    AssetCatalog.lua
    Centralized asset references so visual reskins require config edits only.
]]

local AssetCatalog = {}

AssetCatalog.Hub = {
    ThemeName = "anime_neon_v1",
    GroundMaterial = Enum.Material.Slate,
    GroundColor = Color3.fromRGB(28, 31, 44),
    RollStationColor = Color3.fromRGB(79, 166, 255),
    PortalColor = Color3.fromRGB(161, 94, 255),
    AccentColor = Color3.fromRGB(255, 120, 234),
    SecondaryAccentColor = Color3.fromRGB(80, 255, 238),
}

AssetCatalog.Dungeon = {
    FloorMaterial = Enum.Material.Basalt,
    FloorColor = Color3.fromRGB(23, 24, 37),
    WallMaterial = Enum.Material.Slate,
    WallColor = Color3.fromRGB(34, 36, 54),
    AccentColor = Color3.fromRGB(106, 188, 255),
}

AssetCatalog.Models = {
    Enabled = false,
    RootFolder = "AuraAssets",
    WarnOnMissing = true,
    -- Slot descriptor shape:
    -- { name = "ModelName", offset = Vector3.new(), rotation_degrees = Vector3.new(), scale = 1.0, static = true }
    -- A plain string model name is also supported.
    Hub = {
        DecorSet = nil,
        RollStation = nil,
        InventoryPedestal = nil,
        RiftPortal = nil,
    },
    Dungeon = {
        FloorSet = nil,
        WallSet = nil,
    },
    Enemies = {
        grunt_a = nil,
        grunt_b = nil,
        grunt_c = nil,
        rift_boss_v1 = nil,
    },
}

AssetCatalog.AuraVfx = {
    Common = { Color = Color3.fromRGB(180, 180, 180), LightRange = 5, Rate = 6 },
    Rare = { Color = Color3.fromRGB(82, 165, 255), LightRange = 8, Rate = 12 },
    Epic = { Color = Color3.fromRGB(188, 108, 255), LightRange = 10, Rate = 18 },
    Legendary = { Color = Color3.fromRGB(255, 205, 92), LightRange = 14, Rate = 24 },
}

AssetCatalog.Sounds = {
    UiClick = "rbxasset://sounds/button.wav",
    RollAnticipation = "rbxasset://sounds/electronicpingshort.wav",
    RollRevealCommon = "rbxasset://sounds/uuhhh.mp3",
    RollRevealRare = "rbxasset://sounds/bass.wav",
    RollRevealEpic = "rbxasset://sounds/electronicpingshort.wav",
    RollRevealLegendary = "rbxasset://sounds/electronicpingshort.wav",
    CombatHit = "rbxasset://sounds/swordlunge.wav",
    BossTelegraph = "rbxasset://sounds/electronicpingshort.wav",
    BossDeath = "rbxasset://sounds/bass.wav",
    LevelUp = "rbxasset://sounds/electronicpingshort.wav",
    Reward = "rbxasset://sounds/button.wav",
}

return AssetCatalog
