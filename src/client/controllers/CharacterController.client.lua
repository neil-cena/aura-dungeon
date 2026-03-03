--[[
	CharacterController.client.lua
	Applies mobile-friendly character defaults.
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
if not player then
	return
end

player.CameraMode = Enum.CameraMode.Classic

local function applyHumanoidSettings(character)
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return
	end
	humanoid.WalkSpeed = 16
	humanoid.AutoRotate = true
	if UserInputService.TouchEnabled then
		humanoid.JumpPower = 42
	end
end

player.CharacterAdded:Connect(function(character)
	task.delay(0.15, function()
		applyHumanoidSettings(character)
	end)
end)

if player.Character then
	applyHumanoidSettings(player.Character)
end
