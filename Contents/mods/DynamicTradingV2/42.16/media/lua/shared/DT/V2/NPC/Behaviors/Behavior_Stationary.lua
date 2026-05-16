-- ==============================================================================
-- Behavior_Stationary.lua
-- Shared stationary behavior utilities for Idle/Guard/Trading style states.
-- ==============================================================================

DTNPCLogic = DTNPCLogic or {}
DTNPCLogic.Behaviors = DTNPCLogic.Behaviors or {}
DTNPCLogic.Stationary = DTNPCLogic.Stationary or {}
require "DT/V2/NPC/Sys/DTNPC_Protect"

local Stationary = DTNPCLogic.Stationary

Stationary.DEFAULT_REACTION_RADIUS = Stationary.DEFAULT_REACTION_RADIUS or 10
Stationary.REACT_IDLE_STATE = "0"
Stationary.INTERACTION_IDLE_STATE = "3"
Stationary.TRADE_INTERACTION_IDLE_STATE = "10"
Stationary.TARGET_STICKY_BONUS = 1.5

local function getPlayerRuntimeID(player)
    if DTNPCProtect and DTNPCProtect.GetPlayerRuntimeID then
        return DTNPCProtect.GetPlayerRuntimeID(player)
    end
    if not player then return nil end
    return "player:" .. tostring(player)
end

local function syncStationaryStateChange(zombie, npcData)
    if not zombie or not npcData or not DTNPCServerCore or not DTNPCServerCore.SyncToAllClients then
        return
    end

    local ownedZombie = DTNPCServerCore.FindZombieByUUID and DTNPCServerCore.FindZombieByUUID(npcData.uuid) or nil
    if ownedZombie ~= zombie then
        return
    end

    DTNPCServerCore.SyncToAllClients(zombie, npcData)
    if DTNPCServerCore.BroadcastPosition then
        DTNPCServerCore.BroadcastPosition(zombie, npcData)
    end
end

local function canUseAmbientAutoDefense(npcData)
    if not npcData then
        return false
    end

    local state = npcData.state or "Idle"
    local status = npcData.status or ""
    return state == "Trading"
        or state == "PlayerZone"
        or status == "Trading"
        or status == "Resting"
end

local function getStationaryCombatAnchorTarget(zombie, npcData)
    if DTNPCProtect and DTNPCProtect.GetCombatAnchorTarget then
        return DTNPCProtect.GetCombatAnchorTarget(npcData, zombie)
    end
    return nil
end

local function getStationaryCombatAnchorRadius(npcData)
    if DTNPCProtect and DTNPCProtect.GetStationaryCombatLeashRadius then
        return DTNPCProtect.GetStationaryCombatLeashRadius(npcData)
    end
    return nil
end

local function maybeStartAutoDefense(zombie, npcData)
    if not zombie or not npcData or not canUseAmbientAutoDefense(npcData) then
        return false
    end
    if not DTNPCProtect or not DTNPCProtect.SelectNearestThreat or not DTNPCProtect.GetTradingDefenseState then
        return false
    end

    DTNPCProtect.RememberStationaryPost(zombie, npcData, npcData.state)

    local target, targetDist = DTNPCProtect.SelectNearestThreat(
        zombie,
        npcData,
        nil,
        getStationaryCombatAnchorTarget(zombie, npcData),
        getStationaryCombatAnchorRadius(npcData)
    )
    if not target then
        npcData.combatResumeState = nil
        return false
    end

    local nextState = DTNPCProtect.GetTradingDefenseState(npcData, targetDist or 9999)
    if not nextState then
        return false
    end

    if npcData.combatResumeState ~= npcData.state then
        npcData.combatResumeState = npcData.state
    end
    if npcData.state ~= nextState then
        npcData.state = nextState
        syncStationaryStateChange(zombie, npcData)
    end

    local behavior = DTNPCLogic.Behaviors[nextState]
    if behavior then
        behavior(zombie, npcData, target, targetDist)
        return true
    end

    return false
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

    if npcData and npcData.state == "Bandage" then
        return tostring(DTNPCHealth and DTNPCHealth.BANDAGE_IDLE_STATE or "11")
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

    if maybeStartAutoDefense(zombie, npcData) then
        return
    end

    if DTNPCProtect and canUseAmbientAutoDefense(npcData) then
        DTNPCProtect.RememberStationaryPost(zombie, npcData, npcData.state)
    end

    if not zombie:isUseless() then
        zombie:setUseless(true)
        zombie:setPath2(nil)
        zombie:setRunning(false)
    end

    zombie:setVariable("bMoving", false)
    zombie:setVariable("isMoving", false)
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
