-- Resolves bounded settlement and event context for commercial quotes.
-- MarketSense remains the intrinsic valuation and taxonomy authority; this
-- module only supplies DynamicTrading-owned pressure and event factors.

DTCommon = DTCommon or {}

local Pricing = DTCommon.MarketPricing or {}
DTCommon.MarketPricing = Pricing

local Catalog = DTCommon.MarketCatalog
local Market = DTCommon.SettlementMarket
local Policy = DTCommon.CoreActorPolicy
local Schema = DTCommon.MarketSchema

Pricing.VERSION = 1
Pricing.MARKET_PRESSURE_SCALE = 0.25
Pricing.MAX_MARKET_MODIFIER = 0.25
Pricing.MAX_EVENT_PRICE_MULTIPLIER = 4
Pricing.MAX_ITEM_CACHE = 256
Pricing.MAX_EVENT_MODIFIERS = Schema and Schema.MAX_MODIFIERS or 16
Pricing.MAX_CATEGORIES = Schema and Schema.MAX_CATEGORIES or 32

local function number(value, fallback)
    value = tonumber(value)
    if not value or value ~= value or value == math.huge
        or value == -math.huge
    then return fallback end
    return value
end

local function integer(value, fallback)
    return math.floor(number(value, fallback))
end

local function clamp(value, low, high, fallback)
    value = number(value, fallback)
    return math.max(low, math.min(high, value))
end

local function text(value, maximum)
    value = tostring(value or "")
    if value == "" then return nil end
    if #value > maximum then return string.sub(value, 1, maximum) end
    return value
end

local function sortedKeys(value)
    local keys = {}
    for key, _ in pairs(value or {}) do
        if type(key) == "string" and key ~= "" then
            keys[#keys + 1] = key
        end
    end
    table.sort(keys)
    return keys
end

local function copyCategories(value)
    local categories = {}
    local keys = sortedKeys(value)
    for index = 1, math.min(#keys, Pricing.MAX_CATEGORIES) do
        local key = keys[index]
        local source = value[key]
        if type(source) == "table" then
            categories[key] = {
                supply = clamp(source.supply, 0, 1, 0.5),
                demand = clamp(source.demand, 0, 1, 0.5),
            }
        end
    end
    return categories
end

local function copyEventModifiers(value)
    local modifiers = {}
    if type(value) ~= "table" then return modifiers end
    for index = 1, math.min(#value, Pricing.MAX_EVENT_MODIFIERS) do
        local source = value[index]
        local marketTag
        if type(source) == "table" then
            marketTag = text(source.marketTag or source.category
                or source.tag, 96)
            if marketTag then
                modifiers[#modifiers + 1] = {
                    marketTag = marketTag,
                    supplyDelta = clamp(source.supplyDelta, -1, 1, 0),
                    demandDelta = clamp(source.demandDelta, -1, 1, 0),
                    availabilityMultiplier = clamp(
                        source.availabilityMultiplier, 0, 4, 1),
                    priceMultiplier = clamp(source.priceMultiplier, 0,
                        Pricing.MAX_EVENT_PRICE_MULTIPLIER, 1),
                    eventID = text(source.eventID or source.id, 192),
                }
            end
        end
    end
    return modifiers
end

local function eventAPI()
    local events = rawget(DTCommon, "MarketEvents")
    return type(events) == "table" and events or nil
end

local function resolveEventContext(settlementID, record, options)
    local events = eventAPI()
    local resolver
    local ok
    local result
    local reason
    if not events then return nil end
    resolver = events.ResolveContext or events.GetContext
    if type(resolver) ~= "function" then return nil end
    ok, result, reason = pcall(resolver, settlementID, record, options)
    if not ok or type(result) ~= "table" then
        return {
            revision = 0,
            modifiers = {},
            unavailable = true,
            reason = reason or "event_context_unavailable",
        }
    end
    return {
        revision = math.max(0, integer(result.revision, 0)),
        modifiers = copyEventModifiers(result.modifiers),
        activeEventIDs = result.activeEventIDs,
        activeEventCount = math.max(0, integer(result.activeEventCount, 0)),
        unavailable = result.unavailable == true,
        reason = result.reason,
    }
end

local function policySettlementID(record)
    if not Policy or type(Policy.Get) ~= "function" then return nil end
    local policy = Policy.Get(record)
    if not policy then return nil end
    -- Prefer the trader's actual current/home context. The last commercial
    -- visit remains a separate historical field and is only a compatibility
    -- fallback for older records that predate resident context.
    return text(policy.currentSettlementID, 192)
        or text(policy.lastSettlementID, 192)
        or text(policy.homeSettlementID, 192)
end

local function settlementIDFor(record, options)
    local requested = type(options) == "table" and options.settlementID or nil
    return text(requested or policySettlementID(record), 192)
end

local function neutralItemContext(fullType, context, reason)
    return {
        fullType = text(fullType, 192),
        settlementID = context and context.settlementID or nil,
        marketRevision = context and context.marketRevision or nil,
        eventRevision = context and context.eventRevision or nil,
        category = nil,
        marketApplied = false,
        marketSupply = nil,
        marketDemand = nil,
        effectiveSupply = nil,
        effectiveDemand = nil,
        marketPressure = 0,
        marketModifier = 0,
        availabilityMultiplier = 1,
        eventPriceMultiplier = 1,
        eventCount = 0,
        activeEventCount = context and context.activeEventCount or 0,
        reason = reason or "market_context_unavailable",
    }
end

function Pricing.BuildContext(record, player, options)
    local context = {}
    local policyContext
    local settlementID
    local market
    local marketReason
    local eventContext
    options = type(options) == "table" and options or {}
    if Policy and type(Policy.PriceContext) == "function" then
        local ok
        ok, policyContext = pcall(Policy.PriceContext, record, player)
        if ok and type(policyContext) == "table" then
            for key, value in pairs(policyContext) do
                context[key] = value
            end
        end
    end
    context.relationshipModifier = clamp(context.relationshipModifier,
        -0.25, 0.25, 0)
    settlementID = settlementIDFor(record, options)
    context.settlementID = settlementID
    context.categories = {}
    context.itemFacts = {}
    context.itemFactCount = 0
    context.marketAvailable = false
    context.marketRevision = nil
    context.eventRevision = nil
    context.eventModifiers = {}
    if settlementID and Market and type(Market.Get) == "function" then
        market, marketReason = Market.Get(settlementID)
        if type(market) == "table" then
            context.marketAvailable = true
            context.marketRevision = math.max(0,
                integer(market.revision, 0))
            context.marketProfileID = text(market.profileID, 96)
            context.categories = copyCategories(market.categories)
        else
            context.marketReason = marketReason or "market_not_found"
        end
    elseif settlementID then
        context.marketReason = "market_service_unavailable"
    else
        context.marketReason = "settlement_unresolved"
    end
    eventContext = resolveEventContext(settlementID, record, options)
    if eventContext then
        context.eventRevision = eventContext.revision
        context.eventModifiers = eventContext.modifiers
        context.activeEventIDs = eventContext.activeEventIDs or {}
        context.activeEventCount = eventContext.activeEventCount or 0
        context.eventReason = eventContext.reason
        context.eventsUnavailable = eventContext.unavailable == true
    end
    -- These are server-only references used by IsCurrent; they never cross
    -- the snapshot or quote wire projection.
    context.eventRecord = record
    context.eventOptions = options
    context.quoteContextRevision = Pricing.ContextRevision(context)
    return context
end

function Pricing.ContextRevision(context)
    context = type(context) == "table" and context or {}
    return tostring(context.marketRevision or "none") .. ":"
        .. tostring(context.eventRevision or "none")
end

function Pricing.IsCurrent(context)
    local current
    if type(context) ~= "table" then return true end
    if context.settlementID and context.marketRevision ~= nil
        and Market and type(Market.Get) == "function"
    then
        current = Market.Get(context.settlementID)
        if type(current) ~= "table"
            or integer(current.revision, -1)
                ~= integer(context.marketRevision, -2)
        then
            return false, "stale_market"
        end
    end
    local events = eventAPI()
    if context.eventRevision ~= nil
        and events and type(events.GetRevision) == "function"
    then
        local ok
        local revision
        ok, revision = pcall(events.GetRevision, context.settlementID,
            context.eventRecord, context.eventOptions)
        if not ok or integer(revision, -1)
            ~= integer(context.eventRevision, -2)
        then
            return false, "stale_event"
        end
    end
    return true
end

function Pricing.GetItemContext(fullType, context)
    local key = text(fullType, 192)
    local fact
    local category
    local base
    local baseSupply
    local baseDemand
    local supply
    local demand
    local eventPriceMultiplier = 1
    local availabilityMultiplier = 1
    local eventCount = 0
    local pressure
    local marketModifier
    local modifiers
    if type(context) ~= "table" then
        context = Pricing.BuildContext(nil, nil)
    end
    if not key then return neutralItemContext(fullType, context, "item_required") end
    if type(context.itemFacts) ~= "table" then context.itemFacts = {} end
    fact = context.itemFacts[key]
    if not fact and Catalog and type(Catalog.Get) == "function" then
        fact = Catalog.Get(key)
        if type(fact) == "table"
            and (context.itemFactCount or 0) < Pricing.MAX_ITEM_CACHE
        then
            context.itemFacts[key] = fact
            context.itemFactCount = (context.itemFactCount or 0) + 1
        end
    end
    category = fact and text(fact.category, 96) or nil
    if not category then
        return neutralItemContext(key, context, "market_category_unavailable")
    end
    base = context.categories and context.categories[category] or nil
    baseSupply = type(base) == "table"
        and clamp(base.supply, 0, 1, 0.5) or 0.5
    baseDemand = type(base) == "table"
        and clamp(base.demand, 0, 1, 0.5) or 0.5
    supply = baseSupply
    demand = baseDemand
    modifiers = context.eventModifiers or {}
    for index = 1, math.min(#modifiers, Pricing.MAX_EVENT_MODIFIERS) do
        local modifier = modifiers[index]
        if type(modifier) == "table"
            and tostring(modifier.marketTag or "") == category
        then
            supply = clamp(supply + clamp(modifier.supplyDelta, -1, 1, 0),
                0, 1, supply)
            demand = clamp(demand + clamp(modifier.demandDelta, -1, 1, 0),
                0, 1, demand)
            availabilityMultiplier = clamp(availabilityMultiplier
                * clamp(modifier.availabilityMultiplier, 0, 4, 1),
                0, 4, 1)
            eventPriceMultiplier = clamp(eventPriceMultiplier
                * clamp(modifier.priceMultiplier, 0,
                    Pricing.MAX_EVENT_PRICE_MULTIPLIER, 1),
                0, Pricing.MAX_EVENT_PRICE_MULTIPLIER, 1)
            eventCount = eventCount + 1
        end
    end
    pressure = demand - supply
    marketModifier = clamp(pressure * Pricing.MARKET_PRESSURE_SCALE,
        -Pricing.MAX_MARKET_MODIFIER, Pricing.MAX_MARKET_MODIFIER, 0)
    return {
        fullType = key,
        settlementID = context.settlementID,
        marketRevision = context.marketRevision,
        eventRevision = context.eventRevision,
        category = category,
        marketApplied = context.marketAvailable == true
            and type(base) == "table",
        marketSupply = baseSupply,
        marketDemand = baseDemand,
        effectiveSupply = supply,
        effectiveDemand = demand,
        marketPressure = pressure,
        marketModifier = marketModifier,
        availabilityMultiplier = availabilityMultiplier,
        eventPriceMultiplier = eventPriceMultiplier,
        eventCount = eventCount,
        activeEventCount = context.activeEventCount or 0,
        reason = type(base) == "table" and context.marketAvailable == true
            and nil or (context.marketReason
                or "market_category_untracked"),
    }
end

return Pricing
