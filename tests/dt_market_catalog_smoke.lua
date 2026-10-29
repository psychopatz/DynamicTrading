local T = require "tests/support/test"

DTCommon = { MONEY_FULL_TYPE = "Base.Money" }
local known = {
    ["Base.CannedBeans"] = {
        fullType = "Base.CannedBeans",
        category = "Food",
        primary = "FoodPreserved",
        tags = { "FoodPreserved" },
        expandedTags = { "Food", "FoodPreserved" },
        availability = { status = "obtainable" },
        price = 12,
    },
    ["Base.Bandage"] = {
        fullType = "Base.Bandage",
        category = "Medical",
        primary = "MedicalBandage",
        tags = { "MedicalBandage" },
        availability = { status = "obtainable" },
        price = 8,
    },
    ["Base.UnavailableFood"] = {
        fullType = "Base.UnavailableFood",
        category = "Food",
        tags = { "FoodFresh" },
        availability = { status = "unobtainable" },
        price = 4,
    },
    ["Base.Money"] = {
        fullType = "Base.Money",
        category = "Currency",
        tags = { "Currency" },
        availability = { status = "obtainable" },
        price = 1,
    },
    ["Workshop.RareTool"] = {
        fullType = "Workshop.RareTool",
        availability = nil,
        price = 40,
    },
}
local knownCalls = 0
local tagCalls = 0
local availabilityCalls = 0
local loadCalls = 0

MarketSense = {
    EnsureRuntimeRegistryLoaded = function()
        loadCalls = loadCalls + 1
        return true
    end,
    GetAllKnownItems = function()
        knownCalls = knownCalls + 1
        return known
    end,
    GetTags = function(fullType)
        tagCalls = tagCalls + 1
        if fullType == "Workshop.RareTool" then
            return {
                category = "Tool",
                primary = "ToolRare",
                tags = { "ToolRare" },
                expandedTags = { "Tool", "ToolRare" },
            }
        end
        return {}
    end,
    GetItemAvailability = function(fullType)
        availabilityCalls = availabilityCalls + 1
        if fullType == "Workshop.RareTool" then
            return { status = "obtainable" }
        end
        return { status = "unobtainable" }
    end,
}

local Catalog = T.load(
    "DTCommon", "shared", "DTCommon/DTCommon_MarketCatalog.lua")
Catalog.Reset()
local built, buildReason = Catalog.Build()
T.truthy(built, buildReason)
T.equal(knownCalls, 1, "catalog builds from MarketSense once")
T.equal(loadCalls, 1, "catalog asks MarketSense to load its registry once")
T.equal(tagCalls, 1, "catalog queries tags only for incomplete rows")
T.equal(availabilityCalls, 1,
    "catalog queries availability only for incomplete rows")

local builtAgain, builtAgainReason = Catalog.Build()
T.truthy(builtAgain, builtAgainReason)
T.equal(knownCalls, 1, "repeated catalog builds do not rescan the registry")
T.equal(Catalog.Diagnostics().buildCount, 1,
    "catalog build revision remains bounded")

local categories = Catalog.Categories()
T.equal(#categories, 4, "catalog exposes MarketSense category vocabulary")
T.equal(categories[1], "Currency", "categories are deterministic")
T.equal(categories[4], "Tool", "categories include tag-derived rows")

local allFood = Catalog.ListCategory("Food")
T.equal(#allFood, 2, "category list keeps unavailable facts for diagnostics")
T.equal(allFood[1], "Base.CannedBeans", "category list is sorted")
T.equal(allFood[2], "Base.UnavailableFood", "category list is bounded")
local foodCandidates = Catalog.GetCandidates("Food")
T.equal(#foodCandidates, 1, "candidate query filters availability")
T.equal(foodCandidates[1], "Base.CannedBeans",
    "candidate query keeps obtainable food")

local rare, rareReason = Catalog.Get("Workshop.RareTool")
T.truthy(rare, rareReason)
T.equal(rare.category, "Tool", "single-item facts use MarketSense tags")
T.equal(rare.obtainable, true, "single-item facts use MarketSense availability")
local money = Catalog.Get("Base.Money")
T.equal(money.tradeable, false, "currency is not a trade candidate")

local diagnostics = Catalog.Diagnostics()
T.equal(diagnostics.scannedCount, 5, "catalog scan count is bounded")
T.equal(diagnostics.indexedCount, 5, "catalog index count is explicit")
T.equal(diagnostics.categoryCount, 4, "catalog category count is explicit")

Catalog.Reset()
local rebuilt, rebuiltReason = Catalog.Ensure()
T.truthy(rebuilt, rebuiltReason)
T.equal(knownCalls, 2, "explicit invalidation permits one new build")

MarketSense = nil
Catalog.Reset()
local unavailable, unavailableReason = Catalog.Ensure()
T.equal(unavailable, false, "catalog degrades without MarketSense")
T.equal(unavailableReason, "marketsense_catalog_unavailable",
    "catalog degradation has a stable reason")

T.finish("dt_market_catalog")
