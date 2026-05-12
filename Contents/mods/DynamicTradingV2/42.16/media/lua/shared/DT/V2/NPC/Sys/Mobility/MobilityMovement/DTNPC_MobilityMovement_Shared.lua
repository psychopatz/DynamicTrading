-- ==============================================================================
-- DTNPC_MobilityMovement_Shared.lua
-- Shared helpers for directional and target-based mobility movement.
-- ==============================================================================

DTNPCMobility = DTNPCMobility or {}

local Mobility = DTNPCMobility
local Internal = Mobility.Internal or {}

Mobility.Internal = Internal

function Internal.applyMovementState(zombie, anim)
    Mobility.SetLocomotionState(zombie, {
        moving = true,
        profileKey = anim and anim.profileKey or nil,
        isRunning = anim and anim.isRunning == true,
        animSpeed = anim and anim.animSpeed or nil,
        walkType = anim and anim.walkType or nil,
        dtWalkType = anim and anim.dtWalkType or nil,
        engineWalkType = anim and anim.engineWalkType or nil,
        idleState = anim and anim.idleState or nil,
        crawl = anim and anim.crawl == true or false,
    })
end

function Internal.buildAnimOverride(anim, profile)
    if type(anim) ~= "table" and type(profile) ~= "table" then
        return nil
    end

    local merged = {}
    if type(anim) == "table" then
        for key, value in pairs(anim) do
            merged[key] = value
        end
    end
    if type(profile) == "table" then
        merged.profileKey = profile.profileKey or merged.profileKey
        merged.isRunning = profile.isRunning == true
        merged.animSpeed = tonumber(profile.animSpeed) or merged.animSpeed
        merged.dtWalkType = profile.dtWalkType or merged.dtWalkType
        merged.engineWalkType = profile.engineWalkType or merged.engineWalkType
        merged.walkType = profile.walkType ~= nil and profile.walkType or merged.walkType
        merged.crawl = profile.crawl == true or merged.crawl == true
    end

    return merged
end

function Internal.resetMovementProgressSafe(npcData)
    if Mobility.ResetMovementProgress then
        Mobility.ResetMovementProgress(npcData)
    end
end

function Internal.recordMovementProgressSafe(npcData, currentX, currentY, goalX, goalY, options)
    if Mobility.RecordMovementProgress then
        return Mobility.RecordMovementProgress(npcData, currentX, currentY, goalX, goalY, options)
    end
    return nil
end

function Internal.shouldRecoverFromNoProgressSafe(npcData, options)
    if Mobility.ShouldTriggerProgressRecovery then
        return Mobility.ShouldTriggerProgressRecovery(npcData, options)
    end
    return false, nil
end
