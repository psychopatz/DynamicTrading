-- ==============================================================================
-- DTNPC_ClientSync_Interpolation.lua
-- Client-side position interpolation for smooth NPC movement.
-- Predicts NPC position between server updates for visual smoothness.
-- Works automatically on modded and vanilla maps.
-- ==============================================================================

DTNPC_ClientSync = DTNPC_ClientSync or {}
DTNPC_ClientInterpolation = DTNPC_ClientInterpolation or {}

local ClientSync = DTNPC_ClientSync
local modules = ClientSync.Modules or {}

ClientSync.Modules = modules

if modules.Interpolation then
    return
end

modules.Interpolation = true

-- Interpolation state per NPC
-- Format: [uuid] = { lastX, lastY, lastZ, targetX, targetY, targetZ, lastUpdateTime, updateFreq }
DTNPC_ClientInterpolation.NPCState = DTNPC_ClientInterpolation.NPCState or {}

-- Configuration (milliseconds)
DTNPC_ClientInterpolation.CONFIG = {
    BASE_UPDATE_FREQ = 350,       -- Base visual blend duration in milliseconds.
    INTERPOLATION_FACTOR = 1.0,   -- How much to interpolate (1.0 = full, 0.5 = half)
    DISTANCE_THRESHOLD = 18,      -- Snap instead of smoothing large teleports
    MAX_UPDATE_TIME = 2200,       -- Drop stale interpolation state after this many ms
    MAX_EXTRAPOLATE_MS = 180,
}

local function shouldApplyClientInterpolation()
    return isClient() and not isServer()
end

-- ==============================================================================
-- 1. UPDATE TRACKING
-- ==============================================================================

local function getNowMs()
    if getTimeInMillis then
        return getTimeInMillis()
    end
    return os.time() * 1000
end

function DTNPC_ClientInterpolation.RecordUpdate(uuid, x, y, z, updateFreq, motionHint)
    if not uuid or not x then return end
    if not shouldApplyClientInterpolation() then
        return
    end
    
    local state = DTNPC_ClientInterpolation.NPCState[uuid] or {}
    local nowMs = getNowMs()
    local hint = type(motionHint) == "table" and motionHint or nil
    local durationMs = tonumber(updateFreq) or (hint and tonumber(hint.durationMs)) or DTNPC_ClientInterpolation.CONFIG.BASE_UPDATE_FREQ
    durationMs = math.max(50, math.min(1200, durationMs))
    
    state.lastX = hint and tonumber(hint.fromX) or state.targetX or state.lastX or x
    state.lastY = hint and tonumber(hint.fromY) or state.targetY or state.lastY or y
    state.lastZ = state.targetZ or z
    
    -- Store new target and timing
    state.targetX = hint and tonumber(hint.toX) or x
    state.targetY = hint and tonumber(hint.toY) or y
    state.targetZ = z
    state.lastUpdateTime = nowMs
    state.updateFreq = durationMs
    state.dirX = hint and tonumber(hint.dirX) or nil
    state.dirY = hint and tonumber(hint.dirY) or nil
    state.crawl = hint and hint.crawl == true or false
    state.running = hint and hint.running == true or false
    
    DTNPC_ClientInterpolation.NPCState[uuid] = state
end

-- ==============================================================================
-- 2. INTERPOLATED POSITION CALCULATION
-- ==============================================================================

function DTNPC_ClientInterpolation.GetInterpolatedPosition(uuid, zombie)
    if not shouldApplyClientInterpolation() then
        if zombie then
            return zombie:getX(), zombie:getY(), zombie:getZ()
        end
        return nil
    end

    local state = DTNPC_ClientInterpolation.NPCState[uuid]
    if not state or not state.targetX then
        -- No state recorded, return actual zombie position
        if zombie then
            return zombie:getX(), zombie:getY(), zombie:getZ()
        end
        return nil
    end
    
    local currentTime = getNowMs()
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
    local maxTime = (tonumber(state.updateFreq) or DTNPC_ClientInterpolation.CONFIG.BASE_UPDATE_FREQ)
        + DTNPC_ClientInterpolation.CONFIG.MAX_EXTRAPOLATE_MS
    local progress = math.min(timeSinceUpdate / math.max(1, tonumber(state.updateFreq) or 1), maxTime / math.max(1, tonumber(state.updateFreq) or 1))
    progress = progress * DTNPC_ClientInterpolation.CONFIG.INTERPOLATION_FACTOR
    
    -- Verify distance is reasonable (sanity check)
    local dx = state.targetX - state.lastX
    local dy = state.targetY - state.lastY
    local dist = math.sqrt(dx * dx + dy * dy)
    
    if dist > DTNPC_ClientInterpolation.CONFIG.DISTANCE_THRESHOLD then
        DTNPC_ClientInterpolation.NPCState[uuid] = nil
        if zombie then
            return state.targetX, state.targetY, state.targetZ, true
        end
        return state.targetX, state.targetY, state.targetZ, true
    end
    
    -- Linear interpolation
    local interpX = state.lastX + (state.targetX - state.lastX) * progress
    local interpY = state.lastY + (state.targetY - state.lastY) * progress
    local interpZ = state.lastZ + (state.targetZ - state.lastZ) * progress
    
    return interpX, interpY, interpZ, false
end

function DTNPC_ClientInterpolation.ApplyToZombie(uuid, zombie)
    if not uuid or not zombie then
        return false
    end
    if not shouldApplyClientInterpolation() then
        return false
    end

    local interpX, interpY, interpZ, shouldSnap = DTNPC_ClientInterpolation.GetInterpolatedPosition(uuid, zombie)
    if not interpX or not interpY then
        return false
    end

    local localX = zombie:getX()
    local localY = zombie:getY()
    local localZ = zombie:getZ()
    local dx = interpX - localX
    local dy = interpY - localY
    local dz = (interpZ or localZ) - localZ

    if math.abs(dx) <= 0.001 and math.abs(dy) <= 0.001 and math.abs(dz) <= 0.001 then
        return false
    end

    zombie:setX(interpX)
    zombie:setY(interpY)
    if interpZ ~= nil and math.abs(dz) > 0.001 then
        zombie:setZ(interpZ)
    end

    return true
end

function DTNPC_ClientInterpolation.HasFreshState(uuid)
    if not shouldApplyClientInterpolation() then
        return false
    end
    local state = uuid and DTNPC_ClientInterpolation.NPCState[uuid] or nil
    if not state or not state.targetX then
        return false
    end
    return (getNowMs() - (tonumber(state.lastUpdateTime) or 0)) <= DTNPC_ClientInterpolation.CONFIG.MAX_UPDATE_TIME
end

function DTNPC_ClientInterpolation.ApplyToTrackedNPCs()
    if not shouldApplyClientInterpolation() then
        return 0
    end

    local cell = getCell()
    if not cell then
        return 0
    end

    local zombieList = cell:getZombieList()
    if not zombieList then
        return 0
    end

    local applied = 0
    for i = 0, zombieList:size() - 1 do
        local zombie = zombieList:get(i)
        if zombie and not zombie:isDead() then
            local modData = zombie:getModData()
            local uuid = modData and modData.DTNPC_UUID or nil
            if uuid and not (DTNPCClient and DTNPCClient.LocalControlled and DTNPCClient.LocalControlled[uuid]) then
                if DTNPC_ClientInterpolation.ApplyToZombie(uuid, zombie) then
                    applied = applied + 1
                end
            end
        end
    end

    return applied
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
        DynamicTrading.Log("DTV2", "NPC", "Debug", "No state for UUID: " .. uuid)
        return
    end
    
    DynamicTrading.Log("DTV2", "NPC", "Debug", "UUID: " .. uuid)
    DynamicTrading.Log("DTV2", "NPC", "Debug", "  Last Pos: " .. string.format("(%.1f, %.1f, %.1f)", state.lastX, state.lastY, state.lastZ))
    DynamicTrading.Log("DTV2", "NPC", "Debug", "  Target Pos: " .. string.format("(%.1f, %.1f, %.1f)", state.targetX, state.targetY, state.targetZ))
    DynamicTrading.Log("DTV2", "NPC", "Debug", "  Update Freq: " .. state.updateFreq .. "h")
    DynamicTrading.Log("DTV2", "NPC", "Debug", "  Last Update: " .. string.format("%.2f", getGameTime():getWorldAgeHours() - state.lastUpdateTime) .. " hours ago")
end
