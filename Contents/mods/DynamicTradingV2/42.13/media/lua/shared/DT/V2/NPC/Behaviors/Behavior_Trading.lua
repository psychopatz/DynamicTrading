-- ==============================================================================
-- Behavior_Trading.lua
-- Handles the live trading state while the NPC is available to interact with.
-- ==============================================================================

DTNPCLogic = DTNPCLogic or {}
DTNPCLogic.Behaviors = DTNPCLogic.Behaviors or {}
require "DT/V2/NPC/Sys/DTNPC_Protect"

local RANGED_KITE_MIN = 3.25
local RANGED_KITE_MAX = 8.5
local RANGED_MAX_RANGE = 13.5
local RANGED_ADVANCE_SPEED = 0.05
local RANGED_BACKPEDAL_SPEED = 0.03
local TRADING_DEFENSE_MELEE_REACH = 1.25
local TRADING_DEFENSE_DEFAULT_SPEED = 0.05

local function isTileSafe(x, y, z)
    local cell = getCell()
    local sq = cell and cell:getGridSquare(x, y, z) or nil
    if not sq then return true end
    if not sq:isFree(false) then return false end
    if sq:isSolid() or sq:isSolidTrans() then return false end
    return true
end

local function faceTarget(zombie, target)
    if zombie and target then
        zombie:faceLocation(target:getX(), target:getY())
    end
end

local function getTargetDistance(zombie, target)
    if not zombie or not target then
        return 9999
    end

    local dx = target:getX() - zombie:getX()
    local dy = target:getY() - zombie:getY()
    return math.sqrt((dx * dx) + (dy * dy))
end

local function stopMoveAnim(zombie)
    zombie:setVariable("bMoving", false)
    zombie:setVariable("isMoving", false)
    zombie:setVariable("Speed", 0.0)
    zombie:setRunning(false)
end

local function forceWalkAnim(zombie, isRunning)
    zombie:setVariable("bMoving", true)
    zombie:setVariable("isMoving", true)
    zombie:setVariable("Speed", isRunning and 1.15 or 1.0)
    zombie:setRunning(isRunning == true)
end

local function ensureManualControl(zombie)
    if not zombie:isUseless() then
        zombie:setUseless(true)
    end
    zombie:setPath2(nil)
    zombie:setTarget(nil)
end

local function moveTowardTarget(zombie, speed, target, stopDistance)
    local zx, zy, zz = zombie:getX(), zombie:getY(), zombie:getZ()
    local tx, ty = target:getX(), target:getY()
    local dx = tx - zx
    local dy = ty - zy
    local len = math.sqrt((dx * dx) + (dy * dy))
    local desiredDistance = math.max(0, tonumber(stopDistance) or 0)
    if len <= 0.001 then
        stopMoveAnim(zombie)
        return true
    end
    if len <= desiredDistance then
        stopMoveAnim(zombie)
        return true
    end

    dx = dx / len
    dy = dy / len
    local step = math.min(speed, math.max(0, len - desiredDistance))
    if step <= 0.001 then
        stopMoveAnim(zombie)
        return true
    end

    local nextX = zx + (dx * step)
    local nextY = zy + (dy * step)

    if isTileSafe(nextX, nextY, zz) then
        forceWalkAnim(zombie, speed > 0.06)
        zombie:setX(nextX)
        zombie:setY(nextY)
        zombie:faceLocation(nextX, nextY)
        return true
    end

    if len <= (desiredDistance + 0.35) then
        stopMoveAnim(zombie)
        return true
    end

    stopMoveAnim(zombie)
    return false
end

local function syncCombatStateChange(zombie, npcData)
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

local exitTradingDefense

local function getPostDistance(zombie, npcData)
    local postX, postY, postZ = DTNPCProtect.GetStationaryPost(npcData)
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

local function returnToPostOrResume(zombie, npcData)
    local resumeState = npcData.combatResumeState or "Trading"
    local postX, postY, postZ = DTNPCProtect.GetStationaryPost(npcData)

    if postX == nil or postY == nil then
        exitTradingDefense(zombie, npcData)
        return
    end

    local dist = getPostDistance(zombie, npcData)
    if dist ~= nil and dist <= 0.75 then
        zombie:setX(postX)
        zombie:setY(postY)
        zombie:setZ(postZ or zombie:getZ())
        stopMoveAnim(zombie)
        npcData.combatResumeState = resumeState
        exitTradingDefense(zombie, npcData)
        return
    end

    ensureManualControl(zombie)

    local pointTarget = {
        getX = function() return postX end,
        getY = function() return postY end,
        getZ = function() return postZ or zombie:getZ() end,
    }

    local moved = moveTowardTarget(zombie, TRADING_DEFENSE_DEFAULT_SPEED, pointTarget, 0.3)
    if not moved then
        zombie:setX(postX)
        zombie:setY(postY)
        zombie:setZ(postZ or zombie:getZ())
        stopMoveAnim(zombie)
        npcData.combatResumeState = resumeState
        exitTradingDefense(zombie, npcData)
        return
    end

    zombie:faceLocation(postX, postY)

    dist = getPostDistance(zombie, npcData)
    if dist ~= nil and dist <= 0.75 then
        zombie:setX(postX)
        zombie:setY(postY)
        zombie:setZ(postZ or zombie:getZ())
        stopMoveAnim(zombie)
        npcData.combatResumeState = resumeState
        exitTradingDefense(zombie, npcData)
    end
end

exitTradingDefense = function(zombie, npcData)
    local resumeState = npcData.combatResumeState or "Trading"
    npcData.state = resumeState
    npcData.combatResumeState = nil
    npcData.attackTimer = 0
    npcData.reactionTimer = 0
    zombie:setTarget(nil)
    if DTNPCProtect and DTNPCProtect.ClearCombatTarget then
        DTNPCProtect.ClearCombatTarget(npcData)
    end
    stopMoveAnim(zombie)
    syncCombatStateChange(zombie, npcData)
end

local function enterTradingDefense(zombie, npcData, state)
    local changed = false
    local resumeState = npcData.combatResumeState or npcData.state or "Trading"
    if npcData.combatResumeState ~= resumeState then
        npcData.combatResumeState = resumeState
        changed = true
    end
    DTNPCProtect.RememberStationaryPost(zombie, npcData, resumeState)
    if npcData.state ~= state then
        npcData.state = state
        changed = true
    end
    if changed then
        syncCombatStateChange(zombie, npcData)
    end
end

DTNPCLogic.Behaviors["Trading"] = function(zombie, npcData)
    local target = nil
    local targetDist = 9999
    DTNPCProtect.RememberStationaryPost(zombie, npcData, "Trading")
    if DTNPCProtect and DTNPCProtect.SelectNearestThreat then
        target, targetDist = DTNPCProtect.SelectNearestThreat(zombie, npcData)
    end
    if target then
        local nextState = DTNPCProtect and DTNPCProtect.GetTradingDefenseState and DTNPCProtect.GetTradingDefenseState(npcData, targetDist or 9999) or nil
        if nextState then
            enterTradingDefense(zombie, npcData, nextState)
            local behavior = DTNPCLogic.Behaviors[nextState]
            if behavior then
                behavior(zombie, npcData, target, targetDist)
            end
            return
        end
        if DTNPCProtect and DTNPCProtect.ClearCombatTarget then
            DTNPCProtect.ClearCombatTarget(npcData)
        end
    else
        npcData.combatResumeState = nil
    end

    DTNPCLogic.Stationary.Run(zombie, npcData)
end

DTNPCLogic.Behaviors["TradingDefenseRanged"] = function(zombie, npcData)
    local target, targetDist = DTNPCProtect.SelectNearestThreat(zombie, npcData)
    if not DTNPCProtect.HasUsableRangedLoadout(npcData) then
        returnToPostOrResume(zombie, npcData)
        return
    end
    if not target then
        returnToPostOrResume(zombie, npcData)
        return
    end

    ensureManualControl(zombie)

    local zx, zy, zz = zombie:getX(), zombie:getY(), zombie:getZ()
    local tx, ty = target:getX(), target:getY()
    local dx = tx - zx
    local dy = ty - zy
    local len = math.sqrt((dx * dx) + (dy * dy))
    if len > 0.001 then
        dx = dx / len
        dy = dy / len
        faceTarget(zombie, target)
    end

    local moveDir = 0
    local moveSpeed = 0
    if len < RANGED_KITE_MIN then
        npcData.reactionTimer = (npcData.reactionTimer or 0) + 1
        if npcData.reactionTimer >= 18 then
            moveDir = -1
            moveSpeed = RANGED_BACKPEDAL_SPEED
        end
    elseif len > RANGED_KITE_MAX then
        npcData.reactionTimer = 0
        moveDir = 1
        moveSpeed = RANGED_ADVANCE_SPEED
    else
        npcData.reactionTimer = 0
    end

    local moved = false
    if moveDir ~= 0 then
        zombie:setVariable("DTIdleState", "0")
        local nextX = zx + (dx * moveSpeed * moveDir)
        local nextY = zy + (dy * moveSpeed * moveDir)
        if isTileSafe(nextX, nextY, zz) then
            forceWalkAnim(zombie, false)
            zombie:setX(nextX)
            zombie:setY(nextY)
            moved = true
        else
            stopMoveAnim(zombie)
        end
    else
        stopMoveAnim(zombie)
        if DTNPC and DTNPC.SetRangedCombatIdleState then
            DTNPC.SetRangedCombatIdleState(zombie, npcData)
        end
    end

    faceTarget(zombie, target)

    if targetDist > RANGED_MAX_RANGE then
        return
    end

    local stats = DTNPCProtect.GetRangedCombatStats(npcData)
    npcData.attackTimer = (npcData.attackTimer or 0) + 1
    if npcData.attackTimer < stats.fireRate then
        return
    end

    npcData.attackTimer = 0
    if DTNPC and DTNPC.TriggerRangedCombatAnim then
        DTNPC.TriggerRangedCombatAnim(zombie, npcData)
    end
    DTNPCProtect.ConsumeAmmo(npcData, 1)
    DTNPCProtect.ConsumeWeaponCondition(npcData, "ranged", 1)
    zombie:getEmitter():playSound("DT_GunRandom")

    local hitChance = moved and stats.hitMove or stats.hitStill
    if ZombRand(100) < hitChance then
        DTNPCProtect.ApplyCombatHit(zombie, npcData, target, {
            attackType = "ranged",
            damage = stats.damage,
        })
    end
end

DTNPCLogic.Behaviors["TradingDefenseMelee"] = function(zombie, npcData)
    local target, targetDist = DTNPCProtect.SelectNearestThreat(zombie, npcData)
    if not DTNPCProtect.HasUsableMeleeLoadout(npcData) then
        returnToPostOrResume(zombie, npcData)
        return
    end
    if not target then
        returnToPostOrResume(zombie, npcData)
        return
    end

    ensureManualControl(zombie)
    faceTarget(zombie, target)

    local stats = DTNPCProtect.GetMeleeCombatStats(npcData)
    local engageReach = math.max(stats.reach or TRADING_DEFENSE_MELEE_REACH, 1.45)
    local currentDist = getTargetDistance(zombie, target)
    if currentDist > engageReach then
        local arrived = moveTowardTarget(
            zombie,
            stats.chaseSpeed or TRADING_DEFENSE_DEFAULT_SPEED,
            target,
            math.max(0.9, engageReach - 0.1)
        )
        if not arrived then
            return
        end

        currentDist = getTargetDistance(zombie, target)
        if currentDist > engageReach then
            return
        end
    end

    stopMoveAnim(zombie)
    if DTNPC and DTNPC.SetMeleeCombatIdleState then
        DTNPC.SetMeleeCombatIdleState(zombie, npcData)
    end

    npcData.attackTimer = (npcData.attackTimer or 0) + 1
    if npcData.attackTimer < stats.attackRate then
        return
    end

    npcData.attackTimer = 0
    if DTNPC and DTNPC.TriggerMeleeCombatAnim then
        DTNPC.TriggerMeleeCombatAnim(zombie, npcData)
    end
    DTNPCProtect.ConsumeWeaponCondition(npcData, "melee", 1)
    if ZombRand(100) < stats.hitChance then
        DTNPCProtect.ApplyCombatHit(zombie, npcData, target, {
            attackType = "melee",
            damage = stats.damage,
        })
    end
end
