-- ==============================================================================
-- DTNPC_ManagerRegistration_Reclaim.lua
-- Existing world-zombie reclaim and adoption flow.
-- ==============================================================================

DTNPCManager = DTNPCManager or {}

if isClient() and not isServer() then return end

function DTNPCManager.ReclaimZombie(zombie, npcData, reason)
    if not zombie or not npcData then return nil end
    if zombie:isDead() then return nil end
    if npcData.status == "Dead" then return nil end

    local modData = zombie:getModData()
    local uuid = npcData.uuid or modData.DTNPC_UUID
    if not uuid then return nil end

    npcData.uuid = uuid
    if not npcData.visualID then
        npcData.visualID = ZombRand(1000000)
    end

    local previousBodyInstanceID = npcData.currentBodyInstanceID
    local newBodyInstanceID = zombie:getPersistentOutfitID()
    local bodyChanged = tostring(previousBodyInstanceID or "") ~= tostring(newBodyInstanceID or "")
    if bodyChanged then
        DTNPCManager.BumpPresenceRevision(npcData)
    else
        DTNPCManager.EnsurePresenceRevision(npcData)
    end

    DTNPC.AttachData(zombie, npcData)
    DTNPC.ApplyVisuals(zombie, npcData)
    if DTNPC.RestoreNPCBodyState then
        DTNPC.RestoreNPCBodyState(zombie, npcData, {
            clearTarget = true,
            normalizeCompanionHostility = true,
        })
    end

    modData.IsDTNPC = true
    modData.DTNPC_UUID = uuid
    modData.DTNPCVisualID = npcData.visualID
    modData.DTNPCPresenceRevision = DTNPCManager.GetPresenceRevision(npcData)

    if not zombie:isUseless() then
        zombie:setUseless(true)
    end
    zombie:DoZombieStats()
    if DTNPCHealth and DTNPCHealth.InitializeForSpawn then
        DTNPCHealth.InitializeForSpawn(zombie, npcData, { resetCurrent = false })
    else
        zombie:setHealth(2)
    end

    zombie:resetModelNextFrame()

    DTNPCManager.Register(zombie, npcData)

    if DTNPCServerCore and DTNPCServerCore.SyncToAllClients then
        DTNPCServerCore.SyncToAllClients(zombie, npcData)
    end

    if DTNPCManager.RespawnDebug and DTNPCManager.RespawnDebug.Log then
        DTNPCManager.RespawnDebug.Log(
            "reclaim_" .. tostring(uuid),
            "Process=reclaim_existing_zombie uuid=" .. tostring(uuid) ..
                " name=" .. tostring(npcData.name or "Unknown") ..
                " reason=" .. tostring(reason or "repair") ..
                " bodyInstanceID=" .. tostring(zombie:getPersistentOutfitID()) ..
                " visualID=" .. tostring(npcData.visualID),
            true
        )
    end

    DynamicTrading.Log(
        "DTV2",
        "NPC",
        "Adopt",
        "Reclaimed existing world zombie for " .. (npcData.name or uuid) .. " (" .. (reason or "repair") .. ")"
    )

    return zombie
end
