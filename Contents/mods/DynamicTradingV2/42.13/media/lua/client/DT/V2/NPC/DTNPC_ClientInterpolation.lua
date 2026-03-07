-- ==============================================================================
-- DTNPC_ClientInterpolation.lua
-- Client-side position interpolation for smooth NPC movement.
-- Predicts NPC position between server updates for visual smoothness.
-- Works automatically on modded and vanilla maps.
-- ==============================================================================

DTNPC_ClientInterpolation = DTNPC_ClientInterpolation or {}

-- Interpolation state per NPC
-- Format: [uuid] = { lastX, lastY, lastZ, targetX, targetY, targetZ, lastUpdateTime, updateFreq }
DTNPC_ClientInterpolation.NPCState = DTNPC_ClientInterpolation.NPCState or {}

-- Configuration (in game hours)
DTNPC_ClientInterpolation.CONFIG = {
    BASE_UPDATE_FREQ = 0.5,       -- Base update frequency in hours (~1 second)
    INTERPOLATION_FACTOR = 1.0,   -- How much to interpolate (1.0 = full, 0.5 = half)
    DISTANCE_THRESHOLD = 50,      -- Only interpolate if distance < 50 tiles
    MAX_UPDATE_TIME = 2.0,        -- Max time between updates before resetting (in hours)
}

-- ==============================================================================
-- 1. UPDATE TRACKING
-- ==============================================================================

function DTNPC_ClientInterpolation.RecordUpdate(uuid, x, y, z, updateFreq)
    if not uuid or not x then return end
    
    local state = DTNPC_ClientInterpolation.NPCState[uuid] or {}
    
    -- Store previous position
    state.lastX = state.targetX or x
    state.lastY = state.targetY or y
    state.lastZ = state.targetZ or z
    
    -- Store new target and timing
    state.targetX = x
    state.targetY = y
    state.targetZ = z
    state.lastUpdateTime = getGameTime():getWorldAgeHours()
    state.updateFreq = updateFreq or DTNPC_ClientInterpolation.CONFIG.BASE_UPDATE_FREQ
    
    DTNPC_ClientInterpolation.NPCState[uuid] = state
end

-- ==============================================================================
-- 2. INTERPOLATED POSITION CALCULATION
-- ==============================================================================

function DTNPC_ClientInterpolation.GetInterpolatedPosition(uuid, zombie)
    local state = DTNPC_ClientInterpolation.NPCState[uuid]
    if not state or not state.targetX then
        -- No state recorded, return actual zombie position
        if zombie then
            return zombie:getX(), zombie:getY(), zombie:getZ()
        end
        return nil
    end
    
    local currentTime = getGameTime():getWorldAgeHours()
    local timeSinceUpdate = currentTime - (state.lastUpdateTime or currentTime)
    
    -- Reset if update is stale (NPC likely disconnected or despawned)
    if timeSinceUpdate > DTNPC_ClientInterpolation.CONFIG.MAX_UPDATE_TIME then
        DTNPC_ClientInterpolation.NPCState[uuid] = nil
        if zombie then
            return zombie:getX(), zombie:getY(), zombie:getZ()
        end
        return nil
    end
    
    -- Calculate progress (0 to 1) within update interval
    local progress = math.min(timeSinceUpdate / state.updateFreq, 1.0)
    progress = progress * DTNPC_ClientInterpolation.CONFIG.INTERPOLATION_FACTOR
    
    -- Verify distance is reasonable (sanity check)
    local dx = state.targetX - state.lastX
    local dy = state.targetY - state.lastY
    local dist = math.sqrt(dx * dx + dy * dy)
    
    if dist > DTNPC_ClientInterpolation.CONFIG.DISTANCE_THRESHOLD then
        -- Distance too large - likely a teleport or synchronization issue
        -- Return actual position without interpolation
        if zombie then
            return zombie:getX(), zombie:getY(), zombie:getZ()
        end
        return state.targetX, state.targetY, state.targetZ
    end
    
    -- Linear interpolation
    local interpX = state.lastX + (state.targetX - state.lastX) * progress
    local interpY = state.lastY + (state.targetY - state.lastY) * progress
    local interpZ = state.lastZ + (state.targetZ - state.lastZ) * progress
    
    return interpX, interpY, interpZ
end

-- ==============================================================================
-- 3. CLEANUP
-- ==============================================================================

function DTNPC_ClientInterpolation.ClearNPC(uuid)
    DTNPC_ClientInterpolation.NPCState[uuid] = nil
end

function DTNPC_ClientInterpolation.ClearAll()
    DTNPC_ClientInterpolation.NPCState = {}
end

-- ==============================================================================
-- 4. DEBUG / MONITORING
-- ==============================================================================

function DTNPC_ClientInterpolation.GetTrackedCount()
    local count = 0
    for _ in pairs(DTNPC_ClientInterpolation.NPCState) do
        count = count + 1
    end
    return count
end

function DTNPC_ClientInterpolation.DebugPrint(uuid)
    local state = DTNPC_ClientInterpolation.NPCState[uuid]
    if not state then
        print("[DTNPC_Interp] No state for UUID: " .. uuid)
        return
    end
    
    print("[DTNPC_Interp] UUID: " .. uuid)
    print("  Last Pos: " .. string.format("(%.1f, %.1f, %.1f)", state.lastX, state.lastY, state.lastZ))
    print("  Target Pos: " .. string.format("(%.1f, %.1f, %.1f)", state.targetX, state.targetY, state.targetZ))
    print("  Update Freq: " .. state.updateFreq .. "h")
    print("  Last Update: " .. string.format("%.2f", getGameTime():getWorldAgeHours() - state.lastUpdateTime) .. " hours ago")
end
