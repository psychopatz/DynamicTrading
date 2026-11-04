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

local function listTraderRecords(force, now)
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
                        providerState = ca.providerState,
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

if type(Presentation.ListTraderRecords) ~= "function" then
    Presentation.ListTraderRecords = listTraderRecords
end

local CoreClient
local function coreClient()
    if CoreClient == false then return nil end
    if CoreClient then return CoreClient end
    local ok, value = pcall(
        require,
        "PsychopatzCore/World/SurvivorWorld/PsychopatzSurvivorWorldClient"
    )
    if not ok or type(value) ~= "table" then
        CoreClient = false
        return nil
    end
    CoreClient = value
    return CoreClient
end
local FactionPresentation
do
    local ok, value = pcall(
        require,
        "PsychopatzCore/Actors/PsychopatzActorFactionPresentation"
    )
    if ok then FactionPresentation = value end
end

local TRADER_COLOR = {
    r = 0.95, g = 0.75, b = 0.15, a = 1,
}

local function actorIndex()
    local output = {}
    local client = coreClient()
    local entries = client and client.ListActors
        and client.ListActors(false) or {}
    for _, entry in ipairs(entries) do
        if entry and entry.actorID then
            output[tostring(entry.actorID)] = entry
        end
    end
    return output
end

local function factionFor(entry, ca)
    local source = entry and entry.factionPresentation
    if type(source) == "table" then return source end
    if FactionPresentation and FactionPresentation.Build then
        return FactionPresentation.Build({
            factionID = entry and entry.factionID
                or ca and ca.factionID,
            factionName = entry and entry.factionName
                or ca and ca.factionName,
            factionArchetypeID = entry and entry.factionArchetypeID
                or ca and ca.factionArchetypeID,
            factionPresentation = ca and ca.factionPresentation,
        })
    end
    return nil
end

local function commercialLabel(traderID, record, ca, journey)
    local label = tostring(record and record.n or traderID)
    local active = journey and (
        journey.state == "en_route"
            or journey.state == "planned"
            or journey.state == "waiting"
    )
    local directory = DTCommon.SettlementDirectory
    if active and ca and ca.destinationSettlementID then
        local destination = directory
            and directory.Get
            and directory.Get(ca.destinationSettlementID)
            or nil
        label = label .. " -> " .. tostring(
            destination and destination.name
                or ca.destinationSettlementID
        )
    elseif ca and ca.currentSettlementID then
        local current = directory
            and directory.Get
            and directory.Get(ca.currentSettlementID)
            or nil
        label = label .. " [" .. tostring(
            current and current.name or ca.currentSettlementID
        ) .. "]"
    end
    return label
end

function Presentation.ListTraderViews(force, now)
    local actors = actorIndex()
    local output = {}
    for _, row in ipairs(Presentation.ListTraderRecords(force, now)) do
        local record = row.record or {}
        local ca = record.ca or {}
        local boundActorID = row.actorID or ca.actorID
        local actor = actors[tostring(boundActorID or "")]
        local client = coreClient()
        if not actor and client and client.GetActor and boundActorID then
            actor = client.GetActor(boundActorID)
        end
        local faction = factionFor(actor, ca)
        if actor then
            output[#output + 1] = {
                traderID = tostring(row.traderID),
                actorID = tostring(boundActorID),
                provider = row.provider or ca.provider,
                providerState = row.providerState or ca.providerState
                    or actor.providerState,
                name = tostring(record.n or actor.label or row.traderID),
                label = commercialLabel(
                    row.traderID,
                    record,
                    ca,
                    actor.journey
                ),
                record = record,
                commercial = ca,
                actor = actor,
                position = actor.position,
                canonicalPosition = actor.canonicalPosition
                    or actor.position,
                journey = actor.journey,
                route = actor.journey and actor.journey.route or nil,
                portrait = actor.portrait,
                portraitSpec = coreClient()
                    and coreClient().GetPortraitSpec
                    and coreClient().GetPortraitSpec(actor)
                    or nil,
                factionID = actor.factionID or ca.factionID,
                factionName = actor.factionName or ca.factionName,
                factionPresentation = faction,
                communityID = actor.communityID or ca.communityID,
                role = actor.role or ca.role,
                seen = ca.seen == true or record.seen == true,
                talkAvailable = ca.talkAvailable ~= false,
                tradeAvailable = ca.tradeAvailable ~= false,
                debug = {
                    bodyID = actor.bodyID,
                    sourceID = actor.sourceID,
                    provider = row.provider or ca.provider,
                    providerState = row.providerState
                        or ca.providerState or actor.providerState,
                },
            }
        end
    end
    table.sort(output, function(left, right)
        return left.traderID < right.traderID
    end)
    return output
end

function Presentation.GetTraderView(traderID, force, now)
    traderID = tostring(traderID or "")
    for _, row in ipairs(Presentation.ListTraderViews(force, now)) do
        if row.traderID == traderID then return row end
    end
    return nil, "trader_not_found"
end

local function decorateTrader(entry, style)
    local actorID = tostring(entry and entry.actorID or "")
    local view
    for _, row in ipairs(Presentation.ListTraderViews(false)) do
        if row.actorID == actorID then
            view = row
            break
        end
    end
    if not view then return style end
    style.label = view.label
    style.color = TRADER_COLOR
    style.size = math.max(10, tonumber(style.size) or 10)
    style.icon = {
        id = "dynamictrading.trader",
        glyph = "T",
        r = 1,
        g = 0.85,
        b = 0.2,
        a = 1,
    }
    local faction = view.factionPresentation
    if type(faction) == "table" then
        local badge = faction.badge or faction
        style.badge = {
            factionID = faction.factionID or view.factionID,
            glyph = badge.glyph or faction.glyph or "F",
            r = badge.color and badge.color.r or 1,
            g = badge.color and badge.color.g or 1,
            b = badge.color and badge.color.b or 1,
            a = badge.color and badge.color.a or 1,
        }
    end
    style.subtitle = tostring(view.provider or "DynamicTrading")
    style.hoverMetadata = {
        traderID = view.traderID,
        factionID = view.factionID,
        communityID = view.communityID,
    }
    return style
end

local actorMapOK, ActorMap = pcall(
    require,
    "PsychopatzCore/World/SurvivorWorld/PsychopatzSurvivorWorldActorMap"
)
if actorMapOK and ActorMap
    and type(ActorMap.RegisterDecorator) == "function"
then
    ActorMap.RegisterDecorator("DynamicTrading:Trader", {
        priority = 100,
        decorate = decorateTrader,
    })
end

return Presentation
