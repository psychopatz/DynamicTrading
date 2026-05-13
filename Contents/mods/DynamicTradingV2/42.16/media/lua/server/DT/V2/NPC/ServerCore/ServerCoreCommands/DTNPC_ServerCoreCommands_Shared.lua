-- ==============================================================================
-- DTNPC_ServerCoreCommands_Shared.lua
-- Shared helpers for DTNPC server command modules.
-- ==============================================================================

DTNPCServerCore = DTNPCServerCore or {}
DTNPCServerCoreCommands = DTNPCServerCoreCommands or {}
DTNPCServerCoreCommands.Internal = DTNPCServerCoreCommands.Internal or {}
DTNPCServerCoreCommands.Handlers = DTNPCServerCoreCommands.Handlers or {}

if isClient() and not isServer() then return end

local Internal = DTNPCServerCoreCommands.Internal

function Internal.CountTable(t)
    local count = 0
    for _ in pairs(t or {}) do
        count = count + 1
    end
    return count
end

function Internal.Lower(value)
    return string.lower(tostring(value or ""))
end

function Internal.SendCompanionNotice(player, reason)
    local payload = {
        message = reason or "You cannot command this companion.",
        severity = "error",
        popup = true
    }

    if DynamicTrading and DynamicTrading.ServerHelpers and DynamicTrading.ServerHelpers.SendResponse then
        DynamicTrading.ServerHelpers.SendResponse(player, "DColony", "ColonyNotice", payload)
        return
    end

    if DTNPCServerCore and DTNPCServerCore.SanitizeNetworkData then
        payload = DTNPCServerCore.SanitizeNetworkData(payload)
    end
    sendServerCommand(player, "DColony", "ColonyNotice", payload)
end

function Internal.CanPlayerCommandCompanion(player, npcData, systemCompanionOrder)
    local isCompanion = npcData
        and tostring(npcData.dcCompanionJob or "") == "TravelCompanion"
        and tostring(npcData.linkedWorkerID or "") ~= ""

    if not isCompanion or systemCompanionOrder then
        return true, nil
    end

    local companion = DC_Colony and DC_Colony.Companion or nil
    local canCommand, reason = false, "Companion command authority is unavailable."
    if companion and companion.CanPlayerCommandCompanion then
        canCommand, reason = companion.CanPlayerCommandCompanion(player, npcData)
    end

    return canCommand, reason
end

function Internal.ResolveFactionName(factionID)
    if not factionID then
        return "Independent"
    end

    local factions = ModData.get("DynamicTrading_Factions")
    if factions and factions.Factions and factions.Factions[factionID] then
        local faction = factions.Factions[factionID]
        return faction.name or faction.displayName or factionID
    end

    return factionID
end

function Internal.IsOwnedTravelCompanionForPlayer(player, npcData)
    if not player or not npcData then
        return false
    end

    local isCompanion = tostring(npcData.dcCompanionJob or "") == "TravelCompanion"
        or tostring(npcData.linkedWorkerID or "") ~= ""
    if not isCompanion then
        return false
    end

    local playerID = player.getOnlineID and player:getOnlineID() or nil
    if playerID ~= nil and npcData.masterID ~= nil and tonumber(npcData.masterID) == tonumber(playerID) then
        return true
    end

    local username = player.getUsername and player:getUsername() or nil
    if not username or username == "" then
        return false
    end

    return (npcData.master and tostring(npcData.master) == username)
        or (npcData.ownerUsername and tostring(npcData.ownerUsername) == username)
        or (npcData.dcCompanionOwner and tostring(npcData.dcCompanionOwner) == username)
end

function Internal.BuildMetadataEntry(uuid, soul, npcData, player)
    local isCallableCompanion = Internal.IsOwnedTravelCompanionForPlayer(player, npcData)
    return {
        uuid = uuid,
        name = soul.name,
        archetypeID = soul.archetypeID or "General",
        factionID = soul.factionID or "Independent",
        factionName = Internal.ResolveFactionName(soul.factionID),
        isFemale = soul.isFemale,
        identitySeed = soul.identitySeed or 1,
        status = soul.status or "Unknown",
        state = soul.state,
        returnTime = soul.returnTime,
        lastX = soul.lastX or (soul.homeCoords and soul.homeCoords.x),
        lastY = soul.lastY or (soul.homeCoords and soul.homeCoords.y),
        lastZ = soul.lastZ or (soul.homeCoords and soul.homeCoords.z) or 0,
        radarCategory = isCallableCompanion and "Callable" or nil,
        isCallableCompanion = isCallableCompanion,
    }
end
