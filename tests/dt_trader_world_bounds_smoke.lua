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

DTCommon.Storage = DTCommon.Storage or {
    IsAuthority = function() return true end,
}
DTCommon.TraderService = DTCommon.TraderService or {
    ForEach = function() end,
}
local TraderWorld = T.load(
    "DTCommon", "shared", "DTCommon/DTCommon_TraderWorld.lua")
local Providers = DTCommon.TraderProviders
local Integrations = T.load(
    "DTCommon", "shared", "DTCommon/DTCommon_IntegrationRegistry.lua")
local Contacts = T.load(
    "DTCommon", "client", "DTCommon/DTCommon_TraderContacts.lua")

-- Client-side modules are loaded without engine events; this smoke only locks
-- their bounded cadence constants.
Events = nil
package.preload["PsychopatzCore/00_PsychopatzCore_Init"] =
    function() return PsychopatzCore end
local Nearby = T.load(
    "DTAbstract", "client", "DTAbstract/DTAbstract_NearbyDiscovery.lua")
local Representation = T.load(
    "DTCommon", "server",
    "DTCommon/DTCommon_TraderRepresentationRuntime.lua")

T.equal(TraderWorld.MAX_ROAMING_TRADERS, 2,
    "canonical roaming trader population bound changed")
T.equal(TraderWorld.INTERVAL_HOURS, 1,
    "canonical trader-world simulation cadence changed")
T.equal(Directory.MAX_SETTLEMENTS, 256,
    "settlement directory capacity bound changed")
T.equal(Providers.MAX_PROVIDERS, 16,
    "provider registry capacity bound changed")
T.equal(Integrations.MAX_ADAPTERS, 16,
    "integration adapter capacity bound changed")
T.equal(Contacts.MAX_CONTACTS, 64,
    "contact enumeration bound changed")
T.equal(Contacts.MAX_PAGE_SIZE, 12,
    "contact page bound changed")
T.equal(Projection.MAX_ENTRIES, 256,
    "actor projection entry bound changed")
T.equal(Projection.MAX_SNAPSHOT_BYTES, 256 * 1024,
    "actor projection byte bound changed")
T.equal(Nearby.CHECK_INTERVAL_SECONDS, 2,
    "nearby discovery cadence changed")
T.equal(Representation.CHECK_INTERVAL_MS, 2000,
    "common representation handoff cadence changed")

T.finish("dt_trader_world_bounds_smoke")
