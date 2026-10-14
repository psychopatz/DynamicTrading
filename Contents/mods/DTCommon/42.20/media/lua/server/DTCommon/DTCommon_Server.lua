DTCommon = DTCommon or {}
local Service = DTCommon.TraderService

local function log(level, message)
    print("[DT][" .. tostring(level) .. "] " .. tostring(message))
end

local function isLocalPlayer(player)
    local localPlayer = getSpecificPlayer and getSpecificPlayer(0) or nil
    if localPlayer ~= nil and player == localPlayer then return true end
    if player and type(player.isLocalPlayer) == "function" then
        local ok, value = pcall(player.isLocalPlayer, player)
        return ok and value == true
    end
    return false
end

local function send(player, command, payload)
    payload = payload or {}
    if isLocalPlayer(player) and type(triggerEvent) == "function" then
        triggerEvent("OnServerCommand", DTCommon.MOD_ID, command, payload)
        return true
    end
    if player and type(sendServerCommand) == "function" then
        sendServerCommand(player, DTCommon.MOD_ID, command, payload)
        return true
    end
    if type(triggerEvent) == "function"
        and (not isServer or not isServer())
    then
        triggerEvent("OnServerCommand", DTCommon.MOD_ID, command, payload)
        return true
    end
    return false
end

local function onClientCommand(module, command, player, args)
    if module ~= DTCommon.MOD_ID then return end
    args = type(args) == "table" and args or {}
    if command == "RequestTrader" then
        log("INFO", "snapshot_request trader=" .. tostring(args.traderID))
        local snapshot, reason = Service.Snapshot(args.traderID, player)
        log("INFO", "snapshot_response trader=" .. tostring(args.traderID)
            .. " items=" .. tostring(snapshot and #(snapshot.items or {}) or 0)
            .. " reason=" .. tostring(reason))
        send(player, "TraderSnapshot", snapshot or {
            traderID = args.traderID,
            reason = reason,
        })
    elseif command == "TradeRequest" then
        log("INFO", "trade_request trader=" .. tostring(args.traderID)
            .. " request=" .. tostring(args.requestID))
        local result = Service.ExecuteTrade(player, args)
        log("INFO", "trade_response trader=" .. tostring(args.traderID)
            .. " accepted=" .. tostring(result and result.accepted)
            .. " reason=" .. tostring(result and result.reason))
        send(player, "TradeResult", result)
    elseif command == "TradeBasketRequest" then
        log("INFO", "trade_basket_request trader=" .. tostring(args.traderID)
            .. " request=" .. tostring(args.requestID))
        local result = Service.ExecuteTradeBasket(player, args)
        log("INFO", "trade_basket_response trader=" .. tostring(args.traderID)
            .. " accepted=" .. tostring(result and result.accepted)
            .. " reason=" .. tostring(result and result.reason))
        send(player, "TradeResult", result)
    end
end

if Events and Events.OnClientCommand
    and type(Events.OnClientCommand.Add) == "function"
then
    Events.OnClientCommand.Add(onClientCommand)
end

return DTCommon
