-- ==============================================================================
-- DTNPC_LifecycleFinalDeath_Finalize.lua
-- Final incapacitated-death resolution helpers.
-- ==============================================================================

DTNPCLifecycle = DTNPCLifecycle or {}
DTNPCLifecycle.Internal = DTNPCLifecycle.Internal or {}

local internal = DTNPCLifecycle.Internal

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
    if liveData.incapState ~= "Active" then
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
    DTNPCLifecycle.DropDeathMoney(zombie, liveData, removalContext)
    local finalKillContext = DTNPCLifecycle.WithFinalKillContext(zombie, removalContext)
    local manualCorpseCreated = false
    if finalKillContext.forcedLiveBodyRemoval == true then
        manualCorpseCreated = DTNPCLifecycle.CreateCorpseFromZombie(zombie, liveData, "incapacitated_final_kill") == true
        finalKillContext.manualCorpseCreated = manualCorpseCreated
    end
    DTNPCManager.RemoveData(uuid, "Dead", nil, nil, finalKillContext)

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
