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

local record = {
    n = "Orchestrated Trader",
    ca = {
        actorID = "actor:orchestrated",
        provider = "DTAbstract",
        providerState = "abstract",
    },
}
DTCommon = {
    TraderService = {
        ForEach = function(callback)
            callback("trader:orchestrated", record)
        end,
    },
}

local materialized = 0
local dematerialized = 0
DTHoomans = {
    ProviderRuntime = {
        GetPosition = function()
            return { x = 100, y = 100, z = 0 }
        end,
        MaterializeTrader = function(traderID)
            T.equal(traderID, "trader:orchestrated",
                "orchestrator targeted wrong trader")
            materialized = materialized + 1
            record.ca.provider = "DTHoomans"
            record.ca.providerState = "materialized"
            return { actorId = "actor:orchestrated" }
        end,
        DematerializeTrader = function(traderID)
            T.equal(traderID, "trader:orchestrated",
                "orchestrator dematerialized wrong trader")
            dematerialized = dematerialized + 1
            record.ca.provider = "DTAbstract"
            record.ca.providerState = "abstract"
            return { actorId = "actor:orchestrated" }
        end,
    },
}

local projectionPublishes = 0
DTAbstract = {
    ProjectionServer = {
        Publish = function()
            projectionPublishes = projectionPublishes + 1
        end,
    },
}

local Handoff = T.load(
    "DTAbstract", "server", "DTAbstract/DTAbstract_Handoff.lua")

local near = Handoff.Tick(20)
T.equal(near.checked, 1, "near pass did not check trader")
T.equal(near.materialized, 1,
    "production orchestrator did not materialize nearby trader")
T.equal(materialized, 1, "physical runtime was not called")
T.equal(record.ca.provider, "DTHoomans",
    "provider state did not transition")

currentPlayer.x = 1000
local far = Handoff.Tick(21)
T.equal(far.dematerialized, 1,
    "production orchestrator did not dematerialize far trader")
T.equal(dematerialized, 1, "physical runtime dematerialize not called")
T.equal(record.ca.provider, "DTAbstract",
    "provider did not return to abstract")
T.equal(projectionPublishes, 2,
    "provider transitions did not refresh client projection")

T.finish("dt_abstract_handoff_orchestrator_smoke")
