local T = require "tests/support/test"
T.addPackagePaths()

DTCommon = {}
local Providers = T.load(
    "DTCommon",
    "shared",
    "DTCommon/DTCommon_TraderProviderRegistry.lua"
)
DTCommon.TraderProviders = Providers

local traderID = "trader:group:handoff"
local record = {
    ca = {
        actorID = "actor:group:leader",
        provider = "AbstractGroup",
        providerState = "abstract",
        returnProviderID = nil,
    },
}
DTCommon.TraderService = {
    GetRecord = function(id)
        return id == traderID and record or nil
    end,
    ForEach = function(callback)
        callback(traderID, record)
    end,
}

local notifications = {}
DTCommon.TraderWorld = {
    NotifyChange = function(kind, payload)
        notifications[#notifications + 1] = {
            kind = kind,
            payload = payload,
        }
    end,
}

local materializePosition
local rebasedPosition
Providers.Register("AbstractGroup", {
    kind = "abstract",
    priority = 100,
    getPosition = function()
        return { x = 150, y = 200, z = 0 }
    end,
    rebaseMovement = function(_, _, options)
        rebasedPosition = options.position
        return {
            id = "agroup:handoff",
            journey = {
                journeyID = "group_journey:handoff",
                state = "en_route",
            },
        }
    end,
})

Providers.Register("PhysicalFixture", {
    kind = "physical",
    priority = 200,
    materializeTraderPriority = 300,
    materializeTrader = function(_, options)
        materializePosition = options.position
        record.ca.provider = "PhysicalFixture"
        record.ca.providerState = "materialized"
        record.ca.returnProviderID = options.returnProviderID
        return { actorId = record.ca.actorID }, {
            bodyID = "body:handoff",
        }
    end,
    dematerializeTrader = function(_, options)
        T.equal(
            options.returnProviderID,
            "AbstractGroup",
            "return provider was not preserved"
        )
        record.ca.provider = "AbstractGroup"
        record.ca.providerState = "abstract"
        record.ca.returnProviderID = nil
        return { actorId = record.ca.actorID }, {
            position = { x = 175, y = 210, z = 0 },
        }
    end,
})

local Runtime = T.load(
    "DTCommon",
    "server",
    "DTCommon/DTCommon_TraderRepresentationRuntime.lua"
)

local actor, result = Runtime.MaterializeTrader(
    traderID,
    { now = 5 }
)
T.truthy(actor, result)
T.truthy(materializePosition,
    "source-provider position was not passed to materialization")
T.equal(materializePosition.x, 150,
    "materialization did not use group projection X")
T.equal(materializePosition.y, 200,
    "materialization did not use group projection Y")
T.equal(
    record.ca.returnProviderID,
    "AbstractGroup",
    "materialization lost return provider"
)

local resumed, dematResult = Runtime.DematerializeTrader(
    traderID,
    { now = 6 }
)
T.truthy(resumed, dematResult)
T.truthy(rebasedPosition,
    "return provider did not receive physical final position")
T.equal(rebasedPosition.x, 175,
    "group rebase did not receive final body X")
T.equal(rebasedPosition.y, 210,
    "group rebase did not receive final body Y")
T.equal(record.ca.provider, "AbstractGroup",
    "provider did not return to abstract group")
T.equal(#notifications, 2,
    "representation transitions did not emit both notifications")
T.equal(notifications[1].kind, "representation_materialized",
    "materialization notification mismatch")
T.equal(notifications[2].kind, "representation_dematerialized",
    "dematerialization notification mismatch")

T.finish("dt_group_journey_representation_handoff_smoke")
