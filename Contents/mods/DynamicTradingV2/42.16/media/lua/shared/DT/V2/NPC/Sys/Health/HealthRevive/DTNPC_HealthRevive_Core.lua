-- ==============================================================================
-- DTNPC_HealthRevive_Core.lua
-- Shared revive constants and core accessors.
-- ==============================================================================

DTNPCHealth = DTNPCHealth or {}
DTNPCHealth.Internal = DTNPCHealth.Internal or {}

local internal = DTNPCHealth.Internal

DTNPCHealth.REVIVE_DEFAULT_COST_MIN = DTNPCHealth.REVIVE_DEFAULT_COST_MIN or 1
DTNPCHealth.REVIVE_DEFAULT_COST_MAX = DTNPCHealth.REVIVE_DEFAULT_COST_MAX or 3
DTNPCHealth.REVIVE_INITIAL_HP = DTNPCHealth.REVIVE_INITIAL_HP or 10
DTNPCHealth.REVIVE_INITIAL_HP_RATIO = DTNPCHealth.REVIVE_INITIAL_HP_RATIO or 0.25
DTNPCHealth.WEAKENED_THRESHOLD_RATIO = DTNPCHealth.WEAKENED_THRESHOLD_RATIO or 0.30
DTNPCHealth.WEAKENED_RECOVERY_RATIO = DTNPCHealth.WEAKENED_RECOVERY_RATIO or DTNPCHealth.WEAKENED_THRESHOLD_RATIO
DTNPCHealth.WEAKENED_DEPARTURE_SPEED_MULT = DTNPCHealth.WEAKENED_DEPARTURE_SPEED_MULT or 0.55
DTNPCHealth.WEAKENED_DEPARTURE_ANIM_SPEED = DTNPCHealth.WEAKENED_DEPARTURE_ANIM_SPEED or 0.82
DTNPCHealth.WEAKENED_CROUCH_PROFILE_KEY = DTNPCHealth.WEAKENED_CROUCH_PROFILE_KEY or "weakened_crouch"
DTNPCHealth.INCAP_CRAWL_PROFILE_KEY = DTNPCHealth.INCAP_CRAWL_PROFILE_KEY or "incap_crawl"
DTNPCHealth.INCAP_CRAWL_SPEED_MULT = DTNPCHealth.INCAP_CRAWL_SPEED_MULT or 0.38
DTNPCHealth.REVIVE_ESCAPE_TARGET_DIST = DTNPCHealth.REVIVE_ESCAPE_TARGET_DIST or 20
DTNPCHealth.REVIVE_INTERACT_RANGE = DTNPCHealth.REVIVE_INTERACT_RANGE or 3.5
DTNPCHealth.REVIVE_REPUTATION_REWARD = DTNPCHealth.REVIVE_REPUTATION_REWARD or 5
DTNPCHealth.ALLY_REVIVE_SEARCH_RADIUS = DTNPCHealth.ALLY_REVIVE_SEARCH_RADIUS or 16
DTNPCHealth.ALLY_REVIVE_THREAT_RADIUS = DTNPCHealth.ALLY_REVIVE_THREAT_RADIUS or 11
DTNPCHealth.ALLY_REVIVE_ACTION_DURATION_MS = DTNPCHealth.ALLY_REVIVE_ACTION_DURATION_MS or 3500
DTNPCHealth.ALLY_REVIVE_LEASE_MS = DTNPCHealth.ALLY_REVIVE_LEASE_MS or 6000
DTNPCHealth.ALLY_REVIVE_RETRY_DELAY_MS = DTNPCHealth.ALLY_REVIVE_RETRY_DELAY_MS or 5000
DTNPCHealth.POST_REVIVE_GRACE_WINDOW_MS = DTNPCHealth.POST_REVIVE_GRACE_WINDOW_MS or 2500
DTNPCHealth.BODY_RECOVERY_RETRY_MS = DTNPCHealth.BODY_RECOVERY_RETRY_MS or 2000
DTNPCHealth.PREMATURE_DEATH_RECOVERY_WINDOW_MS = DTNPCHealth.PREMATURE_DEATH_RECOVERY_WINDOW_MS or 8000
DTNPCHealth.PREMATURE_DEATH_RECOVERY_MAX_CHAIN = DTNPCHealth.PREMATURE_DEATH_RECOVERY_MAX_CHAIN or 2
DTNPCHealth.SELF_BANDAGE_COMBAT_COOLDOWN_MS = DTNPCHealth.SELF_BANDAGE_COMBAT_COOLDOWN_MS or 12000
DTNPCHealth.REVIVE_VALID_ITEM_TYPES = DTNPCHealth.REVIVE_VALID_ITEM_TYPES or {
    "Base.RippedSheets",
    "Base.AlcoholRippedSheets",
    "Base.Bandage",
    "Base.AlcoholBandage",
}

local function getSandboxReviveCostBounds()
    local sandbox = SandboxVars and SandboxVars.DynamicTrading or nil
    local minValue = tonumber(sandbox and sandbox.ReviveCostMin) or DTNPCHealth.REVIVE_DEFAULT_COST_MIN
    local maxValue = tonumber(sandbox and sandbox.ReviveCostMax) or DTNPCHealth.REVIVE_DEFAULT_COST_MAX

    minValue = math.max(1, math.floor(minValue + 0.5))
    maxValue = math.max(1, math.floor(maxValue + 0.5))
    if maxValue < minValue then
        minValue, maxValue = maxValue, minValue
    end

    return minValue, maxValue
end

internal.getSandboxReviveCostBounds = getSandboxReviveCostBounds

function DTNPCHealth.RollReviveCost()
    local minValue, maxValue = getSandboxReviveCostBounds()
    if maxValue <= minValue then
        return minValue
    end

    if ZombRand then
        return minValue + ZombRand((maxValue - minValue) + 1)
    end

    return minValue + math.floor(math.random() * ((maxValue - minValue) + 1))
end

function DTNPCHealth.GetHealthState(npcData)
    if not npcData then
        return nil
    end
    if tostring(npcData.status or "") == "Dead" or tonumber(npcData.deathFinalizedAt) then
        return "Dead"
    end
    if npcData.incapState == "Active" or tostring(npcData.state or "") == "Incapacitated" then
        return "Incapacitated"
    end
    local explicit = tostring(npcData.healthState or "")
    if explicit == "Weakened" or explicit == "Healthy" then
        return explicit
    end

    local current = DTNPCHealth.GetCurrentHP and DTNPCHealth.GetCurrentHP(npcData) or nil
    local maxHealth = DTNPCHealth.GetMaxHP and DTNPCHealth.GetMaxHP(npcData) or nil
    if current ~= nil and maxHealth ~= nil and maxHealth > 0 then
        local ratio = current / maxHealth
        if ratio <= (tonumber(DTNPCHealth.WEAKENED_THRESHOLD_RATIO) or 0.30) then
            return "Weakened"
        end
        return "Healthy"
    end

    if explicit == "Weakened" then
        return "Weakened"
    end
    return "Healthy"
end

function DTNPCHealth.GetReviveRequirement(npcData)
    if type(npcData) ~= "table" then
        return nil
    end

    local reviveData = type(npcData.reviveData) == "table" and npcData.reviveData or nil
    local requiredCount = tonumber(reviveData and reviveData.requiredItemCount) or nil
    if requiredCount and requiredCount > 0 then
        return math.max(1, math.floor(requiredCount))
    end

    return nil
end
