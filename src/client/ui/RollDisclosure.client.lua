--[[
	RollDisclosure.client.lua
	Renders disclosure text from shared RollConfig at every roll entry point.
	Must appear before roll confirmation. Source: odds-and-pity-spec §5.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local RollConfig = require(ReplicatedStorage.shared.config.RollConfig)

-- Disclosure text (single source of truth from config)
local disclosureText = RollConfig.GetDisclosureText()

-- Export for UI components to display
local RollDisclosure = {}
RollDisclosure.Text = disclosureText
RollDisclosure.GetText = RollConfig.GetDisclosureText

-- Create ScreenGui with disclosure (visible at roll entry points)
function RollDisclosure.CreateDisclosureGui()
	local gui = Instance.new("ScreenGui")
	gui.Name = "RollDisclosure"
	gui.ResetOnSpawn = false

	-- Top-left corner, compact size so it doesn't block gameplay (OnboardingOverlay is bottom-center)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(0.32, 0, 0.28, 0)
	frame.Position = UDim2.new(0.02, 0, 0.02, 0)
	frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	frame.Parent = gui

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -12, 1, -12)
	label.Position = UDim2.new(0, 6, 0, 6)
	label.BackgroundTransparency = 1
	label.Text = disclosureText
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextSize = 11
	label.TextWrapped = true
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextYAlignment = Enum.TextYAlignment.Top
	label.Parent = frame

	return gui
end

-- Auto-init: show disclosure when local player exists
local player = Players.LocalPlayer
if player then
	local gui = RollDisclosure.CreateDisclosureGui()
	gui.Parent = player:WaitForChild("PlayerGui")
end

return RollDisclosure
