--[[
	ProfileStore.lua
	Phase 4 persistence:
	- DataStoreService-backed profiles
	- session locking (lease-based)
	- autosave loop + leave/close flush
	- in-memory fallback for Studio/test safety
]]

local DataStoreService = game:GetService("DataStoreService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local ProfileStore = {}

local PROFILE_STORE_KEY = "PlayerData_%s"
local PROFILE_DATASTORE_NAME = "AuraDungeonProfiles_v1"
local MAX_ATTEMPTS = 3
local BACKOFF_MS = { 100, 250, 500 }
local JITTER_MAX_MS = 50

local LOCK_LEASE_SECONDS = 120
local AUTOSAVE_INTERVAL_SECONDS = 30

local ACTIVE_SESSION_ID = HttpService:GenerateGUID(false)

local profileCache = {}
local dirtyKeys = {}

local function nowUtcIso()
	return os.date("!%Y-%m-%dT%H:%M:%SZ")
end

local function nowEpoch()
	return os.time()
end

local function jitter()
	return math.random(0, JITTER_MAX_MS) / 1000
end

local function shouldUseDataStore()
	if RunService:IsStudio() and _G.AuraUseDataStoreInStudio ~= true then
		return false
	end
	return true
end

local DATASTORE_ENABLED = shouldUseDataStore()
local profileDataStore = nil
if DATASTORE_ENABLED then
	local ok, dsOrErr = pcall(function()
		return DataStoreService:GetDataStore(PROFILE_DATASTORE_NAME)
	end)
	if ok then
		profileDataStore = dsOrErr
	else
		DATASTORE_ENABLED = false
		warn("[Aura Dungeon] ProfileStore falling back to memory backend:", tostring(dsOrErr))
	end
end

local function isTransientFailure(err)
	local msg = tostring(err):lower()
	return msg:find("timeout") or msg:find("throttl") or msg:find("unavailable") or msg:find("service unavailable")
end

local function profileKey(playerId)
	return string.format(PROFILE_STORE_KEY, playerId)
end

local function deepCopyTable(value)
	if type(value) ~= "table" then
		return value
	end
	local out = {}
	for k, v in pairs(value) do
		out[k] = deepCopyTable(v)
	end
	return out
end

local function mergeDefaults(base, defaults)
	if type(base) ~= "table" then
		return deepCopyTable(defaults)
	end
	for k, v in pairs(defaults) do
		if base[k] == nil then
			base[k] = deepCopyTable(v)
		elseif type(base[k]) == "table" and type(v) == "table" then
			mergeDefaults(base[k], v)
		end
	end
	return base
end

function ProfileStore.CreateDefaultProfile(playerId)
	local now = nowUtcIso()
	return {
		schema_version = 2,
		player_id = playerId,
		created_at = now,
		updated_at = now,
		currencies = { coins = 500, tokens = 100, gems = 0 },
		inventory = {
			auras = {},
			weapons = {},
			equipped = {},
			equipped_aura = nil,
			equipped_weapon = nil,
		},
		roll_state = {
			aura_lane = { roll_count_total = 0, since_rare_plus = 0, since_epic_plus = 0, since_legendary = 0 },
			weapon_lane = { roll_count_total = 0, since_rare_plus = 0, since_epic_plus = 0, since_legendary = 0 },
		},
		progression = {
			level = 1,
			xp_total = 0,
			dungeons_completed = 0,
			boss_kills = 0,
			legendary_rolls = 0,
			onboarding_state = {},
			daily_reward = {
				last_claim_utc = "",
				daily_reward_claimed = false,
			},
			battle_pass = {
				season_id = "s1",
				points = 0,
				battle_pass_tier = 1,
				premium_unlocked = false,
				claimed_free = {},
				claimed_premium = {},
			},
			party_luck_bonus = 0,
		},
		shop = {
			owned = {},
			perks = {},
			cosmetics = {},
		},
		compliance = {
			age_group = "unknown",
			region_code = "unknown",
			restricted_monetization = true,
		},
		_session_lock = nil,
	}
end

local function migrateAndNormalize(profile, playerId)
	local defaults = ProfileStore.CreateDefaultProfile(playerId)
	local merged = mergeDefaults(profile or {}, defaults)
	merged.player_id = playerId
	merged.schema_version = math.max(2, tonumber(merged.schema_version or 1))
	return merged
end

local function loadProfileFromDataStore(playerId)
	local key = profileKey(playerId)
	local loadedProfile = nil
	local blocked = false

	for attempt = 1, MAX_ATTEMPTS do
		local ok, err = pcall(function()
			loadedProfile = profileDataStore:UpdateAsync(key, function(current)
				local row = migrateAndNormalize(current, playerId)
				local lock = row._session_lock
				local now = nowEpoch()
				if lock and lock.session_id and lock.session_id ~= ACTIVE_SESSION_ID and tonumber(lock.expires_at or 0) > now then
					blocked = true
					return row
				end
				row._session_lock = {
					session_id = ACTIVE_SESSION_ID,
					expires_at = now + LOCK_LEASE_SECONDS,
				}
				row.updated_at = nowUtcIso()
				return row
			end)
		end)
		if ok then
			if blocked then
				return nil, "profile_locked_by_other_session"
			end
			if type(loadedProfile) ~= "table" then
				return nil, "datastore_load_nil"
			end
			return migrateAndNormalize(loadedProfile, playerId), nil
		end
		if not isTransientFailure(err) then
			return nil, err
		end
		if attempt < MAX_ATTEMPTS then
			task.wait((BACKOFF_MS[attempt] or 500) / 1000 + jitter())
		end
	end

	return nil, "datastore_load_failed"
end

local function saveProfileToDataStore(playerId, releaseLock)
	local key = profileKey(playerId)
	local cached = profileCache[key]
	if type(cached) ~= "table" then
		return true, nil
	end

	local saveErr = nil
	for attempt = 1, MAX_ATTEMPTS do
		local didWrite = false
		local ok, err = pcall(function()
			profileDataStore:UpdateAsync(key, function(current)
				local row = migrateAndNormalize(current, playerId)
				local lock = row._session_lock
				local now = nowEpoch()
				if lock and lock.session_id and lock.session_id ~= ACTIVE_SESSION_ID and tonumber(lock.expires_at or 0) > now then
					return row
				end

				local nextProfile = deepCopyTable(cached)
				nextProfile.updated_at = nowUtcIso()
				if releaseLock then
					nextProfile._session_lock = nil
				else
					nextProfile._session_lock = {
						session_id = ACTIVE_SESSION_ID,
						expires_at = now + LOCK_LEASE_SECONDS,
					}
				end
				didWrite = true
				return nextProfile
			end)
		end)
		if ok then
			if not didWrite then
				return false, "profile_lock_lost"
			end
			dirtyKeys[key] = nil
			return true, nil
		end
		saveErr = err
		if not isTransientFailure(err) then
			return false, err
		end
		if attempt < MAX_ATTEMPTS then
			task.wait((BACKOFF_MS[attempt] or 500) / 1000 + jitter())
		end
	end

	return false, saveErr or "datastore_save_failed"
end

local function ensureProfileLoaded(playerId)
	local key = profileKey(playerId)
	if profileCache[key] then
		return profileCache[key], nil
	end

	if not DATASTORE_ENABLED then
		local profile = migrateAndNormalize(ProfileStore.CreateDefaultProfile(playerId), playerId)
		profileCache[key] = profile
		return profile, nil
	end

	local loaded, err = loadProfileFromDataStore(playerId)
	if not loaded then
		return nil, err or "profile_load_failed"
	end
	profileCache[key] = loaded
	return loaded, nil
end

function ProfileStore.GetProfile(playerId)
	if type(playerId) ~= "string" or playerId == "" then
		return nil, "invalid player id"
	end
	return ensureProfileLoaded(playerId)
end

function ProfileStore.UpdateProfile(playerId, mutatorFn)
	if type(playerId) ~= "string" or playerId == "" then
		return false, "invalid player id"
	end
	if type(mutatorFn) ~= "function" then
		return false, "invalid mutator"
	end

	local key = profileKey(playerId)
	local profile, loadErr = ensureProfileLoaded(playerId)
	if not profile then
		return false, loadErr or "profile_unavailable"
	end

	local newProfile, mutateErr = mutatorFn(profile)
	if mutateErr then
		return false, mutateErr
	end
	if not newProfile then
		return false, "mutator returned nil"
	end

	newProfile = migrateAndNormalize(newProfile, playerId)
	newProfile.updated_at = nowUtcIso()
	profileCache[key] = newProfile
	dirtyKeys[key] = true

	if not DATASTORE_ENABLED then
		return true, nil
	end
	return true, nil
end

function ProfileStore.FlushProfile(playerId, releaseLock)
	if type(playerId) ~= "string" or playerId == "" then
		return false, "invalid player id"
	end
	local key = profileKey(playerId)
	if not profileCache[key] then
		return true, nil
	end
	if not DATASTORE_ENABLED then
		dirtyKeys[key] = nil
		return true, nil
	end
	return saveProfileToDataStore(playerId, releaseLock == true)
end

function ProfileStore.FlushAll(releaseLock)
	local okAll = true
	for key in pairs(profileCache) do
		local playerId = tostring(key):gsub("^PlayerData_", "")
		local ok = ProfileStore.FlushProfile(playerId, releaseLock == true)
		if not ok then
			okAll = false
		end
	end
	return okAll
end

function ProfileStore.ClearCache()
	table.clear(profileCache)
	table.clear(dirtyKeys)
end

function ProfileStore.GetAllProfilesSnapshot()
	local out = {}
	for _, profile in pairs(profileCache) do
		table.insert(out, profile)
	end
	return out
end

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

function ProfileStore.GetBackendInfo()
	return {
		datastore_enabled = DATASTORE_ENABLED,
		datastore_name = PROFILE_DATASTORE_NAME,
		session_id = ACTIVE_SESSION_ID,
		cached_profiles = #ProfileStore.GetAllProfilesSnapshot(),
	}
end

if DATASTORE_ENABLED and RunService:IsServer() then
	task.spawn(function()
		while true do
			task.wait(AUTOSAVE_INTERVAL_SECONDS)
			for key in pairs(dirtyKeys) do
				local playerId = tostring(key):gsub("^PlayerData_", "")
				ProfileStore.FlushProfile(playerId, false)
			end
		end
	end)
end

if RunService:IsServer() then
	Players.PlayerRemoving:Connect(function(player)
		local playerId = tostring(player.UserId)
		ProfileStore.FlushProfile(playerId, true)
		local key = profileKey(playerId)
		profileCache[key] = nil
		dirtyKeys[key] = nil
	end)

	local okBind, bindErr = pcall(function()
		game:BindToClose(function()
			ProfileStore.FlushAll(true)
		end)
	end)
	if not okBind then
		warn("[Aura Dungeon] BindToClose hook skipped in this context:", tostring(bindErr))
	end
end

return ProfileStore
