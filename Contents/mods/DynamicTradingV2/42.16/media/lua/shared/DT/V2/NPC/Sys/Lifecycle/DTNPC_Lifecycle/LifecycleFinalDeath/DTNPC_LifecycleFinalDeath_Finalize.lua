-- ==============================================================================
-- DTNPC_LifecycleFinalDeath_Finalize.lua
-- Final incapacitated-death resolution helpers.
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

function DTNPCLifecycle.FinalizeIncapacitatedDeath(zombie, npcData, attacker, context)
    local modData = zombie and zombie.getModData and zombie:getModData() or nil
    if modData then
        modData.DTNPCZombieDeadHandled = true
    end

    local uuid = (npcData and npcData.uuid) or internal.getUUIDFromZombie(zombie)
    local liveData = internal.getLiveNPCData(uuid, npcData)
    if not uuid or not liveData then
        return false
    end
    if (tonumber(liveData.deathFinalizedAt) or 0) > 0 or tostring(liveData.status or "") == "Dead" then
        return true
    end
    if liveData.incapState ~= "Active" and not hasTerminalDeathRequest(liveData) then
        return false
    end

    local removalContext = internal.copyContext(context)
    local killerContext = internal.buildKillerContext(attacker, liveData)
    if killerContext then
        for key, value in pairs(killerContext) do
            removalContext[key] = value
        end
    end

    if removalContext and removalContext.killerUsername and liveData.factionID and liveData.factionID ~= "Independent" then
        if DynamicTrading and DynamicTrading.GameplayLogs and DynamicTrading.GameplayLogs.AddFactionEvent then
            DynamicTrading.GameplayLogs.AddFactionEvent(liveData.factionID, DynamicTrading.GameplayEvents.MEMBER_KILLED_BY_PLAYER, { removalContext.killerUsername, liveData.name or "A member" })
        end
    end

    if DTNPCHealth and DTNPCHealth.Internal and DTNPCHealth.Internal.markTerminalDeathState then
        DTNPCHealth.Internal.markTerminalDeathState(liveData)
    else
        liveData.status = "Dead"
        liveData.state = "Dead"
        liveData.incapState = nil
        liveData.healthState = nil
        liveData.reviveData = nil
        liveData.health = 0
        liveData.lastHealth = 0
        if type(liveData.combatHealth) == "table" then
            liveData.combatHealth.current = 0
            liveData.combatHealth.enabled = false
            liveData.combatHealth.engineProtected = false
            liveData.combatHealth.incapGraceUntil = 0
            liveData.combatHealth.lastEngineHealth = 0
        end
    end

    DynamicTrading.Log("DTV2", "NPC", "Lifecycle", "Incapacitated NPC killed for good: " .. (liveData.name or uuid))
    if DTNPCHostility and DTNPCHostility.PlayDeathSound then
        DTNPCHostility.PlayDeathSound(zombie, liveData)
    end
    if DTNPC_ZombieAggro and DTNPC_ZombieAggro.EmitVocalNoise then
        DTNPC_ZombieAggro.EmitVocalNoise(zombie, liveData, "Death", {
            radius = 22,
            volume = 1.2,
            cooldownMs = 0,
        })
    end
    DTNPCLifecycle.DropDeathMoney(zombie, liveData, removalContext)
    local finalKillContext = DTNPCLifecycle.WithFinalKillContext(zombie, removalContext)
    local manualCorpseCreated = false
    if finalKillContext.forcedLiveBodyRemoval == true then
        manualCorpseCreated = DTNPCLifecycle.CreateCorpseFromZombie(zombie, liveData, "incapacitated_final_kill") == true
        finalKillContext.manualCorpseCreated = manualCorpseCreated
    end
    local deathFactionID = liveData.factionID
    DTNPCManager.RemoveData(uuid, "Dead", nil, nil, finalKillContext)
    if deathFactionID and DynamicTrading_Factions and DynamicTrading_Factions.AuditFactionExtinction then
        DynamicTrading_Factions.AuditFactionExtinction(deathFactionID, { reason = "member_killed" })
    end

    if finalKillContext.forcedLiveBodyRemoval == true and zombie and not (zombie.isDead and zombie:isDead()) then
        DynamicTrading.Log(
            "DTV2",
            "NPC",
            "Warn",
            "Engine Kill did not convert incapacitated body to corpse; "
                .. (manualCorpseCreated and "manual corpse created, " or "manual corpse failed, ")
                .. "removing live body for " .. tostring(liveData.name or uuid)
        )
        zombie:removeFromWorld()
        zombie:removeFromSquare()
    end
    return true
end
