local T = require "tests/support/test"

local authority = true
local marketKey = "DTCommon.SettlementMarkets"
local modData = {
    [marketKey] = {
        schemaVersion = 0,
        revision = -2,
        markets = {
            community_seed = {
                profileID = "farm",
                ignoredField = true,
            },
        },
        ignoredField = true,
    },
}
local transmissions = {}

DTCommon = {
    MARKET_MODDATA_KEY = marketKey,
    MarketSchema = T.load(
        "DTCommon", "shared", "DTCommon/DTCommon_MarketSchema.lua"),
}
PsychopatzCore = {
    RuntimeRole = { AllowsServerCode = function() return authority end },
}
ModData = {
    getOrCreate = function(key)
        modData[key] = modData[key] or {}
        return modData[key]
    end,
    transmit = function(key) transmissions[#transmissions + 1] = key end,
}
PNC = {
    Communities = {
        Get = function(id)
            if id == "community_alpha" or id == "community_beta"
                or id == "community_seed"
            then
                return { id = id, status = "active" }
            end
            if id == "community_closed" then
                return { id = id, status = "closed" }
            end
            if id and id ~= "" then
                return { id = id, status = "active" }
            end
            return nil
        end,
    },
}

local savedRequire = require
require = function(moduleName)
    if moduleName == "PsychopatzCore/Inventory/PsychopatzInventory" then
        return {}
    end
    error("unexpected module in market registry: " .. tostring(moduleName))
end
local Storage = T.load(
    "DTCommon", "shared", "DTCommon/DTCommon_Storage.lua")
require = savedRequire
DTCommon.Storage = Storage
local Registry = T.load(
    "DTCommon", "shared", "DTCommon/DTCommon_SettlementMarket.lua")

local data, dataReason = Storage.GetMarketData()
T.truthy(data, dataReason)
T.equal(data.schemaVersion, 1, "storage migrates the market envelope")
T.equal(data.revision, 0, "storage clamps the market envelope revision")
T.equal(data.ignoredField, nil, "storage drops unknown envelope fields")
T.equal(data.markets.community_seed.profileID, "farm",
    "storage keeps partial market defaults")
T.equal(data.markets.community_seed.ignoredField, nil,
    "storage drops unknown market fields")

local alpha, created = Registry.GetOrCreate("community_alpha", {
    profileID = "farm",
    wealth = 0.75,
})
T.truthy(alpha, "active canonical settlement creates a market")
T.equal(created, true, "new market reports creation")
T.equal(alpha.settlementID, "community_alpha",
    "market stores the canonical settlement ID")
T.equal(alpha.profileID, "farm", "market stores its profile")
T.equal(modData[marketKey].revision, 1,
    "market creation advances the persistent envelope revision")
T.equal(transmissions[#transmissions], marketKey,
    "market creation transmits the market envelope")

local sameAlpha, createdAgain = Registry.GetOrCreate("community_alpha", {
    profileID = "military",
})
T.equal(createdAgain, false, "existing market is not recreated")
T.equal(sameAlpha.profileID, "farm", "existing profile is preserved")
T.equal(modData[marketKey].revision, 1,
    "reading an existing market does not write")

sameAlpha.categories.food = { supply = 0, demand = 1 }
local persistedAlpha = Registry.Get("community_alpha")
T.equal(persistedAlpha.categories.food, nil,
    "market reads return a protected normalized copy")

local beta, betaCreated = Registry.GetOrCreate("community_beta", "military")
T.truthy(beta, "second active settlement creates a market")
T.equal(betaCreated, true, "second market reports creation")
T.equal(beta.profileID, "military", "second profile persists")

local listed = Registry.List()
T.equal(#listed, 3, "bounded registry lists all current markets")
T.equal(listed[1].settlementID, "community_alpha",
    "registry list is deterministic")
T.equal(listed[2].settlementID, "community_beta",
    "registry list remains sorted")
T.equal(listed[3].settlementID, "community_seed",
    "migrated market remains registered")

local committed, commitReason = Registry.Commit("community_alpha", {
    profileID = "farm",
    categories = { Food = { supply = 0.9, demand = 0.2 } },
}, 0)
T.truthy(committed, commitReason)
T.equal(committed.revision, 1, "market commit advances its own revision")
T.equal(committed.categories.Food.supply, 0.9,
    "market commit stores bounded category pressure")
local stale, staleReason = Registry.Commit("community_alpha", {
    profileID = "farm",
}, 0)
T.equal(stale, nil, "stale market commits are rejected")
T.equal(staleReason, "market_revision_conflict",
    "stale market commits have a stable reason")

local diagnostics, diagnosticReason = Registry.Diagnostics()
T.truthy(diagnostics, diagnosticReason)
T.equal(diagnostics.marketCount, 3, "market diagnostics count records")
T.equal(diagnostics.categoryCount, 1,
    "market diagnostics count compact categories")

local closed, closedReason = Registry.GetOrCreate("community_closed", "farm")
T.equal(closed, nil, "inactive settlement cannot create market state")
T.equal(closedReason, "settlement_not_found",
    "inactive settlement rejection is explicit")

authority = false
local denied, deniedReason = Registry.GetOrCreate("community_beta", "farm")
T.truthy(denied, "existing market remains readable on a client")
T.equal(deniedReason, false, "client read does not attempt creation")
local missing, missingReason = Registry.GetOrCreate("community_alpha_new", "farm")
T.equal(missing, nil, "client cannot create a market")
T.equal(missingReason, "server_authority_required",
    "client market creation is server-authoritative")

T.finish("dt_settlement_market_registry")
