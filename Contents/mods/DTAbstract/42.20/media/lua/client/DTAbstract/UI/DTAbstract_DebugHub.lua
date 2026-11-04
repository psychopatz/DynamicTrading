-- Thin DTAbstract authorization/transport adapter for the shared trader
-- manager. The trader model and window live in DTCommon.

DTAbstract = DTAbstract or {}
DTAbstract.DebugHub = DTAbstract.DebugHub or {}

local DebugHub = DTAbstract.DebugHub
local Manager = require "DTCommon/DTCommon_TraderManager"
local CoreClient = require
    "PsychopatzCore/World/SurvivorWorld/PsychopatzSurvivorWorldClient"

DebugHub.LastResult = DebugHub.LastResult or nil
DebugHub.LastSpawn = DebugHub.LastSpawn or nil

local function player()
    return getSpecificPlayer and getSpecificPlayer(0)
        or (getPlayer and getPlayer() or nil)
end

local function canUseDebug()
    local current = player()
    if not current then return true end
    local debugSettings = PsychopatzCore and PsychopatzCore.Debug
    if debugSettings and type(debugSettings.CanUse) == "function" then
        return debugSettings.CanUse(current) == true
    end
    return false
end

local function sendAbstract(command, args)
    local current = player()
    if not current or type(sendClientCommand) ~= "function" then
        return false, "send_command_unavailable"
    end
    sendClientCommand(current, "DTAbstract", command, args or {})
    return true
end

local function sendCommonSpawn(x, y, z)
    local current = player()
    if not current or type(sendClientCommand) ~= "function" then
        return false, "send_command_unavailable"
    end
    sendClientCommand(
        current,
        DTCommon.MOD_ID or "DTCommon",
        "DebugSpawnTrader",
        { x = tonumber(x), y = tonumber(y), z = tonumber(z) or 0 }
    )
    return true
end

local function locate(row)
    if not row or not row.position then
        return false, "trader_position_unavailable"
    end
    pcall(require, "ISUI/Maps/ISWorldMap")
    if ISWorldMap and type(ISWorldMap.ShowWorldMap) == "function" then
        ISWorldMap.ShowWorldMap(
            0, row.position.x, row.position.y, 18.0)
    elseif ISWorldMap_ToggleMap then
        ISWorldMap_ToggleMap()
    end
    return true, row.position
end

local function providerAction(action, row, args)
    args = type(args) == "table" and args or {}
    if action == "refresh" then
        local actors = CoreClient.RequestActors()
        local discovery = CoreClient.RequestDiscovery()
        return actors == true or discovery == true
    elseif action == "spawn_near" then
        local current = player()
        if not current then return false, "player_unavailable" end
        local x = current.getX and tonumber(current:getX()) or nil
        local y = current.getY and tonumber(current:getY()) or nil
        local z = current.getZ and tonumber(current:getZ()) or 0
        if not x or not y then return false, "player_position_unavailable" end
        return sendCommonSpawn(x + 25, y, z)
    elseif action == "spawn_at" then
        local current = player()
        local x = args.x or current and current.getX and current:getX()
        local y = args.y or current and current.getY and current:getY()
        local z = args.z or current and current.getZ and current:getZ() or 0
        return sendCommonSpawn(x, y, z)
    elseif action == "force_tick" then
        return sendAbstract("ForceTick", { now = args.now })
    end

    if not row then return false, "trader_required" end
    if action == "talk" then
        local Bridge = DTAbstract.CoreConversation
            or require "DTAbstract/DTAbstract_CoreConversation"
        return Bridge.Request(
            row.traderID,
            args.mode or "debug",
            {
                actorID = row.actorID,
                displayName = row.name or row.displayName,
            }
        )
    elseif action == "trade" then
        if DTCommon and DTCommon.Client
            and type(DTCommon.Client.OpenTrader) == "function"
        then
            return DTCommon.Client.OpenTrader(row.traderID, {
                mode = "trade",
                actorID = row.actorID,
            })
        end
        return false, "trade_unavailable"
    elseif action == "locate" then
        return locate(row)
    elseif action == "force_arrival" then
        return sendAbstract("ForceArrival", { traderID = row.traderID })
    elseif action == "teleport" then
        return sendAbstract("TeleportToTrader", { traderID = row.traderID })
    elseif action == "remove" then
        return sendAbstract("RemoveTrader", { traderID = row.traderID })
    elseif action == "mark_seen" then
        if DTAbstract.NearbyDiscovery
            and type(DTAbstract.NearbyDiscovery.MarkDiscovered)
                == "function"
        then
            return DTAbstract.NearbyDiscovery.MarkDiscovered(row.traderID)
        end
        return false, "discovery_unavailable"
    elseif action == "reset_seen" then
        if DTAbstract.NearbyDiscovery
            and type(DTAbstract.NearbyDiscovery.ResetDiscovery)
                == "function"
        then
            return DTAbstract.NearbyDiscovery.ResetDiscovery(row.traderID)
        end
        return false, "discovery_unavailable"
    end
    return false, "abstract_action_unavailable"
end

Manager.RegisterProvider("DTAbstract", {
    authorize = function()
        return canUseDebug()
    end,
    action = providerAction,
})

function DebugHub.ListTraders(force)
    return Manager.ListTraders(force == true)
end

function DebugHub.RefreshProjection()
    local actors, actorReason = CoreClient.RequestActors()
    local discovery, discoveryReason = CoreClient.RequestDiscovery()
    if actors or discovery then return true end
    return false, actorReason or discoveryReason
end

function DebugHub.SpawnNear()
    return Manager.Action("spawn_near", nil)
end

function DebugHub.SpawnAt(x, y, z)
    return Manager.Action("spawn_at", nil, { x = x, y = y, z = z })
end

function DebugHub.ForceTick(now)
    return Manager.Action("force_tick", nil, { now = now })
end

function DebugHub.ForceArrival(traderID)
    return Manager.Action("force_arrival", traderID)
end

function DebugHub.TeleportToTrader(traderID)
    return Manager.Action("teleport", traderID)
end

function DebugHub.RemoveTrader(traderID)
    return Manager.Action("remove", traderID)
end

function DebugHub.OpenDebugTalk(traderID)
    return Manager.Action("talk", traderID, { mode = "debug" })
end

function DebugHub.LocateOnMap(traderID)
    return Manager.Action("locate", traderID)
end

function DebugHub.ResetDiscovery(traderID)
    return Manager.Action("reset_seen", traderID)
end

function DebugHub.MarkDiscovery(traderID)
    return Manager.Action("mark_seen", traderID)
end

function DebugHub.Open()
    return Manager.Open()
end

local function onServerCommand(module, command, args)
    args = type(args) == "table" and args or {}
    if module == "DTAbstract"
        and (command == "TraderDebugActionResult"
            or command == "TraderSpawned")
    then
        DebugHub.LastResult = args
        if command == "TraderSpawned" then
            DebugHub.LastSpawn = args
        end
        Manager.SetResult(
            tostring(args.accepted == false and "FAILED" or "OK")
                .. " " .. tostring(args.action or command)
                .. (args.reason and (" (" .. tostring(args.reason) .. ")")
                    or ""),
            args
        )
    elseif module == (DTCommon.MOD_ID or "DTCommon")
        and command == "TraderDebugSpawnResult"
    then
        DebugHub.LastSpawn = args
        local feedback = {
            accepted = args.accepted == true,
            action = args.pending == true and "spawn_queued" or "spawn",
            reason = args.reason,
            traderID = args.traderID,
            actorID = args.actorID,
        }
        DebugHub.LastResult = feedback
        Manager.SetResult(
            tostring(feedback.accepted and "OK" or "FAILED")
                .. " " .. feedback.action
                .. (feedback.reason
                    and (" (" .. tostring(feedback.reason) .. ")") or ""),
            feedback
        )
    end
end

if Events and Events.OnServerCommand
    and type(Events.OnServerCommand.Add) == "function"
    and not DebugHub._serverCommandHook
then
    DebugHub._serverCommandHook = true
    Events.OnServerCommand.Add(onServerCommand)
end

return DebugHub
