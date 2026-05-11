-- ==============================================================================
-- DTNPC_ProtectState_Anchor.lua
-- Combat anchor and stationary post helpers for DTNPCProtect.
-- ==============================================================================

DTNPCProtect = DTNPCProtect or {}
DTNPCProtect.Internal = DTNPCProtect.Internal or {}

local Internal = DTNPCProtect.Internal
local buildPointTarget = Internal.ProtectStateBuildPointTarget

function DTNPCProtect.GetCombatAnchor(npcData, zombie)
    if npcData then
        local postX = tonumber(npcData.stationaryPostX)
        local postY = tonumber(npcData.stationaryPostY)
        if postX ~= nil and postY ~= nil then
            return postX, postY, tonumber(npcData.stationaryPostZ) or 0
        end

        local home = npcData.homeCoords
        if type(home) == "table" and home.x ~= nil and home.y ~= nil then
            return tonumber(home.x), tonumber(home.y), tonumber(home.z) or 0
        end

        local anchorX = tonumber(npcData.anchorX)
        local anchorY = tonumber(npcData.anchorY)
        if anchorX ~= nil and anchorY ~= nil then
            return anchorX, anchorY, tonumber(npcData.anchorZ) or 0
        end
    end

    if zombie then
        return zombie:getX(), zombie:getY(), zombie:getZ() or 0
    end

    return nil, nil, nil
end

function DTNPCProtect.GetCombatAnchorTarget(npcData, zombie)
    local x, y, z = DTNPCProtect.GetCombatAnchor(npcData, zombie)
    return buildPointTarget(x, y, z)
end

function DTNPCProtect.GetDistanceToCombatAnchor(x, y, z, npcData, zombie)
    local anchorX, anchorY, anchorZ = DTNPCProtect.GetCombatAnchor(npcData, zombie)
    if anchorX == nil or anchorY == nil then
        return nil
    end

    local actualZ = tonumber(z) or anchorZ or 0
    local resolvedAnchorZ = tonumber(anchorZ) or 0
    if math.abs(actualZ - resolvedAnchorZ) > 1.1 then
        return 9999
    end

    local dx = (tonumber(x) or anchorX) - anchorX
    local dy = (tonumber(y) or anchorY) - anchorY
    return math.sqrt((dx * dx) + (dy * dy))
end

function DTNPCProtect.RememberStationaryPost(zombie, npcData, state, force)
    if not zombie or not npcData then
        return false
    end

    DTNPCProtect.EnsureDataDefaults(npcData)

    local desiredState = state or npcData.state or "Idle"
    local currentX = zombie:getX()
    local currentY = zombie:getY()
    local currentZ = zombie:getZ()
    local resetDistance = tonumber(DTNPCProtect.CONFIG.StationaryPostResetDistance) or 4
    local storedX = tonumber(npcData.stationaryPostX)
    local storedY = tonumber(npcData.stationaryPostY)
    local storedZ = tonumber(npcData.stationaryPostZ) or currentZ
    local dist = 9999

    if storedX ~= nil and storedY ~= nil then
        local dx = currentX - storedX
        local dy = currentY - storedY
        dist = math.sqrt((dx * dx) + (dy * dy))
    end

    local shouldUpdate = force == true
        or storedX == nil
        or storedY == nil
        or npcData.stationaryPostState ~= desiredState
        or (npcData.combatResumeState == nil and dist > resetDistance)
        or math.abs(currentZ - storedZ) > 0.1

    if not shouldUpdate then
        return false
    end

    npcData.stationaryPostX = currentX
    npcData.stationaryPostY = currentY
    npcData.stationaryPostZ = currentZ
    npcData.stationaryPostState = desiredState
    return true
end

function DTNPCProtect.GetStationaryPost(npcData)
    if not npcData then
        return nil, nil, nil
    end

    local x = tonumber(npcData.stationaryPostX)
    local y = tonumber(npcData.stationaryPostY)
    local z = tonumber(npcData.stationaryPostZ) or 0
    if x == nil or y == nil then
        return nil, nil, nil
    end

    return x, y, z
end
