--[[
	MacroController.server.lua
	Exposes macro snapshot data for high-level UI surfaces.
]]

local Remotes = require(script.Parent.Remotes)
local MacroService = require(script.Parent.Parent.domain.MacroService)

Remotes.GetMacroSnapshot.OnServerInvoke = function(player)
	local playerId = tostring(player.UserId)
	local snapshot, err = MacroService.GetSnapshot(playerId)
	if not snapshot then
		return { success = false, err = err or "snapshot_unavailable" }
	end
	return { success = true, snapshot = snapshot }
end
