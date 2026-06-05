-- ==============================================================================
-- DTNPC_HealthShared_Ownership.lua
-- Ownership and linked-worker helpers for DT NPC health.
-- ==============================================================================

DTNPCHealth = DTNPCHealth or {}
DTNPCHealth.Internal = DTNPCHealth.Internal or {}

local internal = DTNPCHealth.Internal

local function isColonyOwnedCompanionNPC(npcData)
    if DTNPCRoles and DTNPCRoles.ResolveContext then
        local ok, context = pcall(DTNPCRoles.ResolveContext, npcData)
        if ok and type(context) == "table" then
            return context.isColonyOwned == true
        end
    end

    return type(npcData) == "table" and tostring(npcData.linkedWorkerID or "") ~= ""
end

internal.isColonyOwnedCompanionNPC = isColonyOwnedCompanionNPC

local function isPlayerOwnedNPC(npcData)
    if DTNPCRoles and DTNPCRoles.ResolveContext then
        local ok, context = pcall(DTNPCRoles.ResolveContext, npcData)
        if ok and type(context) == "table" then
            return context.isPlayerOwned == true
        end
    end

    return isColonyOwnedCompanionNPC(npcData)
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
