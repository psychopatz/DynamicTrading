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
    local eventRegistry = DTCommon and DTCommon.MarketEvents or nil
    if eventRegistry and type(eventRegistry.ListActive) == "function" then
        events, eventContext = eventRegistry.ListActive(
            target and target.communityID,
            faction,
            { now = context and context.at }
        )
        if eventContext and eventContext.activeEventCount then
            score = score + math.min(4,
                tonumber(eventContext.activeEventCount) or 0) * 2
        else
            score = score + math.min(4, #(events or {})) * 2
        end
    end
    -- A bound trader is a commercial specialist. This small bounded bonus is
    -- intentionally independent of any item registry or carried inventory.
    if faction and faction.archetypeID == "trader" then score = score + 2 end
    if reads == 0 then return 0 end
    return clamp(score, -MAX_SCORE, MAX_SCORE)
end

function Mobility.Register()
    local service = PNC and PNC.CommercialMobilityService or nil
    local ok
    local reason
    if not service or type(service.RegisterOpportunityScorer) ~= "function" then
        return false, "commercial_mobility_service_unavailable"
    end
    if Mobility.Registered then return true, "already_registered" end
    ok, reason = pcall(
        service.RegisterOpportunityScorer,
        "dynamic_trading",
        Mobility.OpportunityScore
    )
    if not ok then return false, reason end
    Mobility.Registered = reason == "scorer_registered"
        or reason == "scorer_replaced"
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
            and not faction.mobile.mobilityIntent
        then
            local ok, updated = pcall(
                factions.UpdateMobileGroup,
                faction.id,
                { mobilityIntent = "commercial" },
                "dynamic_trading_commercial_mobility_migration"
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
