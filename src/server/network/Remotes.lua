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
return Remotes


