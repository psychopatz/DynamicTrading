-- Thin physical-provider adapter for the shared DTCommon trader manager.

DTHoomans = DTHoomans or {}
local Client = DTHoomans.Client or {}
local Manager = require "DTCommon/DTCommon_TraderManager"

local function player()
    return getSpecificPlayer and getSpecificPlayer(0)
        or (getPlayer and getPlayer() or nil)
end

local function canUseDebug()
    local debugSettings = PsychopatzCore and PsychopatzCore.Debug
    if debugSettings and type(debugSettings.CanUse) == "function" then
        return debugSettings.CanUse(player()) == true
    end
    local pncClient = PNC and PNC.Client
    return pncClient and type(pncClient.CanUseDebug) == "function"
        and pncClient.CanUseDebug() == true
end

local function send(command, args)
    local current = player()
    if not current or type(sendClientCommand) ~= "function" then
        return false, "send_command_unavailable"
    end
    sendClientCommand(current, DTHoomans.MOD_ID, command, args or {})
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

local function action(action, row, args)
    args = type(args) == "table" and args or {}
    local current = player()
    if action == "spawn_near" or action == "spawn_at" then
        if not current then return false, "player_unavailable" end
        local x = args.x or current.getX and current:getX() or 0
        local y = args.y or current.getY and current:getY() or 0
        local z = args.z or current.getZ and current:getZ() or 0
        if action == "spawn_near" then x = x + 25 end
        return send(DTHoomans.SPAWN_COMMAND or "SpawnTrader", {
            x = x, y = y, z = z,
        })
    elseif action == "force_tick" or action == "force_arrival" then
        return send("DebugRoamingTick", {
            traderID = row and row.traderID,
        })
    elseif action == "refresh" then
        if type(Client.RefreshTraderMap) == "function" then
            Client.RefreshTraderMap()
        end
        return send("DebugListTraders", {})
    end

    if not row then return false, "trader_required" end
    if action == "talk" then
        if type(Client.RequestTraderConversation) == "function" then
            return Client.RequestTraderConversation(row.traderID, {
                mode = args.mode or "debug",
                actorID = row.actorID,
                npcID = row.actorID,
            })
        end
        return false, "conversation_unavailable"
    elseif action == "trade" then
        if DTCommon and DTCommon.Client
            and type(DTCommon.Client.OpenTrader) == "function"
        then
            return DTCommon.Client.OpenTrader(row.traderID, {
                mode = "trade",
                npcID = row.actorID,
            })
        end
        return false, "trade_unavailable"
    elseif action == "locate" then
        return locate(row)
    elseif action == "teleport" then
        return send("DebugTeleportTrader", { traderID = row.traderID })
    elseif action == "remove" then
        return false, "physical_remove_unavailable"
    elseif action == "mark_seen" or action == "reset_seen" then
        return false, "discovery_action_unavailable"
    end
    return false, "hoomans_action_unavailable"
end

Manager.RegisterProvider("DTHoomans", {
    authorize = function()
        return canUseDebug()
    end,
    action = action,
})

return Manager
