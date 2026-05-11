-- ==============================================================================
-- DTNPC_ProtectState_Pursuit.lua
-- Combat pursuit tracking helpers for DTNPCProtect.
-- ==============================================================================

DTNPCProtect = DTNPCProtect or {}
DTNPCProtect.Internal = DTNPCProtect.Internal or {}

local Internal = DTNPCProtect.Internal
local nowMillis = Internal.ProtectStateNowMillis

local function resolveTrackedTargetID(npcData, target)
    if npcData and npcData.combatTargetID then
        return tostring(npcData.combatTargetID)
    end

    if not target then
        return nil
    end

    local onlineID = target.getOnlineID and target:getOnlineID() or nil
    if onlineID and onlineID ~= 0 then
        return "online:" .. tostring(onlineID)
    end
    local outfitID = target.getPersistentOutfitID and target:getPersistentOutfitID() or nil
    if outfitID and outfitID ~= 0 then
        return "outfit:" .. tostring(outfitID)
    end
    local objectID = target.getID and target:getID() or nil
    if objectID and objectID ~= 0 then
        return "id:" .. tostring(objectID)
    end

    return tostring(target)
end

function DTNPCProtect.ResetCombatPursuit(npcData)
    if not npcData then
        return
    end

    npcData.combatPursuitTargetID = nil
    npcData.combatPursuitStartedAt = 0
    npcData.combatPursuitLastProgressAt = 0
    npcData.combatPursuitLastAttackAt = 0
    npcData.combatPursuitLastDistance = nil
end

function DTNPCProtect.MarkCombatPursuit(npcData, target, currentDistance, attacked)
    if not npcData then
        return
    end

    DTNPCProtect.EnsureDataDefaults(npcData)

    local now = nowMillis()
    local trackedTargetID = resolveTrackedTargetID(npcData, target)
    if trackedTargetID ~= nil and npcData.combatPursuitTargetID ~= trackedTargetID then
        npcData.combatPursuitTargetID = trackedTargetID
        npcData.combatPursuitStartedAt = now
        npcData.combatPursuitLastProgressAt = now
        npcData.combatPursuitLastAttackAt = 0
        npcData.combatPursuitLastDistance = tonumber(currentDistance)
    end

    local progressThreshold = math.max(0.05, tonumber(DTNPCProtect.CONFIG.CombatProgressDistance) or 0.35)
    local previousDistance = tonumber(npcData.combatPursuitLastDistance)
    local distance = tonumber(currentDistance)
    if distance ~= nil then
        if previousDistance == nil or distance <= (previousDistance - progressThreshold) then
            npcData.combatPursuitLastProgressAt = now
        end
        npcData.combatPursuitLastDistance = distance
    end

    if attacked == true then
        npcData.combatPursuitLastAttackAt = now
        npcData.combatPursuitLastProgressAt = now
    end
end

function DTNPCProtect.ShouldAbortCombatPursuit(npcData, timeoutMs)
    if not npcData or not npcData.combatPursuitTargetID then
        return false
    end

    local timeout = math.max(1000, tonumber(timeoutMs) or DTNPCProtect.GetCombatUnreachableTimeoutMs(npcData))
    local now = nowMillis()
    local lastProgress = math.max(
        tonumber(npcData.combatPursuitStartedAt) or 0,
        tonumber(npcData.combatPursuitLastProgressAt) or 0,
        tonumber(npcData.combatPursuitLastAttackAt) or 0
    )

    return (now - lastProgress) >= timeout
end

function DTNPCProtect.ClearCombatTarget(npcData)
    if npcData then
        npcData.combatTargetID = nil
        npcData.combatTargetType = nil
        DTNPCProtect.ResetCombatPursuit(npcData)
    end
end
