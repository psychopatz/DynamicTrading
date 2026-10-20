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
    elseif command == "TalkOpen" then
        local Talk = DTCommon.TalkService
        local result
        local reason
        if not Talk or type(Talk.Open) ~= "function" then
            result, reason = nil, "talk_service_unavailable"
        else
            result, reason = Talk.Open(player, args.traderID, args.mode, {
                requestID = args.requestID,
                language = args.language,
            })
        end
        log("INFO", "talk_open_response trader=" .. tostring(args.traderID)
            .. " accepted=" .. tostring(result and result.accepted == true)
            .. " reason=" .. tostring(reason))
        send(player, "TalkResult", result or {
            accepted = false,
            traderID = args.traderID,
            mode = args.mode,
            reason = reason or "talk_rejected",
        })
    elseif command == "TalkSubmit" then
        local Talk = DTCommon.TalkService
        local result
        local reason
        if not Talk or type(Talk.Submit) ~= "function" then
            result, reason = nil, "talk_service_unavailable"
        else
            result, reason = Talk.Submit(
                player,
                args.traderID,
                args.sessionID,
                args.text,
                {
                    mode = args.mode,
                    requestID = args.requestID,
                    language = args.language,
                }
            )
        end
        log("INFO", "talk_submit_response trader=" .. tostring(args.traderID)
            .. " accepted=" .. tostring(result and result.accepted == true)
            .. " reason=" .. tostring(reason))
        send(player, "TalkResult", result or {
            accepted = false,
            traderID = args.traderID,
            mode = args.mode,
            reason = reason or "talk_rejected",
        })
    elseif command == "TalkClose" then
        local Talk = DTCommon.TalkService
        local closed
        local reason
        if Talk and type(Talk.Close) == "function" then
            closed, reason = Talk.Close(
                player, args.traderID, args.sessionID, args.mode)
        else
            closed, reason = false, "talk_service_unavailable"
        end
        log("INFO", "talk_close trader=" .. tostring(args.traderID)
            .. " closed=" .. tostring(closed == true)
            .. " reason=" .. tostring(reason))
        send(player, "TalkResult", {
            accepted = closed == true,
            traderID = args.traderID,
            mode = args.mode,
            reason = closed == true and "talk_closed" or reason,
        })
    end
end

if Events and Events.OnClientCommand
    and type(Events.OnClientCommand.Add) == "function"
then
    Events.OnClientCommand.Add(onClientCommand)
end

return DTCommon
