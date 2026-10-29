-- Bounded production producer for grounded settlement market conditions.
-- The producer reads persisted market pressure only; the generic event
-- registry remains unaware of these named condition semantics.

DTCommon = DTCommon or {}

local Producer = DTCommon.MarketEventProducer or {}
DTCommon.MarketEventProducer = Producer

local Market = DTCommon.SettlementMarket
local Events = DTCommon.MarketEvents
local Definitions = DTCommon.MarketEventDefinitions
local MAX_ID_LENGTH = 192
local MAX_TIMESTAMP = 2147483647

Producer.VERSION = 1
Producer.DURATION_HOURS = 12
Producer.COOLDOWN_HOURS = 12
Producer.SHORTAGE_ENTER_SUPPLY = 0.25
Producer.SHORTAGE_ENTER_DEMAND = 0.70
Producer.SHORTAGE_CLEAR_SUPPLY = 0.45
Producer.SHORTAGE_CLEAR_DEMAND = 0.55
Producer.SURPLUS_ENTER_SUPPLY = 0.75
Producer.SURPLUS_ENTER_DEMAND = 0.35
Producer.SURPLUS_CLEAR_SUPPLY = 0.60
Producer.SURPLUS_CLEAR_DEMAND = 0.45

local DEFINITION_BY_TYPE = {
    food_shortage = Definitions and Definitions.FOOD_SHORTAGE,
    agricultural_surplus = Definitions and Definitions.AGRICULTURAL_SURPLUS,
}

local function authority()
    local storage = DTCommon and DTCommon.Storage
    return storage and type(storage.IsAuthority) == "function"
        and storage.IsAuthority() == true
end

local function number(value, fallback)
    value = tonumber(value)
    if not value or value ~= value or value == math.huge
        or value == -math.huge
    then return fallback end
    return value
end

local function clamp(value, low, high, fallback)
    value = number(value, fallback)
    return math.max(low, math.min(high, value))
end

local function bounded(value, maximum)
    value = tostring(value or "")
    maximum = tonumber(maximum) or MAX_ID_LENGTH
    return #value > maximum and string.sub(value, 1, maximum) or value
end

local function hash(value)
    local result = 17
    for index = 1, #value do
        result = (result * 31 + string.byte(value, index)) % MAX_TIMESTAMP
    end
    return tostring(result)
end

local function eventID(settlementID)
    local id = bounded(settlementID)
    return bounded("dt-market-condition:" .. hash(id) .. ":"
        .. bounded(id, 96))
end

local function worldAge()
    local getter = rawget(_G, "getGameTime")
    local gameTime
    local ok
    local value
    if type(getter) ~= "function" then return 0 end
    ok, gameTime = pcall(getter)
    if not ok or not gameTime
        or type(gameTime.getWorldAgeHours) ~= "function"
    then return 0 end
    ok, value = pcall(gameTime.getWorldAgeHours, gameTime)
    return ok and clamp(value, 0, MAX_TIMESTAMP, 0) or 0
end

local function resolveNow(options, market)
    options = type(options) == "table" and options or {}
    local now = options.now == nil and worldAge() or options.now
    now = clamp(now, 0, MAX_TIMESTAMP, 0)
    return math.max(now, number(market and market.lastUpdateAt, 0))
end

local function active(event, now)
    local startsAt
    local endsAt
    if type(event) ~= "table" then return false end
    startsAt = number(event.startsAt, 0)
    endsAt = number(event.endsAt, nil)
    if now < startsAt then return false end
    return endsAt == nil or now < endsAt
end

local function conditionFor(food)
    local supply = number(food and food.supply, 0.5)
    local demand = number(food and food.demand, 0.5)
    if supply <= Producer.SHORTAGE_ENTER_SUPPLY
        and demand >= Producer.SHORTAGE_ENTER_DEMAND
    then
        return "food_shortage"
    end
    if supply >= Producer.SURPLUS_ENTER_SUPPLY
        and demand <= Producer.SURPLUS_ENTER_DEMAND
    then
        return "agricultural_surplus"
    end
    return nil
end

local function clearCondition(eventType, food)
    local supply = number(food and food.supply, 0.5)
    local demand = number(food and food.demand, 0.5)
    if eventType == "food_shortage" then
        return supply >= Producer.SHORTAGE_CLEAR_SUPPLY
            or demand <= Producer.SHORTAGE_CLEAR_DEMAND
    end
    if eventType == "agricultural_surplus" then
        return supply <= Producer.SURPLUS_CLEAR_SUPPLY
            or demand >= Producer.SURPLUS_CLEAR_DEMAND
    end
    return true
end

local function definitionFor(eventType)
    return DEFINITION_BY_TYPE[eventType]
end

local function instantiate(eventType, id, startsAt, endsAt)
    local definition = definitionFor(eventType)
    if not definition or not Definitions
        or type(Definitions.Instantiate) ~= "function"
    then return nil, "market_event_definition_unavailable" end
    return Definitions.Instantiate(definition, id, {
        kind = "settlement",
        id = bounded(id),
    }, startsAt, endsAt)
end

local function result(id, now, state, event, changed, reason)
    return {
        settlementID = id,
        eventID = eventID(id),
        now = now,
        state = state,
        event = event,
        changed = changed == true,
        reason = reason,
    }
end

local function clearEvent(id, previous, now)
    local startsAt = number(previous and previous.startsAt, now)
    local endedAt = math.max(startsAt, now)
    local definition, reason = instantiate(
        previous and previous.type, id, startsAt, endedAt)
    local registered
    if not definition then return nil, reason end
    registered, reason = Events.Register(eventID(id), definition)
    if not registered then return nil, reason end
    return registered
end

local function startEvent(id, eventType, now)
    local endsAt = math.min(MAX_TIMESTAMP,
        now + Producer.DURATION_HOURS)
    local definition, reason = instantiate(eventType, id, now, endsAt)
    local registered
    if not definition then return nil, reason end
    registered, reason = Events.Register(eventID(id), definition)
    if not registered then return nil, reason end
    return registered
end

function Producer.EventID(settlementID)
    local id = bounded(settlementID)
    if id == "" then return nil end
    return eventID(id)
end

function Producer.Evaluate(settlementID, options)
    local id = bounded(settlementID)
    local market
    local food
    local now
    local currentType
    local previous
    local previousReason
    local previousActive
    local cleared
    local cooldownUntil
    local started
    local reason
    if not authority() then return nil, "server_authority_required" end
    if id == "" then return nil, "settlement_id_required" end
    if not Market or type(Market.Get) ~= "function" then
        return nil, "market_service_unavailable"
    end
    if not Events or type(Events.Get) ~= "function"
        or type(Events.Register) ~= "function"
    then return nil, "market_event_registry_unavailable" end
    market, reason = Market.Get(id)
    if not market then return nil, reason end
    food = market.categories and market.categories.Food or nil
    now = resolveNow(options, market)
    currentType = conditionFor(food)
    previous, previousReason = Events.Get(eventID(id))
    if not previous and previousReason ~= "event_not_found" then
        return nil, previousReason
    end
    if previous and not definitionFor(previous.type) then
        return nil, "producer_event_identity_conflict"
    end
    previousActive = active(previous, now)
    if previousActive and not clearCondition(previous.type, food) then
        return result(id, now, previous.type, previous, false,
            "condition_sustained")
    end
    if previousActive then
        cleared, reason = clearEvent(id, previous, now)
        if not cleared then return nil, reason end
        return result(id, now, "cleared", cleared, true,
            "condition_cleared")
    end
    if currentType then
        cooldownUntil = previous and number(previous.endsAt, nil) or nil
        if cooldownUntil and now < cooldownUntil + Producer.COOLDOWN_HOURS
        then
            return result(id, now, "cooldown", previous, false,
                "producer_cooldown")
        end
        started, reason = startEvent(id, currentType, now)
        if not started then return nil, reason end
        return result(id, now, currentType, started, true,
            "condition_entered")
    end
    return result(id, now, "neutral", previous, false, "no_condition")
end

return Producer
