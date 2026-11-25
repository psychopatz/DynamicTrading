if PsychopatzCore and PsychopatzCore.RuntimeRole
    and not PsychopatzCore.RuntimeRole.AllowsServerCode()
then return end

-- DynamicTrading's bounded economic contribution to the generic Hoomans
-- commercial-mobility contract. Hoomans still discovers and validates the
-- destination and owns the travel lifecycle; this scorer only reads compact
-- market/event state and never mutates stock, pressure, or market records.

DTHoomans = DTHoomans or {}
DTHoomans.CommercialMobility = DTHoomans.CommercialMobility or {}

local Mobility = DTHoomans.CommercialMobility
local CATEGORY_ORDER = { "Food", "Medical", "Resource", "Tool", "Weapon" }
local MAX_CATEGORY_READS = 5
local MAX_SCORE = 25
local MAX_CARAVAN_MIGRATIONS = 8
local RISK_PENALTY_SCALE = 10
local MAX_RISK_PENALTY = 12
local MAX_DISTANCE_PENALTY = 10
local DISTANCE_PENALTY_DIVISOR = 600
local LOW_STOCK_THRESHOLD = 0.35
local LOW_STOCK_RESTOCK_BONUS = 10

local function clamp(value, low, high)
    value = tonumber(value) or 0
    if value ~= value or value == math.huge or value == -math.huge then
        value = 0
    end
    return math.max(low, math.min(high, value))
end

local function marketFor(target)
    local markets = DTCommon and DTCommon.SettlementMarket or nil
    if not markets or type(markets.Get) ~= "function" then return nil end
    return markets.Get(target and target.communityID)
end

local function modifierRiskSignal(modifier)
    if type(modifier) ~= "table" then return 0 end
    local tag = tostring(modifier.marketTag or "")
    if tag ~= "CaravanRisk" and tag ~= "TravelRisk" then
        return 0
    end
    local fromDemand = math.max(0, tonumber(modifier.demandDelta) or 0)
    local fromPrice = math.max(0, (tonumber(modifier.priceMultiplier) or 1) - 1)
    return math.max(fromDemand, fromPrice)
end

local function extractMarketEventRisk(events, eventContext)
    local risk = 0
    local modifiers = type(eventContext) == "table" and eventContext.modifiers or nil
    if type(modifiers) == "table" then
        for index = 1, math.min(#modifiers, 16) do
            risk = math.max(risk, modifierRiskSignal(modifiers[index]))
        end
    end
    if type(events) == "table" then
        for index = 1, math.min(#events, 16) do
            local ev = events[index]
            if type(ev) == "table" then
                risk = math.max(risk, math.max(0, tonumber(ev.caravanRisk) or 0))
                risk = math.max(risk, math.max(0, tonumber(ev.travelRisk) or 0))
                if type(ev.modifiers) == "table" then
                    for mIndex = 1, math.min(#ev.modifiers, 16) do
                        risk = math.max(risk, modifierRiskSignal(ev.modifiers[mIndex]))
                    end
                end
            end
        end
    end
    return risk
end

local function extractScopedEventRisk(faction, target, eventContext, context)
    local scoped = PsychopatzCore and PsychopatzCore.ScopedWorldEvents or nil
    if not scoped or type(scoped.AggregateEffects) ~= "function" then
        return 0
    end
    local communityID = target and target.communityID or nil
    local regionID = (type(eventContext) == "table" and eventContext.regionID)
        or (target and (target.regionID or target.regionId))
    local factionID = faction and (faction.id or faction.factionID or faction.g) or nil
    if not communityID and not regionID and not factionID then
        return 0
    end
    local agg = scoped.AggregateEffects({
        settlementID = communityID,
        regionID = regionID,
        factionID = factionID,
    }, context and context.at)
    if type(agg) ~= "table" or type(agg.effects) ~= "table" then
        return 0
    end
    local caravanRisk = math.max(0, tonumber(agg.effects.caravanRisk) or 0)
    local travelRisk = math.max(0, tonumber(agg.effects.travelRisk) or 0)
    local hostilityDelta = math.max(0, (tonumber(agg.effects.hostileActivityMultiplier) or 1) - 1)
    return math.max(0, math.max(caravanRisk, travelRisk) + hostilityDelta * 0.5)
end

function Mobility.OpportunityScore(faction, target, context)
    local market = marketFor(target)
    local score = 0
    local category
    local pressure
    local reads = 0
    local events
    local eventContext
    if not market then return 0 end
    for index = 1, math.min(#CATEGORY_ORDER, MAX_CATEGORY_READS) do
        category = market.categories
            and market.categories[CATEGORY_ORDER[index]] or nil
        if category then
            pressure = (tonumber(category.demand) or 0.5)
                - (tonumber(category.supply) or 0.5)
            score = score + clamp(pressure, -1, 1) * 5
            reads = reads + 1
        end
    end
    local cache = type(context) == "table" and context._mobilityCache or nil
    if type(context) == "table" and not cache then
        cache = {}
        context._mobilityCache = cache
    end
    local cacheKey = tostring(target and target.communityID or "")
    local cached = cache and cache[cacheKey] or nil
    local marketRisk = 0
    local scopedRisk = 0
    if cached then
        score = score + cached.eventBonus
        marketRisk = cached.marketRisk
        scopedRisk = cached.scopedRisk
    else
        local eventBonus = 0
        local eventRegistry = DTCommon and DTCommon.MarketEvents or nil
        if eventRegistry and type(eventRegistry.ListActive) == "function" then
            events, eventContext = eventRegistry.ListActive(
                target and target.communityID,
                faction,
                {
                    now = context and context.at,
                    regionID = target and (target.regionID or target.regionId),
                }
            )
            if eventContext and eventContext.activeEventCount then
                eventBonus = math.min(4,
                    tonumber(eventContext.activeEventCount) or 0) * 2
            else
                eventBonus = math.min(4, #(events or {})) * 2
            end
        end
        marketRisk = extractMarketEventRisk(events, eventContext)
        scopedRisk = extractScopedEventRisk(faction, target, eventContext, context)
        score = score + eventBonus
        if cache and cacheKey ~= "" then
            cache[cacheKey] = {
                eventBonus = eventBonus,
                marketRisk = marketRisk,
                scopedRisk = scopedRisk,
            }
        end
    end
    local effectiveRisk = math.max(marketRisk, scopedRisk)
    if effectiveRisk > 0 then
        score = score - clamp(effectiveRisk * RISK_PENALTY_SCALE, 0, MAX_RISK_PENALTY)
    end
    -- Distance decay keeps caravans forming realistic regional trade loops.
    local fx = faction and faction.mobile and tonumber(faction.mobile.x)
        or (type(context) == "table" and tonumber(context.originX)) or nil
    local fy = faction and faction.mobile and tonumber(faction.mobile.y)
        or (type(context) == "table" and tonumber(context.originY)) or nil
    local tx = target and tonumber(target.x or (target.home and target.home.x)) or nil
    local ty = target and tonumber(target.y or (target.home and target.home.y)) or nil
    if fx and fy and tx and ty then
        local dx, dy = tx - fx, ty - fy
        local dist = math.sqrt(dx * dx + dy * dy)
        score = score - clamp(dist / DISTANCE_PENALTY_DIVISOR, 0, MAX_DISTANCE_PENALTY)
    end
    -- Revisit cooldown penalty prevents A<->B settlement ping-ponging.
    local recent = (type(context) == "table" and context.recentSettlements)
        or (faction and faction.mobile and faction.mobile.recentSettlements) or nil
    if type(recent) == "table" and target and target.communityID then
        local cid = tostring(target.communityID)
        if tostring(recent[1] or "") == cid then
            score = score - 8
        elseif tostring(recent[2] or "") == cid then
            score = score - 4
        end
    end
    -- Low-stock caravans prioritize non-player NPC settlements to replenish.
    local stockRatio = type(context) == "table" and tonumber(context.stockRatio) or nil
    if stockRatio ~= nil and stockRatio < LOW_STOCK_THRESHOLD then
        local settlementMod = DTHoomans and DTHoomans.Settlement or nil
        local isPlayerBase = target and target.playerOwned == true
            or (settlementMod and type(settlementMod.IsPlayerOwnedSettlement) == "function"
                and settlementMod.IsPlayerOwnedSettlement(target) == true)
        if not isPlayerBase then
            score = score + LOW_STOCK_RESTOCK_BONUS
        end
    end
    -- A bound trader is a commercial specialist. This small bounded bonus is
    -- intentionally independent of any item registry or carried inventory.
    if faction and DTCommon
        and type(DTCommon.IsTraderFaction) == "function"
        and DTCommon.IsTraderFaction(faction)
    then
        score = score + 2
    end
    if reads == 0 then return 0 end
    return clamp(score, -MAX_SCORE, MAX_SCORE)
end

function Mobility.Register()
    local service = PNC and PNC.CommercialMobilityService or nil
    local ok
    local registered
    local reason
    if not service or type(service.RegisterOpportunityScorer) ~= "function" then
        return false, "commercial_mobility_service_unavailable"
    end
    if Mobility.Registered then return true, "already_registered" end
    ok, registered, reason = pcall(
        service.RegisterOpportunityScorer,
        "dynamic_trading",
        Mobility.OpportunityScore
    )
    if not ok then return false, registered end
    Mobility.Registered = registered == true
        and (reason == "scorer_registered"
            or reason == "scorer_replaced")
    if not Mobility.Registered then
        return false, reason or "scorer_registration_failed"
    end
    return Mobility.Registered, reason
end

-- Existing saves may contain a DT caravan generated before the generic
-- mobility intent existed. Apply a bounded, idempotent field-only repair; do
-- not recreate factions, move members, or alter trader records.
function Mobility.MigrateExistingCaravans()
    local factions = PNC and PNC.Factions or nil
    local registry = factions and factions.Registry
        and factions.Registry.byID or nil
    local migrated = 0
    if not registry or not factions
        or type(factions.UpdateMobileGroup) ~= "function"
    then
        return 0
    end
    for _, faction in pairs(registry) do
        if migrated >= MAX_CARAVAN_MIGRATIONS then break end
        if type(faction) == "table"
            and faction.status == "active"
            and faction.tags and faction.tags.dynamicTrading == true
            and faction.mobile and faction.mobile.active == true
            and tostring(faction.mobile.mobilityIntent or "")
                ~= "dynamic_trading_managed"
        then
            local ok, updated = pcall(
                factions.UpdateMobileGroup,
                faction.id,
                { mobilityIntent = "dynamic_trading_managed" },
                "dynamic_trading_managed_mobility_migration"
            )
            if ok and updated ~= false then migrated = migrated + 1 end
        end
    end
    return migrated
end

Mobility.Register()

if Events and Events.OnGameStart
    and type(Events.OnGameStart.Add) == "function"
    and not Mobility.StartHookRegistered
then
    Mobility.StartHookRegistered = true
    Events.OnGameStart.Add(function()
        Mobility.Register()
        Mobility.MigrateExistingCaravans()
    end)
end

return Mobility
