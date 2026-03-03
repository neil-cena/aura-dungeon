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

return Remotes
