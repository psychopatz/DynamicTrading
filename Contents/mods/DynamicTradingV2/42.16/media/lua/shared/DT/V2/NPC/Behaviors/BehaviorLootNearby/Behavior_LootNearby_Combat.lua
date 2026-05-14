-- ==============================================================================
-- Behavior_LootNearby_Combat.lua
-- Combat interruption and commander-follow helpers for loot search behavior.
-- ==============================================================================

DTNPCLogic = DTNPCLogic or {}
DTNPCLogic.Internal = DTNPCLogic.Internal or {}
DTNPCLogic.Internal.LootNearby = DTNPCLogic.Internal.LootNearby or {}

local LootNearby = DTNPCLogic.Internal.LootNearby
local modules = LootNearby.Modules or {}
local Constants = LootNearby.Constants or {}

LootNearby.Modules = modules
LootNearby.Constants = Constants

if modules.Combat then
    return
end

modules.Combat = true

function LootNearby.StopLooting(zombie, npcData, notice, sentiment)
    LootNearby.LootDebugLog(npcData, nil, "Stop", "Looting stopped. notice=" .. tostring(notice) .. " sentiment=" .. tostring(sentiment))
    if npcData then
        npcData.state = "Stay"
        npcData.dcLootStatus = notice and "idle" or npcData.dcLootStatus
        npcData.dcLootTarget = nil
        npcData.dcLootTargetKey = nil
        npcData.isMovingState = false
    end
    if DTNPCProtect and DTNPCProtect.ResetGuardedCombatState then
        DTNPCProtect.ResetGuardedCombatState(zombie, npcData, {
            clearAutoProtectState = true,
        })
    end
    if zombie and DTNPCMobility and DTNPCMobility.Stop then
        DTNPCMobility.Stop(zombie)
    end
    if notice and DTNPCProtect and DTNPCProtect.PushCompanionNotice then
        DTNPCProtect.PushCompanionNotice(zombie, npcData, notice, sentiment or "neutral")
    end
end

function LootNearby.RunLootCombat(zombie, npcData)
    if not zombie or not npcData or not DTNPCProtect then
        return false
    end

    local anchorTarget = DTNPCProtect.GetCombatAnchorTarget and DTNPCProtect.GetCombatAnchorTarget(npcData, zombie)
        or LootNearby.BuildPointTarget(zombie:getX(), zombie:getY(), zombie:getZ())
    local engageRadius = tonumber(npcData.protectEngageRadius) or Constants.LOOT_THREAT_RADIUS
    local lootRadius = tonumber(npcData.dcLootRadius) or engageRadius
    local leashRadius = math.max(engageRadius + Constants.LOOT_THREAT_LEASH_BONUS, lootRadius)
    local target, targetDist = DTNPCProtect.SelectNearestThreat(
        zombie,
        npcData,
        engageRadius,
        anchorTarget,
        leashRadius
    )

    if not target then
        if DTNPCProtect.ResetGuardedCombatState then
            DTNPCProtect.ResetGuardedCombatState(zombie, npcData, {
                clearAutoProtectState = true,
            })
        end
        npcData.dcLootStatus = npcData.dcLootStatus == "combat" and "searching" or npcData.dcLootStatus
        return false
    end

    local requestedState = npcData.combatOrder or "ProtectAuto"
    local resolvedState = DTNPCProtect.ResolveProtectState and DTNPCProtect.ResolveProtectState(npcData, requestedState) or requestedState
    if requestedState == "ProtectAuto" and DTNPCProtect.GetAutoProtectState then
        resolvedState = DTNPCProtect.GetAutoProtectState(npcData, targetDist)
    end

    npcData.autoProtectActiveState = resolvedState
    npcData.dcLootStatus = "combat"
    if DTNPCProtect.EnsureManualCombatControl then
        DTNPCProtect.EnsureManualCombatControl(zombie)
    end
    if DTNPCProtect.AnnounceCompanionCombatEngage then
        DTNPCProtect.AnnounceCompanionCombatEngage(zombie, npcData, "loot")
    end

    if resolvedState == "ProtectRanged" and DTNPCProtect.ExecuteGuardedRangedCombat then
        DTNPCProtect.ExecuteGuardedRangedCombat(zombie, npcData, target, targetDist, {
            mode = "loot",
            issuePrefix = "LootRanged",
            unavailableText = "Can't cover the loot. No usable firearm.",
            onRangedAttack = function(attackZombie, attackNpcData)
                if DTNPCProtect and DTNPCProtect.AnnounceCompanionRangedAttack then
                    DTNPCProtect.AnnounceCompanionRangedAttack(attackZombie, attackNpcData, "loot")
                end
            end,
        })
        return true
    end

    if resolvedState == "ProtectMelee" and DTNPCProtect.ExecuteGuardedMeleeCombat then
        local anchorX = anchorTarget and anchorTarget.getX and anchorTarget:getX() or zombie:getX()
        local anchorY = anchorTarget and anchorTarget.getY and anchorTarget:getY() or zombie:getY()
        local anchorZ = anchorTarget and anchorTarget.getZ and anchorTarget:getZ() or zombie:getZ()
        DTNPCProtect.ExecuteGuardedMeleeCombat(zombie, npcData, target, targetDist, {
            mode = "loot",
            issuePrefix = "LootMelee",
            unavailableText = "Can't defend the loot. No usable melee weapon.",
            blockedText = "Can't reach that threat from the looting area.",
            blockCounterKey = "lootCombatBlockedTicks",
            fallbackReach = 1.25,
            defaultSpeed = 0.05,
            enterBuffer = 0.25,
            holdBuffer = 0.45,
            stopBuffer = 0.16,
            debugLabel = "LootMeleeSwing",
            anchorX = anchorX,
            anchorY = anchorY,
            anchorZ = anchorZ,
            leashRadius = leashRadius,
        })
        return true
    end

    if DTNPCProtect.ReportCombatIssue then
        local text, sentiment = nil, nil
        if DTNPCProtect.BuildFallbackNotice then
            text, sentiment = DTNPCProtect.BuildFallbackNotice(requestedState, resolvedState)
        end
        DTNPCProtect.ReportCombatIssue(
            zombie,
            npcData,
            "LootNoLoadout",
            text or "No combat loadout ready to cover looting.",
            sentiment or "warning",
            "requested=" .. tostring(requestedState) .. " resolved=" .. tostring(resolvedState)
        )
    end
    return false
end

function LootNearby.FindOnlinePlayer(username)
    if not username or username == "" then
        return nil
    end

    local onlinePlayers = getOnlinePlayers and getOnlinePlayers() or nil
    if onlinePlayers then
        for index = 0, onlinePlayers:size() - 1 do
            local player = onlinePlayers:get(index)
            if player and player.getUsername and player:getUsername() == username then
                return player
            end
        end
    end

    local localPlayer = getSpecificPlayer and getSpecificPlayer(0) or nil
    if localPlayer and localPlayer.getUsername and localPlayer:getUsername() == username then
        return localPlayer
    end

    return nil
end

function LootNearby.GetLootCommanderTarget(npcData, worker)
    local usernames = {
        tostring(npcData and npcData.dcCommanderUsername or ""),
        tostring(worker and worker.ownerUsername or ""),
    }

    for _, username in ipairs(usernames) do
        if username ~= "" then
            local player = LootNearby.FindOnlinePlayer(username)
            if player then
                return player
            end
        end
    end

    return nil
end

function LootNearby.UpdateLootFollowEscort(zombie, npcData, commander)
    if not zombie or not npcData or not commander then
        return nil
    end

    local dist = LootNearby.GetDistance(zombie:getX(), zombie:getY(), commander:getX(), commander:getY())
    if DTNPCLogic and DTNPCLogic.Behaviors and DTNPCLogic.Behaviors["Follow"] then
        DTNPCLogic.Behaviors["Follow"](zombie, npcData, commander, dist)
    end
    return dist
end
