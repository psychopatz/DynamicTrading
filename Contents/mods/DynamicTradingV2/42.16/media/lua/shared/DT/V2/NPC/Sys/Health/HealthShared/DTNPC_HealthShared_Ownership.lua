-- ==============================================================================
-- DTNPC_HealthShared_Ownership.lua
-- Ownership and linked-worker helpers for DT NPC health.
-- ==============================================================================

DTNPCHealth = DTNPCHealth or {}
DTNPCHealth.Internal = DTNPCHealth.Internal or {}

local internal = DTNPCHealth.Internal

local function isPlayerOwnedNPC(npcData)
    if not npcData then
        return false
    end

    if npcData.isBandit == true or tostring(npcData.factionID or "") == "Bandits" then
        return false
    end
    if npcData.raidHostileFaction == true or npcData.banditGroupID ~= nil then
        return false
    end

    if DTNPCProtect and DTNPCProtect.IsPlayerOwnedTrader then
        local ok, result = pcall(DTNPCProtect.IsPlayerOwnedTrader, npcData)
        if ok and result == true then
            return true
        end
    end

    if npcData.isPlayerFactionTrader == true then
        return true
    end

    if npcData.masterID ~= nil then
        return true
    end

    if npcData.master and tostring(npcData.master) ~= "" then
        return true
    end

    if DynamicTrading_Factions and DynamicTrading_Factions.GetFaction then
        local faction = DynamicTrading_Factions.GetFaction(npcData.factionID)
        if faction and faction.playerOwned == true then
            return true
        end
    end

    return npcData.linkedWorkerID ~= nil
end

internal.isPlayerOwnedNPC = isPlayerOwnedNPC

local function getLinkedWorkerCompanionBridge()
    local colony = rawget(_G, "DC_Colony")
    local companion = colony and colony.Companion or nil
    if type(companion) ~= "table" then
        return nil
    end
    return companion
end

internal.getLinkedWorkerCompanionBridge = getLinkedWorkerCompanionBridge

local function getLinkedWorkerHealthSnapshot(npcData)
    local bridge = getLinkedWorkerCompanionBridge()
    if not bridge or not bridge.GetHealthSeed or not npcData or not npcData.linkedWorkerID then
        return nil
    end

    local registry = rawget(_G, "DC_Colony") and DC_Colony.Registry or nil
    local worker = registry and registry.GetWorkerRaw and registry.GetWorkerRaw(npcData.linkedWorkerID) or nil
    if not worker then
        return nil
    end

    return bridge.GetHealthSeed(worker)
end

internal.getLinkedWorkerHealthSnapshot = getLinkedWorkerHealthSnapshot

local function hasLinkedWorkerBandageSupply(npcData)
    local bridge = getLinkedWorkerCompanionBridge()
    if not bridge or not bridge.ResolveBandageSupply or not npcData or not npcData.linkedWorkerID then
        return false
    end

    local registry = rawget(_G, "DC_Colony") and DC_Colony.Registry or nil
    local worker = registry and registry.GetWorkerRaw and registry.GetWorkerRaw(npcData.linkedWorkerID) or nil
    if not worker then
        return false
    end

    return bridge.ResolveBandageSupply(worker) ~= nil
end

internal.hasLinkedWorkerBandageSupply = hasLinkedWorkerBandageSupply

local function consumeLinkedWorkerBandageSupply(npcData)
    local bridge = getLinkedWorkerCompanionBridge()
    if not bridge or not bridge.ConsumeBandageSupply or not npcData or not npcData.linkedWorkerID then
        return nil
    end

    return bridge.ConsumeBandageSupply(npcData.linkedWorkerID)
end

internal.consumeLinkedWorkerBandageSupply = consumeLinkedWorkerBandageSupply

local function syncLinkedWorkerHealth(npcData)
    local bridge = getLinkedWorkerCompanionBridge()
    if not bridge or not bridge.SyncWorkerHealthFromNPC or not npcData or not npcData.linkedWorkerID then
        return false
    end

    return bridge.SyncWorkerHealthFromNPC(npcData.linkedWorkerID, npcData) == true
end

internal.syncLinkedWorkerHealth = syncLinkedWorkerHealth

local function handleLinkedWorkerIncapacitated(npcData)
    local bridge = getLinkedWorkerCompanionBridge()
    if not bridge or not bridge.HandleIncapacitatedNPC or not npcData or not npcData.linkedWorkerID then
        return false
    end

    return bridge.HandleIncapacitatedNPC(npcData) == true
end

internal.handleLinkedWorkerIncapacitated = handleLinkedWorkerIncapacitated
