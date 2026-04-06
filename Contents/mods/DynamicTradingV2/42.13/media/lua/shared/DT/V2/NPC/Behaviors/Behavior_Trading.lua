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

local function getCombatAnchorTarget(zombie, npcData)
    if DTNPCProtect and DTNPCProtect.GetCombatAnchorTarget then
        return DTNPCProtect.GetCombatAnchorTarget(npcData, zombie)
    end
    return nil
end

local function getCombatLeashRadius(npcData)
    if DTNPCProtect and DTNPCProtect.GetStationaryCombatLeashRadius then
        return DTNPCProtect.GetStationaryCombatLeashRadius(npcData)
    end
    return 10
end

local function getDistanceToCombatAnchor(zombie, npcData, x, y, z)
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

local function selectStationaryThreat(zombie, npcData)
    local anchorTarget = getCombatAnchorTarget(zombie, npcData)
    local anchorRadius = getCombatLeashRadius(npcData)
    return DTNPCProtect.SelectNearestThreat(zombie, npcData, nil, anchorTarget, anchorRadius)
end

local function isOutsideCombatLeash(zombie, npcData, x, y, z, padding)
    local dist = getDistanceToCombatAnchor(zombie, npcData, x, y, z)
    if dist == nil then
        return false, nil, nil
    end

    local leash = getCombatLeashRadius(npcData) + math.max(0, tonumber(padding) or 0)
    return dist > leash, dist, leash
end

local function markCombatPursuit(npcData, target, dist, attacked)
    if DTNPCProtect and DTNPCProtect.MarkCombatPursuit then
        DTNPCProtect.MarkCombatPursuit(npcData, target, dist, attacked)
    end
end

local function shouldAbortCombatPursuit(npcData)
    if DTNPCProtect and DTNPCProtect.ShouldAbortCombatPursuit then
        return DTNPCProtect.ShouldAbortCombatPursuit(npcData)
    end
    return false
end

local function stopMoveAnim(zombie)
    zombie:setVariable("bMoving", false)
    zombie:setVariable("isMoving", false)
    zombie:setVariable("Speed", 0.0)
    zombie:setRunning(false)
end

local function forceWalkAnim(zombie, isRunning)
    zombie:setVariable("DTIdleState", "0")
    zombie:setVariable("bMoving", true)
    zombie:setVariable("isMoving", true)
    zombie:setVariable("WalkType", "1")
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

local function moveTowardTarget(zombie, speed, target, stopDistance, anchorX, anchorY, anchorZ, leashRadius)
    local zx, zy, zz = zombie:getX(), zombie:getY(), zombie:getZ()
    local tx, ty = target:getX(), target:getY()
    local dx = tx - zx
    local dy = ty - zy
    local len = math.sqrt((dx * dx) + (dy * dy))
    local desiredDistance = math.max(0, tonumber(stopDistance) or 0)
    if len <= 0.001 then
        stopMoveAnim(zombie)
        return true, "arrived"
    end
    if len <= desiredDistance then
        stopMoveAnim(zombie)
        return true, "arrived"
    end

    dx = dx / len
    dy = dy / len
    local step = math.min(speed, math.max(0, len - desiredDistance))
    if step <= 0.001 then
        stopMoveAnim(zombie)
        return true, "arrived"
    end

    local nextX = zx + (dx * step)
    local nextY = zy + (dy * step)

    if anchorX ~= nil and anchorY ~= nil and leashRadius ~= nil then
        local leashDx = nextX - anchorX
        local leashDy = nextY - anchorY
        local leashDist = math.sqrt((leashDx * leashDx) + (leashDy * leashDy))
        local leashFloor = tonumber(anchorZ) or zz
        if math.abs(zz - leashFloor) > 1.1 or leashDist > leashRadius then
            stopMoveAnim(zombie)
            return false, "leash"
        end
    end

    if isTileSafe(nextX, nextY, zz) then
        forceWalkAnim(zombie, speed > 0.06)
        zombie:setX(nextX)
        zombie:setY(nextY)
        zombie:faceLocation(nextX, nextY)
        return true, "moving"
    end

    if len <= (desiredDistance + 0.35) then
        stopMoveAnim(zombie)
        return true, "close_enough"
    end

    stopMoveAnim(zombie)
    return false, "blocked"
end

local function moveAwayFromTarget(zombie, speed, target, desiredDistance, anchorX, anchorY, anchorZ, leashRadius)
    local zx, zy, zz = zombie:getX(), zombie:getY(), zombie:getZ()
    local tx, ty = target:getX(), target:getY()
    local dx = zx - tx
    local dy = zy - ty
    local len = math.sqrt((dx * dx) + (dy * dy))
    local safeDistance = math.max(0, tonumber(desiredDistance) or 0)

    if len >= safeDistance then
        stopMoveAnim(zombie)
        return true, "spaced"
    end

    if len <= 0.001 then
        dx = ZombRandFloat(-1.0, 1.0)
        dy = ZombRandFloat(-1.0, 1.0)
        len = math.sqrt((dx * dx) + (dy * dy))
        if len <= 0.001 then
            stopMoveAnim(zombie)
            return false, "blocked"
        end
    end

    dx = dx / len
    dy = dy / len

    local step = math.min(speed, math.max(0, safeDistance - len))
    if step <= 0.001 then
        stopMoveAnim(zombie)
        return true, "spaced"
    end

    local nextX = zx + (dx * step)
    local nextY = zy + (dy * step)

    if anchorX ~= nil and anchorY ~= nil and leashRadius ~= nil then
        local leashDx = nextX - anchorX
        local leashDy = nextY - anchorY
        local leashDist = math.sqrt((leashDx * leashDx) + (leashDy * leashDy))
        local leashFloor = tonumber(anchorZ) or zz
        if math.abs(zz - leashFloor) > 1.1 or leashDist > leashRadius then
            stopMoveAnim(zombie)
            return false, "leash"
        end
    end

    if isTileSafe(nextX, nextY, zz) then
        forceWalkAnim(zombie, false)
        zombie:setX(nextX)
        zombie:setY(nextY)
        zombie:faceLocation(tx, ty)
        return true, "moving"
    end

    stopMoveAnim(zombie)
    return false, "blocked"
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

local function returnToPostOrResume(zombie, npcData)
    local resumeState = npcData.combatResumeState or "Trading"
    local postX, postY, postZ = DTNPCProtect.GetCombatAnchor and DTNPCProtect.GetCombatAnchor(npcData, zombie) or DTNPCProtect.GetStationaryPost(npcData)

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
    if DTNPCProtect and DTNPCProtect.ResetCombatRhythm then
        DTNPCProtect.ResetCombatRhythm(npcData)
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
        target, targetDist = selectStationaryThreat(zombie, npcData)
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
    local target, targetDist = selectStationaryThreat(zombie, npcData)
    if not DTNPCProtect.HasUsableRangedLoadout(npcData) then
        returnToPostOrResume(zombie, npcData)
        return
    end
    if not target then
        returnToPostOrResume(zombie, npcData)
        return
    end

    ensureManualControl(zombie)

    local anchorTarget = getCombatAnchorTarget(zombie, npcData)
    local anchorX = anchorTarget and anchorTarget:getX() or nil
    local anchorY = anchorTarget and anchorTarget:getY() or nil
    local anchorZ = anchorTarget and anchorTarget:getZ() or zombie:getZ()
    local leashRadius = getCombatLeashRadius(npcData)
    local outsideLeash, leashDist, leashLimit = isOutsideCombatLeash(zombie, npcData)
    if outsideLeash then
        if DTNPCProtect and DTNPCProtect.ReportCombatIssue then
            DTNPCProtect.ReportCombatIssue(
                zombie,
                npcData,
                "TradingDefenseLeash",
                "Too far from post. Returning.",
                "warning",
                "dist=" .. tostring(string.format("%.2f", leashDist or 0)) .. " leash=" .. tostring(string.format("%.2f", leashLimit or leashRadius))
            )
        end
        returnToPostOrResume(zombie, npcData)
        return
    end

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

    local recovering, recovery = false, nil
    if DTNPCProtect and DTNPCProtect.GetCombatRecovery then
        recovering, recovery = DTNPCProtect.GetCombatRecovery(npcData, "ranged", target)
    end

    local desiredMin = recovering and math.max(RANGED_KITE_MIN, recovery and recovery.distance or RANGED_KITE_MIN) or RANGED_KITE_MIN
    local desiredMax = recovering and math.max(RANGED_KITE_MAX, desiredMin + 0.75) or RANGED_KITE_MAX

    local moveDir = 0
    local moveSpeed = 0
    if len < desiredMin then
        npcData.reactionTimer = (npcData.reactionTimer or 0) + 1
        if npcData.reactionTimer >= 18 then
            moveDir = -1
            moveSpeed = RANGED_BACKPEDAL_SPEED
        end
    elseif len > desiredMax then
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
        local nextOutsideLeash = false
        if anchorX ~= nil and anchorY ~= nil then
            local nextDx = nextX - anchorX
            local nextDy = nextY - anchorY
            nextOutsideLeash = math.sqrt((nextDx * nextDx) + (nextDy * nextDy)) > leashRadius
        end
        if nextOutsideLeash then
            if DTNPCProtect and DTNPCProtect.ReportCombatIssue then
                DTNPCProtect.ReportCombatIssue(
                    zombie,
                    npcData,
                    "TradingDefenseLeashAdvance",
                    "Won't chase that far. Returning.",
                    "warning",
                    "targetDist=" .. tostring(string.format("%.2f", len))
                )
            end
            returnToPostOrResume(zombie, npcData)
            return
        elseif isTileSafe(nextX, nextY, zz) then
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
        markCombatPursuit(npcData, target, targetDist, false)
        if shouldAbortCombatPursuit(npcData) then
            if DTNPCProtect and DTNPCProtect.ReportCombatIssue then
                DTNPCProtect.ReportCombatIssue(
                    zombie,
                    npcData,
                    "TradingDefenseRangeTimeout",
                    "Can't reach that threat. Returning.",
                    "warning",
                    "targetDist=" .. tostring(string.format("%.2f", targetDist))
                )
            end
            returnToPostOrResume(zombie, npcData)
        end
        return
    end

    local stats = DTNPCProtect.GetRangedCombatStats(npcData)
    if recovering then
        npcData.attackTimer = 0
        markCombatPursuit(npcData, target, targetDist, false)
        return
    end

    npcData.attackTimer = (npcData.attackTimer or 0) + 1
    local attacked = false
    if npcData.attackTimer < stats.fireRate then
        markCombatPursuit(npcData, target, targetDist, false)
        return
    end

    npcData.attackTimer = 0
    if DTNPC and DTNPC.TriggerRangedCombatAnim then
        DTNPC.TriggerRangedCombatAnim(zombie, npcData)
    end
    attacked = true
    DTNPCProtect.ConsumeAmmo(npcData, 1)
    DTNPCProtect.ConsumeWeaponCondition(npcData, "ranged", 1)
    zombie:getEmitter():playSound("DT_GunRandom")

    local hitChance = moved and stats.hitMove or stats.hitStill
    markCombatPursuit(npcData, target, targetDist, attacked)
    if ZombRand(100) < hitChance then
        DTNPCProtect.ApplyCombatHit(zombie, npcData, target, {
            attackType = "ranged",
            damage = stats.damage,
        })
    end
    if DTNPCProtect and DTNPCProtect.RecordCombatAttack then
        DTNPCProtect.RecordCombatAttack(zombie, npcData, "ranged", target)
    end
end

DTNPCLogic.Behaviors["TradingDefenseMelee"] = function(zombie, npcData)
    local target, targetDist = selectStationaryThreat(zombie, npcData)
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

    local anchorTarget = getCombatAnchorTarget(zombie, npcData)
    local anchorX = anchorTarget and anchorTarget:getX() or nil
    local anchorY = anchorTarget and anchorTarget:getY() or nil
    local anchorZ = anchorTarget and anchorTarget:getZ() or zombie:getZ()
    local leashRadius = getCombatLeashRadius(npcData)
    local outsideLeash, leashDist, leashLimit = isOutsideCombatLeash(zombie, npcData)
    if outsideLeash then
        if DTNPCProtect and DTNPCProtect.ReportCombatIssue then
            DTNPCProtect.ReportCombatIssue(
                zombie,
                npcData,
                "TradingDefenseMeleeLeash",
                "Too far from post. Returning.",
                "warning",
                "dist=" .. tostring(string.format("%.2f", leashDist or 0)) .. " leash=" .. tostring(string.format("%.2f", leashLimit or leashRadius))
            )
        end
        returnToPostOrResume(zombie, npcData)
        return
    end

    local stats = DTNPCProtect.GetMeleeCombatStats(npcData)
    local engageReach = math.max(stats.reach or TRADING_DEFENSE_MELEE_REACH, 1.45)
    local currentDist = getTargetDistance(zombie, target)
    local recovering, recovery = false, nil
    if DTNPCProtect and DTNPCProtect.GetCombatRecovery then
        recovering, recovery = DTNPCProtect.GetCombatRecovery(npcData, "melee", target)
    end

    if recovering then
        npcData.attackTimer = 0
        local retreatDistance = math.max(engageReach + 0.45, recovery and recovery.distance or (engageReach + 0.7))
        if currentDist < retreatDistance then
            local movedAway, moveState = moveAwayFromTarget(
                zombie,
                math.max(0.028, (stats.chaseSpeed or TRADING_DEFENSE_DEFAULT_SPEED) * 0.75),
                target,
                retreatDistance,
                anchorX,
                anchorY,
                anchorZ,
                leashRadius
            )
            if moveState == "leash" then
                returnToPostOrResume(zombie, npcData)
                return
            end
            if not movedAway then
                stopMoveAnim(zombie)
            end
        else
            stopMoveAnim(zombie)
            if DTNPC and DTNPC.SetMeleeCombatIdleState then
                DTNPC.SetMeleeCombatIdleState(zombie, npcData)
            end
        end
        markCombatPursuit(npcData, target, currentDist, false)
        return
    end

    if currentDist > engageReach then
        local arrived, moveState = moveTowardTarget(
            zombie,
            stats.chaseSpeed or TRADING_DEFENSE_DEFAULT_SPEED,
            target,
            math.max(0.9, engageReach - 0.1),
            anchorX,
            anchorY,
            anchorZ,
            leashRadius
        )
        currentDist = getTargetDistance(zombie, target)
        markCombatPursuit(npcData, target, currentDist, false)

        if moveState == "leash" then
            if DTNPCProtect and DTNPCProtect.ReportCombatIssue then
                DTNPCProtect.ReportCombatIssue(
                    zombie,
                    npcData,
                    "TradingDefenseMeleeLeashAdvance",
                    "Won't chase that far. Returning.",
                    "warning",
                    "targetDist=" .. tostring(string.format("%.2f", currentDist))
                )
            end
            returnToPostOrResume(zombie, npcData)
            return
        end

        if not arrived then
            if shouldAbortCombatPursuit(npcData) then
                if DTNPCProtect and DTNPCProtect.ReportCombatIssue then
                    DTNPCProtect.ReportCombatIssue(
                        zombie,
                        npcData,
                        "TradingDefenseMeleeTimeout",
                        "Can't reach that threat. Returning.",
                        "warning",
                        "targetDist=" .. tostring(string.format("%.2f", currentDist))
                    )
                end
                returnToPostOrResume(zombie, npcData)
            end
            return
        end

        if currentDist > engageReach then
            if shouldAbortCombatPursuit(npcData) then
                if DTNPCProtect and DTNPCProtect.ReportCombatIssue then
                    DTNPCProtect.ReportCombatIssue(
                        zombie,
                        npcData,
                        "TradingDefenseMeleeClosingTimeout",
                        "Can't close in on that threat. Returning.",
                        "warning",
                        "targetDist=" .. tostring(string.format("%.2f", currentDist))
                    )
                end
                returnToPostOrResume(zombie, npcData)
            end
            return
        end
    end

    stopMoveAnim(zombie)
    if DTNPC and DTNPC.SetMeleeCombatIdleState then
        DTNPC.SetMeleeCombatIdleState(zombie, npcData)
    end

    npcData.attackTimer = (npcData.attackTimer or 0) + 1
    if npcData.attackTimer < stats.attackRate then
        markCombatPursuit(npcData, target, currentDist, false)
        return
    end

    npcData.attackTimer = 0
    if DTNPC and DTNPC.TriggerMeleeCombatAnim then
        DTNPC.TriggerMeleeCombatAnim(zombie, npcData)
    end
    markCombatPursuit(npcData, target, currentDist, true)
    DTNPCProtect.ConsumeWeaponCondition(npcData, "melee", 1)
    if ZombRand(100) < stats.hitChance then
        DTNPCProtect.ApplyCombatHit(zombie, npcData, target, {
            attackType = "melee",
            damage = stats.damage,
        })
    end
    if DTNPCProtect and DTNPCProtect.RecordCombatAttack then
        DTNPCProtect.RecordCombatAttack(zombie, npcData, "melee", target)
    end
end
