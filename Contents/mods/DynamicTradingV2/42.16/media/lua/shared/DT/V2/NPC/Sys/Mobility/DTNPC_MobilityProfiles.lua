-- ==============================================================================
-- DTNPC_MobilityProfiles.lua
-- Shared locomotion profile definitions for DT NPC fake movement.
-- ==============================================================================

DTNPCMobility = DTNPCMobility or {}

local Mobility = DTNPCMobility
local Internal = Mobility.Internal or {}

Mobility.Internal = Internal

local DEFAULT_CRAWL_SPEED_MULT = 0.38

local function getProfiles()
    return {
        default = {
            key = "default",
            speedMultiplier = 1.0,
        },
        weakened_crouch = {
            key = "weakened_crouch",
            speedMultiplier = tonumber(DTNPCHealth and DTNPCHealth.WEAKENED_DEPARTURE_SPEED_MULT) or 0.55,
            animSpeed = tonumber(DTNPCHealth and DTNPCHealth.WEAKENED_DEPARTURE_ANIM_SPEED) or 0.82,
            dtWalkType = "SneakWalk",
            walkType = "1",
            isRunning = false,
            crawl = false,
        },
        incap_crawl = {
            key = "incap_crawl",
            speedMultiplier = tonumber(DTNPCHealth and DTNPCHealth.INCAP_CRAWL_SPEED_MULT) or DEFAULT_CRAWL_SPEED_MULT,
            animSpeed = 0.28,
            dtWalkType = "Crawl",
            walkType = "",
            isRunning = false,
            crawl = true,
        },
    }
end

function Mobility.GetLocomotionProfile(profileKey)
    local key = tostring(profileKey or "default")
    local profiles = getProfiles()
    return profiles[key] or profiles.default
end

function Mobility.ResolveLocomotionStateOptions(options)
    options = type(options) == "table" and options or {}

    local profileKey = options.profileKey
    if profileKey == nil or profileKey == "" then
        return options
    end

    local profile = Mobility.GetLocomotionProfile(profileKey)
    if type(profile) ~= "table" then
        return options
    end

    local merged = {}
    for key, value in pairs(profile) do
        if key ~= "key" and key ~= "speedMultiplier" then
            merged[key] = value
        end
    end
    for key, value in pairs(options) do
        merged[key] = value
    end
    merged.profileKey = profile.key or profileKey
    return merged
end
