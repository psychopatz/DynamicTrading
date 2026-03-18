-- ==============================================================================
-- Behavior_Stationary.lua
-- Shared stationary behavior utilities for Idle/Guard/Trading style states.
-- ==============================================================================

DTNPCLogic = DTNPCLogic or {}
DTNPCLogic.Behaviors = DTNPCLogic.Behaviors or {}
DTNPCLogic.Stationary = DTNPCLogic.Stationary or {}

local Stationary = DTNPCLogic.Stationary

Stationary.DEFAULT_REACTION_RADIUS = Stationary.DEFAULT_REACTION_RADIUS or 10
Stationary.REACT_IDLE_STATE = "0"
Stationary.INTERACTION_IDLE_STATE = "3"
Stationary.TRADE_INTERACTION_IDLE_STATE = "10"
Stationary.TARGET_STICKY_BONUS = 1.5

local function getPlayerRuntimeID(player)
    if not player then return nil end

    local onlineID = player.getOnlineID and player:getOnlineID()
    if onlineID and onlineID ~= 0 then
        return "online:" .. tostring(onlineID)
    end

    local username = player.getUsername and player:getUsername()
    if username and username ~= "" then
        return "user:" .. tostring(username)
    end

    return "player:" .. tostring(player)
end

function Stationary.GetClientForcedIdleState(zombie)
    if not zombie then return nil end

    local modData = zombie:getModData()
    if not modData then return nil end

    return modData.DTNPCClientForcedIdleState
end

function Stationary.GetDesiredIdleState(zombie, npcData)
    local forcedState = Stationary.GetClientForcedIdleState(zombie)
    if forcedState ~= nil and forcedState ~= "" then
        return tostring(forcedState)
    end

    return nil
end

function Stationary.AcquireNearbyPlayerTarget(zombie, npcData)
    if not zombie then return nil, 9999 end

    local players = DTNPCLogic.GetActivePlayers and DTNPCLogic.GetActivePlayers() or nil
    if not players or #players == 0 then
        if npcData then
            npcData._dtPresenceActive = false
            npcData._dtPresenceTargetID = nil
            npcData._dtPresenceTargetName = nil
        end
        return nil, 9999
    end

    local zx = zombie:getX()
    local zy = zombie:getY()
    local zz = zombie:getZ()
    local radius = (npcData and tonumber(npcData.reactionRadius)) or Stationary.DEFAULT_REACTION_RADIUS
    local acquireRadiusSq = radius * radius
    local keepRadius = radius + Stationary.TARGET_STICKY_BONUS
    local keepRadiusSq = keepRadius * keepRadius

    local currentTarget = nil
    local currentTargetDistSq = nil
    local nearestTarget = nil
    local nearestTargetDistSq = nil
    local currentTargetID = npcData and npcData._dtPresenceTargetID or nil

    for i = 1, #players do
        local player = players[i]
        if player and not player:isDead() and math.abs((player:getZ() or 0) - zz) <= 1 then
            local dx = player:getX() - zx
            local dy = player:getY() - zy
            local distSq = (dx * dx) + (dy * dy)

            if distSq <= acquireRadiusSq then
                if nearestTarget == nil or distSq < nearestTargetDistSq then
                    nearestTarget = player
                    nearestTargetDistSq = distSq
                end
            end

            if currentTargetID and getPlayerRuntimeID(player) == currentTargetID and distSq <= keepRadiusSq then
                currentTarget = player
                currentTargetDistSq = distSq
            end
        end
    end

    local chosenTarget = currentTarget or nearestTarget
    local chosenDistSq = currentTargetDistSq or nearestTargetDistSq

    if npcData then
        if chosenTarget then
            npcData._dtPresenceActive = true
            npcData._dtPresenceTargetID = getPlayerRuntimeID(chosenTarget)
            npcData._dtPresenceTargetName = chosenTarget:getUsername()
        else
            npcData._dtPresenceActive = false
            npcData._dtPresenceTargetID = nil
            npcData._dtPresenceTargetName = nil
        end
    end

    if chosenTarget and chosenDistSq then
        return chosenTarget, math.sqrt(chosenDistSq)
    end

    return nil, 9999
end

function Stationary.Run(zombie, npcData)
    if not zombie then return end

    if not zombie:isUseless() then
        zombie:setUseless(true)
        zombie:setPath2(nil)
        zombie:setRunning(false)
    end

    zombie:setVariable("bMoving", false)
    zombie:setVariable("Speed", 0.0)
    zombie:setPath2(nil)
    zombie:setTarget(nil)

    local target = Stationary.AcquireNearbyPlayerTarget(zombie, npcData)
    if target then
        zombie:faceLocation(target:getX(), target:getY())
    end

    local desiredIdleState = Stationary.GetDesiredIdleState(zombie, npcData)
    if desiredIdleState then
        zombie:setVariable("DTIdleState", desiredIdleState)
    end

    if zombie:isMoving() then
        zombie:setX(zombie:getX())
        zombie:setY(zombie:getY())
    end
end
