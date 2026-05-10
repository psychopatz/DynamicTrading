-- ==============================================================================
-- Behavior_Guard.lua
-- Active anchored guard behavior.
-- ==============================================================================

DTNPCLogic = DTNPCLogic or {}
DTNPCLogic.Behaviors = DTNPCLogic.Behaviors or {}
require "DT/V2/NPC/Sys/DTNPC_Protect"
require "DT/V2/NPC/Sys/Mobility/DTNPC_Mobility"

local GUARD_DEFAULT_ENGAGE_RADIUS = 12
local GUARD_RETURN_STOP_DISTANCE = 0.25
local GUARD_RETURN_SPEED = 0.045
local GUARD_MELEE_REACH = 1.25
local GUARD_MELEE_SPEED = 0.05

local function toProtectState(guardState)
    if guardState == "GuardRanged" then
        return "ProtectRanged"
    end
    if guardState == "GuardMelee" then
        return "ProtectMelee"
    end
    return nil
end

local function createPointTarget(x, y, z)
    if x == nil or y == nil then
        return nil
    end
    local px = tonumber(x)
    local py = tonumber(y)
    local pz = tonumber(z) or 0
    return {
        getX = function() return px end,
        getY = function() return py end,
        getZ = function() return pz end,
    }
end

local function getDistance(ax, ay, bx, by)
    local dx = (tonumber(ax) or 0) - (tonumber(bx) or 0)
    local dy = (tonumber(ay) or 0) - (tonumber(by) or 0)
    return math.sqrt((dx * dx) + (dy * dy))
end

local function moveBackToPost(zombie, npcData)
    if not zombie or not npcData then
        return false
    end

    if not DTNPCProtect or not DTNPCProtect.GetStationaryPost then
        return false
    end

    local postX, postY, postZ = DTNPCProtect.GetStationaryPost(npcData)
    if postX == nil or postY == nil then
        return false
    end

    local currentDist = getDistance(zombie:getX(), zombie:getY(), postX, postY)
    if currentDist <= GUARD_RETURN_STOP_DISTANCE then
        npcData.guardReturningToPost = nil
        return false
    end

    if not zombie:isUseless() then
        zombie:setUseless(true)
    end

    local moved, state = DTNPCMobility.MoveTowardTarget(zombie, npcData, {
        target = createPointTarget(postX, postY, postZ),
        speed = tonumber(npcData.guardReturnSpeed) or GUARD_RETURN_SPEED,
        staminaMode = "return",
        desiredRun = false,
        stopDistance = GUARD_RETURN_STOP_DISTANCE,
        blockCounterKey = "guardReturnBlockedTicks",
        stuckTicks = 12,
        anim = {
            animSpeed = 1.0,
            isRunning = false,
            walkType = "1",
        },
    })

    if state == "exhausted" then
        npcData.guardReturningToPost = true
        npcData.isMovingState = false
        DTNPCMobility.Stop(zombie)
        zombie:faceLocation(postX, postY)
        return true
    end

    if moved and (state == "moving" or state == "unstuck") then
        npcData.isMovingState = true
        npcData.guardReturningToPost = true
        return true
    end

    if state == "arrived" or state == "close_enough" then
        npcData.guardReturningToPost = nil
        npcData.isMovingState = false
        return false
    end

    npcData.guardReturningToPost = false
    return false
end

DTNPCLogic.Behaviors["Guard"] = function(zombie, npcData)
    if not zombie or not npcData then
        return
    end

    if not DTNPCProtect then
        DTNPCLogic.Stationary.Run(zombie, npcData)
        return
    end

    local postX, postY = nil, nil
    if DTNPCProtect.GetStationaryPost then
        postX, postY = DTNPCProtect.GetStationaryPost(npcData)
    end
    if postX == nil or postY == nil or npcData.stationaryPostState ~= "Guard" then
        DTNPCProtect.RememberStationaryPost(zombie, npcData, "Guard", true)
    end

    local engageRadius = tonumber(npcData.guardEngageRadius)
        or tonumber(npcData.stationaryCombatLeashRadius)
        or GUARD_DEFAULT_ENGAGE_RADIUS
    local leashRadius = tonumber(npcData.guardLeashRadius)
        or tonumber(npcData.stationaryCombatLeashRadius)
        or engageRadius

    local anchorTarget = DTNPCProtect.GetCombatAnchorTarget and DTNPCProtect.GetCombatAnchorTarget(npcData, zombie) or zombie
    local target, targetDist = DTNPCProtect.SelectNearestThreat(
        zombie,
        npcData,
        engageRadius,
        anchorTarget,
        leashRadius
    )

    if not target then
        npcData.autoProtectActiveState = nil

        if DTNPCProtect.AnnounceCompanionCombatReturn then
            DTNPCProtect.AnnounceCompanionCombatReturn(zombie, npcData, "guard")
        end

        local returning = moveBackToPost(zombie, npcData)
        if returning then
            return
        end

        if DTNPCProtect.ResetGuardedCombatState then
            DTNPCProtect.ResetGuardedCombatState(zombie, npcData, {
                clearAutoProtectState = true,
            })
        end
        DTNPCLogic.Stationary.Run(zombie, npcData)
        return
    end

    if DTNPCProtect.EnsureManualCombatControl then
        DTNPCProtect.EnsureManualCombatControl(zombie)
    end
    if DTNPCProtect.AnnounceCompanionCombatEngage then
        DTNPCProtect.AnnounceCompanionCombatEngage(zombie, npcData, "guard")
    end

    local guardState = DTNPCProtect.ResolveGuardCombatState
        and DTNPCProtect.ResolveGuardCombatState(npcData, targetDist, nil)
        or nil
    npcData.autoProtectActiveState = toProtectState(guardState)

    if guardState == "GuardRanged" and DTNPCProtect.ExecuteGuardedRangedCombat then
        DTNPCProtect.ExecuteGuardedRangedCombat(zombie, npcData, target, targetDist, {
            mode = "guard",
            issuePrefix = "GuardRanged",
            unavailableText = "No firearm ready for guard duty.",
            onRangedAttack = function(attackZombie, attackNpcData)
                if DTNPCProtect and DTNPCProtect.AnnounceCompanionRangedAttack then
                    DTNPCProtect.AnnounceCompanionRangedAttack(attackZombie, attackNpcData, "guard")
                end
            end,
        })
        return
    end

    if guardState == "GuardMelee" and DTNPCProtect.ExecuteGuardedMeleeCombat then
        local anchorX = anchorTarget and anchorTarget.getX and anchorTarget:getX() or zombie:getX()
        local anchorY = anchorTarget and anchorTarget.getY and anchorTarget:getY() or zombie:getY()
        local anchorZ = anchorTarget and anchorTarget.getZ and anchorTarget:getZ() or zombie:getZ()
        DTNPCProtect.ExecuteGuardedMeleeCombat(zombie, npcData, target, targetDist, {
            mode = "guard",
            issuePrefix = "GuardMelee",
            unavailableText = "No melee weapon ready for guard duty.",
            blockedText = "Can't reach that threat from this guard post.",
            blockCounterKey = "guardBlockedTicks",
            fallbackReach = GUARD_MELEE_REACH,
            defaultSpeed = GUARD_MELEE_SPEED,
            enterBuffer = 0.25,
            holdBuffer = 0.45,
            stopBuffer = 0.16,
            debugLabel = "GuardMeleeSwing",
            anchorX = anchorX,
            anchorY = anchorY,
            anchorZ = anchorZ,
            leashRadius = leashRadius,
        })
        return
    end

    if DTNPCProtect and DTNPCProtect.ReportCombatIssue then
        DTNPCProtect.ReportCombatIssue(
            zombie,
            npcData,
            "GuardNoLoadout",
            "No combat loadout ready for guard duty.",
            "warning",
            "state=" .. tostring(guardState)
        )
    end

    if DTNPCProtect and DTNPCProtect.ResetGuardedCombatState then
        DTNPCProtect.ResetGuardedCombatState(zombie, npcData, {
            clearAutoProtectState = true,
        })
    end
    DTNPCLogic.Stationary.Run(zombie, npcData)
end
