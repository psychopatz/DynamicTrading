-- Read-only client view of DynamicTrading commercial trader bindings.
--
-- Canonical actor/world presentation is owned by PsychopatzCore SurvivorWorld.
-- This module intentionally exposes only trader records and commercial provider
-- metadata for adopter UI surfaces.

DTCommon = DTCommon or {}
DTCommon.TraderPresentation = DTCommon.TraderPresentation or {}

local Presentation = DTCommon.TraderPresentation

Presentation.RECORD_CACHE_SECONDS = 2
Presentation.RecordCache = Presentation.RecordCache or {
    at = -1,
    revision = -1,
    rows = {},
}

local function wallSeconds()
    if getTimeInMillis then
        local value = tonumber(getTimeInMillis())
        if value then return value / 1000 end
    end
    return 0
end

local function commercialRevision()
    local storage = DTCommon and DTCommon.Storage or nil
    if not storage or type(storage.GetData) ~= "function" then
        return -1
    end
    local ok, data = pcall(storage.GetData)
    if not ok or type(data) ~= "table" then return -1 end
    return math.max(0, math.floor(tonumber(data.r) or 0))
end

function Presentation.InvalidateRecordCache()
    Presentation.RecordCache.at = -1
    Presentation.RecordCache.revision = -1
    Presentation.RecordCache.rows = {}
end

function Presentation.ListTraderRecords(force, now)
    local cache = Presentation.RecordCache
    now = tonumber(now) or wallSeconds()
    local revision = commercialRevision()
    local expired = cache.at < 0
        or (now > 0
            and (now - cache.at)
                >= Presentation.RECORD_CACHE_SECONDS)

    if force == true
        or revision ~= cache.revision
        or expired
    then
        local rows = {}
        local service = DTCommon and DTCommon.TraderService or nil
        if service and type(service.ForEach) == "function" then
            service.ForEach(function(traderID, record)
                local ca = record and record.ca or nil
                local actorID = ca
                    and (ca.actorID)
                    or nil
                if actorID then
                    rows[#rows + 1] = {
                        traderID = traderID,
                        record = record,
                        actorID = actorID,
                        provider = ca.provider,
                    }
                end
            end)
        end
        table.sort(rows, function(left, right)
            return tostring(left.traderID)
                < tostring(right.traderID)
        end)
        cache.rows = rows
        cache.at = now
        cache.revision = revision
    end
    return cache.rows
end

return Presentation
