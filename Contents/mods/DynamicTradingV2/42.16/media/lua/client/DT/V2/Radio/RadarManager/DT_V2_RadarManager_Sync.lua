-- ==============================================================================
-- DT_V2_RadarManager_Sync.lua
-- Network sync and metadata hydration for the radar manager.
-- ==============================================================================

local RadarManager = DT_V2_RadarManager

function RadarManager.RequestRoster()
    if isServer() then
        return
    end

    DynamicTrading.Log("DTV2", "Radio", "Sync", "Requesting fresh Roster from Server...")
    sendClientCommand(getSpecificPlayer(0), "DynamicTrading_V2", "RequestRoster", {})
end

function RadarManager.HandleServerCommand(module, command, arguments)
    if module == "DynamicTrading_V2" and command == "SyncRoster" then
        DynamicTrading.Log("DTV2", "Radio", "Sync", "Received Roster & Faction Sync from Server.")
        RadarManager.ClientRoster = arguments.roster
        RadarManager.ClientFactions = arguments.factions
    end
end

function RadarManager.CacheMetadata(uuid, soul)
    if not uuid or not soul then
        return
    end

    if DTNPCClient and DTNPCClient.CacheMetadata then
        DTNPCClient.CacheMetadata(uuid, {
            uuid = uuid,
            name = soul.name,
            factionID = soul.factionID,
            archetypeID = soul.archetypeID,
            isFemale = soul.isFemale,
            identitySeed = soul.identitySeed,
            status = soul.status,
            state = soul.state,
            returnTime = soul.returnTime,
            lastX = soul.lastX,
            lastY = soul.lastY,
            lastZ = soul.lastZ
        })
    end
end

function RadarManager.OnMetadataReceived(uuid, meta)
    if not uuid or not meta then
        return
    end

    RadarManager.ClientRoster = RadarManager.ClientRoster or { Souls = {} }
    RadarManager.ClientRoster.Souls = RadarManager.ClientRoster.Souls or {}

    local soul = RadarManager.ClientRoster.Souls[uuid] or {}
    if meta.name ~= nil then soul.name = meta.name end
    if meta.factionID ~= nil then soul.factionID = meta.factionID end
    if meta.archetypeID ~= nil then soul.archetypeID = meta.archetypeID end
    if meta.isFemale ~= nil then soul.isFemale = meta.isFemale end
    if meta.identitySeed ~= nil then soul.identitySeed = meta.identitySeed end
    if meta.status ~= nil then soul.status = meta.status end
    if meta.state ~= nil then soul.state = meta.state end
    if meta.returnTime ~= nil then soul.returnTime = meta.returnTime end
    if meta.lastX ~= nil then soul.lastX = meta.lastX end
    if meta.lastY ~= nil then soul.lastY = meta.lastY end
    if meta.lastZ ~= nil then soul.lastZ = meta.lastZ end
    soul.status = soul.status or "Unknown"
    soul.lastZ = soul.lastZ or 0

    RadarManager.ClientRoster.Souls[uuid] = soul
    RadarManager.CacheMetadata(uuid, soul)
end
