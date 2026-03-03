--[[
	CameraController.client.lua
	Keeps third-person camera bounds sensible for mobile readability.
]]

local Players = game:GetService("Players")
local player = Players.LocalPlayer
if not player then
	return
end

player.CameraMinZoomDistance = 8
player.CameraMaxZoomDistance = 24
