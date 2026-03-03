--[[
	RiftController.client.lua
	Day 3: Handles rift entry, combat action, complete. Works with OnboardingOverlay.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
if not player then
	return
end

local OnboardingRemotes = ReplicatedStorage:WaitForChild("OnboardingRemotes", 10)
if not OnboardingRemotes then
	return
end

local RequestStartBeginnerRift = OnboardingRemotes:FindFirstChild("RequestStartBeginnerRift")
local ReportCombatAction = OnboardingRemotes:FindFirstChild("ReportCombatAction")
local RequestCompleteBeginnerRift = OnboardingRemotes:FindFirstChild("RequestCompleteBeginnerRift")

if not RequestStartBeginnerRift or not ReportCombatAction or not RequestCompleteBeginnerRift then
	return
end

local RiftController = {}

function RiftController.EnterRift()
	RequestStartBeginnerRift:FireServer()
end

function RiftController.ReportCombat()
	ReportCombatAction:FireServer({})
end

function RiftController.CompleteRift()
	RequestCompleteBeginnerRift:FireServer()
end

return RiftController
