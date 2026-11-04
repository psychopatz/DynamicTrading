-- One-way normalization of DynamicTrading records written before canonical
-- PsychopatzCore SurvivorWorld actor/provider fields became authoritative.

DTCommon = DTCommon or {}
DTCommon.PreSurvivorWorldImport =
    DTCommon.PreSurvivorWorldImport or {}

local Import = DTCommon.PreSurvivorWorldImport

local function copy(value)
    local output = {}
    for key, child in pairs(
        type(value) == "table" and value or {}
    ) do
        output[key] = child
    end
    return output
end

function Import.NormalizePolicySpec(spec)
    local source = type(spec) == "table" and spec or {}
    local output = copy(source)
    local changed = false

    if output.actorID == nil and output.actorId == nil then
        local oldActorID =
            source.coreActorID or source.coreActorId
        if oldActorID ~= nil then
            output.actorID = oldActorID
            changed = true
        end
    end
    if output.provider == nil
        and source.coreProvider ~= nil
    then
        output.provider = source.coreProvider
        changed = true
    end

    for _, key in ipairs({
        "coreActorID",
        "coreActorId",
        "coreProvider",
    }) do
        if output[key] ~= nil then
            output[key] = nil
            changed = true
        end
    end

    return output, changed
end

return Import
