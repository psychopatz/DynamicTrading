-- ==============================================================================
-- DT_V2_RadarManager_Coords.lua
-- Coordinate lookup logic for discovered traders.
-- ==============================================================================

local RadarManager = DT_V2_RadarManager

function RadarManager.GetTraderCoords(uuid)
    local zombie = DTNPCClient and DTNPCClient.FindZombieByUUID and DTNPCClient.FindZombieByUUID(uuid) or nil
    if zombie then
        return zombie:getX(), zombie:getY(), zombie:getZ(), true
    end

    local rosterData = RadarManager.GetRosterData()
    if rosterData and rosterData.Souls and rosterData.Souls[uuid] then
        local soul = rosterData.Souls[uuid]
        local x = soul.lastX or (soul.homeCoords and soul.homeCoords.x)
        local y = soul.lastY or (soul.homeCoords and soul.homeCoords.y)
        local z = soul.lastZ or (soul.homeCoords and soul.homeCoords.z) or 0
        return x, y, z, false
    end

    return nil, nil, nil, false
end
