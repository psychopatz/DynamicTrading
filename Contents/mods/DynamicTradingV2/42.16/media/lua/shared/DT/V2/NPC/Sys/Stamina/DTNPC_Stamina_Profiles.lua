-- ==============================================================================
-- DTNPC_Stamina_Profiles.lua
-- Shared stamina tuning profiles for custom locomotion states.
-- ==============================================================================

DTNPCStamina = DTNPCStamina or {}
DTNPCStamina.Internal = DTNPCStamina.Internal or {}

local Stamina = DTNPCStamina
local Internal = DTNPCStamina.Internal

function Stamina.GetMovementStateProfile(profileKey)
    local key = tostring(profileKey or "default")
    local profiles = {
        default = {
            key = "default",
            drainMultiplier = 1.0,
            pauseThreshold = tonumber(Internal.MoveExhaustPauseRatio) or 0.25,
            resumeThreshold = tonumber(Internal.MoveExhaustResumeRatio) or 0.40,
            passiveRecoverMultiplier = 1.0,
        },
        weakened_crouch = {
            key = "weakened_crouch",
            drainMultiplier = 1.10,
            pauseThreshold = 0.35,
            resumeThreshold = 0.50,
            passiveRecoverMultiplier = 1.0,
        },
        incap_crawl = {
            key = "incap_crawl",
            drainMultiplier = 1.85,
            pauseThreshold = 0.60,
            resumeThreshold = 0.75,
            passiveRecoverMultiplier = 0.32,
        },
    }

    return profiles[key] or profiles.default
end

function Internal.resolveMovementThresholds(profileKey)
    local profile = Stamina.GetMovementStateProfile(profileKey)
    local pauseThreshold = tonumber(profile and profile.pauseThreshold) or tonumber(Internal.MoveExhaustPauseRatio) or 0.25
    local resumeThreshold = tonumber(profile and profile.resumeThreshold) or tonumber(Internal.MoveExhaustResumeRatio) or 0.40
    if resumeThreshold < pauseThreshold then
        resumeThreshold = pauseThreshold
    end
    return profile, pauseThreshold, resumeThreshold
end
