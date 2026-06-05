DTNPCCorpseCleanup = DTNPCCorpseCleanup or {}
DTNPCCorpseCleanup.Internal = DTNPCCorpseCleanup.Internal or {}

local Cleanup = DTNPCCorpseCleanup
local Internal = Cleanup.Internal

local function buildCorpseInfo(corpse, entry)
    local modData = Internal.getCorpseModData(corpse)
    return {
        token = tostring(modData and modData.DTCorpseCleanupToken or entry and entry.token or ""),
        uuid = tostring(modData and modData.DTNPC_UUID or ""),
        name = tostring(modData and modData.DTNPC_Name or ""),
        x = Internal.floorNumber(entry and entry.x) or Internal.floorNumber(corpse and corpse.getX and corpse:getX()) or 0,
        y = Internal.floorNumber(entry and entry.y) or Internal.floorNumber(corpse and corpse.getY and corpse:getY()) or 0,
        z = Internal.floorNumber(entry and entry.z) or Internal.floorNumber(corpse and corpse.getZ and corpse:getZ()) or 0,
        removedAtHour = Internal.worldHour(),
    }
end

function Cleanup.ClassifyCorpse(npcData, corpse, entry)
    local corpseInfo = buildCorpseInfo(corpse, entry)
    local corpseClass = "ordinary"

    local bodyUUID = tostring(corpseInfo.uuid or "")
    if bodyUUID ~= "" and DTNPCServerCore and DTNPCServerCore.GetNPCDataByUUID then
        local _, deadNPCData = DTNPCServerCore.GetNPCDataByUUID(bodyUUID)
        if type(deadNPCData) == "table"
            and tostring(deadNPCData.ownerUsername or "") ~= ""
            and tostring(deadNPCData.ownerUsername or "") == tostring(npcData and npcData.ownerUsername or "")
            and deadNPCData.linkedWorkerID ~= nil then
            corpseClass = "colony_teammate"
            corpseInfo.workerID = deadNPCData.linkedWorkerID
            corpseInfo.ownerUsername = deadNPCData.ownerUsername
        end
    end

    return corpseClass, corpseInfo
end

return Cleanup
