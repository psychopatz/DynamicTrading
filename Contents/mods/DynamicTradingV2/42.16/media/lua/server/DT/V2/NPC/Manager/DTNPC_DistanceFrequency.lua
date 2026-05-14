-- ==============================================================================
-- DTNPC_DistanceFrequency.lua
-- Server-side distance-based update frequency system (Phase 2.2).
-- Uses spatial hash proximity to determine how often NPCs send position updates.
-- ==============================================================================

DTNPC_DistanceFrequency = DTNPC_DistanceFrequency or {}

local function nowMillis()
    if getTimeInMillis then
        return math.floor(tonumber(getTimeInMillis()) or 0)
    end

    local gameTime = getGameTime and getGameTime() or nil
    if gameTime and gameTime.getWorldAgeHours then
        return math.floor((tonumber(gameTime:getWorldAgeHours()) or 0) * 3600000)
    end

    return 0
end

local function buildTier(range, seconds, label)
    local intervalMs = math.max(1, math.floor((tonumber(seconds) or 0) * 1000))
    return {
        range = range,
        rangeSq = range * range,
        updateFreq = tonumber(seconds) or 0,
        updateIntervalMs = intervalMs,
        label = label,
    }
end

-- Distance tiers (in tiles)
DTNPC_DistanceFrequency.TIERS = {
    VERY_CLOSE = buildTier(50, 0.5, "Very Close"),
    CLOSE      = buildTier(100, 1.5, "Close"),
    MEDIUM     = buildTier(150, 3.0, "Medium"),
    FAR        = buildTier(250, 6.0, "Far"),
}

-- NPC update timers
-- Format: [uuid] = { lastUpdateAtMs, updateFreq, updateIntervalMs, currentTier }
DTNPC_DistanceFrequency.NPCTimers = DTNPC_DistanceFrequency.NPCTimers or {}

-- ==============================================================================
-- 1. DETERMINE DISTANCE TIER
-- ==============================================================================

function DTNPC_DistanceFrequency.GetTierForDistance(distance)
    local numericDistance = math.max(0, tonumber(distance) or 0)
    if numericDistance <= DTNPC_DistanceFrequency.TIERS.VERY_CLOSE.range then
        return "VERY_CLOSE"
    elseif numericDistance <= DTNPC_DistanceFrequency.TIERS.CLOSE.range then
        return "CLOSE"
    elseif numericDistance <= DTNPC_DistanceFrequency.TIERS.MEDIUM.range then
        return "MEDIUM"
    else
        return "FAR"
    end
end

function DTNPC_DistanceFrequency.GetUpdateFrequencyForDistance(distance)
    local tier = DTNPC_DistanceFrequency.GetTierForDistance(distance)
    return DTNPC_DistanceFrequency.TIERS[tier].updateFreq
end

-- ==============================================================================
-- 2. TIMER MANAGEMENT
-- ==============================================================================

function DTNPC_DistanceFrequency.InitializeNPC(uuid)
    if not DTNPC_DistanceFrequency.NPCTimers[uuid] then
        local defaultTier = DTNPC_DistanceFrequency.TIERS.CLOSE
        DTNPC_DistanceFrequency.NPCTimers[uuid] = {
            lastUpdateAtMs = 0,
            updateFreq = defaultTier.updateFreq,
            updateIntervalMs = defaultTier.updateIntervalMs,
            currentTier = "CLOSE",
            distanceToNearest = 999999,
        }
    end
end

function DTNPC_DistanceFrequency.UpdateNPC(uuid, x, y, nearbyPlayers)
    DTNPC_DistanceFrequency.InitializeNPC(uuid)

    local npcTimer = DTNPC_DistanceFrequency.NPCTimers[uuid]
    local minDistSq = nil
    for _, player in ipairs(nearbyPlayers or {}) do
        if player then
            local dx = (tonumber(player:getX()) or 0) - (tonumber(x) or 0)
            local dy = (tonumber(player:getY()) or 0) - (tonumber(y) or 0)
            local distSq = (dx * dx) + (dy * dy)
            if minDistSq == nil or distSq < minDistSq then
                minDistSq = distSq
            end
        end
    end

    if minDistSq == nil then
        minDistSq = math.huge
    end

    local tierName = "FAR"
    if minDistSq <= DTNPC_DistanceFrequency.TIERS.VERY_CLOSE.rangeSq then
        tierName = "VERY_CLOSE"
    elseif minDistSq <= DTNPC_DistanceFrequency.TIERS.CLOSE.rangeSq then
        tierName = "CLOSE"
    elseif minDistSq <= DTNPC_DistanceFrequency.TIERS.MEDIUM.rangeSq then
        tierName = "MEDIUM"
    end

    local tier = DTNPC_DistanceFrequency.TIERS[tierName]
    npcTimer.currentTier = tierName
    npcTimer.updateFreq = tier.updateFreq
    npcTimer.updateIntervalMs = tier.updateIntervalMs
    npcTimer.distanceToNearest = minDistSq == math.huge and 999999 or math.sqrt(minDistSq)
end

function DTNPC_DistanceFrequency.ShouldUpdateNPC(uuid)
    DTNPC_DistanceFrequency.InitializeNPC(uuid)

    local npcTimer = DTNPC_DistanceFrequency.NPCTimers[uuid]
    local currentTime = nowMillis()
    local timeSinceUpdate = currentTime - math.max(0, tonumber(npcTimer.lastUpdateAtMs) or 0)

    if timeSinceUpdate >= math.max(1, tonumber(npcTimer.updateIntervalMs) or 1) then
        npcTimer.lastUpdateAtMs = currentTime
        return true, npcTimer.currentTier
    end

    return false, npcTimer.currentTier
end

function DTNPC_DistanceFrequency.RemoveNPC(uuid)
    DTNPC_DistanceFrequency.NPCTimers[uuid] = nil
end

function DTNPC_DistanceFrequency.Clear()
    DTNPC_DistanceFrequency.NPCTimers = {}
end

-- ==============================================================================
-- 3. QUERY FUNCTIONS
-- ==============================================================================

function DTNPC_DistanceFrequency.GetUpdateStats()
    local stats = {
        VERY_CLOSE = 0,
        CLOSE = 0,
        MEDIUM = 0,
        FAR = 0,
    }

    for _, timer in pairs(DTNPC_DistanceFrequency.NPCTimers) do
        local tier = timer.currentTier
        if stats[tier] then
            stats[tier] = stats[tier] + 1
        end
    end

    return stats
end

function DTNPC_DistanceFrequency.DebugNPC(uuid)
    local timer = DTNPC_DistanceFrequency.NPCTimers[uuid]

    if not timer then
        DynamicTrading.Log("DTV2", "NPC", "Debug", "No timer for UUID: " .. uuid)
        return
    end

    local lastUpdatedAgoMs = nowMillis() - math.max(0, tonumber(timer.lastUpdateAtMs) or 0)
    DynamicTrading.Log("DTV2", "NPC", "Debug", "UUID: " .. uuid)
    DynamicTrading.Log("DTV2", "NPC", "Debug", "  Tier: " .. timer.currentTier)
    DynamicTrading.Log("DTV2", "NPC", "Debug", "  Update Freq: " .. tostring(timer.updateFreq) .. " seconds")
    DynamicTrading.Log("DTV2", "NPC", "Debug", "  Distance to Nearest: " .. string.format("%.1f", timer.distanceToNearest) .. " tiles")
    DynamicTrading.Log("DTV2", "NPC", "Debug", "  Last Updated: " .. string.format("%.2f", lastUpdatedAgoMs / 1000) .. " seconds ago")
end

function DTNPC_DistanceFrequency.DebugStats()
    local stats = DTNPC_DistanceFrequency.GetUpdateStats()

    DynamicTrading.Log("DTV2", "NPC", "Debug", "Update Distribution:")
    DynamicTrading.Log("DTV2", "NPC", "Debug", "  Very Close (<50 tiles):   " .. stats.VERY_CLOSE .. " NPCs")
    DynamicTrading.Log("DTV2", "NPC", "Debug", "  Close (50-100 tiles):     " .. stats.CLOSE .. " NPCs")
    DynamicTrading.Log("DTV2", "NPC", "Debug", "  Medium (100-150 tiles):   " .. stats.MEDIUM .. " NPCs")
    DynamicTrading.Log("DTV2", "NPC", "Debug", "  Far (>150 tiles):         " .. stats.FAR .. " NPCs")
end
