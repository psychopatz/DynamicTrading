-- ==============================================================================
-- DTNPC_DistanceFrequency.lua
-- Server-side distance-based update frequency system (Phase 2.2).
-- Uses spatial hash proximity to determine how often NPCs send position updates.
-- ==============================================================================

DTNPC_DistanceFrequency = DTNPC_DistanceFrequency or {}

-- Distance tiers (in tiles)
DTNPC_DistanceFrequency.TIERS = {
    VERY_CLOSE = { range = 50,   updateFreq = 0.5,  label = "Very Close" },  -- Every 0.5s (~1 tick)
    CLOSE      = { range = 100,  updateFreq = 1.5,  label = "Close" },       -- Every 1.5s (~3 ticks)
    MEDIUM     = { range = 150,  updateFreq = 3.0,  label = "Medium" },      -- Every 3s (~6 ticks)
    FAR        = { range = 250,  updateFreq = 6.0,  label = "Far" },         -- Every 6s (~12 ticks)
}

-- NPC update timers
-- Format: [uuid] = { lastUpdateTime, updateFreq, currentTier }
DTNPC_DistanceFrequency.NPCTimers = DTNPC_DistanceFrequency.NPCTimers or {}

-- ==============================================================================
-- 1. DETERMINE DISTANCE TIER
-- ==============================================================================

function DTNPC_DistanceFrequency.GetTierForDistance(distance)
    if distance <= DTNPC_DistanceFrequency.TIERS.VERY_CLOSE.range then
        return "VERY_CLOSE"
    elseif distance <= DTNPC_DistanceFrequency.TIERS.CLOSE.range then
        return "CLOSE"
    elseif distance <= DTNPC_DistanceFrequency.TIERS.MEDIUM.range then
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
        DTNPC_DistanceFrequency.NPCTimers[uuid] = {
            lastUpdateTime = 0,
            updateFreq = 1.5,  -- Default to CLOSE
            currentTier = "CLOSE",
            distanceToNearest = 999999
        }
    end
end

function DTNPC_DistanceFrequency.UpdateNPC(uuid, x, y, nearbyPlayers)
    DTNPC_DistanceFrequency.InitializeNPC(uuid)
    
    local npcTimer = DTNPC_DistanceFrequency.NPCTimers[uuid]
    
    -- Find closest player
    local minDist = 999999
    for _, player in ipairs(nearbyPlayers) do
        local dx = player:getX() - x
        local dy = player:getY() - y
        local dist = math.sqrt(dx * dx + dy * dy)
        
        if dist < minDist then
            minDist = dist
        end
    end
    
    -- Determine tier based on closest distance
    local tier = DTNPC_DistanceFrequency.GetTierForDistance(minDist)
    npcTimer.currentTier = tier
    npcTimer.updateFreq = DTNPC_DistanceFrequency.TIERS[tier].updateFreq
    npcTimer.distanceToNearest = minDist
end

function DTNPC_DistanceFrequency.ShouldUpdateNPC(uuid)
    DTNPC_DistanceFrequency.InitializeNPC(uuid)
    
    local npcTimer = DTNPC_DistanceFrequency.NPCTimers[uuid]
    local currentTime = getGameTime():getWorldAgeHours()
    local timeSinceUpdate = currentTime - npcTimer.lastUpdateTime
    
    if timeSinceUpdate >= npcTimer.updateFreq then
        npcTimer.lastUpdateTime = currentTime
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
    
    DynamicTrading.Log("DTV2", "NPC", "Debug", "UUID: " .. uuid)
    DynamicTrading.Log("DTV2", "NPC", "Debug", "  Tier: " .. timer.currentTier)
    DynamicTrading.Log("DTV2", "NPC", "Debug", "  Update Freq: " .. timer.updateFreq .. " hours")
    DynamicTrading.Log("DTV2", "NPC", "Debug", "  Distance to Nearest: " .. string.format("%.1f", timer.distanceToNearest) .. " tiles")
    DynamicTrading.Log("DTV2", "NPC", "Debug", "  Last Updated: " .. string.format("%.2f", getGameTime():getWorldAgeHours() - timer.lastUpdateTime) .. " hours ago")
end

function DTNPC_DistanceFrequency.DebugStats()
    local stats = DTNPC_DistanceFrequency.GetUpdateStats()
    
    DynamicTrading.Log("DTV2", "NPC", "Debug", "Update Distribution:")
    DynamicTrading.Log("DTV2", "NPC", "Debug", "  Very Close (<50 tiles):   " .. stats.VERY_CLOSE .. " NPCs")
    DynamicTrading.Log("DTV2", "NPC", "Debug", "  Close (50-100 tiles):     " .. stats.CLOSE .. " NPCs")
    DynamicTrading.Log("DTV2", "NPC", "Debug", "  Medium (100-150 tiles):   " .. stats.MEDIUM .. " NPCs")
    DynamicTrading.Log("DTV2", "NPC", "Debug", "  Far (>150 tiles):         " .. stats.FAR .. " NPCs")
end
