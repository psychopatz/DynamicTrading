local T = require "tests/support/test"
T.addPackagePaths()

local Projection =
    require "PsychopatzCore/Actors/PsychopatzActorProjection"

DTCommon = DTCommon or {}
local Directory = T.load(
    "DTCommon", "shared", "DTCommon/DTCommon_SettlementDirectory.lua")

PsychopatzCore = PsychopatzCore or {}
PsychopatzCore.RuntimeRole = {
    AllowsServerCode = function() return true end,
}
DTAbstract = DTAbstract or {}

local Lifecycle = T.load(
    "DTAbstract", "server", "DTAbstract/DTAbstract_Lifecycle.lua")

-- Client-side modules are loaded without engine events; this smoke only locks
-- their bounded cadence constants.
Events = nil
package.preload["PsychopatzCore/00_PsychopatzCore_Init"] =
    function() return PsychopatzCore end
local Nearby = T.load(
    "DTAbstract", "client", "DTAbstract/DTAbstract_NearbyDiscovery.lua")
local Handoff = T.load(
    "DTAbstract", "server", "DTAbstract/DTAbstract_Handoff.lua")

T.equal(Lifecycle.MAX_ABSTRACT_TRADERS, 2,
    "standalone abstract trader population bound changed")
T.equal(Lifecycle.INTERVAL_HOURS, 1,
    "abstract lifecycle simulation cadence changed")
T.equal(Directory.MAX_SETTLEMENTS, 256,
    "settlement directory capacity bound changed")
T.equal(Projection.MAX_ENTRIES, 256,
    "actor projection entry bound changed")
T.equal(Projection.MAX_SNAPSHOT_BYTES, 256 * 1024,
    "actor projection byte bound changed")
T.equal(Nearby.CHECK_INTERVAL_SECONDS, 2,
    "nearby discovery cadence changed")
T.equal(Handoff.CHECK_INTERVAL_MS, 2000,
    "provider handoff cadence changed")

T.finish("dt_abstract_bounds_smoke")
