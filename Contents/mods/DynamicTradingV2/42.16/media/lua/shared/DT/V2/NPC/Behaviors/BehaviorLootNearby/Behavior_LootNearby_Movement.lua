-- ==============================================================================
-- Behavior_LootNearby_Movement.lua
-- Inspection timing and movement recovery helpers for loot search behavior.
-- ==============================================================================

DTNPCLogic = DTNPCLogic or {}
DTNPCLogic.Internal = DTNPCLogic.Internal or {}
DTNPCLogic.Internal.LootNearby = DTNPCLogic.Internal.LootNearby or {}

local LootNearby = DTNPCLogic.Internal.LootNearby
local modules = LootNearby.Modules or {}
local Constants = LootNearby.Constants or {}

LootNearby.Modules = modules
LootNearby.Constants = Constants

if modules.Movement then
    return
end

modules.Movement = true

function LootNearby.ResetLootAntiStuck(npcData)
    if DTNPCBehaviorAntiStuck and DTNPCBehaviorAntiStuck.Reset then
        DTNPCBehaviorAntiStuck.Reset(npcData, "LootNearby")
    end
end

function LootNearby.BeginLootInspection(npcData, sourceKey)
    if not npcData or not sourceKey then
        return false
    end

    local currentTime = LootNearby.NowMillis()
    if npcData.dcLootInspectSourceKey ~= sourceKey then
        npcData.dcLootInspectSourceKey = sourceKey
        npcData.dcLootInspectStartedAt = currentTime
        return false
    end

    return currentTime > 0 and (currentTime - (tonumber(npcData.dcLootInspectStartedAt) or 0)) >= Constants.LOOT_DISCOVERY_DWELL_MS
end

function LootNearby.ClearLootInspection(npcData, sourceKey)
    if not npcData then
        return
    end
    if sourceKey == nil or npcData.dcLootInspectSourceKey == sourceKey then
        npcData.dcLootInspectSourceKey = nil
        npcData.dcLootInspectStartedAt = nil
    end
end

function LootNearby.TrackLootApproach(npcData, sourceKey)
    if not npcData or not sourceKey then
        return
    end

    local currentTime = LootNearby.NowMillis()
    if npcData.dcLootApproachSourceKey ~= sourceKey then
        npcData.dcLootApproachSourceKey = sourceKey
        npcData.dcLootApproachStartedAt = currentTime
    elseif not npcData.dcLootApproachStartedAt or tonumber(npcData.dcLootApproachStartedAt) <= 0 then
        npcData.dcLootApproachStartedAt = currentTime
    end
end

function LootNearby.ClearLootApproach(npcData, sourceKey)
    if not npcData then
        return
    end
    if sourceKey == nil or npcData.dcLootApproachSourceKey == sourceKey then
        npcData.dcLootApproachSourceKey = nil
        npcData.dcLootApproachStartedAt = nil
    end
end

function LootNearby.ShouldTeleportLootApproach(npcData, sourceKey)
    if not npcData or not sourceKey or npcData.dcLootApproachSourceKey ~= sourceKey then
        return false
    end

    local currentTime = LootNearby.NowMillis()
    local startedAt = tonumber(npcData.dcLootApproachStartedAt) or 0
    return currentTime > 0 and startedAt > 0 and (currentTime - startedAt) >= Constants.LOOT_APPROACH_TIMEOUT_MS
end

function LootNearby.TeleportLootToSource(zombie, npcData, source)
    if not zombie or not npcData or not source then
        return false
    end

    local targetX = tonumber(source.approachX or source.x)
    local targetY = tonumber(source.approachY or source.y)
    local targetZ = tonumber(source.approachZ or source.z) or zombie:getZ()
    if targetX == nil or targetY == nil then
        return false
    end

    zombie:setX(targetX)
    zombie:setY(targetY)
    zombie:setZ(targetZ)
    zombie:faceLocation(tonumber(source.x) or targetX, tonumber(source.y) or targetY)
    if DTNPCMobility and DTNPCMobility.Stop then
        DTNPCMobility.Stop(zombie)
    end

    npcData.lootSearchBlockedTicks = 0
    npcData.dcLootForcedPassageAt = LootNearby.NowMillis()
    LootNearby.ClearLootApproach(npcData, source.key)
    return true
end

function LootNearby.ForceLootPassage(zombie, npcData, source)
    if not zombie or not npcData or not source then
        return false
    end

    local targetX = tonumber(source.approachX or source.x)
    local targetY = tonumber(source.approachY or source.y)
    local targetZ = tonumber(source.approachZ or source.z) or zombie:getZ()
    if targetX == nil or targetY == nil then
        return false
    end

    local faceX = tonumber(source.x) or targetX
    local faceY = tonumber(source.y) or targetY
    local dx = faceX - targetX
    local dy = faceY - targetY
    local len = math.sqrt((dx * dx) + (dy * dy))
    if len <= 0.001 then
        dx = targetX - zombie:getX()
        dy = targetY - zombie:getY()
        len = math.sqrt((dx * dx) + (dy * dy))
    end
    if len <= 0.001 then
        dx = 1
        dy = 0
        len = 1
    end

    dx = dx / len
    dy = dy / len

    zombie:setX(targetX + (dx * Constants.LOOT_FORCE_PHASE_DISTANCE))
    zombie:setY(targetY + (dy * Constants.LOOT_FORCE_PHASE_DISTANCE))
    zombie:setZ(targetZ)
    zombie:faceLocation(faceX, faceY)
    if DTNPCMobility and DTNPCMobility.Stop then
        DTNPCMobility.Stop(zombie)
    end

    npcData.lootSearchBlockedTicks = 0
    npcData.dcLootForcedPassageAt = LootNearby.NowMillis()
    return true
end

function LootNearby.TryRecoverLootMovement(zombie, npcData, source, moved, moveState)
    if not zombie or not npcData or not source or not DTNPCBehaviorAntiStuck or not DTNPCBehaviorAntiStuck.TryRecover then
        return false
    end

    local targetX = tonumber(source.approachX or source.x) or zombie:getX()
    local targetY = tonumber(source.approachY or source.y) or zombie:getY()
    local targetZ = tonumber(source.approachZ or source.z) or zombie:getZ()
    local currentDist = LootNearby.GetDistance(zombie:getX(), zombie:getY(), targetX, targetY)

    local recovered = DTNPCBehaviorAntiStuck.TryRecover(zombie, npcData, {
        behaviorKey = "LootNearby",
        target = {
            getX = function() return targetX end,
            getY = function() return targetY end,
            getZ = function() return targetZ end,
        },
        currentDist = currentDist,
        moved = moved,
        moveState = moveState,
        blockCounterKey = "lootSearchBlockedTicks",
        blockedTicks = npcData.lootSearchBlockedTicks,
        blockedThreshold = 18,
        hardBlockedThreshold = 28,
        stallThreshold = 20,
        minDistance = 1.0,
        farDistance = 12.0,
        farStallThreshold = 30,
        cooldownTicks = 180,
        maxRecoveries = 2,
        arrivalRadius = 1.0,
        allowExactTarget = false,
        faceX = tonumber(source.x) or targetX,
        faceY = tonumber(source.y) or targetY,
    })

    if recovered then
        LootNearby.LootDebugLogChanged(npcData, nil, "loot_antistuck", "AntiStuck", "Recovered near source " .. tostring(source.label or source.key))
        npcData.dcLootForcePhaseUsed = nil
        return true
    end

    local blockedTicks = math.max(0, tonumber(npcData.lootSearchBlockedTicks) or 0)
    local currentTime = LootNearby.NowMillis()
    local lastForcedAt = tonumber(npcData.dcLootForcedPassageAt) or 0
    if blockedTicks >= Constants.LOOT_FORCE_PHASE_STALL_TICKS
        and (currentTime <= 0 or lastForcedAt <= 0 or (currentTime - lastForcedAt) >= 2500)
        and LootNearby.ForceLootPassage(zombie, npcData, source) then
        npcData.dcLootForcePhaseUsed = true
        LootNearby.LootDebugLogChanged(npcData, nil, "loot_antistuck_phase", "AntiStuck", "Forced passage near source " .. tostring(source.label or source.key))
        return true
    end

    return false
end
