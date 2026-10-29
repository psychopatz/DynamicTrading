-- Read-only presentation projections for authoritative market events.
-- Event definitions remain in DTCommon.MarketEvents; WorldKnowledge owns
-- published facts and Radio OS receives bounded summaries from this adapter.

DTCommon = DTCommon or {}

local Presentation = DTCommon.MarketEventPresentation or {}
DTCommon.MarketEventPresentation = Presentation

local Events = DTCommon.MarketEvents
local MAX_EVENTS = 4
local MAX_TEXT = 192
local MAX_FACT_ID = 96
local MAX_TIMESTAMP = 2147483647

Presentation.VERSION = 1
Presentation.MAX_EVENTS = MAX_EVENTS

local function number(value, fallback)
    value = tonumber(value)
    if not value or value ~= value or value == math.huge
        or value == -math.huge
    then return fallback end
    return value
end

local function bounded(value, maximum)
    value = tostring(value or "")
    maximum = tonumber(maximum) or MAX_TEXT
    return #value > maximum and string.sub(value, 1, maximum) or value
end

local function hash(value)
    local result = 17
    for index = 1, #value do
        result = (result * 31 + string.byte(value, index)) % MAX_TIMESTAMP
    end
    return tostring(result)
end

function Presentation.FactID(eventID, settlementID)
    return "dt-market-event:" .. hash(
        bounded(eventID, MAX_FACT_ID) .. "|" .. bounded(settlementID, MAX_FACT_ID)
    )
end

local function eventSummary(event, context)
    local presentation = type(event.presentation) == "table"
        and event.presentation or {}
    local scope = type(event.scope) == "table" and event.scope or {}
    local settlementID = context and context.settlementID or "world"
    return {
        factID = Presentation.FactID(event.eventID, settlementID),
        eventID = bounded(event.eventID, MAX_TEXT),
        eventType = bounded(event.type, 64),
        scope = {
            kind = bounded(scope.kind, 32),
            id = scope.id and bounded(scope.id, MAX_TEXT) or nil,
        },
        settlementID = settlementID,
        regionID = context and context.regionID or nil,
        factionID = context and context.factionID or nil,
        startsAt = number(event.startsAt, 0),
        endsAt = event.endsAt ~= nil
            and number(event.endsAt, nil) or nil,
        headlineKey = bounded(presentation.headlineKey, MAX_TEXT),
        descriptionKey = bounded(presentation.descriptionKey, MAX_TEXT),
        importance = math.max(0, math.floor(number(
            presentation.importance, 0))),
        active = true,
    }
end

function Presentation.Summary(settlementID, record, options)
    local active
    local context
    local reason
    local output = {
        version = Presentation.VERSION,
        settlementID = bounded(settlementID, MAX_TEXT),
        events = {},
        activeEventCount = 0,
        available = false,
    }
    if not Events or type(Events.ListActive) ~= "function" then
        return output, "market_event_registry_unavailable"
    end
    active, context = Events.ListActive(settlementID, record, options)
    if type(context) ~= "table" then
        return output, context or "market_event_context_unavailable"
    end
    output.settlementID = context.settlementID
    output.regionID = context.regionID
    output.factionID = context.factionID
    output.revision = context.revision
    output.storeRevision = context.storeRevision
    output.now = context.now
    output.available = true
    for index = 1, math.min(#(active or {}), MAX_EVENTS) do
        output.events[#output.events + 1] = eventSummary(
            active[index], context)
    end
    output.activeEventCount = #output.events
    output.noNews = output.activeEventCount == 0
    return output
end

function Presentation.FactSpecification(summary)
    summary = type(summary) == "table" and summary or {}
    local settlementID = bounded(summary.settlementID, MAX_TEXT)
    settlementID = settlementID ~= "" and settlementID or "world"
    if bounded(summary.eventID, MAX_TEXT) == "" then
        return nil, "market_event_identity_required"
    end
    return {
        factID = summary.factID or Presentation.FactID(
            summary.eventID, settlementID),
        kind = "market.event",
        producer = "dynamictrading:market-events",
        eventID = summary.eventID,
        subject = { id = settlementID, kind = "settlement" },
        location = { id = settlementID, kind = "settlement" },
        occurredAt = number(summary.startsAt, 0),
        observedAt = number(summary.now, summary.startsAt or 0),
        expiresAt = summary.endsAt,
        retention = "derived_current",
        provenance = "public",
        confidence = 1,
        shareable = true,
        payload = {
            eventID = summary.eventID,
            eventType = summary.eventType,
            scopeKind = summary.scope and summary.scope.kind or nil,
            scopeID = summary.scope and summary.scope.id or nil,
            settlementID = settlementID,
            startsAt = summary.startsAt,
            endsAt = summary.endsAt,
            headlineKey = summary.headlineKey,
            descriptionKey = summary.descriptionKey,
            importance = summary.importance,
        },
    }
end

return Presentation
