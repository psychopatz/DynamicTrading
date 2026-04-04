-- ==============================================================================
-- Behavior_Protect.lua
-- Companion protect behaviors for ranged and melee escort combat.
-- ==============================================================================

DTNPCLogic = DTNPCLogic or {}
DTNPCLogic.Behaviors = DTNPCLogic.Behaviors or {}
require "DT/V2/NPC/Sys/DTNPC_Protect"

local RANGED_KITE_MIN = 3.25
local RANGED_KITE_MAX = 8.5
local RANGED_MAX_RANGE = 13.5
local RANGED_ADVANCE_SPEED = 0.05
local RANGED_BACKPEDAL_SPEED = 0.03
local MELEE_REACH = 1.25
local MELEE_DEFAULT_SPEED = 0.05
local PROTECT_LEASH = 14
local PROTECT_MASTER_ENGAGE_RADIUS = 10

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

local function clearProtectCombat(zombie, npcData)
    if npcData then
        npcData.attackTimer = 0
        npcData.reactionTimer = 0
        npcData.autoProtectActiveState = nil
        DTNPCProtect.ClearCombatTarget(npcData)
    end
    if zombie then
        zombie:setTarget(nil)
    end
end

local function pushCompanionModeNotice(zombie, npcData, dialogueStatus, dialogueState, mode)
    if not npcData then
        return false
    end
    if mode and npcData.companionAmbientMode == mode then
        return false
    end

    if DTNPCProtect and DTNPCProtect.PushCompanionAmbientCue then
        if DTNPCProtect.PushCompanionAmbientCue(zombie, npcData, dialogueStatus, dialogueState) then
            npcData.companionAmbientMode = mode or npcData.companionAmbientMode
            return true
        end
    end

    return false
end

local function announceCombatEngage(zombie, npcData)
    if not npcData then
        return
    end

    local targetID = npcData.combatTargetID
    if npcData.companionCombatActive == true and npcData.companionLastCombatTargetID == targetID then
        return
    end

    npcData.companionCombatActive = true
    npcData.companionLastCombatTargetID = targetID
    npcData.companionLastRangedTargetID = nil
    pushCompanionModeNotice(zombie, npcData, "Companion", "Attack", "combat")
    if DTNPCProtect and DTNPCProtect.LogProtectDebug then
        DTNPCProtect.LogProtectDebug(npcData, "engage", "target=" .. tostring(targetID))
    end
end

local function announceRangedAttack(zombie, npcData)
    if not npcData then
        return
    end

    local targetID = npcData.combatTargetID
    if not targetID or npcData.companionLastRangedTargetID == targetID then
        return
    end

    npcData.companionLastRangedTargetID = targetID
    pushCompanionModeNotice(zombie, npcData, "Companion", "AttackRange", "ranged")
end

local function announceReturnToMaster(zombie, npcData)
    if not npcData or npcData.companionCombatActive ~= true then
        return
    end

    npcData.companionCombatActive = false
    npcData.companionLastCombatTargetID = nil
    npcData.companionLastRangedTargetID = nil
    pushCompanionModeNotice(zombie, npcData, "Companion", "Return", "return")
end

local function followEscort(zombie, npcData, master, dist)
    announceReturnToMaster(zombie, npcData)
    clearProtectCombat(zombie, npcData)
    if DTNPCLogic.Behaviors["Follow"] then
        DTNPCLogic.Behaviors["Follow"](zombie, npcData, master, dist)
    end
end

local function getProtectEngageRadius(npcData)
    return tonumber(npcData and npcData.protectEngageRadius) or PROTECT_MASTER_ENGAGE_RADIUS
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

local function syncProtectStateChange(zombie, npcData)
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

local function protectTargetOrEscort(zombie, npcData, master, distToMaster, requestedState)
    local effectiveState = DTNPCProtect.ResolveProtectState(npcData, requestedState)

    if effectiveState == "ProtectRanged" and requestedState ~= "ProtectRanged" then
        npcData.state = "ProtectRanged"
        syncProtectStateChange(zombie, npcData)
        DTNPCLogic.Behaviors["ProtectRanged"](zombie, npcData, master, distToMaster)
        return nil, nil, true
    end

    if effectiveState == "ProtectMelee" and requestedState ~= "ProtectMelee" then
        npcData.state = "ProtectMelee"
        syncProtectStateChange(zombie, npcData)
        DTNPCLogic.Behaviors["ProtectMelee"](zombie, npcData, master, distToMaster)
        return nil, nil, true
    end

    if not effectiveState or not master or distToMaster > PROTECT_LEASH then
        if requestedState and distToMaster and distToMaster > PROTECT_LEASH and DTNPCProtect and DTNPCProtect.ReportCombatIssue then
            DTNPCProtect.ReportCombatIssue(
                zombie,
                npcData,
                "ProtectLeash",
                "Too far from you. Regrouping.",
                "warning",
                "distToMaster=" .. tostring(string.format("%.2f", tonumber(distToMaster) or 0))
            )
        elseif requestedState and not effectiveState and DTNPCProtect and DTNPCProtect.ReportCombatIssue then
            local text, sentiment = DTNPCProtect.BuildFallbackNotice(requestedState, effectiveState)
            DTNPCProtect.ReportCombatIssue(
                zombie,
                npcData,
                "ProtectNoLoadout:" .. tostring(requestedState),
                text or "No combat loadout ready.",
                sentiment or "warning",
                "requested=" .. tostring(requestedState)
            )
        end
        followEscort(zombie, npcData, master, distToMaster)
        return nil, nil, true
    end

    local target, targetDist = DTNPCProtect.SelectNearestZombie(
        zombie,
        npcData,
        nil,
        master,
        getProtectEngageRadius(npcData)
    )
    if not target then
        if requestedState and DTNPCProtect and DTNPCProtect.ReportCombatIssue then
            DTNPCProtect.ReportCombatIssue(
                zombie,
                npcData,
                "ProtectNoTarget:" .. tostring(requestedState),
                "No threat in protect range.",
                "neutral",
                "requested=" .. tostring(requestedState) .. " engageRadius=" .. tostring(getProtectEngageRadius(npcData))
            )
        end
        followEscort(zombie, npcData, master, distToMaster)
        return nil, nil, true
    end

    announceCombatEngage(zombie, npcData)
    ensureManualControl(zombie)
    return target, targetDist, false
end

local function executeProtectRanged(zombie, npcData, target, targetDist)
    if DTNPCProtect and not DTNPCProtect.HasUsableRangedLoadout(npcData) then
        if DTNPCProtect.ReportCombatIssue then
            DTNPCProtect.ReportCombatIssue(
                zombie,
                npcData,
                "ProtectRangedUnavailable",
                "Can't fire. No usable firearm.",
                "warning",
                "targetDist=" .. tostring(string.format("%.2f", tonumber(targetDist) or 0))
            )
        end
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
        zombie:faceLocation(tx, ty)
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
    announceRangedAttack(zombie, npcData)
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

local function executeProtectMelee(zombie, npcData, target, targetDist)
    if DTNPCProtect and not DTNPCProtect.HasUsableMeleeLoadout(npcData) then
        if DTNPCProtect.ReportCombatIssue then
            DTNPCProtect.ReportCombatIssue(
                zombie,
                npcData,
                "ProtectMeleeUnavailable",
                "Can't swing. No usable melee weapon.",
                "warning",
                "targetDist=" .. tostring(string.format("%.2f", tonumber(targetDist) or 0))
            )
        end
        return
    end

    faceTarget(zombie, target)

    local stats = DTNPCProtect.GetMeleeCombatStats(npcData)
    local engageReach = math.max(stats.reach or MELEE_REACH, 1.45)
    local currentDist = getTargetDistance(zombie, target)
    if currentDist > engageReach then
        local arrived = moveTowardTarget(
            zombie,
            stats.chaseSpeed or MELEE_DEFAULT_SPEED,
            target,
            math.max(0.9, engageReach - 0.1)
        )
        if not arrived then
            if DTNPCProtect and DTNPCProtect.ReportCombatIssue then
                DTNPCProtect.ReportCombatIssue(
                    zombie,
                    npcData,
                    "ProtectMeleeBlocked",
                    "Can't reach that zombie.",
                    "warning",
                    "currentDist=" .. tostring(string.format("%.2f", currentDist))
                )
            end
            return
        end

        currentDist = getTargetDistance(zombie, target)
        if currentDist > engageReach then
            if DTNPCProtect and DTNPCProtect.LogProtectDebug and isDebugEnabled and isDebugEnabled() then
                DTNPCProtect.LogProtectDebug(
                    npcData,
                    "ProtectMeleeClosing",
                    "currentDist=" .. tostring(string.format("%.2f", currentDist))
                        .. " reach=" .. tostring(string.format("%.2f", engageReach))
                )
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
        return
    end

    npcData.attackTimer = 0
    if DTNPC and DTNPC.TriggerMeleeCombatAnim then
        DTNPC.TriggerMeleeCombatAnim(zombie, npcData)
    end
    DTNPCProtect.ConsumeWeaponCondition(npcData, "melee", 1)
    if DTNPCProtect and DTNPCProtect.LogProtectDebug and isDebugEnabled and isDebugEnabled() then
        DTNPCProtect.LogProtectDebug(
            npcData,
            "ProtectMeleeSwing",
            "dist=" .. tostring(string.format("%.2f", currentDist))
                .. " hitChance=" .. tostring(stats.hitChance)
        )
    end
    if ZombRand(100) < stats.hitChance then
        DTNPCProtect.ApplyCombatHit(zombie, npcData, target, {
            attackType = "melee",
            damage = stats.damage,
        })
    end
end

DTNPCLogic.Behaviors["ProtectRanged"] = function(zombie, npcData, master, distToMaster)
    local target, targetDist, handled = protectTargetOrEscort(zombie, npcData, master, distToMaster, "ProtectRanged")
    if handled then
        return
    end
    executeProtectRanged(zombie, npcData, target, targetDist)
end

DTNPCLogic.Behaviors["ProtectMelee"] = function(zombie, npcData, master, distToMaster)
    local target, targetDist, handled = protectTargetOrEscort(zombie, npcData, master, distToMaster, "ProtectMelee")
    if handled then
        return
    end
    executeProtectMelee(zombie, npcData, target, targetDist)
end

DTNPCLogic.Behaviors["ProtectAuto"] = function(zombie, npcData, master, distToMaster)
    if not master or distToMaster > PROTECT_LEASH then
        followEscort(zombie, npcData, master, distToMaster)
        return
    end

    local target, targetDist = DTNPCProtect.SelectNearestZombie(
        zombie,
        npcData,
        nil,
        master,
        getProtectEngageRadius(npcData)
    )
    if not target then
        followEscort(zombie, npcData, master, distToMaster)
        return
    end

    announceCombatEngage(zombie, npcData)
    ensureManualControl(zombie)
    local resolvedState = DTNPCProtect.GetAutoProtectState(npcData, targetDist)
    npcData.autoProtectActiveState = resolvedState

    if resolvedState == "ProtectRanged" then
        executeProtectRanged(zombie, npcData, target, targetDist)
        return
    end
    if resolvedState == "ProtectMelee" then
        executeProtectMelee(zombie, npcData, target, targetDist)
        return
    end

    followEscort(zombie, npcData, master, distToMaster)
end
