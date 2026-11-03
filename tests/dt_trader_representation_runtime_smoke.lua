local T = require "tests/support/test"
T.addPackagePaths()

local currentPlayer = {
    x = 110, y = 100,
    getX = function(self) return self.x end,
    getY = function(self) return self.y end,
}
getSpecificPlayer = function() return currentPlayer end
getPlayer = function() return currentPlayer end
isServer = function() return false end
getGameTime = function()
    return { getWorldAgeHours = function() return 20 end }
end
Events = { OnTick = { Add = function() end } }

local records = {
    ["trader:orchestrated"] = {
        n = "Orchestrated Trader",
        ca = {
            actorID = "actor:orchestrated",
            provider = "FixtureAbstract",
            providerState = "abstract",
        },
    },
    ["trader:native"] = {
        n = "Native Physical Trader",
        ca = {
            actorID = "actor:native",
            provider = "FixturePhysical",
            providerState = "materialized",
            returnProviderID = nil,
        },
    },
}

DTCommon = {
    TraderService = {
        ForEach = function(callback)
            for id, record in pairs(records) do callback(id, record) end
        end,
        GetRecord = function(id) return records[id] end,
    },
}
local Providers = T.load(
    "DTCommon", "shared", "DTCommon/DTCommon_TraderProviderRegistry.lua")
DTCommon.TraderProviders = Providers

local changes = {}
DTCommon.TraderWorld = {
    NotifyChange = function(kind, payload)
        changes[#changes + 1] = { kind = kind, payload = payload }
        return true
    end,
}

local materialized = 0
local dematerialized = 0
Providers.Register("FixtureAbstract", {
    kind = "abstract",
    priority = 100,
    getPosition = function(traderID)
        if traderID == "trader:orchestrated" then
            return { x = 100, y = 100, z = 0 }
        end
        return nil
    end,
})
Providers.Register("FixturePhysical", {
    kind = "physical",
    priority = 200,
    materializeTraderPriority = 300,
    getPosition = function(traderID)
        if traderID == "trader:orchestrated" then
            return { x = 100, y = 100, z = 0 }
        end
        if traderID == "trader:native" then
            return { x = 100, y = 100, z = 0 }
        end
    end,
    materializeTrader = function(traderID, options)
        T.equal(traderID, "trader:orchestrated",
            "common representation targeted wrong trader")
        T.equal(options.returnProviderID, "FixtureAbstract",
            "origin provider was not preserved")
        materialized = materialized + 1
        local record = records[traderID]
        record.ca.provider = "FixturePhysical"
        record.ca.providerState = "materialized"
        record.ca.returnProviderID = options.returnProviderID
        return { actorId = record.ca.actorID }
    end,
    dematerializeTrader = function(traderID, options)
        T.equal(traderID, "trader:orchestrated",
            "common representation dematerialized wrong trader")
        T.equal(options.returnProviderID, "FixtureAbstract",
            "return provider was not forwarded")
        dematerialized = dematerialized + 1
        local record = records[traderID]
        record.ca.provider = "FixtureAbstract"
        record.ca.providerState = "abstract"
        record.ca.returnProviderID = nil
        return { actorId = record.ca.actorID }
    end,
})

local Runtime = T.load(
    "DTCommon", "server",
    "DTCommon/DTCommon_TraderRepresentationRuntime.lua")

local near = Runtime.Tick(20)
T.equal(near.checked, 2, "representation pass did not inspect both traders")
T.equal(near.materialized, 1,
    "common runtime did not materialize nearby abstract trader")
T.equal(materialized, 1, "physical provider capability was not called")
T.equal(records["trader:orchestrated"].ca.provider, "FixturePhysical",
    "provider state did not transition")

-- Native physical traders carry no return provider and must remain physical.
currentPlayer.x = 1000
local far = Runtime.Tick(21)
T.equal(far.dematerialized, 1,
    "temporary physical representation did not return abstract")
T.equal(dematerialized, 1,
    "physical dematerialize capability was not called exactly once")
T.equal(records["trader:orchestrated"].ca.provider, "FixtureAbstract",
    "temporary trader did not return to origin provider")
T.equal(records["trader:native"].ca.provider, "FixturePhysical",
    "native physical trader was incorrectly dematerialized")
T.equal(records["trader:native"].ca.returnProviderID, nil,
    "native physical trader gained a fabricated return provider")

T.truthy(#changes >= 2,
    "representation transitions did not emit common change notifications")
T.equal(changes[1].kind, "representation_materialized",
    "materialize change kind mismatch")
T.equal(changes[#changes].kind, "representation_dematerialized",
    "dematerialize change kind mismatch")

T.finish("dt_trader_representation_runtime_smoke")
