--[[
    Debug trader teleport must use the shared PsychopatzCore teleport.

    A server cannot move a remote player's client by writing its own copy of the
    player, so the previous DTHoomans fallback (`player:setX/setY/setZ`) either
    did nothing in multiplayer or desynchronised the player. These assertions
    pin the shared path plus the two properties that made the old code unsafe:
    no direct position write, and no silent success when the shared service
    refuses or is unavailable.
]]

local T = require "tests/support/test"

local commandHandler
local sent

local rawWrites = {}
local teleportCalls = {}
local teleportResult = true
local teleportReason
local delegated = {}

local player = {
    getUsername = function() return "smoke-player" end,
    setX = function(_, value)
        rawWrites[#rawWrites + 1] = { "setX", value }
    end,
    setY = function(_, value)
        rawWrites[#rawWrites + 1] = { "setY", value }
    end,
    setZ = function(_, value)
        rawWrites[#rawWrites + 1] = { "setZ", value }
    end,
}

Events = {
    OnClientCommand = {
        Add = function(handler) commandHandler = handler end,
    },
}
getSpecificPlayer = function() return nil end
isServer = function() return true end
sendServerCommand = function(target, module, command, payload)
    sent = { target = target, module = module, command = command, args = payload }
end

DTHoomans = {
    MOD_ID = "DTHoomans",
    SPAWN_COMMAND = "SpawnTrader",
}
DTCommon = {
    TraderService = {
        GetRecord = function(traderID)
            if traderID ~= "dt_caravan_one" then return nil end
            return { p = "merchant_one", l = "merchant_one" }
        end,
    },
}
PNC = {
    Registry = {
        Get = function(npcID)
            if npcID == "merchant_one" then
                return {
                    id = npcID, alive = true,
                    x = 1000, y = 2000, z = 0,
                }
            end
            return nil
        end,
    },
    ServerCommandRouter = {
        CanUseDebug = function() return true end,
    },
}
PsychopatzCore = {
    Teleport = {
        ToCoordinates = function(target, x, y, z, options)
            teleportCalls[#teleportCalls + 1] = {
                player = target, x = x, y = y, z = z, options = options,
            }
            if teleportResult == true then return true end
            return false, teleportReason
        end,
    },
}

local function teleport()
    commandHandler("DTHoomans", "DebugTeleportTrader", player, {
        traderID = "dt_caravan_one",
    })
end

T.load("DTHoomans", "server", "DTHoomans/DTHoomans_Server.lua")
T.truthy(commandHandler, "server command handler is registered")

-- ---------------------------------------------------------------------------
-- The fallback path uses the shared teleport exactly once.
-- ---------------------------------------------------------------------------
teleport()
T.equal(#teleportCalls, 1, "shared teleport used for the trader fallback")
T.equal(teleportCalls[1].player, player, "teleport targets the requesting player")
T.equal(teleportCalls[1].x, 1001.5, "teleport offsets the leader in x")
T.equal(teleportCalls[1].y, 2001.5, "teleport offsets the leader in y")
T.equal(teleportCalls[1].z, 0, "teleport keeps the leader level")
T.equal(#rawWrites, 0, "no direct player position write")
T.equal(sent.command, "TraderDebugActionResult", "debug result command")
T.equal(sent.args.accepted, true, "successful teleport is reported")
T.equal(sent.args.reason, "teleported", "successful teleport reason")
T.equal(sent.args.action, "teleport", "debug action identity")

-- ---------------------------------------------------------------------------
-- A refusal is surfaced, and never becomes a raw write.
-- ---------------------------------------------------------------------------
teleportResult = false
teleportReason = "not_authorized"
teleport()
T.equal(#teleportCalls, 2, "refusal still went through the shared service")
T.equal(sent.args.accepted, false, "refusal is reported as not accepted")
T.equal(sent.args.reason, "not_authorized", "shared refusal reason propagates")
T.equal(#rawWrites, 0, "refusal never falls back to a raw write")

teleportReason = nil
teleport()
T.equal(sent.args.reason, "teleport_unavailable",
    "missing refusal reason is normalised")

-- ---------------------------------------------------------------------------
-- The Project Hoomans helper stays the preferred path.
-- ---------------------------------------------------------------------------
teleportResult = true
PNC.ServerDebugCommandHandler = {
    Internal = {
        TeleportPlayerToRecord = function(target, npcID)
            delegated[#delegated + 1] = { player = target, npcID = npcID }
            return true
        end,
    },
}
local callsBefore = #teleportCalls
teleport()
T.equal(#delegated, 1, "PNC helper used when available")
T.equal(delegated[1].player, player, "PNC helper receives the player")
T.equal(delegated[1].npcID, "merchant_one", "PNC helper receives the leader id")
T.equal(#teleportCalls, callsBefore, "shared teleport skipped when PNC handled it")
T.equal(#rawWrites, 0, "delegation performs no raw write")

PNC.ServerDebugCommandHandler.Internal.TeleportPlayerToRecord =
    function() return false end
teleport()
T.equal(#teleportCalls, callsBefore + 1,
    "shared teleport used when the PNC helper refuses")
T.equal(#rawWrites, 0, "PNC refusal performs no raw write")

-- ---------------------------------------------------------------------------
-- With no teleport service at all the player must stay untouched.
-- ---------------------------------------------------------------------------
PNC.ServerDebugCommandHandler = nil
PsychopatzCore = { Teleport = nil }
package.loaded["PsychopatzCore/World/PsychopatzTeleport"] = nil
local previousPreload =
    package.preload["PsychopatzCore/World/PsychopatzTeleport"]
package.preload["PsychopatzCore/World/PsychopatzTeleport"] = function()
    error("teleport service unavailable in test")
end

callsBefore = #teleportCalls
teleport()
T.equal(sent.args.accepted, false, "unavailable teleport service is reported")
T.equal(sent.args.reason, "teleport_unavailable", "unavailable reason reported")
T.equal(#teleportCalls, callsBefore, "no teleport was attempted")
T.equal(#rawWrites, 0, "unavailable teleport service never mutates the player")

package.preload["PsychopatzCore/World/PsychopatzTeleport"] = previousPreload
PsychopatzCore = {
    Teleport = {
        ToCoordinates = function(target, x, y, z)
            teleportCalls[#teleportCalls + 1] = {
                player = target, x = x, y = y, z = z,
            }
            return true
        end,
    },
}

-- ---------------------------------------------------------------------------
-- The pre-existing guards are unchanged.
-- ---------------------------------------------------------------------------
callsBefore = #teleportCalls
commandHandler("DTHoomans", "DebugTeleportTrader", player, {
    traderID = "missing_trader",
})
T.equal(sent.args.reason, "trader_not_found", "unknown trader is rejected")
T.equal(#teleportCalls, callsBefore, "unknown trader is never teleported")
T.equal(#rawWrites, 0, "unknown trader performs no raw write")

PNC.ServerCommandRouter.CanUseDebug = function() return false end
commandHandler("DTHoomans", "DebugTeleportTrader", player, {
    traderID = "dt_caravan_one",
})
T.equal(sent.args.reason, "debug_denied", "debug gate still denies")
T.equal(#teleportCalls, callsBefore, "denied caller is never teleported")
T.equal(#rawWrites, 0, "denied caller performs no raw write")

T.finish("dt_debug_trader_teleport_smoke")
