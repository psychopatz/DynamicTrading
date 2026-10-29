-- Thin DynamicTrading adapter over PsychopatzCore's reusable World Knowledge
-- mechanism. DTCommon owns traderID binding and persistence placement; Core
-- owns the ledger, actor references, provenance, ranking, and propagation.
-- This module never reads or mutates stock, budgets, quotes, sessions, or
-- player inventory while building conversational knowledge.
DTCommon = DTCommon or {}

local Adapter = DTCommon.WorldKnowledge or {}
DTCommon.WorldKnowledge = Adapter

local loaded, Core = pcall(require,
    "PsychopatzCore/WorldKnowledge/PsychopatzWorldKnowledge")
if not loaded or type(Core) ~= "table" then Core = nil end

local TraderService = DTCommon.TraderService
local Policy = DTCommon.CoreActorPolicy
local Storage = DTCommon.Storage
local EventPresentation = DTCommon.MarketEventPresentation
local MAX_CONTEXT = 4
local MAX_TRACE = 64
local MAX_TEXT = 240

Adapter.VERSION = 1
Adapter.MODDATA_FIELD = "worldKnowledge"
Adapter.Trace = Adapter.Trace or {}

local function text(value, fallback, maximum)
    if value == nil then return fallback end
    value = tostring(value)
    if value == "" then return fallback end
    maximum = tonumber(maximum) or MAX_TEXT
    return #value > maximum and string.sub(value, 1, maximum) or value
end

local function copy(value, depth)
    local output
    depth = depth or 0
    if type(value) ~= "table" or depth >= 3 then return value end
    output = {}
    for key, item in pairs(value) do
        output[key] = copy(item, depth + 1)
    end
    return output
end

local function recordFor(value)
    if type(value) == "table" then return value end
    if not TraderService or type(TraderService.GetRecord) ~= "function" then
        return nil, "trader_service_unavailable"
    end
    local id = text(value, nil, 128)
    if not id then return nil, "trader_required" end
    local record = TraderService.GetRecord(id)
    if not record then return nil, "trader_not_found" end
    return record
end

local function traderID(value, record)
    if type(value) == "string" or type(value) == "number" then
        return text(value, nil, 128)
    end
    if type(record) == "table" then
        return text(record.traderID or record.id or record.t, nil, 128)
    end
    return nil
end

local function actorID(record)
    if not Policy or type(Policy.Get) ~= "function" then
        return nil, "core_actor_policy_unavailable"
    end
    local policy = Policy.Get(record)
    local id = text(policy and (policy.actorID or policy.actorId), nil, 128)
    if not id then return nil, "core_actor_required" end
    return id
end

local function core()
    if not Core or type(Core.Context) ~= "function" then
        return nil, "core_world_knowledge_unavailable"
    end
    return Core
end

local function addTrace(entry)
    Adapter.Trace[#Adapter.Trace + 1] = copy(entry)
    while #Adapter.Trace > MAX_TRACE do table.remove(Adapter.Trace, 1) end
end

local function defaultRender(fact, reference)
    local provenance = reference and reference.provenance or "unknown"
    local payload = type(fact) == "table" and fact.payload or nil
    local route = type(payload) == "table"
        and text(payload.routeID or payload.routeId, nil, 96) or nil
    local market = type(payload) == "table"
        and text(payload.marketID or payload.marketId, nil, 96) or nil
    local subject = type(fact) == "table" and fact.subject or nil
    local subjectID = type(subject) == "table" and text(subject.id, nil, 96)
        or text(subject, nil, 96)
    local eventType = type(payload) == "table"
        and text(payload.eventType, nil, 96) or nil
    local headlineKey = type(payload) == "table"
        and text(payload.headlineKey, nil, 192) or nil
    local headline = headlineKey and DTCommon.T
        and DTCommon.T(headlineKey, headlineKey) or nil
    local label = route or market or subjectID or "the trade route"
    if type(fact) ~= "table" then return nil end
    if fact.kind ~= "market.route" and fact.kind ~= "market.availability"
        and fact.kind ~= "trader.route" and fact.kind ~= "market.event"
    then
        return nil
    end
    if fact.kind == "market.event" then
        return "I heard about " .. tostring(headline or eventType
            or "a market event") .. " at " .. tostring(label) .. "."
    end
    if provenance == "told" or provenance == "radio" then
        return "I heard that " .. label .. " is active."
    end
    return "I can confirm that " .. label .. " is active."
end

function Adapter.Reset(options)
    Adapter.Trace = {}
    if not Core or type(Core.Reset) ~= "function" then
        return nil, "core_world_knowledge_unavailable"
    end
    return Core.Reset(options)
end

function Adapter.Publish(specification, options)
    local world = core()
    if not world then return nil, "core_world_knowledge_unavailable" end
    specification = copy(type(specification) == "table" and specification or {})
    specification.producer = specification.producer or "dynamictrading"
    return world.Publish(specification, options)
end

-- Publish active authoritative market events into the existing Core ledger
-- and acquire them for one trader on demand. This deliberately avoids an
-- event-start loop over every trader; Talk requests hydrate only the actor
-- that is actually being presented. Stock, budget, and quote state are not
-- touched by this projection.
function Adapter.SyncMarketEvents(trader, options)
    local world = core()
    local record
    local reason
    local actor
    local policy
    local settlementID
    local summary
    local synced = {}
    local failures = {}
    options = copy(type(options) == "table" and options or {})
    if not world then return nil, "core_world_knowledge_unavailable" end
    if not EventPresentation
        or type(EventPresentation.Summary) ~= "function"
        or type(EventPresentation.FactSpecification) ~= "function"
    then return nil, "market_event_presentation_unavailable" end
    if Storage and type(Storage.IsAuthority) == "function"
        and Storage.IsAuthority() ~= true
    then return nil, "server_authority_required" end
    record, reason = recordFor(trader)
    if not record then return nil, reason end
    actor, reason = actorID(record)
    if not actor then return nil, reason end
    policy = Policy and type(Policy.Get) == "function"
        and Policy.Get(record) or {}
    settlementID = options.settlementID or policy.currentSettlementID
        or policy.lastSettlementID or policy.homeSettlementID
    summary, reason = EventPresentation.Summary(
        settlementID, record, options)
    if not summary then return nil, reason end
    for index = 1, #(summary.events or {}) do
        local event = summary.events[index]
        local specification
        local fact
        local reference
        local factReason
        specification, factReason = EventPresentation.FactSpecification(event)
        if specification then
            fact, factReason = world.Publish(specification, {
                now = summary.now,
            })
        end
        if fact then
            reference, factReason = world.Acquire(actor, fact.factID, {
                authorized = true,
                provenance = "public",
                source = "dynamictrading:market-events",
                acquisitionPath = "market-events",
                confidence = 1,
                learnedAt = summary.now,
            })
        end
        if reference then
            synced[#synced + 1] = {
                factID = fact.factID,
                eventID = event.eventID,
            }
        else
            failures[#failures + 1] = {
                eventID = event.eventID,
                reason = factReason or "market_event_fact_failed",
            }
        end
    end
    return {
        settlementID = summary.settlementID,
        revision = summary.revision,
        now = summary.now,
        activeEventCount = summary.activeEventCount,
        noNews = summary.activeEventCount == 0,
        facts = synced,
        failures = failures,
    }
end

function Adapter.Acquire(trader, factID, specification)
    local world = core()
    local record, reason = recordFor(trader)
    local id
    if not world then return nil, "core_world_knowledge_unavailable" end
    if not record then return nil, reason end
    id, reason = actorID(record)
    if not id then return nil, reason end
    specification = copy(type(specification) == "table" and specification or {})
    if specification.authorized ~= true then
        return nil, "knowledge_authorization_required"
    end
    return world.Acquire(id, factID, specification)
end

function Adapter.BuildConversationContext(trader, options)
    local world = core()
    local record, reason = recordFor(trader)
    local id
    local result
    if not world then return nil, "core_world_knowledge_unavailable" end
    if not record then return nil, reason end
    id, reason = actorID(record)
    if not id then return nil, reason end
    options = copy(type(options) == "table" and options or {})
    Adapter.SyncMarketEvents(trader, options)
    options.max = math.max(1, math.min(MAX_CONTEXT,
        math.floor(tonumber(options.max) or MAX_CONTEXT)))
    if type(options.renderFact) ~= "function" then
        options.renderFact = defaultRender
    end
    result = world.Context(id, options)
    result.traderID = traderID(trader, record)
    result.actorID = id
    return result
end

function Adapter.Explain(trader, factID, now)
    local world = core()
    local record, reason = recordFor(trader)
    local id
    local explanation
    local fact
    if not world then return nil, "core_world_knowledge_unavailable" end
    if not record then return nil, reason end
    id, reason = actorID(record)
    if not id then return nil, reason end
    explanation, reason = world.Explain(id, factID, now)
    if not explanation then return nil, reason end
    if world.Ledger and type(world.Ledger.Get) == "function" then
        fact = world.Ledger.Get(world.LedgerState, factID)
    end
    if fact then
        explanation.subject = copy(fact.subject)
        explanation.location = copy(fact.location)
        explanation.expiresAt = fact.expiresAt
        explanation.payload = copy(fact.payload)
    end
    return explanation
end

function Adapter.Propagate(fromTrader, toTrader, options)
    local world = core()
    local source, reason = recordFor(fromTrader)
    local target
    local fromID
    local toID
    if not world then return nil, "core_world_knowledge_unavailable" end
    if not source then return nil, reason end
    target, reason = recordFor(toTrader)
    if not target then return nil, reason end
    fromID, reason = actorID(source)
    if not fromID then return nil, reason end
    toID, reason = actorID(target)
    if not toID then return nil, reason end
    options = copy(type(options) == "table" and options or {})
    if options.authorized ~= true then
        addTrace({ accepted = false, reason = "propagation_authorization_required",
            fromTraderID = traderID(fromTrader, source),
            toTraderID = traderID(toTrader, target), })
        return nil, "propagation_authorization_required"
    end
    if options.channel ~= "conversation" and options.channel ~= "radio" then
        addTrace({ accepted = false, reason = "propagation_channel_invalid",
            fromTraderID = traderID(fromTrader, source),
            toTraderID = traderID(toTrader, target), })
        return nil, "propagation_channel_invalid"
    end
    options.max = math.max(1, math.min(3, math.floor(
        tonumber(options.max) or 3)))
    options.source = options.source or ("dynamictrading:" .. options.channel)
    options.acquisitionPath = options.acquisitionPath or options.channel
    options.provenance = options.provenance
        or (options.channel == "radio" and "radio" or "told")
    local transferred, shareReason = world.Share(fromID, toID, options)
    addTrace({ accepted = transferred ~= nil, reason = shareReason,
        fromTraderID = traderID(fromTrader, source),
        toTraderID = traderID(toTrader, target),
        fromActorID = fromID, toActorID = toID,
        factIDs = transferred and copy(transferred) or {}, })
    return transferred, shareReason
end

function Adapter.Save(options)
    local world = core()
    local data
    if not world then return nil, "core_world_knowledge_unavailable" end
    if Storage and type(Storage.IsAuthority) == "function"
        and Storage.IsAuthority() ~= true
    then return nil, "server_authority_required" end
    if not Storage or type(Storage.GetData) ~= "function" then
        return nil, "storage_unavailable"
    end
    data = Storage.GetData()
    data[Adapter.MODDATA_FIELD] = world.ToPayload(options)
    if type(Storage.Touch) == "function" then Storage.Touch() end
    if type(Storage.Transmit) == "function" then Storage.Transmit() end
    return data[Adapter.MODDATA_FIELD]
end

function Adapter.Load(options)
    local world = core()
    local data
    local payload
    if not world then return nil, "core_world_knowledge_unavailable" end
    if not Storage or type(Storage.GetData) ~= "function" then
        return nil, "storage_unavailable"
    end
    data = Storage.GetData()
    payload = data[Adapter.MODDATA_FIELD]
    if type(payload) ~= "table" then return false, "world_knowledge_empty" end
    return world.FromPayload(payload, options)
end

if Events and Events.OnSave and type(Events.OnSave.Add) == "function"
    and not Adapter._saveHooked
then
    Adapter._saveHooked = true
    Events.OnSave.Add(function() Adapter.Save() end)
end

return Adapter
