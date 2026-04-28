-- ==============================================================================
-- Behavior_Protect.lua
-- Companion protect behaviors for ranged and melee escort combat.
-- ==============================================================================

DTNPCLogic = DTNPCLogic or {}
DTNPCLogic.Behaviors = DTNPCLogic.Behaviors or {}
require "DT/V2/NPC/Sys/DTNPC_Protect"
require "DT/V2/NPC/Sys/Mobility/DTNPC_Mobility"

local MELEE_REACH = 1.25
local MELEE_DEFAULT_SPEED = 0.05
local MELEE_APPROACH_STOP_BUFFER = 0.16
local PROTECT_LEASH = 14
local PROTECT_MASTER_ENGAGE_RADIUS = 10

local function resetProtectMoveState(npcData)
    if not npcData then
        return
    end

    npcData.isMovingState = false
    npcData.protectMovePrimed = nil
    npcData.protectMoveReason = nil
end

local function clearProtectCombat(zombie, npcData)
    DTNPCProtect.ResetGuardedCombatState(zombie, npcData, {
        resetMoveState = resetProtectMoveState,
        clearAutoProtectState = true,
    })
end

local function announceCombatEngage(zombie, npcData)
    DTNPCProtect.AnnounceCompanionCombatEngage(zombie, npcData, "combat")
    if DTNPCProtect.LogProtectDebug then
        DTNPCProtect.LogProtectDebug(npcData, "engage", "target=" .. tostring(npcData and npcData.combatTargetID))
    end
end

local function announceRangedAttack(zombie, npcData)
    DTNPCProtect.AnnounceCompanionRangedAttack(zombie, npcData, "ranged")
end

local function announceReturnToMaster(zombie, npcData)
    DTNPCProtect.AnnounceCompanionCombatReturn(zombie, npcData, "return")
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

local function resolveAutoProtectCombatState(zombie, npcData, targetDist)
    if not DTNPCProtect or not DTNPCProtect.GetAutoProtectState then
        return nil
    end

    local hasRanged = DTNPCProtect.HasUsableRangedLoadout and DTNPCProtect.HasUsableRangedLoadout(npcData)
    local hasMelee = DTNPCProtect.HasUsableMeleeLoadout and DTNPCProtect.HasUsableMeleeLoadout(npcData)
    local distance = tonumber(targetDist) or 9999

    if hasMelee and distance <= 1.85 then
        return "ProtectMelee"
    end

    local primaryItem = zombie and zombie.getPrimaryHandItem and zombie:getPrimaryHandItem() or nil
    if primaryItem then
        local isPrimaryRanged = false
        if primaryItem.isRanged and primaryItem:isRanged() then
            isPrimaryRanged = true
        elseif primaryItem.isAimedFirearm and primaryItem:isAimedFirearm() then
            isPrimaryRanged = true
        elseif primaryItem.getAmmoType and primaryItem:getAmmoType() and primaryItem:getAmmoType() ~= "" then
            isPrimaryRanged = true
        end

        if isPrimaryRanged and hasRanged then
            return "ProtectRanged"
        end
        if hasMelee then
            return "ProtectMelee"
        end
    end

    return DTNPCProtect.GetAutoProtectState(npcData, targetDist)
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

    local target, targetDist = DTNPCProtect.SelectNearestThreat(
        zombie,
        npcData,
        nil,
        master,
        getProtectEngageRadius(npcData),
        true
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
    DTNPCProtect.EnsureManualCombatControl(zombie)
    return target, targetDist, false
end

local function executeProtectRanged(zombie, npcData, target, targetDist)
    DTNPCProtect.ExecuteGuardedRangedCombat(zombie, npcData, target, targetDist, {
        mode = "protect",
        issuePrefix = "ProtectRanged",
        unavailableText = "Can't fire. No usable firearm.",
        onCombatIdle = function(idleZombie, idleNpcData)
            if DTNPC and DTNPC.SetRangedCombatIdleState then
                DTNPC.SetRangedCombatIdleState(idleZombie, idleNpcData)
            end
        end,
        onRangedAttack = function(attackZombie, attackNpcData)
            announceRangedAttack(attackZombie, attackNpcData)
        end,
    })
end

local function executeProtectMelee(zombie, npcData, target, targetDist, master)
    local anchorX = master and master.getX and master:getX() or zombie:getX()
    local anchorY = master and master.getY and master:getY() or zombie:getY()
    local anchorZ = master and master.getZ and master:getZ() or zombie:getZ()
    DTNPCProtect.ExecuteGuardedMeleeCombat(zombie, npcData, target, targetDist, {
        mode = "protect",
        issuePrefix = "ProtectMelee",
        unavailableText = "Can't swing. No usable melee weapon.",
        blockedText = "Can't reach that zombie.",
        blockCounterKey = "protectBlockedTicks",
        fallbackReach = MELEE_REACH,
        defaultSpeed = MELEE_DEFAULT_SPEED,
        enterBuffer = 0.25,
        holdBuffer = 0.45,
        stopBuffer = MELEE_APPROACH_STOP_BUFFER,
        debugLabel = "ProtectMeleeSwing",
        anchorX = anchorX,
        anchorY = anchorY,
        anchorZ = anchorZ,
        leashRadius = math.max(getProtectEngageRadius(npcData), PROTECT_LEASH),
    })
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
    executeProtectMelee(zombie, npcData, target, targetDist, master)
end

DTNPCLogic.Behaviors["ProtectAuto"] = function(zombie, npcData, master, distToMaster)
    if not master or distToMaster > PROTECT_LEASH then
        followEscort(zombie, npcData, master, distToMaster)
        return
    end

    local target, targetDist = DTNPCProtect.SelectNearestThreat(
        zombie,
        npcData,
        nil,
        master,
        getProtectEngageRadius(npcData),
        true
    )
    if not target then
        followEscort(zombie, npcData, master, distToMaster)
        return
    end

    local resolvedState = resolveAutoProtectCombatState(zombie, npcData, targetDist)
    npcData.autoProtectActiveState = resolvedState

    if not resolvedState then
        if DTNPCProtect and DTNPCProtect.ReportCombatIssue then
            local text, sentiment = DTNPCProtect.BuildFallbackNotice("ProtectAuto", nil)
            DTNPCProtect.ReportCombatIssue(
                zombie,
                npcData,
                "ProtectNoLoadout:ProtectAuto",
                text or "No combat loadout ready.",
                sentiment or "warning",
                "requested=ProtectAuto"
            )
        end
        followEscort(zombie, npcData, master, distToMaster)
        return
    end

    announceCombatEngage(zombie, npcData)
    DTNPCProtect.EnsureManualCombatControl(zombie)

    if resolvedState == "ProtectRanged" then
        executeProtectRanged(zombie, npcData, target, targetDist)
        return
    end
    if resolvedState == "ProtectMelee" then
        executeProtectMelee(zombie, npcData, target, targetDist, master)
        return
    end

    followEscort(zombie, npcData, master, distToMaster)
end
