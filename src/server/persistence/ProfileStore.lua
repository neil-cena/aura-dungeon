--[[
	ProfileStore.lua
	Profile get/update wrappers with optimistic version checks and retry/backoff.
	Retry policy: data-schema-v1 §8 (3 attempts, 100/250/500ms + jitter).
]]

local HttpService = game:GetService("HttpService")

local ProfileStore = {}

local PROFILE_STORE_KEY = "PlayerData_%s"
local MAX_ATTEMPTS = 3
local BACKOFF_MS = { 100, 250, 500 }
local JITTER_MAX_MS = 50

-- In-memory profile cache (for Day 2; replace with DataStoreService/ProfileService in production)
local profileCache = {}

local function jitter()
	return math.random(0, JITTER_MAX_MS) / 1000
end

local function sleep(seconds)
	task.wait(seconds)
end

local function isTransientFailure(err)
	local msg = tostring(err):lower()
	return msg:find("timeout") or msg:find("throttl") or msg:find("unavailable") or msg:find("service unavailable")
end

--[[
	GetProfile(playerId: string) -> (profile, err?)
	Returns cached or fresh profile. Does not retry (read-only).
]]
function ProfileStore.GetProfile(playerId)
	if type(playerId) ~= "string" or playerId == "" then
		return nil, "invalid player id"
	end
	local key = string.format(PROFILE_STORE_KEY, playerId)
	if profileCache[key] then
		return profileCache[key], nil
	end
	-- New player: return default profile
	local profile = ProfileStore.CreateDefaultProfile(playerId)
	profileCache[key] = profile
	return profile, nil
end

function ProfileStore.CreateDefaultProfile(playerId)
	local now = os.date("!%Y-%m-%dT%H:%M:%SZ")
	return {
		schema_version = 1,
		player_id = playerId,
		created_at = now,
		updated_at = now,
		currencies = { coins = 500, tokens = 100, gems = 0 },
		inventory = { auras = {}, weapons = {}, equipped = {} },
		roll_state = {
			aura_lane = { roll_count_total = 0, since_rare_plus = 0, since_epic_plus = 0, since_legendary = 0 },
			weapon_lane = { roll_count_total = 0, since_rare_plus = 0, since_epic_plus = 0, since_legendary = 0 },
		},
		progression = { dungeons_completed = 0, boss_kills = 0, onboarding_state = {} },
		compliance = {
			age_group = "unknown",
			region_code = "unknown",
			restricted_monetization = true, -- Safe default until policy resolution.
		},
	}
end

--[[
	UpdateProfile(playerId: string, mutatorFn: (profile) -> (newProfile, err?))
	Applies mutator with retry/backoff. Returns (success, err).
]]
function ProfileStore.UpdateProfile(playerId, mutatorFn)
	if type(playerId) ~= "string" or playerId == "" then
		return false, "invalid player id"
	end
	if type(mutatorFn) ~= "function" then
		return false, "invalid mutator"
	end

	local key = string.format(PROFILE_STORE_KEY, playerId)
	local lastErr

	for attempt = 1, MAX_ATTEMPTS do
		local profile = profileCache[key] or ProfileStore.CreateDefaultProfile(playerId)
		local newProfile, mutateErr = mutatorFn(profile)

		if mutateErr then
			-- Validation failure: do not retry
			return false, mutateErr
		end

		if not newProfile then
			return false, "mutator returned nil"
		end

		-- Simulated write (in production: DataStore:SetAsync with version check)
		local ok, err = pcall(function()
			profileCache[key] = newProfile
			newProfile.updated_at = os.date("!%Y-%m-%dT%H:%M:%SZ")
		end)

		if ok then
			return true, nil
		end

		lastErr = err
		if not isTransientFailure(err) then
			return false, err
		end

		if attempt < MAX_ATTEMPTS then
			local delay = (BACKOFF_MS[attempt] or 500) / 1000 + jitter()
			task.wait(delay)
		end
	end

	return false, lastErr or "max retries exceeded"
end

-- For tests: clear cache
function ProfileStore.ClearCache()
	table.clear(profileCache)
end

-- For tests: explicit compliance override on cached profile.
function ProfileStore.SetCompliance(playerId, compliancePatch)
	if type(playerId) ~= "string" or playerId == "" then
		return false, "invalid player id"
	end
	if type(compliancePatch) ~= "table" then
		return false, "invalid compliance patch"
	end

	local ok, err = ProfileStore.UpdateProfile(playerId, function(profile)
		profile.compliance = profile.compliance or {}
		for k, v in pairs(compliancePatch) do
			profile.compliance[k] = v
		end
		return profile, nil
	end)
	return ok, err
end

return ProfileStore
