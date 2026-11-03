local T = require "tests/support/test"
T.addPackagePaths()

DTCommon = DTCommon or {}
local Directory = T.load(
    "DTCommon", "shared", "DTCommon/DTCommon_SettlementDirectory.lua")
Directory.Reset()

local communities = {
    ["community:test"] = {
        id = "community:test",
        name = "Test Haven",
        status = "active",
        home = { x = 1500, y = 2600, z = 0 },
    },
}
PNC = {
    Communities = {
        Get = function(id) return communities[id] end,
        List = function()
            return { communities["community:test"] }
        end,
    },
}
DTHoomans = {}

local Provider = T.load(
    "DTHoomans", "server",
    "DTHoomans/DTHoomans_SettlementDirectoryProvider.lua")
T.truthy(Provider, "Hoomans settlement provider did not load")

local item = Directory.Get("community:test")
T.truthy(item, "directory did not resolve Hoomans community provider")
T.equal(item.name, "Test Haven", "community name mismatch")
T.equal(item.position.x, 1500, "community X mismatch")
T.equal(item.position.y, 2600, "community Y mismatch")
T.equal(item.provider, "DTHoomans", "provider identity mismatch")

local listed = Directory.List()
T.equal(#listed, 1, "provider list did not enumerate community")
T.equal(listed[1].settlementID, "community:test",
    "provider list settlement ID mismatch")

T.finish("dt_hoomans_settlement_directory_provider_smoke")
