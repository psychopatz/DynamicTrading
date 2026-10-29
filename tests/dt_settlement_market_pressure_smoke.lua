local T = require "tests/support/test"

local authority = true
local marketKey = "DTCommon.SettlementMarkets"
local modData = {}

DTCommon = {
    MARKET_MODDATA_KEY = marketKey,
    MarketSchema = T.load(
        "DTCommon", "shared", "DTCommon/DTCommon_MarketSchema.lua"),
}
DTCommon.MarketProfiles = T.load(
    "DTCommon", "shared", "DTCommon/DTCommon_MarketProfiles.lua")
PsychopatzCore = {
    RuntimeRole = { AllowsServerCode = function() return authority end },
}
ModData = {
    getOrCreate = function(key)
        modData[key] = modData[key] or {}
        return modData[key]
    end,
    transmit = function() return true end,
}
PNC = {
    Communities = {
        Get = function(id)
            if id and id ~= "" then return { id = id, status = "active" } end
            return nil
        end,
    },
}

local savedRequire = require
require = function(moduleName)
    if moduleName == "PsychopatzCore/Inventory/PsychopatzInventory" then
        return {}
    end
    error("unexpected module in market pressure: " .. tostring(moduleName))
end
local Storage = T.load(
    "DTCommon", "shared", "DTCommon/DTCommon_Storage.lua")
require = savedRequire
DTCommon.Storage = Storage
local Registry = T.load(
    "DTCommon", "shared", "DTCommon/DTCommon_SettlementMarket.lua")
local function near(actual, expected, label)
    T.truthy(math.abs(actual - expected) < 0.000001, label)
end

local farm, farmCreated = Registry.GetOrCreate("community_farm", "farm")
local military, militaryCreated = Registry.GetOrCreate(
    "community_military", "military")
T.truthy(farm, "farm market is created")
T.truthy(military, "military market is created")
T.equal(farmCreated, true, "farm creation is reported")
T.equal(militaryCreated, true, "military creation is reported")
T.equal(farm.categories.Food.supply, 0.85,
    "farm profile has high food supply")
T.equal(military.categories.Food.supply, 0.35,
    "military profile has low food supply")
T.equal(farm.categories.Food.demand, 0.25,
    "farm profile has low food demand")
T.equal(military.categories.Food.demand, 0.75,
    "military profile has high food demand")

local pressured, pressureChanged = Registry.ApplyDelta("community_farm", {
    categories = {
        Food = { supplyDelta = -0.5, demandDelta = 0.4 },
    },
    wealthDelta = 0.2,
}, {
    expectedRevision = 0,
    now = 10,
})
T.truthy(pressured, "market pressure mutation succeeds")
T.equal(pressureChanged, true, "market pressure reports a change")
T.equal(pressured.revision, 1, "pressure mutation advances market revision")
T.equal(pressured.lastUpdateAt, 10, "pressure mutation records its time")
T.equal(pressured.categories.Food.supply, 0.35,
    "pressure mutation lowers food supply")
T.equal(pressured.categories.Food.demand, 0.65,
    "pressure mutation raises food demand")
T.equal(pressured.wealth, 0.8, "pressure mutation clamps wealth")
T.equal(modData[marketKey].markets.community_farm.revision, 1,
    "pressure mutation persists market revision")
T.equal(modData["DTCommon.Traders"], nil,
    "market pressure does not create trader stock state")

local stale, staleReason = Registry.ApplyDelta("community_farm", {
    Food = { supplyDelta = 0.1 },
}, { expectedRevision = 0, now = 11 })
T.equal(stale, nil, "stale pressure mutation is rejected")
T.equal(staleReason, "market_revision_conflict",
    "stale pressure rejection is explicit")

local recovered, recoveryChanged = Registry.Recover("community_farm", 1, {
    now = 11,
})
T.truthy(recovered, "market recovery succeeds")
T.equal(recoveryChanged, true, "market recovery reports a change")
T.equal(recovered.revision, 2, "recovery advances market revision")
near(recovered.categories.Food.supply, 0.4,
    "recovery moves supply toward the profile baseline")
near(recovered.categories.Food.demand, 0.61,
    "recovery moves demand toward the profile baseline")
T.equal(recovered.lastUpdateAt, 11, "recovery records its time")

local clone = Registry.GetOrCreate("community_farm_clone", "farm")
Registry.ApplyDelta("community_farm_clone", {
    Food = { supplyDelta = -0.5, demandDelta = 0.4 },
}, { expectedRevision = 0, now = 10 })
local recoveredClone = Registry.Recover("community_farm_clone", 1, {
    now = 11,
})
near(recoveredClone.categories.Food.supply,
    recovered.categories.Food.supply,
    "identical recovery inputs are deterministic")
near(recoveredClone.categories.Food.demand,
    recovered.categories.Food.demand,
    "identical recovery demand is deterministic")

local fullyRecovered = Registry.Recover("community_farm", 100, { now = 111 })
T.equal(fullyRecovered.categories.Food.supply, 0.85,
    "long recovery reaches the farm supply baseline")
T.equal(fullyRecovered.categories.Food.demand, 0.25,
    "long recovery reaches the farm demand baseline")

local custom = Registry.GetOrCreate("community_custom", {
    profileID = "farm",
    categories = { Food = { supply = 0.2 } },
})
T.equal(custom.categories.Food.supply, 0.2,
    "profile overrides can change one baseline field")
T.equal(custom.categories.Food.demand, 0.25,
    "profile overrides preserve the other baseline field")
local unknown = Registry.GetOrCreate("community_unknown", "not_a_profile")
T.equal(unknown.profileID, "default", "unknown profiles use a safe default")

local reloadRequire = require
require = function(moduleName)
    if moduleName == "PsychopatzCore/Inventory/PsychopatzInventory" then
        return {}
    end
    error("unexpected module during market reload: " .. tostring(moduleName))
end
local ReloadedStorage = T.load(
    "DTCommon", "shared", "DTCommon/DTCommon_Storage.lua")
require = reloadRequire
DTCommon.Storage = ReloadedStorage
local ReloadedRegistry = T.load(
    "DTCommon", "shared", "DTCommon/DTCommon_SettlementMarket.lua")
local reloadedFarm = ReloadedRegistry.Get("community_farm")
T.truthy(reloadedFarm, "market state survives a storage reload")
near(reloadedFarm.categories.Food.supply, 0.85,
    "reloaded market keeps recovered supply")
T.equal(reloadedFarm.profileID, "farm",
    "reloaded market keeps its profile identity")

local profileDiagnostics = DTCommon.MarketProfiles.Diagnostics()
T.equal(profileDiagnostics.profileCount, 3,
    "profile diagnostics expose the bounded profile set")
T.truthy(profileDiagnostics.categoryCount > 0,
    "profile diagnostics expose category coverage")

authority = false
local denied, deniedReason = Registry.ApplyDelta("community_farm", {
    Food = { supplyDelta = 0.1 },
})
T.equal(denied, nil, "client pressure mutation is rejected")
T.equal(deniedReason, "server_authority_required",
    "client pressure rejection is explicit")

T.finish("dt_settlement_market_pressure")
