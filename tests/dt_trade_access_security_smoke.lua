local T = require "tests/support/test"

local record = {
    traderID = "settlement-near",
    s = "READY",
    a = 0,
    p = "merchant",
    l = "merchant",
    g = "faction-one",
    v = 1,
}
local body = {
    getX = function() return 103 end,
    getY = function() return 104 end,
    isDead = function() return false end,
}
local player = {
    getX = function() return 100 end,
    getY = function() return 100 end,
}
local radioPresent = false

package.preload["PsychopatzCore/Inventory/PsychopatzInventory"] =
    function() return {} end
package.preload["PsychopatzCore/Inventory/PsychopatzInventoryConstants"] =
    function() return {} end
package.preload["PsychopatzCore/Economy/PsychopatzCurrency"] =
    function() return {} end

PsychopatzCore = {
    RadioDeviceState = {
        FindActivePlayerDevice = function()
            return radioPresent and {} or nil
        end,
    },
}
DTCommon = {
    STATUS_READY = "READY",
    Storage = {
        LoadInventory = function() return {} end,
    },
    TraderStock = {
        SnapshotItems = function() return {} end,
    },
    TraderSupport = {},
    TraderService = {},
}
PNC = {
    Registry = {
        GetLiveZombie = function(id)
            return id == "merchant" and body or nil
        end,
        Get = function(id)
            return id == "merchant" and { id = id } or nil
        end,
    },
    Factions = {
        GetNPCAffiliation = function()
            return { role = "trader", factionID = "faction-one" }
        end,
    },
}
DTHoomans = { MOD_ID = "DTHoomans", SPAWN_COMMAND = "SpawnTrader" }
Events = { OnClientCommand = { Add = function() end } }

T.load("DTHoomans", "server", "DTHoomans/DTHoomans_Server.lua")
local Service = T.load(
    "DTCommon", "shared", "DTCommon/DTCommon_TraderService.lua")
DTCommon.TraderService.GetRecord = function() return record end
DTCommon.TraderService.Get = function(_, id)
    return { traderID = id, stockVersion = record.v, items = {} }
end

local snapshot, reason = Service.Snapshot(record.traderID, player)
T.truthy(snapshot, "nearby physical merchant is permitted: " .. tostring(reason))
T.equal(reason, nil, "nearby physical merchant has no denial reason")

body.getX = function() return 200 end
body.getY = function() return 200 end
local denied, deniedReason = Service.Snapshot(record.traderID, player)
T.falsy(denied, "far physical merchant is denied")
T.equal(deniedReason, "access_denied", "far physical denial is explicit")

body.getX = function() return 103 end
body.getY = function() return 104 end
PNC.Factions.GetNPCAffiliation = function()
    return { role = "guard", factionID = "faction-one" }
end
local wrongRole, wrongRoleReason = Service.Snapshot(record.traderID, player)
T.falsy(wrongRole, "wrong-role nearby body is denied")
T.equal(wrongRoleReason, "merchant_role_invalid",
    "wrong role does not grant trade access")

record.a = 1
record.p = "abstract-only"
PNC.Factions.GetNPCAffiliation = function()
    return { role = "trader", factionID = "faction-one" }
end
radioPresent = false
local noRadio, noRadioReason = Service.Snapshot(record.traderID, player)
T.falsy(noRadio, "abstract trader requires an active radio")
T.equal(noRadioReason, "radio_required", "radio denial is explicit")
radioPresent = true
local remote, remoteReason = Service.Snapshot(record.traderID, player)
T.truthy(remote, "abstract trader is allowed with an active radio")
T.equal(remoteReason, nil, "remote access has no denial reason")

T.finish("dt_trade_access_security_smoke")
