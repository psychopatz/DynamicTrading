local T = require "tests/support/test"

DTCommon = { MONEY_FULL_TYPE = "Base.Money" }

local rows = {
    ["Base.CannedBeans"] = {
        fullType = "Base.CannedBeans",
        moduleName = "Base",
        sourceModId = "Vanilla",
        category = "Food",
        primary = "FoodPreserved",
        availability = { status = "obtainable", obtainable = true },
    },
    ["Base.Bandage"] = {
        fullType = "Base.Bandage",
        moduleName = "Base",
        sourceModId = "Vanilla",
        category = "Medical",
        primary = "MedicalBandage",
        availability = { status = "obtainable", obtainable = true },
    },
    ["Base.UnavailableFood"] = {
        fullType = "Base.UnavailableFood",
        moduleName = "Base",
        sourceModId = "Vanilla",
        category = "Food",
        availability = { status = "unobtainable", obtainable = false },
    },
    ["Base.Money"] = {
        fullType = "Base.Money",
        moduleName = "Base",
        sourceModId = "Vanilla",
        category = "Currency",
        availability = { status = "obtainable", obtainable = true },
    },
    ["Workshop.RareTool"] = {
        fullType = "Workshop.RareTool",
        moduleName = "Workshop",
        sourceModId = "WorkshopMod",
        category = "Tool",
        primary = "ToolRare",
        availability = { status = "obtainable", obtainable = true },
    },
}

local queryCalls = 0
local exactCalls = 0
local allKnownCalls = 0

MarketSense = {
    IsCatalogReady = function() return true end,
    GetCatalogRevision = function() return 41 end,
    GetPricingRevision = function() return 7 end,
    GetAllKnownItems = function()
        allKnownCalls = allKnownCalls + 1
        error("DT gateway must never request the full MarketSense universe")
    end,
    GetCatalogItem = function(fullType)
        exactCalls = exactCalls + 1
        return rows[fullType]
    end,
    QueryItems = function(options)
        queryCalls = queryCalls + 1
        local output = {}
        local keys = {}
        for key, row in pairs(rows) do
            local available = not options.obtainableOnly
                or (row.availability and row.availability.obtainable == true)
            local category = not options.category
                or row.category == options.category
            local modded = not options.moddedOnly
                or row.sourceModId ~= "Vanilla"
            if available and category and modded then
                keys[#keys + 1] = key
            end
        end
        table.sort(keys)
        for index = 1, math.min(#keys, options.limit or #keys) do
            output[#output + 1] = rows[keys[index]]
        end
        return output
    end,
}

local Gateway = T.load(
    "DTCommon", "shared", "DTCommon/DTCommon_MarketSenseGateway.lua")

T.truthy(Gateway.IsReady(), "gateway reports canonical MarketSense ready")
T.equal(Gateway.GetCatalogRevision(), 41, "catalog revision passthrough")
T.equal(Gateway.GetPricingRevision(), 7, "pricing revision passthrough")

local food = Gateway.GetCandidates("Food", {
    limit = 8,
    availableOnly = true,
})
T.equal(#food, 1, "gateway filters unavailable candidate via MarketSense")
T.equal(food[1], "Base.CannedBeans", "food candidate identity")

local exact = assert(Gateway.Get("Workshop.RareTool"))
T.equal(exact.category, "Tool", "exact fact comes from MarketSense")
T.truthy(exact.obtainable, "exact fact availability")
T.truthy(exact.tradeable, "non-currency item is tradeable")

local money = assert(Gateway.Get("Base.Money"))
T.falsy(money.tradeable, "DT commercial policy excludes currency")

local seed = Gateway.GetStockSeedCandidates({
    defaults = {
        { fullType = "Base.Bandage", quantity = 5 },
        { fullType = "Base.CannedBeans", quantity = 5 },
    },
    limit = 8,
})
T.truthy(#seed >= 3, "bounded seed pool contains defaults and modded row")
local foundWorkshop = false
for _, candidate in ipairs(seed) do
    if candidate.fullType == "Workshop.RareTool" then
        foundWorkshop = true
        T.truthy(candidate.workshop, "modded source is identified")
    end
end
T.truthy(foundWorkshop, "bounded MarketSense query preserves modded preference")
T.equal(allKnownCalls, 0, "gateway never scans full MarketSense catalog")
T.truthy(queryCalls <= 3, "gateway uses bounded canonical queries")
T.truthy(exactCalls <= 4, "gateway exact lookups remain bounded")

local diagnostics = Gateway.Diagnostics()
T.falsy(diagnostics.persistentUniverseState,
    "gateway explicitly owns no item-universe state")
T.equal(diagnostics.catalogRevision, 41, "diagnostics expose canonical revision")

MarketSense = nil
local missing, reason = Gateway.Get("Base.CannedBeans")
T.equal(missing, nil, "gateway fails boundedly without MarketSense")
T.equal(reason, "marketsense_unavailable", "missing MarketSense reason")

T.finish("dt_marketsense_gateway_smoke")
