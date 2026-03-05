--[[
	PartyPanel.client.lua
	Phase 3: basic party creation/invite/accept/leave panel.
	Toggle with P.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
if not player then
	return
end

local partyRemotes = ReplicatedStorage:WaitForChild("PartyRemotes")
local getPartyState = partyRemotes:WaitForChild("GetPartyState")
local createOrGetParty = partyRemotes:WaitForChild("CreateOrGetParty")
local inviteToParty = partyRemotes:WaitForChild("InviteToParty")
local acceptPartyInvite = partyRemotes:WaitForChild("AcceptPartyInvite")
local leaveParty = partyRemotes:WaitForChild("LeaveParty")
local shared = ReplicatedStorage:WaitForChild("shared")
local UITheme = require(shared.config.UITheme)

local gui = Instance.new("ScreenGui")
gui.Name = "PartyPanelGui"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local panel = Instance.new("Frame")
panel.Size = UDim2.new(0.82, 0, 0.46, 0)
panel.Position = UDim2.new(0.5, 0, 0.52, 0)
panel.AnchorPoint = Vector2.new(0.5, 0.5)
UITheme.ApplyPanel(panel, false)
panel.Visible = false
panel.Parent = gui

local sizeConstraint = Instance.new("UISizeConstraint")
sizeConstraint.MinSize = Vector2.new(300, 220)
sizeConstraint.MaxSize = Vector2.new(560, 420)
sizeConstraint.Parent = panel

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -10, 0, 30)
title.Position = UDim2.new(0, 5, 0, 4)
title.BackgroundTransparency = 1
title.TextColor3 = UITheme.Colors.TextPrimary
title.Font = Enum.Font.GothamBold
title.Text = "Party"
title.Parent = panel
UITheme.ApplyResponsiveText(title, "title", true)

local membersLabel = Instance.new("TextLabel")
membersLabel.Size = UDim2.new(1, -12, 0, 84)
membersLabel.Position = UDim2.new(0, 6, 0, 38)
membersLabel.BackgroundColor3 = UITheme.Colors.PanelDeep
membersLabel.BackgroundTransparency = 0.2
membersLabel.BorderSizePixel = 0
membersLabel.TextXAlignment = Enum.TextXAlignment.Left
membersLabel.TextYAlignment = Enum.TextYAlignment.Top
membersLabel.TextWrapped = true
membersLabel.TextSize = UITheme.GetTextSize("small")
membersLabel.TextColor3 = UITheme.Colors.TextSecondary
membersLabel.Text = "No party"
membersLabel.Parent = panel

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -12, 0, 20)
status.Position = UDim2.new(0, 6, 0, 124)
status.BackgroundTransparency = 1
status.TextXAlignment = Enum.TextXAlignment.Left
status.TextSize = UITheme.GetTextSize("small")
status.TextColor3 = UITheme.Colors.AccentGold
status.Text = ""
status.Parent = panel

local createBtn = Instance.new("TextButton")
createBtn.Size = UDim2.new(0.47, 0, 0, 30)
createBtn.Position = UDim2.new(0.02, 0, 0, 150)
createBtn.BackgroundColor3 = UITheme.Colors.AccentBlue
createBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
createBtn.TextScaled = true
createBtn.Text = "Create Party"
createBtn.Parent = panel

local leaveBtn = Instance.new("TextButton")
leaveBtn.Size = UDim2.new(0.47, 0, 0, 30)
leaveBtn.Position = UDim2.new(0.51, 0, 0, 150)
leaveBtn.BackgroundColor3 = UITheme.Colors.Danger
leaveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
leaveBtn.TextScaled = true
leaveBtn.Text = "Leave Party"
leaveBtn.Parent = panel

local inviteInput = Instance.new("TextBox")
inviteInput.Size = UDim2.new(0.63, 0, 0, 30)
inviteInput.Position = UDim2.new(0.02, 0, 0, 188)
inviteInput.BackgroundColor3 = UITheme.Colors.PanelSoft
inviteInput.TextColor3 = Color3.fromRGB(255, 255, 255)
inviteInput.PlaceholderText = "Target UserId"
inviteInput.Text = ""
inviteInput.TextScaled = true
inviteInput.Parent = panel

local inviteBtn = Instance.new("TextButton")
inviteBtn.Size = UDim2.new(0.33, 0, 0, 30)
inviteBtn.Position = UDim2.new(0.66, 0, 0, 188)
inviteBtn.BackgroundColor3 = UITheme.Colors.Success
inviteBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
inviteBtn.TextScaled = true
inviteBtn.Text = "Invite"
inviteBtn.Parent = panel

local acceptBtn = Instance.new("TextButton")
acceptBtn.Size = UDim2.new(1, -12, 0, 26)
acceptBtn.Position = UDim2.new(0, 6, 1, -32)
acceptBtn.BackgroundColor3 = UITheme.Colors.Success
acceptBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
acceptBtn.TextScaled = true
acceptBtn.Text = "Accept Invite"
acceptBtn.Visible = false
acceptBtn.Parent = panel

local function render(state)
	local party = state and state.party
	local pending = state and state.pending_invite
	if party and type(party.member_ids) == "table" then
		local lines = {
			string.format("Leader: %s", tostring(party.leader_id)),
			string.format("You are %s", party.is_leader and "leader" or "member"),
			"Members:",
		}
		for _, id in ipairs(party.member_ids) do
			table.insert(lines, "- " .. tostring(id))
		end
		membersLabel.Text = table.concat(lines, "\n")
	else
		membersLabel.Text = "No party.\nCreate a party and invite by UserId."
	end
	if pending then
		acceptBtn.Visible = true
		acceptBtn.Text = string.format("Accept Invite from %s", tostring(pending.from_player_name or pending.from_leader_id))
	else
		acceptBtn.Visible = false
	end
end

local function refresh()
	local resp = getPartyState:InvokeServer()
	if resp and resp.success and resp.state then
		render(resp.state)
		status.Text = ""
	else
		status.Text = "Party state unavailable"
	end
end

local function togglePanel()
	panel.Visible = not panel.Visible
	if panel.Visible then
		refresh()
	end
end

local function applySafeArea()
	local fn = _G.AuraApplySafeArea
	if fn then
		fn(panel, { top = true, right = true, bottom = true })
	end
end

local function registerPanel()
	local register = _G.AuraRegisterPanel
	if register then
		register("party", "Party", togglePanel, function()
			return panel.Visible
		end)
	end
end

createBtn.MouseButton1Click:Connect(function()
	local resp = createOrGetParty:InvokeServer()
	status.Text = (resp and resp.success) and "Party ready." or ("Create failed: " .. tostring(resp and resp.err or "unknown"))
	task.delay(0.1, refresh)
end)

leaveBtn.MouseButton1Click:Connect(function()
	local resp = leaveParty:InvokeServer()
	status.Text = (resp and resp.success) and "Left party." or ("Leave failed: " .. tostring(resp and resp.err or "unknown"))
	task.delay(0.1, refresh)
end)

inviteBtn.MouseButton1Click:Connect(function()
	local targetId = tonumber(inviteInput.Text)
	if not targetId then
		status.Text = "Enter a valid numeric UserId."
		return
	end
	local resp = inviteToParty:InvokeServer({ target_user_id = targetId })
	status.Text = (resp and resp.success) and "Invite sent." or ("Invite failed: " .. tostring(resp and resp.err or "unknown"))
	task.delay(0.1, refresh)
end)

acceptBtn.MouseButton1Click:Connect(function()
	local resp = acceptPartyInvite:InvokeServer()
	status.Text = (resp and resp.success) and "Joined party." or ("Accept failed: " .. tostring(resp and resp.err or "unknown"))
	task.delay(0.1, refresh)
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end
	if input.KeyCode == Enum.KeyCode.P then
		togglePanel()
	end
end)

applySafeArea()
registerPanel()
