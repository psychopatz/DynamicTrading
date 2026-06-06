-- ==============================================================================
-- DTNPC_LifecycleFinalDeath_ZombieDead.lua
-- Zombie-dead entry handling for lifecycle final-death flow.
-- ==============================================================================

DTNPCLifecycle = DTNPCLifecycle or {}
DTNPCLifecycle.Internal = DTNPCLifecycle.Internal or {}

local internal = DTNPCLifecycle.Internal

local function hasTerminalDeathRequest(npcData)
    if type(npcData) ~= "table" then
        return false
    end

    if tostring(npcData.status or "") == "Dead" or tonumber(npcData.deathFinalizedAt) then
        return true
    end

    local combatHealth = type(npcData.combatHealth) == "table" and npcData.combatHealth or nil
    return (tonumber(combatHealth and combatHealth.incapFinalKillRequestedAt) or 0) > 0
end

function DTNPCLifecycle.HandleZombieDead(zombie)
    local modData = zombie and zombie.getModData and zombie:getModData() or nil
    if modData and modData.DTNPCZombieDeadHandled == true then
        return
    end

    local uuid = internal.getUUIDFromZombie(zombie)
    local zombieRuntimeID = DTNPC_ZombieAggro and DTNPC_ZombieAggro._internal and DTNPC_ZombieAggro._internal.getZombieRuntimeID
        and DTNPC_ZombieAggro._internal.getZombieRuntimeID(zombie)
        or nil
    if zombieRuntimeID and DTNPC_ZombieAggro and DTNPC_ZombieAggro.OnZombieInvalidated then
        DTNPC_ZombieAggro.OnZombieInvalidated(zombieRuntimeID)
    end

    local attacker = zombie and zombie:getAttackedBy() or nil
    local removalContext = internal.buildKillerContext(attacker)

    if uuid and DTNPCManager and DTNPCManager.Data and DTNPCManager.Data[uuid] then
        if modData then
            modData.DTNPCZombieDeadHandled = true
        end
        local npcData = DTNPCManager.Data[uuid]
        local deadBodyInstanceID = zombie and zombie.getPersistentOutfitID and zombie:getPersistentOutfitID() or nil
        local currentBodyInstanceID = npcData and npcData.currentBodyInstanceID or nil
        if currentBodyInstanceID ~= nil
            and deadBodyInstanceID ~= nil
            and tostring(currentBodyInstanceID) ~= tostring(deadBodyInstanceID) then
            DynamicTrading.Log(
                "DTV2",
                "NPC",
                "Warn",
                "Ignoring stale dead body for "
                    .. tostring(npcData.name or uuid)
                    .. " uuid=" .. tostring(uuid)
                    .. " deadBodyInstanceID=" .. tostring(deadBodyInstanceID)
                    .. " currentBodyInstanceID=" .. tostring(currentBodyInstanceID)
            )
            zombie:removeFromWorld()
            zombie:removeFromSquare()
            return
        end
        DynamicTrading.Log(
            "DTV2",
            "NPC",
            "Lifecycle",
            "ZombieDead triggered for "
                .. tostring(npcData.name or uuid)
                .. " uuid=" .. tostring(uuid)
                .. " engineHealth=" .. tostring(zombie and zombie:getHealth() or nil)
                .. " customCurrent=" .. tostring(npcData.combatHealth and npcData.combatHealth.current or nil)
                .. " customMax=" .. tostring(npcData.combatHealth and npcData.combatHealth.max or nil)
                .. " incapState=" .. tostring(npcData.incapState)
                .. " state=" .. tostring(npcData.state)
                .. " status=" .. tostring(npcData.status)
        )

        local activePlayers = DTNPCManager.GetActivePlayers and DTNPCManager.GetActivePlayers() or {}
        local isWorkerLinkedCompanion = tostring(npcData.dcCompanionJob or "") == "TravelCompanion"
            and tostring(npcData.linkedWorkerID or "") ~= ""
        local isSuspiciousRestartDeath = isWorkerLinkedCompanion
            and #activePlayers <= 0
            and removalContext == nil
            and tostring(npcData.status or "") ~= "Dead"

        if isSuspiciousRestartDeath then
            DynamicTrading.Log(
                "DTV2",
                "NPC",
                "Lifecycle",
                "Ignoring suspicious restart death for worker-linked travel companion and clearing stale body only: "
                    .. tostring(npcData.name or uuid)
                    .. " uuid=" .. tostring(uuid)
            )
            DTNPCManager.RemoveData(
                uuid,
                nil,
                nil,
                nil,
                DTNPCLifecycle.WithStaleBodyCleanupContext({
                    reason = "restart_companion_stale_body",
                }, zombie:getX(), zombie:getY(), zombie:getZ())
            )
            return
        end

        local terminalDeathRequested = hasTerminalDeathRequest(npcData)

        if npcData.incapState == "Active"
            and not terminalDeathRequested
            and DTNPCLifecycle.PreserveSuspiciousIncapacitatedDeath(zombie, uuid, npcData) then
            return
        end

        if not removalContext and npcData.lastPlayerAttackerUsername then
            local elapsed = npcData.lastPlayerAttackedAt and (getTimeInMillis() - npcData.lastPlayerAttackedAt) or nil
            if not elapsed or elapsed <= 15000 then
                removalContext = {
                    killerUsername = npcData.lastPlayerAttackerUsername,
                    killerOnlineID = npcData.lastPlayerAttackerOnlineID,
                }
            end
        end
        if npcData.incapState == "Active" or terminalDeathRequested then
            DTNPCLifecycle.FinalizeIncapacitatedDeath(zombie, npcData, attacker, removalContext)
            return
        end

        if DTNPCLifecycle.RecoverPrematureCustomHealthDeath(zombie, uuid, npcData, removalContext) then
            return
        end

        if DTNPCLifecycle.ConvertDeathToIncapacitated(zombie, uuid, npcData, removalContext) then
            return
        end

        if removalContext and removalContext.killerUsername and npcData.factionID and npcData.factionID ~= "Independent" then
            if DynamicTrading and DynamicTrading.GameplayLogs and DynamicTrading.GameplayLogs.AddFactionEvent then
                DynamicTrading.GameplayLogs.AddFactionEvent(npcData.factionID, DynamicTrading.GameplayEvents.MEMBER_KILLED_BY_PLAYER, { removalContext.killerUsername, npcData.name or "A member" })
            end
        end

        DynamicTrading.Log("DTV2", "NPC", "Lifecycle", "NPC Died: " .. (npcData.name or uuid))
        DTNPCLifecycle.DropDeathMoney(zombie, npcData, removalContext)
        local deathFactionID = npcData.factionID
        DTNPCManager.RemoveData(uuid, "Dead", nil, nil, removalContext)
        if deathFactionID and DynamicTrading_Factions and DynamicTrading_Factions.AuditFactionExtinction then
            DynamicTrading_Factions.AuditFactionExtinction(deathFactionID, { reason = "member_killed" })
        end
    else
        DynamicTrading.Log("DTV2", "NPC", "Warn", "Unregister ignored zombie with no authoritative UUID; refusing outfit-ID fallback.")
    end
end
