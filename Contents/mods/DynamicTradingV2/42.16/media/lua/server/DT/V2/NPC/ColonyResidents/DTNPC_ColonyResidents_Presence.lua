DTNPC_ColonyResidents = DTNPC_ColonyResidents or {}

local Residents = DTNPC_ColonyResidents

local function getResidentUUID(workerOrUUID)
    if type(workerOrUUID) == "string" and workerOrUUID ~= "" then
        return workerOrUUID
    end

    if type(workerOrUUID) ~= "table" then
        return nil
    end

    if workerOrUUID.uuid and tostring(workerOrUUID.uuid) ~= "" then
        return tostring(workerOrUUID.uuid)
    end

    local companionData = workerOrUUID.companion
    if type(companionData) == "table" and companionData.uuid and tostring(companionData.uuid) ~= "" then
        return tostring(companionData.uuid)
    end

    if workerOrUUID.residentSoulUUID and tostring(workerOrUUID.residentSoulUUID) ~= "" then
        return tostring(workerOrUUID.residentSoulUUID)
    end

    return nil
end

function Residents.IsLiveResidentAtHome(workerOrUUID, homeCoords, radius)
    if not DTNPCServerCore or not DTNPCServerCore.FindZombieByUUID then
        return false
    end

    local uuid = getResidentUUID(workerOrUUID)
    if not uuid or type(homeCoords) ~= "table" then
        return false
    end

    local zombie = DTNPCServerCore.FindZombieByUUID(uuid)
    if not zombie then
        return false
    end

    local maxRadius = math.max(1, tonumber(radius) or 8)
    local dx = (tonumber(zombie:getX()) or 0) - (tonumber(homeCoords.x) or 0)
    local dy = (tonumber(zombie:getY()) or 0) - (tonumber(homeCoords.y) or 0)
    local dz = math.abs((tonumber(zombie:getZ()) or 0) - (tonumber(homeCoords.z) or 0))
    if dz > 1 then
        return false
    end

    return (dx * dx) + (dy * dy) <= (maxRadius * maxRadius)
end

return Residents
