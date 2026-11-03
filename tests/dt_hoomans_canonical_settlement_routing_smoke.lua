local T = require "tests/support/test"
T.addPackagePaths()

DTCommon = {
    Storage = {
        IsAuthority = function() return true end,
    },
}
local Directory = T.load(
    "DTCommon",
    "shared",
    "DTCommon/DTCommon_SettlementDirectory.lua"
)
Directory.Reset()

local canonical = {
    settlementID = "community:test",
    name = "Test Haven",
    position = { x = 1500, y = 2600, z = 0 },
    provider = "PsychopatzCore",
    enabled = true,
}
Directory.RegisterProvider("PsychopatzCore", {
    Get = function(id)
        if id == canonical.settlementID then return canonical end
    end,
    List = function() return { canonical } end,
})

local faction = {
    id = "faction:test",
    status = "active",
}
PNC = {
    Factions = {
        Get = function(id)
            return id == faction.id and faction or nil
        end,
    },
    MobileGroupDirectorInternal = {
        ResolveSettlementDepartureTargets = function()
            return {
                {
                    communityID = "community:test",
                    x = 1500,
                    y = 2600,
                    z = 0,
                },
            }
        end,
    },
    MobileSettlementVisitService = {
        IsSettlementVisitEligible = function()
            return true
        end,
    },
}
DTHoomans = {}

local Providers = T.load(
    "DTCommon",
    "shared",
    "DTCommon/DTCommon_TraderProviderRegistry.lua"
)
DTCommon.TraderProviders = Providers
DTCommon.SettlementDirectory = Directory
DTCommon.TraderService = {}

local Provider = T.load(
    "DTHoomans",
    "server",
    "DTHoomans/DTHoomans_TraderWorldProvider.lua"
)
T.truthy(Provider, "Hoomans trader provider did not load")

local item = Directory.Get("community:test")
T.truthy(item, "Core settlement did not resolve")
T.equal(
    item.provider,
    "PsychopatzCore",
    "DTHoomans must not replace canonical settlement provider identity"
)
T.equal(item.position.x, 1500, "community X mismatch")
T.equal(item.position.y, 2600, "community Y mismatch")

T.truthy(
    Provider.canTravelTo(
        "trader:test",
        { g = faction.id },
        item,
        10
    ),
    "DTHoomans travel must accept canonical Core community identity"
)

local initSource = T.read(
    "DTHoomans",
    "server",
    "DTHoomans/00_DTHoomans_Server_Init.lua"
)
T.falsy(
    string.find(
        initSource,
        "DTHoomans_SettlementDirectoryProvider",
        1,
        true
    ),
    "DTHoomans must not load a second settlement directory authority"
)

T.finish("dt_hoomans_settlement_directory_provider_smoke")
