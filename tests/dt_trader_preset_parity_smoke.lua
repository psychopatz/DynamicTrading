local T = require "tests/support/test"

T.addPackagePaths()

local Presets = require "DTCommon/DTCommon_TraderPresets"

local function hasItem(items, fullType)
    for _, item in ipairs(items or {}) do
        if tostring(item.fullType or item.type) == fullType then
            return true
        end
    end
    return false
end

local plan = Presets.BuildMembers({
    seed = "dt-preset-parity",
    actorPrefix = "dt:preset:test",
    memberCount = 3,
})

T.truthy(plan, "preset plan is built")
T.equal(#plan.memberSpecs, 3, "preset plan preserves member count")

local trader = plan.memberSpecs[1]
local shotgunGuard = plan.memberSpecs[2]
local sidearmGuard = plan.memberSpecs[3]

T.equal(trader.role, "trader", "first member is the trader")
T.equal(trader.presetID, "dt.trader.caravan", "trader uses DT preset")
T.truthy(hasItem(trader.startingItems, "Base.Bag_DuffelBag"),
    "trader carries the dedicated duffle bag")
T.truthy(hasItem(trader.startingItems, "Base.Shirt_FormalWhite"),
    "trader uses dedicated trader clothing")
T.equal(trader.appearance.slots.Back.type, "Base.Bag_DuffelBag",
    "trader appearance includes the duffle bag")

T.equal(shotgunGuard.role, "guard", "second member is a guard")
T.equal(shotgunGuard.presetID, "dt.guard.shotgun",
    "first guard uses dedicated shotgun preset")
T.equal(shotgunGuard.equipment.primaryFullType,
    "Base.DoubleBarrelShotgun", "shotgun guard has stronger weapon")
T.truthy(hasItem(shotgunGuard.startingItems, "Base.ShotgunShells"),
    "shotgun guard carries shells")

T.equal(sidearmGuard.role, "guard", "third member is a guard")
T.equal(sidearmGuard.presetID, "dt.guard.sidearm",
    "second guard uses dedicated sidearm preset")
T.equal(sidearmGuard.equipment.primaryFullType, "Base.Pistol",
    "sidearm guard has a pistol")

local abstractSource = T.read(
    "DTAbstract", "server", "DTAbstract/DTAbstract_TraderWorldProvider.lua")
T.falsy(string.find(abstractSource, "PNC", 1, true),
    "DTAbstract remains independent of Project Hoomans")

local physicalSource = T.read(
    "DTHoomans", "server",
    "DTHoomans/DTHoomans_CaravanService.lua")
T.contains(physicalSource, "BuildMemberSpecs",
    "DTHoomans consumes the shared preset planner")
T.contains(physicalSource, "CreateCanonicalActors",
    "DTHoomans creates the shared Core actor projection")
T.contains(physicalSource, "canonical.memberSpecs",
    "DTHoomans passes canonical member specs to Hoomans")
local generationSource = T.read(
    "DTCommon", "shared", "DTCommon/DTCommon_TraderGeneration.lua")
T.contains(generationSource, "personalInventory",
    "shared generation transports the canonical Core inventory")
T.falsy(string.find(physicalSource, "GUARD_WEAPONS", 1, true),
    "DTHoomans has no duplicate guard loadout")

T.finish("dt_trader_preset_parity_smoke")
