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
local nearbyAbstractGranted = true

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
        IsAuthority = function() return true end,
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
DTCommon.Integrations = {
    ApplyCapacity = function() return nil, nil, "unhandled" end,
    ResolveDisplayName = function() return nil, "unhandled" end,
    ValidateTraderAccess = function(current, currentRecord, mode)
        if currentRecord.a == 1 and mode == "nearby" then
            if nearbyAbstractGranted then
                return true, true
            end
            return true, false, "access_denied"
        end
        local allowed, reason =
            DTHoomans.ValidateTraderAccess(current, currentRecord)
        return true, allowed, reason
    end,
}
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

nearbyAbstractGranted = true
local nearby, nearbyReason = Service.ValidateTalkAccess(
    player, record.traderID, "nearby")
T.truthy(nearby,
    "abstract nearby Talk must use the proximity authorization contract")
T.equal(nearbyReason, nil,
    "abstract nearby Talk returned an unexpected denial")

nearbyAbstractGranted = false
local farNearby, farNearbyReason = Service.ValidateTalkAccess(
    player, record.traderID, "nearby")
T.falsy(farNearby,
    "abstract nearby Talk must deny a stale/out-of-range contact")
T.equal(farNearbyReason, "access_denied",
    "abstract nearby Talk denial must remain explicit")

T.finish("dt_trade_access_security_smoke")
