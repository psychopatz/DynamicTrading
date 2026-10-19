local T = require "tests/support/test"

local coreRepository = os.getenv("PZ_TEST_CORE_REPOSITORY")
    or "../psychopatzCore"
package.path = coreRepository
    .. "/Contents/mods/PsychopatzCore/common/media/lua/shared/?.lua;"
    .. package.path

local Actors = require "PsychopatzCore/Actors/PsychopatzActors"
local core = { Actors = Actors }
local registry = Actors.NewRegistry()
local actor, actorReason = registry:Create({
    actorId = "npc:p8:dt-adapter",
    identitySeed = "p8-dt-adapter-seed",
    world = { position = { x = 20, y = 21, z = 0 } },
})
T.truthy(actor, actorReason)

DTAbstract = {}
local abstract = dofile(T.repository
    .. "/Contents/mods/DTAbstract/42.20/media/lua/shared/DTAbstract/"
    .. "DTAbstract_CoreProvider.lua")
local acquired, acquireReason = abstract.Acquire(actor, core, {
    owner = "radio:provider",
    now = 1,
})
T.truthy(acquired, acquireReason)
T.equal(acquired.providerLease.provider, "DTAbstract",
    "DTAbstract lease provider")
local abstractProjection, projectionReason = abstract.Project(acquired, core)
T.truthy(abstractProjection, projectionReason)
T.equal(abstractProjection.identity.identitySeed,
    acquired.identity.identitySeed, "DTAbstract identity projection")
local released, releaseReason = abstract.Release(acquired, core, {
    owner = "radio:provider",
    now = 2,
})
T.truthy(released, releaseReason)

DTHoomans = {}
local hoomans = T.load(
    "DTHoomans", "shared", "DTHoomans/DTHoomans_CoreProvider.lua")
local hoomansActor, hoomansReason = hoomans.Acquire(released, core, {
    owner = "hoomans:body",
    now = 3,
})
T.truthy(hoomansActor, hoomansReason)
local applied = false
local materialized, materializeReason = hoomans.Materialize(
    hoomansActor, core, {
        owner = "hoomans:body",
        now = 4,
        bodyFactory = function(projection)
            return "body:p8:dt", { projection = projection }
        end,
        applyProjection = function(body, projection)
            applied = body.projection.identity.identitySeed
                == projection.identity.identitySeed
                and body.projection.personalInventory.items[1].itemId
                    == projection.personalInventory.items[1].itemId
            return applied
        end,
    }
)
T.truthy(materialized, materializeReason)
T.equal(materialized.bodyID, "body:p8:dt", "DTHoomans body id")
T.truthy(applied, "DTHoomans applies canonical appearance and inventory")
T.equal(materialized.actor.providerLease.state, "materialized",
    "DTHoomans materialized lease")

local persisted = false
local destroyed = false
local dematerialized, dematerializeReason = hoomans.Dematerialize(
    materialized.actor, core, {
        owner = "hoomans:body",
        body = materialized.body,
        now = 5,
        persist = function(projection)
            persisted = projection.social ~= nil
                and projection.world ~= nil
            return persisted
        end,
        cleanup = function(body)
            destroyed = body == materialized.body
        end,
    }
)
T.truthy(dematerialized, dematerializeReason)
T.truthy(persisted, "DTHoomans persists social and world state")
T.truthy(destroyed, "DTHoomans releases one body")
T.equal(dematerialized.actor.providerLease.state, "abstract",
    "DTHoomans dematerialized lease")

print("dt_npc_provider_adapter_smoke: PASS")
