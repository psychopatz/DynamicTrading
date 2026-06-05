DT_ColonyResidents = DT_ColonyResidents or {}

local Residents = DT_ColonyResidents

local function isNonEmptyString(value)
    return type(value) == "string" and value ~= ""
end

function Residents.IsResidentSoul(soulLike)
    if type(soulLike) ~= "table" then
        return false
    end

    return soulLike.dcResident == true
        or soulLike.dcResidentWorkerID ~= nil
        or isNonEmptyString(soulLike.dcResidentColonyId)
        or soulLike.linkedWorkerID ~= nil
end

function Residents.NormalizeSoulFlags(soulLike)
    if type(soulLike) ~= "table" then
        return soulLike
    end

    local isResident = Residents.IsResidentSoul(soulLike)
    soulLike.dcResident = isResident == true
    if not isResident then
        return soulLike
    end

    local colonyId = soulLike.dcResidentColonyId
    if colonyId == nil then
        if soulLike.colonyID ~= nil then
            colonyId = soulLike.colonyID
        elseif soulLike.colonyId ~= nil then
            colonyId = soulLike.colonyId
        else
            colonyId = ""
        end
    end

    soulLike.abstractResident = false
    soulLike.dcResidentOwnerUsername = tostring(soulLike.dcResidentOwnerUsername or soulLike.ownerUsername or "")
    soulLike.dcResidentColonyId = tostring(colonyId)
    soulLike.dcResidentRole = tostring(soulLike.dcResidentRole or "worker")
    soulLike.dcResidentHomeMode = tostring(soulLike.dcResidentHomeMode or "base")
    if soulLike.dcResidentWorkerID ~= nil then
        soulLike.dcResidentWorkerID = tostring(soulLike.dcResidentWorkerID)
    elseif soulLike.linkedWorkerID ~= nil then
        soulLike.dcResidentWorkerID = tostring(soulLike.linkedWorkerID)
    end

    return soulLike
end

return Residents
