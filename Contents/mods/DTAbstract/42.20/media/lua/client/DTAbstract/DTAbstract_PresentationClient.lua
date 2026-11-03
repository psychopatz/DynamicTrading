-- Read-only client view of authoritative DTAbstract actor projections.

DTAbstract = DTAbstract or {}
DTAbstract.PresentationClient = DTAbstract.PresentationClient or {}

local Presentation = DTAbstract.PresentationClient
local ProjectionClient =
    require "PsychopatzCore/Actors/PsychopatzActorProjectionClient"
local Journey = require "PsychopatzCore/Actors/PsychopatzActorJourney"

Presentation.SOURCE_ID = "DTAbstract"
Presentation.RECORD_CACHE_SECONDS = 2
Presentation.RecordCache = Presentation.RecordCache or {
    at = -1,
    revision = -1,
    rows = {},
}

function Presentation.RequestSync()
    return ProjectionClient.Request(Presentation.SOURCE_ID)
end

local function wallSeconds()
    if getTimeInMillis then
        local value = tonumber(getTimeInMillis())
        if value then return value / 1000 end
    end
    return 0
end

function Presentation.InvalidateRecordCache()
    Presentation.RecordCache.at = -1
    Presentation.RecordCache.revision = -1
    Presentation.RecordCache.rows = {}
end

function Presentation.ListTraderRecords(force, now)
    local cache = Presentation.RecordCache
    now = tonumber(now) or wallSeconds()
    local revision = ProjectionClient.GetSourceRevision
        and ProjectionClient.GetSourceRevision(Presentation.SOURCE_ID) or -1
    local expired = cache.at < 0
        or (now > 0 and (now - cache.at) >= Presentation.RECORD_CACHE_SECONDS)
    if force == true or revision ~= cache.revision or expired then
        local rows = {}
        if DTCommon and DTCommon.TraderService
            and type(DTCommon.TraderService.ForEach) == "function"
        then
            DTCommon.TraderService.ForEach(function(traderID, record)
                local ca = record and record.ca or nil
                local provider = ca and (ca.provider or ca.coreProvider) or nil
                if ca and (provider == "DTAbstract"
                    or provider == "DTHoomans")
                then
                    rows[#rows + 1] = {
                        traderID = traderID,
                        record = record,
                        provider = provider,
                    }
                end
            end)
        end
        table.sort(rows, function(left, right)
            return tostring(left.traderID) < tostring(right.traderID)
        end)
        cache.rows = rows
        cache.at = now
        cache.revision = revision
    end
    return cache.rows
end

function Presentation.GetActor(actorID)
    actorID = tostring(actorID or "")
    if actorID == "" then return nil end
    return ProjectionClient.Get(actorID)
end

function Presentation.GetForRecord(record)
    local ca = record and record.ca or nil
    if not ca then return nil end
    local actorID = ca.actorID or ca.coreActorID
    return actorID and Presentation.GetActor(actorID) or nil
end

local function worldAge()
    local time = getGameTime and getGameTime() or nil
    if time and type(time.getWorldAgeHours) == "function" then
        return math.max(0, tonumber(time:getWorldAgeHours()) or 0)
    end
    return nil
end

function Presentation.GetPosition(record, now)
    local projection = Presentation.GetForRecord(record)
    if projection and projection.journey then
        local projected = Journey.ProjectPosition(
            projection.journey,
            tonumber(now) or worldAge())
        if projected then return projected, projection end
    end
    if projection and projection.position then
        return projection.position, projection
    end

    -- A stationary trader can still be placed at its authoritative settlement
    -- while the initial projection request is in flight. Never infer a moving
    -- journey position from settlement IDs.
    local ca = record and record.ca or nil
    if ca and not ca.destinationSettlementID
        and ca.currentSettlementID
        and DTCommon and DTCommon.SettlementDirectory
    then
        return DTCommon.SettlementDirectory.ResolvePosition(
            ca.currentSettlementID), nil
    end
    return nil, projection
end

function Presentation.GetJourney(record)
    local projection = Presentation.GetForRecord(record)
    return projection and projection.journey or nil
end

return Presentation
