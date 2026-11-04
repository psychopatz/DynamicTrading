local T = require "tests/support/test"
T.addPackagePaths()

local abstractCall
local liveCall

DTCommon = {}
package.preload["DTCommon/DTCommon_CoreTraderCandidateFactory"] = function()
    return {
        Create = function(spec)
            abstractCall = spec
            return {
                actorID = "actor:abstract",
                groupID = "group:abstract",
            }, nil
        end,
    }
end

local Generation = require "DTCommon/DTCommon_TraderGeneration"
T.truthy(Generation, "shared trader generation facade loads")

local abstract, abstractReason = Generation.GenerateForFaction({
    provider = "DTAbstract",
    presenceMode = "abstract",
    position = { x = 10, y = 20, z = 0 },
    memberCount = 3,
    createdAt = 4,
})
T.truthy(abstract, abstractReason)
T.equal(abstract.actorID, "actor:abstract",
    "abstract mode uses the Core canonical candidate path")
T.truthy(abstractCall, "abstract generation reached the Core factory")
T.equal(abstractCall.presenceMode, "abstract",
    "abstract mode remains explicit at the shared boundary")

local registered = Generation.RegisterProvider("DTHoomans", {
    GenerateForFaction = function(spec)
        liveCall = spec
        return true, "generated", { npcIDs = { "npc:live" } }
    end,
})
T.truthy(registered, "live provider adapter registers")

local liveOK, liveReason, live = Generation.GenerateForFaction({
    provider = "DTHoomans",
    presenceMode = "live",
    factionID = "faction:live",
    nativeSpec = { groupSize = 1 },
})
T.truthy(liveOK, liveReason)
T.equal(liveReason, "generated", "live adapter result is preserved")
T.equal(live.npcIDs[1], "npc:live", "live adapter payload is preserved")
T.truthy(liveCall, "live generation reached the registered provider")
T.equal(liveCall.presenceMode, "live",
    "live mode remains explicit at the provider boundary")
T.equal(liveCall.factionID, "faction:live",
    "shared facade forwards the faction identity")

local autoOK, autoReason = Generation.GenerateForFaction({
    provider = "DTHoomans",
    presenceMode = "auto",
    factionID = "faction:auto",
    nativeSpec = {},
})
T.truthy(autoOK, autoReason)
T.equal(liveCall.presenceMode, "auto",
    "auto mode is delegated to the materialization provider")

local invalid, invalidReason = Generation.GenerateForFaction({
    provider = "DTHoomans",
    presenceMode = "unsupported",
})
T.falsy(invalid, "unsupported presence mode is rejected")
T.equal(invalidReason, "unsupported_presence_mode",
    "unsupported presence mode has a stable reason")

local missing, missingReason = Generation.GenerateForFaction({
    provider = "MissingProvider",
    presenceMode = "live",
})
T.falsy(missing, "unregistered live provider is rejected")
T.equal(missingReason, "provider_generation_unavailable",
    "missing live provider has a stable reason")

local caravanSource = T.read(
    "DTHoomans", "server",
    "DTHoomans/DTHoomans_CaravanService.lua")
T.contains(caravanSource, "TraderGeneration.GenerateForFaction",
    "DTHoomans routes faction generation through the shared facade")

local abstractSource = T.read(
    "DTAbstract", "server",
    "DTAbstract/DTAbstract_TraderWorldProvider.lua")
T.contains(abstractSource, "DTCommon/DTCommon_TraderGeneration",
    "DTAbstract uses the shared generation facade")
T.falsy(string.find(abstractSource, "CoreTraderCandidateFactory", 1, true),
    "DTAbstract does not retain a provider-owned generator dependency")

T.finish("dt_trader_generation_contract_smoke")
