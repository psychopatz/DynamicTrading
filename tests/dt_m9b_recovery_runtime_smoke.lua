local T = require "tests/support/test"

local authority = true
local modData = {}
local marketKey = "DTCommon.SettlementMarkets"
local traderKey = "DTCommon.Traders"

DTCommon = {
    MARKET_MODDATA_KEY = marketKey,
    MODDATA_KEY = traderKey,
    STATUS_READY = "READY",
    STATUS_AWAY = "AWAY",
}
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
            if tostring(id) == "community_m9b" then
                return { id = id, status = "active" }
            end
            return nil
        end,
    },
}
modData[traderKey] = {
    t = {
        ["trader:m9b"] = {
            s = "AWAY",
            v = 1,
            b = 100,
            ca = {},
        },
    },
}

local savedRequire = require
require = function(moduleName)
    if moduleName == "PsychopatzCore/Inventory/PsychopatzInventory" then
        return {}
    end
    error("unexpected storage dependency: " .. tostring(moduleName))
end
DTCommon.MarketSchema = T.load(
    "DTCommon", "shared", "DTCommon/DTCommon_MarketSchema.lua")
DTCommon.MarketProfiles = T.load(
    "DTCommon", "shared", "DTCommon/DTCommon_MarketProfiles.lua")
DTCommon.Storage = T.load(
    "DTCommon", "shared", "DTCommon/DTCommon_Storage.lua")
require = savedRequire

DTCommon.TraderSupport = {
    Bounded = function(value, maximum)
        value = tostring(value or "")
        return #value > maximum and string.sub(value, 1, maximum) or value
    end,
}
DTCommon.CoreActorPolicy = T.load(
    "DTCommon", "shared", "DTCommon/DTCommon_CoreActorPolicy.lua")
DTCommon.TraderStock = {
    SaveAndTransmit = function() return true end,
}
DTCommon.SettlementMarket = T.load(
    "DTCommon", "shared", "DTCommon/DTCommon_SettlementMarket.lua")

savedRequire = require
require = function(moduleName)
    if moduleName == "DTCommon/DTCommon_CoreActorPolicy" then
        return DTCommon.CoreActorPolicy
    end
    error("unexpected trader-registry dependency: " .. tostring(moduleName))
end
DTCommon.TraderService = T.load(
    "DTCommon", "shared", "DTCommon/DTCommon_TraderRegistry.lua")
require = savedRequire

savedRequire = require
require = function(moduleName)
    if moduleName == "PsychopatzCore/Inventory/PsychopatzInventory" then
        return {}
    end
    if moduleName == "PsychopatzCore/Inventory/PsychopatzInventoryConstants" then
        return {}
    end
    if moduleName == "PsychopatzCore/Economy/PsychopatzCurrency" then
        return {}
    end
    if moduleName == "DTCommon/DTCommon_CoreActorPolicy" then
        return DTCommon.CoreActorPolicy
    end
    error("unexpected trader-service dependency: " .. tostring(moduleName))
end
DTCommon.TraderService = T.load(
    "DTCommon", "shared", "DTCommon/DTCommon_TraderService.lua")
require = savedRequire

local registry = DTCommon.SettlementMarket
local service = DTCommon.TraderService
local created = registry.GetOrCreate("community_m9b", "farm")
T.truthy(created, "recovery runtime market fixture exists")
local shifted = registry.ApplyDelta("community_m9b", {
    categories = {
        Food = { supplyDelta = -0.5, demandDelta = 0.4 },
    },
}, { expectedRevision = 0, now = 10 })
T.truthy(shifted, "normal market mutation moves pressure away from baseline")
T.equal(shifted.categories.Food.supply, 0.35,
    "pressure starts below the farm baseline")

local before = registry.Get("community_m9b")
local visit, visitReason = service.MarkSettlementVisit("trader:m9b", {
    authority = "server",
    atSettlement = true,
    settlementID = "community_m9b",
    visitID = "visit:m9b:runtime",
    now = 30,
})
T.truthy(visit, visitReason)
local after = registry.Get("community_m9b")
T.truthy(after.revision > before.revision,
    "authoritative visit advances the market through production recovery")
T.equal(after.lastUpdateAt, 30,
    "production recovery records the authoritative world time")
T.equal(after.categories.Food.supply, 0.85,
    "production recovery moves supply to the farm baseline")
T.equal(after.categories.Food.demand, 0.25,
    "production recovery moves demand to the farm baseline")

local revision = after.revision
authority = false
local denied, deniedReason = service.MarkSettlementVisit("trader:m9b", {
    authority = "server",
    atSettlement = true,
    settlementID = "community_m9b",
    visitID = "visit:m9b:client",
    now = 40,
})
T.equal(denied, nil, "client cannot use the authoritative visit seam")
T.equal(deniedReason, "server_authority_required",
    "client recovery attempt is rejected")
T.equal(registry.Get("community_m9b").revision, revision,
    "client/read-only path does not mutate market recovery")

return T.finish("dt_m9b_recovery_runtime_smoke")
