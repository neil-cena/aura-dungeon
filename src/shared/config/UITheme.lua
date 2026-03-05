--[[
	UITheme.lua
	Anime-neon visual tokens for panel, text, and controls.
]]

local UITheme = {}
local Workspace = game:GetService("Workspace")

UITheme.Fonts = {
	Title = Enum.Font.GothamBlack,
	Body = Enum.Font.Gotham,
	Button = Enum.Font.GothamBold,
}

UITheme.Colors = {
	Panel = Color3.fromRGB(18, 18, 42),
	PanelSoft = Color3.fromRGB(27, 28, 58),
	PanelDeep = Color3.fromRGB(12, 12, 30),
	AccentBlue = Color3.fromRGB(90, 160, 255),
	AccentPink = Color3.fromRGB(255, 95, 216),
	AccentCyan = Color3.fromRGB(74, 255, 230),
	AccentGold = Color3.fromRGB(255, 216, 122),
	Success = Color3.fromRGB(92, 204, 132),
	Danger = Color3.fromRGB(232, 92, 114),
	TextPrimary = Color3.fromRGB(239, 244, 255),
	TextSecondary = Color3.fromRGB(191, 207, 246),
	TextMuted = Color3.fromRGB(142, 156, 193),
	Stroke = Color3.fromRGB(70, 84, 130),
}

UITheme.CornerRadius = UDim.new(0, 8)
UITheme.StrokeThickness = 1

UITheme.TextScale = {
	small = { phone = 12, tablet = 13, desktop = 14 },
	body = { phone = 14, tablet = 15, desktop = 16 },
	title = { phone = 17, tablet = 19, desktop = 21 },
}

function UITheme.GetDeviceProfile()
	local viewport = Workspace.CurrentCamera and Workspace.CurrentCamera.ViewportSize or Vector2.new(1920, 1080)
	local minAxis = math.min(viewport.X, viewport.Y)
	if minAxis < 700 then
		return "phone"
	end
	if minAxis < 1000 then
		return "tablet"
	end
	return "desktop"
end

function UITheme.GetTextSize(role)
	local key = role or "body"
	local byRole = UITheme.TextScale[key] or UITheme.TextScale.body
	local profile = UITheme.GetDeviceProfile()
	return byRole[profile] or byRole.desktop
end

function UITheme.ApplyResponsiveText(label, role, isTitle)
	UITheme.ApplyText(label, isTitle == true)
	label.TextSize = UITheme.GetTextSize(role)
end

function UITheme.ApplyPanel(frame, soft)
	frame.BackgroundColor3 = soft and UITheme.Colors.PanelSoft or UITheme.Colors.Panel
	frame.BorderSizePixel = 0
	frame.BackgroundTransparency = 0.08
end

function UITheme.ApplyText(label, isTitle)
	label.TextColor3 = isTitle and UITheme.Colors.TextPrimary or UITheme.Colors.TextSecondary
	label.Font = isTitle and UITheme.Fonts.Title or UITheme.Fonts.Body
end

return UITheme
