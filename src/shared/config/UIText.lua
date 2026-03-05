--[[
	UIText.lua
	Player-safe copy for common UI surfaces and fallback states.
]]

local UIText = {}

UIText.Common = {
	Unknown = "Unknown",
	NoneEquipped = "None Equipped",
	ServiceUnavailable = "Service unavailable. Try again shortly.",
}

UIText.Inventory = {
	Title = "Loadout Matrix",
	NoParty = "No party active.",
}

UIText.Roll = {
	Title = "Neon Forge",
	IdleResult = "Spin the forge to discover your next aura or weapon.",
}

UIText.Macro = {
	DefaultObjective = "Roll, equip, and clear rifts to grow stronger.",
}

function UIText.FriendlyError(errCode)
	local map = {
		unknown = "Unexpected issue. Please retry.",
		unknown_error = "Unexpected issue. Please retry.",
		invalid_request = "Invalid action request.",
		insufficient_currency = "Not enough currency.",
		purchase_rate_limited = "Please wait a moment before buying again.",
		claim_rate_limited = "Please wait a moment before claiming again.",
	}
	return map[tostring(errCode or "unknown")] or "Action failed. Please try again."
end

return UIText
