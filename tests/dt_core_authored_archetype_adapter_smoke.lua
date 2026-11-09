local T = require "tests/support/test"

T.addPackagePaths()

local Actors = require "PsychopatzCore/Actors/PsychopatzActors"
PsychopatzCore = PsychopatzCore or {}
PsychopatzCore.Actors = Actors

local Presets = T.load(
    "DTCommon", "shared", "DTCommon/DTCommon_TraderPresets.lua")
T.truthy(Presets.RegisterCoreArchetypes,
    "DT Core archetype registration API")

local trader = Actors.Archetypes:Get("dt.trader.caravan")
local guard = Actors.Archetypes:Get("dt.guard.shotgun")
T.truthy(trader, "Core trader archetype registered")
T.truthy(guard, "Core guard archetype registered")
T.equal(trader.role, "trader", "trader role preserved")
T.equal(guard.role, "guard", "guard role preserved")
T.equal(guard.inventory.items[5].fullType, "Base.DoubleBarrelShotgun",
    "guard weapon uses shared item contract")
T.equal(guard.inventory.items[6].quantity, 12,
    "guard ammunition uses shared quantity contract")
T.equal(Actors.Archetypes:Get("dt.guard.shotgun").id,
    "dynamictrading.dt.guard.shotgun", "DT canonical archetype ID")

local plan = Presets.BuildMembers({
    seed = "dt-core-archetype-adapter",
    actorPrefix = "dt:core:archetype",
    memberCount = 2,
})
T.truthy(plan, "DT member plan still builds")
T.equal(plan.memberSpecs[1].presetID, "dt.trader.caravan",
    "DT generation still selects trader preset")
T.equal(plan.memberSpecs[2].presetID, "dt.guard.shotgun",
    "DT generation still selects guard preset")
T.equal(plan.memberSpecs[1].coreArchetypeID,
    "dynamictrading.dt.trader.caravan",
    "DT member carries the canonical Core archetype ID")
T.equal(plan.memberSpecs[2].appearance.resolved.outfitItemSpecs[1].type,
    "Base.Hat_BalaclavaFace",
    "DT member appearance comes from the Core plan")

local actorRegistry = Actors.NewRegistry()
local member = plan.memberSpecs[1]
local actor, actorReason = actorRegistry:Create({
    actorId = member.actorID,
    archetypeID = member.coreArchetypeID,
    identitySeed = member.identitySeed,
    identity = member.identity,
    appearance = member.appearance,
    starterItems = member.startingItems,
})
T.truthy(actor, actorReason)
local portrait, portraitReason = Actors.Presentation.BuildPortrait(actor)
T.truthy(portrait, portraitReason)
T.equal(portrait.actorID, actor.actorId,
    "DTAbstract actor uses the shared Core portrait contract")
T.equal(
    portrait.appearance.outfitItemSpecs[1].type,
    member.appearance.resolved.outfitItemSpecs[1].type,
    "DT portrait uses the same clothing projection as Hoomans")

T.finish("dt_core_authored_archetype_adapter_smoke")
