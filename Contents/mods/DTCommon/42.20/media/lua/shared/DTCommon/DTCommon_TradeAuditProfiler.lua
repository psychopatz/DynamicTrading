-- PsychopatzCore profiler integration for Dynamic Trading.
DTCommon = DTCommon or {}

local Audit = DTCommon.TradeAudit
if type(Audit) ~= "table" then return nil end

local function installProfiler(Profiler)
    local cleanups = {}
    local function wrap(object, method, metric)
        local original = object and object[method]
        local wrapped
        if type(original) ~= "function" then return end
        wrapped = Profiler.Wrap(metric, original, { protectErrors = true })
        if wrapped == original then return end
        object[method] = wrapped
        cleanups[#cleanups + 1] = function()
            if object[method] == wrapped then object[method] = original end
        end
    end

    Audit.Profiler = Profiler
    Audit.PerformanceEnabled = true
    wrap(DTCommon.TraderStock, "Price", Audit.METRIC_PRICE)
    wrap(DTCommon.TraderStock, "Quote", Audit.METRIC_QUOTE)
    wrap(DTCommon.TraderStock, "SnapshotItems", Audit.METRIC_SNAPSHOT_ITEMS)
    wrap(DTCommon.TraderStock, "SnapshotSellRows", Audit.METRIC_SNAPSHOT_SELL_ROWS)
    wrap(DTCommon.TraderService, "Snapshot", Audit.METRIC_SNAPSHOT)
    wrap(DTCommon.TraderService, "ExecuteTradeBasket", Audit.METRIC_EXECUTE_BASKET)
    wrap(DTCommon.MarketPricing, "BuildContext", Audit.METRIC_MARKET_CONTEXT)
    wrap(DTCommon.MarketEvents, "ResolveContext", Audit.METRIC_EVENT_RESOLUTION)
    wrap(DTCommon.MarketEvents, "ListActive", Audit.METRIC_EVENT_PRESENTATION)
    wrap(DTCommon.MarketCatalog, "GetCandidates", Audit.METRIC_CATALOG_QUERY)
    wrap(DTCommon.SettlementMarket, "Recover", Audit.METRIC_MARKET_RECOVERY)
    wrap(DTCommon.TraderService, "MarkSettlementVisit", Audit.METRIC_SETTLEMENT_VISIT)
    wrap(DTCommon.SettlementExchange, "Execute", Audit.METRIC_SETTLEMENT_EXCHANGE)

    return function()
        for index = #cleanups, 1, -1 do cleanups[index]() end
        Audit.PerformanceEnabled = false
        Audit.Profiler = nil
    end
end

local ok
local ProfilerFeatures
ok, ProfilerFeatures = pcall(require,
    "PsychopatzCore/Profiler/PsychopatzProfilerFeatureRegistry")
if not ok or type(ProfilerFeatures) ~= "table"
    or type(ProfilerFeatures.Register) ~= "function"
then
    return Audit
end

ProfilerFeatures.Register({
    id = "DTCommon.TradeAudit",
    namespace = "DTCommon",
    displayName = "Dynamic Trading",
    sections = { "performance" },
    install = installProfiler,
    uninstall = function()
        Audit.PerformanceEnabled = false
        Audit.Profiler = nil
    end,
    snapshotProviders = {
        {
            id = "DTCommon.TradeAudit",
            section = "performance",
            intervalMs = 1000,
            callback = Audit.GetSnapshot,
        },
    },
})

return Audit
