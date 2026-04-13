-- ==============================================================================
-- Behavior_Trading_Shared.lua
-- Shared constants and combat helper functions for trading behaviors.
-- ==============================================================================

DTNPCLogic = DTNPCLogic or {}
DTNPCLogic.Behaviors = DTNPCLogic.Behaviors or {}
DTNPCLogic.BehaviorTrading = DTNPCLogic.BehaviorTrading or {}

local Trading = DTNPCLogic.BehaviorTrading

Trading.RANGED_KITE_MIN = Trading.RANGED_KITE_MIN or 3.25
Trading.RANGED_KITE_MAX = Trading.RANGED_KITE_MAX or 8.5
Trading.RANGED_MAX_RANGE = Trading.RANGED_MAX_RANGE or 13.5
Trading.RANGED_ADVANCE_SPEED = Trading.RANGED_ADVANCE_SPEED or 0.05
Trading.RANGED_BACKPEDAL_SPEED = Trading.RANGED_BACKPEDAL_SPEED or 0.03
Trading.TRADING_DEFENSE_MELEE_REACH = Trading.TRADING_DEFENSE_MELEE_REACH or 1.25
Trading.TRADING_DEFENSE_DEFAULT_SPEED = Trading.TRADING_DEFENSE_DEFAULT_SPEED or 0.05
Trading.MELEE_APPROACH_START_BUFFER = Trading.MELEE_APPROACH_START_BUFFER or 0.18
Trading.MELEE_APPROACH_STOP_BUFFER = Trading.MELEE_APPROACH_STOP_BUFFER or 0.16

function Trading.FaceTarget(zombie, target)
    if zombie and target then
        zombie:faceLocation(target:getX(), target:getY())
    end
end

function Trading.GetTargetDistance(zombie, target)
    if not zombie or not target then
        return 9999
    end

    local dx = target:getX() - zombie:getX()
    local dy = target:getY() - zombie:getY()
    return math.sqrt((dx * dx) + (dy * dy))
end

function Trading.GetCombatAnchorTarget(zombie, npcData)
    if DTNPCProtect and DTNPCProtect.GetCombatAnchorTarget then
        return DTNPCProtect.GetCombatAnchorTarget(npcData, zombie)
    end
    return nil
end

function Trading.GetCombatLeashRadius(npcData)
    if DTNPCProtect and DTNPCProtect.GetStationaryCombatLeashRadius then
        return DTNPCProtect.GetStationaryCombatLeashRadius(npcData)
    end
    return 10
end

function Trading.GetDistanceToCombatAnchor(zombie, npcData, x, y, z)
    if DTNPCProtect and DTNPCProtect.GetDistanceToCombatAnchor then
        return DTNPCProtect.GetDistanceToCombatAnchor(
            x ~= nil and x or zombie:getX(),
            y ~= nil and y or zombie:getY(),
            z ~= nil and z or zombie:getZ(),
            npcData,
            zombie
        )
    end
    return nil
end

function Trading.SelectStationaryThreat(zombie, npcData)
    if not DTNPCProtect or not DTNPCProtect.SelectNearestThreat then
        return nil, 9999
    end

    local anchorTarget = Trading.GetCombatAnchorTarget(zombie, npcData)
    local anchorRadius = Trading.GetCombatLeashRadius(npcData)
    return DTNPCProtect.SelectNearestThreat(zombie, npcData, nil, anchorTarget, anchorRadius)
end

function Trading.IsOutsideCombatLeash(zombie, npcData, x, y, z, padding)
    local dist = Trading.GetDistanceToCombatAnchor(zombie, npcData, x, y, z)
    if dist == nil then
        return false, nil, nil
    end

    local leash = Trading.GetCombatLeashRadius(npcData) + math.max(0, tonumber(padding) or 0)
    return dist > leash, dist, leash
end

function Trading.MarkCombatPursuit(npcData, target, dist, attacked)
    if DTNPCProtect and DTNPCProtect.MarkCombatPursuit then
        DTNPCProtect.MarkCombatPursuit(npcData, target, dist, attacked)
    end
end

function Trading.ShouldAbortCombatPursuit(npcData)
    if DTNPCProtect and DTNPCProtect.ShouldAbortCombatPursuit then
        return DTNPCProtect.ShouldAbortCombatPursuit(npcData)
    end
    return false
end
