--[[
	init.server.lua
	Bootstrap: ensure remotes are created early.
	Controller scripts under server/network run on their own as Scripts.
]]

-- Support both Rojo tree shapes:
-- 1) server as Folder under ServerScriptService
-- 2) server as Script with children (legacy)
local serverContainer = script:FindFirstChild("network") and script or script.Parent
local network = serverContainer:FindFirstChild("network") or script:FindFirstChild("network") or script.Parent:FindFirstChild("network")
if not network then
	error("[Aura Dungeon] network folder not found for bootstrap")
end
require(network:WaitForChild("Remotes"))
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local function ensureRemote(folderName, remoteName, className)
	local folder = ReplicatedStorage:FindFirstChild(folderName)
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = folderName
		folder.Parent = ReplicatedStorage
	end
	local child = folder:FindFirstChild(remoteName)
	if not child then
		child = Instance.new(className)
		child.Name = remoteName
		child.Parent = folder
	end
	return child
end

-- Phase 3 fallback bootstrap for remotes that may not exist in legacy Studio tree sessions.
ensureRemote("DailyRewardRemotes", "GetDailyRewardState", "RemoteFunction")
ensureRemote("DailyRewardRemotes", "ClaimDailyReward", "RemoteFunction")
ensureRemote("SocialRemotes", "GetLeaderboard", "RemoteFunction")
ensureRemote("SocialRemotes", "GlobalCelebration", "RemoteEvent")
ensureRemote("PartyRemotes", "GetPartyState", "RemoteFunction")
ensureRemote("PartyRemotes", "CreateOrGetParty", "RemoteFunction")
ensureRemote("PartyRemotes", "InviteToParty", "RemoteFunction")
ensureRemote("PartyRemotes", "AcceptPartyInvite", "RemoteFunction")
ensureRemote("PartyRemotes", "LeaveParty", "RemoteFunction")
ensureRemote("ShopRemotes", "GetShopState", "RemoteFunction")
ensureRemote("ShopRemotes", "PurchaseShopItem", "RemoteFunction")
ensureRemote("BattlePassRemotes", "GetBattlePassState", "RemoteFunction")
ensureRemote("BattlePassRemotes", "ClaimBattlePassTier", "RemoteFunction")

local worldFolder = serverContainer:FindFirstChild("world") or script:FindFirstChild("world") or script.Parent:FindFirstChild("world")
if not worldFolder then
	error("[Aura Dungeon] world folder not found for bootstrap")
end
local HubBuilder = require(worldFolder:WaitForChild("HubBuilder"))

HubBuilder.Build()
HubBuilder.BindSpawnRouting()

print("[Aura Dungeon] hub + roll/onboarding + dungeon systems initialized")

