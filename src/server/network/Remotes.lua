--[[
	Remotes.lua
	Creates and exposes RemoteEvent instances for RequestRoll and RollResult.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = {}

local folder = ReplicatedStorage:FindFirstChild("RollRemotes")
if not folder then
	folder = Instance.new("Folder")
	folder.Name = "RollRemotes"
	folder.Parent = ReplicatedStorage
end

local function getOrCreate(name, className)
	local child = folder:FindFirstChild(name)
	if not child then
		child = Instance.new(className)
		child.Name = name
		child.Parent = folder
	end
	return child
end

Remotes.RequestRoll = getOrCreate("RequestRoll", "RemoteEvent")
Remotes.RollResult = getOrCreate("RollResult", "RemoteEvent")

-- Day 3: Onboarding and Rift remotes
local onboardingFolder = ReplicatedStorage:FindFirstChild("OnboardingRemotes")
if not onboardingFolder then
	onboardingFolder = Instance.new("Folder")
	onboardingFolder.Name = "OnboardingRemotes"
	onboardingFolder.Parent = ReplicatedStorage
end

local function getOrCreateOnboarding(name, className)
	local child = onboardingFolder:FindFirstChild(name)
	if not child then
		child = Instance.new(className)
		child.Name = name
		child.Parent = onboardingFolder
	end
	return child
end

Remotes.GetOnboardingState = getOrCreateOnboarding("GetOnboardingState", "RemoteFunction")
Remotes.OnboardingStateResult = getOrCreateOnboarding("OnboardingStateResult", "RemoteEvent")
Remotes.RequestFirstInteraction = getOrCreateOnboarding("RequestFirstInteraction", "RemoteEvent")
Remotes.RequestStartBeginnerRift = getOrCreateOnboarding("RequestStartBeginnerRift", "RemoteEvent")
Remotes.ReportCombatAction = getOrCreateOnboarding("ReportCombatAction", "RemoteEvent")
Remotes.RequestCompleteBeginnerRift = getOrCreateOnboarding("RequestCompleteBeginnerRift", "RemoteEvent")
Remotes.OnboardingResult = getOrCreateOnboarding("OnboardingResult", "RemoteEvent")


-- Day 4: Dungeon run remotes
local dungeonFolder = ReplicatedStorage:FindFirstChild("DungeonRemotes")
if not dungeonFolder then
	dungeonFolder = Instance.new("Folder")
	dungeonFolder.Name = "DungeonRemotes"
	dungeonFolder.Parent = ReplicatedStorage
end

local function getOrCreateDungeon(name, className)
	local child = dungeonFolder:FindFirstChild(name)
	if not child then
		child = Instance.new(className)
		child.Name = name
		child.Parent = dungeonFolder
	end
	return child
end

Remotes.GetDungeonState = getOrCreateDungeon("GetDungeonState", "RemoteFunction")
Remotes.RequestStartDungeonRun = getOrCreateDungeon("RequestStartDungeonRun", "RemoteEvent")
Remotes.RequestAdvanceDungeonPhase = getOrCreateDungeon("RequestAdvanceDungeonPhase", "RemoteEvent")
Remotes.RequestCompleteDungeonRun = getOrCreateDungeon("RequestCompleteDungeonRun", "RemoteEvent")
Remotes.DungeonUpdate = getOrCreateDungeon("DungeonUpdate", "RemoteEvent")
Remotes.BossTelegraph = getOrCreateDungeon("BossTelegraph", "RemoteEvent")

-- Day 7: Compliance remotes (read-only status and safe purchase gate checks)
local complianceFolder = ReplicatedStorage:FindFirstChild("ComplianceRemotes")
if not complianceFolder then
	complianceFolder = Instance.new("Folder")
	complianceFolder.Name = "ComplianceRemotes"
	complianceFolder.Parent = ReplicatedStorage
end

local function getOrCreateCompliance(name, className)
	local child = complianceFolder:FindFirstChild(name)
	if not child then
		child = Instance.new(className)
		child.Name = name
		child.Parent = complianceFolder
	end
	return child
end

Remotes.GetComplianceState = getOrCreateCompliance("GetComplianceState", "RemoteFunction")
Remotes.CheckMonetizationEligibility = getOrCreateCompliance("CheckMonetizationEligibility", "RemoteFunction")

-- Phase 1: Inventory/equip remotes
local inventoryFolder = ReplicatedStorage:FindFirstChild("InventoryRemotes")
if not inventoryFolder then
	inventoryFolder = Instance.new("Folder")
	inventoryFolder.Name = "InventoryRemotes"
	inventoryFolder.Parent = ReplicatedStorage
end

local function getOrCreateInventory(name, className)
	local child = inventoryFolder:FindFirstChild(name)
	if not child then
		child = Instance.new(className)
		child.Name = name
		child.Parent = inventoryFolder
	end
	return child
end

Remotes.GetInventory = getOrCreateInventory("GetInventory", "RemoteFunction")
Remotes.RequestEquipItem = getOrCreateInventory("RequestEquipItem", "RemoteEvent")
Remotes.InventoryUpdate = getOrCreateInventory("InventoryUpdate", "RemoteEvent")
Remotes.AuraEquipped = getOrCreateInventory("AuraEquipped", "RemoteEvent")

-- Phase 1: interaction prompts to open UI
local interactionFolder = ReplicatedStorage:FindFirstChild("InteractionRemotes")
if not interactionFolder then
	interactionFolder = Instance.new("Folder")
	interactionFolder.Name = "InteractionRemotes"
	interactionFolder.Parent = ReplicatedStorage
end

local function getOrCreateInteraction(name, className)
	local child = interactionFolder:FindFirstChild(name)
	if not child then
		child = Instance.new(className)
		child.Name = name
		child.Parent = interactionFolder
	end
	return child
end

Remotes.ShowRollPanel = getOrCreateInteraction("ShowRollPanel", "RemoteEvent")
Remotes.ShowInventoryPanel = getOrCreateInteraction("ShowInventoryPanel", "RemoteEvent")
Remotes.ShowDungeonPanel = getOrCreateInteraction("ShowDungeonPanel", "RemoteEvent")

-- Phase 2: combat remotes
local combatFolder = ReplicatedStorage:FindFirstChild("CombatRemotes")
if not combatFolder then
	combatFolder = Instance.new("Folder")
	combatFolder.Name = "CombatRemotes"
	combatFolder.Parent = ReplicatedStorage
end

local function getOrCreateCombat(name, className)
	local child = combatFolder:FindFirstChild(name)
	if not child then
		child = Instance.new(className)
		child.Name = name
		child.Parent = combatFolder
	end
	return child
end

Remotes.RequestAttack = getOrCreateCombat("RequestAttack", "RemoteEvent")
Remotes.CombatUpdate = getOrCreateCombat("CombatUpdate", "RemoteEvent")

-- Macro UI snapshot remotes
local macroFolder = ReplicatedStorage:FindFirstChild("MacroRemotes")
if not macroFolder then
	macroFolder = Instance.new("Folder")
	macroFolder.Name = "MacroRemotes"
	macroFolder.Parent = ReplicatedStorage
end

local function getOrCreateMacro(name, className)
	local child = macroFolder:FindFirstChild(name)
	if not child then
		child = Instance.new(className)
		child.Name = name
		child.Parent = macroFolder
	end
	return child
end

Remotes.GetMacroSnapshot = getOrCreateMacro("GetMacroSnapshot", "RemoteFunction")

-- Phase 3: daily reward remotes
local dailyFolder = ReplicatedStorage:FindFirstChild("DailyRewardRemotes")
if not dailyFolder then
	dailyFolder = Instance.new("Folder")
	dailyFolder.Name = "DailyRewardRemotes"
	dailyFolder.Parent = ReplicatedStorage
end

local function getOrCreateDaily(name, className)
	local child = dailyFolder:FindFirstChild(name)
	if not child then
		child = Instance.new(className)
		child.Name = name
		child.Parent = dailyFolder
	end
	return child
end

Remotes.GetDailyRewardState = getOrCreateDaily("GetDailyRewardState", "RemoteFunction")
Remotes.ClaimDailyReward = getOrCreateDaily("ClaimDailyReward", "RemoteFunction")

-- Phase 3: social remotes
local socialFolder = ReplicatedStorage:FindFirstChild("SocialRemotes")
if not socialFolder then
	socialFolder = Instance.new("Folder")
	socialFolder.Name = "SocialRemotes"
	socialFolder.Parent = ReplicatedStorage
end

local function getOrCreateSocial(name, className)
	local child = socialFolder:FindFirstChild(name)
	if not child then
		child = Instance.new(className)
		child.Name = name
		child.Parent = socialFolder
	end
	return child
end

Remotes.GetLeaderboard = getOrCreateSocial("GetLeaderboard", "RemoteFunction")
Remotes.GlobalCelebration = getOrCreateSocial("GlobalCelebration", "RemoteEvent")

-- Phase 3: party remotes
local partyFolder = ReplicatedStorage:FindFirstChild("PartyRemotes")
if not partyFolder then
	partyFolder = Instance.new("Folder")
	partyFolder.Name = "PartyRemotes"
	partyFolder.Parent = ReplicatedStorage
end

local function getOrCreateParty(name, className)
	local child = partyFolder:FindFirstChild(name)
	if not child then
		child = Instance.new(className)
		child.Name = name
		child.Parent = partyFolder
	end
	return child
end

Remotes.GetPartyState = getOrCreateParty("GetPartyState", "RemoteFunction")
Remotes.CreateOrGetParty = getOrCreateParty("CreateOrGetParty", "RemoteFunction")
Remotes.InviteToParty = getOrCreateParty("InviteToParty", "RemoteFunction")
Remotes.AcceptPartyInvite = getOrCreateParty("AcceptPartyInvite", "RemoteFunction")
Remotes.LeaveParty = getOrCreateParty("LeaveParty", "RemoteFunction")

-- Phase 4: shop remotes
local shopFolder = ReplicatedStorage:FindFirstChild("ShopRemotes")
if not shopFolder then
	shopFolder = Instance.new("Folder")
	shopFolder.Name = "ShopRemotes"
	shopFolder.Parent = ReplicatedStorage
end

local function getOrCreateShop(name, className)
	local child = shopFolder:FindFirstChild(name)
	if not child then
		child = Instance.new(className)
		child.Name = name
		child.Parent = shopFolder
	end
	return child
end

Remotes.GetShopState = getOrCreateShop("GetShopState", "RemoteFunction")
Remotes.PurchaseShopItem = getOrCreateShop("PurchaseShopItem", "RemoteFunction")

-- Phase 4: battle pass remotes
local battlePassFolder = ReplicatedStorage:FindFirstChild("BattlePassRemotes")
if not battlePassFolder then
	battlePassFolder = Instance.new("Folder")
	battlePassFolder.Name = "BattlePassRemotes"
	battlePassFolder.Parent = ReplicatedStorage
end

local function getOrCreateBattlePass(name, className)
	local child = battlePassFolder:FindFirstChild(name)
	if not child then
		child = Instance.new(className)
		child.Name = name
		child.Parent = battlePassFolder
	end
	return child
end

Remotes.GetBattlePassState = getOrCreateBattlePass("GetBattlePassState", "RemoteFunction")
Remotes.ClaimBattlePassTier = getOrCreateBattlePass("ClaimBattlePassTier", "RemoteFunction")

return Remotes


