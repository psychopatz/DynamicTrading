-- ==============================================================================
-- Behavior_Trading_State.lua
-- Trading defense state transitions and return-to-post handling.
-- ==============================================================================

DTNPCLogic = DTNPCLogic or {}
DTNPCLogic.Behaviors = DTNPCLogic.Behaviors or {}
DTNPCLogic.BehaviorTrading = DTNPCLogic.BehaviorTrading or {}

local Trading = DTNPCLogic.BehaviorTrading

function Trading.SyncCombatStateChange(zombie, npcData)
    if DTNPCServerCore and DTNPCServerCore.SyncToAllClients then
        local ownedZombie = DTNPCServerCore.FindZombieByUUID and DTNPCServerCore.FindZombieByUUID(npcData.uuid) or nil
        if ownedZombie == zombie then
            DTNPCServerCore.SyncToAllClients(zombie, npcData)
            if DTNPCServerCore.BroadcastPosition then
                DTNPCServerCore.BroadcastPosition(zombie, npcData)
            end
        end
    end
end

function Trading.GetPostDistance(zombie, npcData)
    local postX, postY, postZ = DTNPCProtect.GetCombatAnchor and DTNPCProtect.GetCombatAnchor(npcData, zombie) or DTNPCProtect.GetStationaryPost(npcData)
    if postX == nil or postY == nil then
        return nil
    end

    local dz = math.abs((zombie:getZ() or 0) - (postZ or 0))
    if dz > 1 then
        return 9999
    end

    local dx = postX - zombie:getX()
    local dy = postY - zombie:getY()
    return math.sqrt((dx * dx) + (dy * dy))
end

function Trading.ReturnToPostOrResume(zombie, npcData)
    local resumeState = npcData.combatResumeState or "Trading"
    local postX, postY, postZ = DTNPCProtect.GetCombatAnchor and DTNPCProtect.GetCombatAnchor(npcData, zombie) or DTNPCProtect.GetStationaryPost(npcData)

    if postX == nil or postY == nil then
        Trading.ExitDefense(zombie, npcData)
        return
    end

    local dist = Trading.GetPostDistance(zombie, npcData)
    if dist ~= nil and dist <= 0.75 then
        zombie:setX(postX)
        zombie:setY(postY)
        zombie:setZ(postZ or zombie:getZ())
        Trading.StopMoveAnim(zombie)
        npcData.combatResumeState = resumeState
        Trading.ExitDefense(zombie, npcData)
        return
    end

    Trading.EnsureManualControl(zombie)

    local pointTarget = {
        getX = function() return postX end,
        getY = function() return postY end,
        getZ = function() return postZ or zombie:getZ() end,
    }

    local dx = postX - zombie:getX()
    local dy = postY - zombie:getY()
    if not Trading.PrimeMovement(zombie, npcData, dx, dy, false, "return-to-post") then
        return
    end

    local moved, moveState = Trading.MoveTowardTarget(zombie, npcData, Trading.TRADING_DEFENSE_DEFAULT_SPEED, pointTarget, 0.3)
    if moveState == "exhausted" then
        Trading.StopMoveAnim(zombie)
        zombie:faceLocation(postX, postY)
        return
    end

    if not moved and moveState ~= "arrived" and moveState ~= "close_enough" then
        zombie:setX(postX)
        zombie:setY(postY)
        zombie:setZ(postZ or zombie:getZ())
        Trading.StopMoveAnim(zombie)
        npcData.combatResumeState = resumeState
        Trading.ExitDefense(zombie, npcData)
        return
    end

    dist = Trading.GetPostDistance(zombie, npcData)
    if dist ~= nil and dist <= 0.75 then
        zombie:setX(postX)
        zombie:setY(postY)
        zombie:setZ(postZ or zombie:getZ())
        Trading.StopMoveAnim(zombie)
        npcData.combatResumeState = resumeState
        Trading.ExitDefense(zombie, npcData)
    end
end

function Trading.ExitDefense(zombie, npcData)
    local resumeState = npcData.combatResumeState or "Trading"
    npcData.state = resumeState
    npcData.combatResumeState = nil
    npcData.attackTimer = 0
    npcData.reactionTimer = 0
    Trading.ResetMoveState(npcData)
    zombie:setTarget(nil)
    if DTNPCProtect and DTNPCProtect.ClearCombatTarget then
        DTNPCProtect.ClearCombatTarget(npcData)
    end
    if DTNPCProtect and DTNPCProtect.ResetCombatRhythm then
        DTNPCProtect.ResetCombatRhythm(npcData)
    end
    Trading.StopMoveAnim(zombie)
    Trading.SyncCombatStateChange(zombie, npcData)
end

function Trading.EnterDefense(zombie, npcData, state)
    local changed = false
    local resumeState = npcData.combatResumeState or npcData.state or "Trading"
    if npcData.combatResumeState ~= resumeState then
        npcData.combatResumeState = resumeState
        changed = true
    end
    DTNPCProtect.RememberStationaryPost(zombie, npcData, resumeState)
    if npcData.state ~= state then
        Trading.ResetMoveState(npcData)
        npcData.state = state
        changed = true
    end
    if changed then
        Trading.SyncCombatStateChange(zombie, npcData)
    end
end
