DTCommon = DTCommon or {}
DTCommon.Client = DTCommon.Client or {}

local Client = DTCommon.Client
local Presentations = DTCommon.TradePresentations
    or require "DTCommon/DTCommon_TradePresentationRegistry"
Client.Snapshots = Client.Snapshots or {}
Client.PendingOpen = Client.PendingOpen or {}
Client.TalkSessions = Client.TalkSessions or {}
Client.RequestSerial = tonumber(Client.RequestSerial) or 0

local function log(level, message)
    print("[DT][" .. tostring(level) .. "] " .. tostring(message))
end

local function player()
    return getSpecificPlayer and getSpecificPlayer(0) or nil
end

function Client.RequestSnapshot(traderID)
    local current = player()
    traderID = tostring(traderID or "")
    if traderID == "" or not current or type(sendClientCommand) ~= "function" then
        log("WARN", "snapshot_request_rejected trader=" .. traderID)
        return false, "client_transport_unavailable"
    end
    log("INFO", "snapshot_request trader=" .. traderID)
    sendClientCommand(current, DTCommon.MOD_ID, "RequestTrader", {
        traderID = traderID,
    })
    return true
end

function Client.OpenTrader(traderID, options)
    options = type(options) == "table" and options or {}
    traderID = tostring(traderID or "")
    if traderID == "" then return false, "trader_id_required" end
    log("INFO", "open_trader trader=" .. traderID
        .. " npc=" .. tostring(options.npcID))
    Client.PendingOpen[traderID] = options.mode == "trade" and {
        mode = "trade",
        npcID = options.npcID and tostring(options.npcID) or nil,
    } or { mode = "legacy" }
    local snapshot = Client.Snapshots[traderID]
    if snapshot then
        -- A registered presentation may open immediately from the cached
        -- snapshot. Otherwise request one fresh authority snapshot.
        local opened = Client.OpenSnapshot(traderID, snapshot)
        if opened == true then return true end
    end
    return Client.RequestSnapshot(traderID)
end

function Client.OpenSnapshot(traderID, snapshot)
    traderID = tostring(traderID or "")
    local pending = Client.PendingOpen[traderID]
    if pending and pending.mode == "trade" then
        local handled, opened = Presentations.Open({
            traderID = traderID,
            snapshot = snapshot,
            pending = pending,
            client = Client,
        })
        if handled and opened then
            log("INFO", "trade_presentation_opened trader=" .. traderID)
            return true
        end
    end
    if DTCommon.TradeWindow then
        DTCommon.TradeWindow.Open(traderID, snapshot)
        log("INFO", "legacy_trade_window_opened trader=" .. traderID)
        return true
    end
    log("WARN", "trade_window_missing trader=" .. traderID)
    return false
end

function Client.SubmitTrade(traderID, operation, fullType, quantity)
    local current = player()
    local snapshot = Client.Snapshots[tostring(traderID or "")]
    if not current or not snapshot or type(sendClientCommand) ~= "function" then
        return false, "trade_transport_unavailable"
    end
    Client.RequestSerial = Client.RequestSerial + 1
    log("INFO", "trade_request trader=" .. tostring(traderID)
        .. " request=" .. tostring(Client.RequestSerial)
        .. " operation=" .. tostring(operation)
        .. " item=" .. tostring(fullType)
        .. " quantity=" .. tostring(quantity))
    sendClientCommand(current, DTCommon.MOD_ID, "TradeRequest", {
        requestID = "dt_trade_" .. tostring(Client.RequestSerial),
        traderID = tostring(traderID),
        operation = operation,
        fullType = fullType,
        quantity = quantity,
        observedStockVersion = snapshot.stockVersion,
        observedQuoteRevision = snapshot.quoteRevision,
    })
    return true
end

function Client.SubmitTradeBasket(traderID, buyRows, sellRows)
    local current = player()
    local snapshot = Client.Snapshots[tostring(traderID or "")]
    if not current or not snapshot or type(sendClientCommand) ~= "function" then
        return false, "trade_transport_unavailable"
    end
    Client.RequestSerial = Client.RequestSerial + 1
    log("INFO", "trade_basket_request trader=" .. tostring(traderID)
        .. " request=" .. tostring(Client.RequestSerial)
        .. " buy=" .. tostring(#(buyRows or {}))
        .. " sell=" .. tostring(#(sellRows or {})))
    sendClientCommand(current, DTCommon.MOD_ID, "TradeBasketRequest", {
        requestID = "dt_trade_basket_" .. tostring(Client.RequestSerial),
        traderID = tostring(traderID),
        buyRows = buyRows or {},
        sellRows = sellRows or {},
        observedStockVersion = snapshot.stockVersion,
        observedQuoteRevision = snapshot.quoteRevision,
    })
    return true
end

-- Talk has its own authenticated server command and session state. It never
-- reuses PendingOpen or the trade snapshot path, so a radio Talk request
-- cannot implicitly open a trade window or authorize an inventory operation.
function Client.RequestTalk(traderID, mode, options)
    local current = player()
    options = type(options) == "table" and options or {}
    traderID = tostring(traderID or "")
    mode = tostring(mode or "radio")
    if traderID == "" or not current
        or type(sendClientCommand) ~= "function"
    then
        log("WARN", "talk_request_rejected trader=" .. traderID)
        return false, "talk_transport_unavailable"
    end
    Client.RequestSerial = Client.RequestSerial + 1
    local requestID = "dt_talk_open_" .. tostring(Client.RequestSerial)
    log("INFO", "talk_open_request trader=" .. traderID
        .. " mode=" .. mode .. " request=" .. requestID)
    sendClientCommand(current, DTCommon.MOD_ID, "TalkOpen", {
        requestID = requestID,
        traderID = traderID,
        mode = mode,
        npcID = options.npcID,
        language = options.language,
    })
    return true, requestID
end

function Client.SubmitTalk(traderID, talkSessionID, text, mode, language)
    local current = player()
    traderID = tostring(traderID or "")
    if traderID == "" or tostring(talkSessionID or "") == ""
        or not current or type(sendClientCommand) ~= "function"
    then
        return false, "talk_transport_unavailable"
    end
    Client.RequestSerial = Client.RequestSerial + 1
    local requestID = "dt_talk_turn_" .. tostring(Client.RequestSerial)
    sendClientCommand(current, DTCommon.MOD_ID, "TalkSubmit", {
        requestID = requestID,
        traderID = traderID,
        sessionID = tostring(talkSessionID),
        mode = tostring(mode or "radio"),
        text = tostring(text or ""),
        language = language,
    })
    return true, requestID
end

function Client.CloseTalk(traderID, talkSessionID, mode)
    local current = player()
    traderID = tostring(traderID or "")
    if traderID == "" or tostring(talkSessionID or "") == ""
        or not current or type(sendClientCommand) ~= "function"
    then
        return false, "talk_transport_unavailable"
    end
    sendClientCommand(current, DTCommon.MOD_ID, "TalkClose", {
        traderID = traderID,
        sessionID = tostring(talkSessionID),
        mode = tostring(mode or "radio"),
    })
    Client.TalkSessions[traderID] = nil
    return true
end

local function onServerCommand(module, command, args)
    if module ~= DTCommon.MOD_ID then return end
    args = type(args) == "table" and args or {}
    local traderID = tostring(args.traderID or "")
    if traderID == "" then
        log("WARN", "server_command_missing_trader command=" .. tostring(command))
        return
    end
    if command == "TraderSnapshot" then
        Client.Snapshots[traderID] = args
        log("INFO", "snapshot_received trader=" .. traderID
            .. " items=" .. tostring(#(args.items or {}))
            .. " reason=" .. tostring(args.reason))
        if Client.PendingOpen[traderID] then
            local opened = Presentations.UpdateSnapshot({
                traderID = traderID,
                snapshot = args,
                pending = Client.PendingOpen[traderID],
                client = Client,
            })
            if not opened then
                opened = Client.OpenSnapshot(traderID, args)
            end
            if not opened then
                log("WARN", "trade_open_failed trader=" .. traderID
                    .. " reason=" .. tostring(args.reason))
            end
            Client.PendingOpen[traderID] = nil
        else
            Presentations.UpdateSnapshot({
                traderID = traderID,
                snapshot = args,
                client = Client,
            })
        end
    elseif command == "TradeResult" then
        if args.snapshot then Client.Snapshots[traderID] = args.snapshot end
        log("INFO", "trade_result trader=" .. traderID
            .. " accepted=" .. tostring(args.accepted)
            .. " reason=" .. tostring(args.reason))
        local handled = Presentations.HandleResult({
            traderID = traderID,
            result = args,
            snapshot = args.snapshot,
            client = Client,
        })
        if not handled and DTCommon.TradeWindow
            and DTCommon.TradeWindow.Active
        then
            if args.snapshot then
                DTCommon.TradeWindow.Active:SetSnapshot(args.snapshot)
            end
            DTCommon.TradeWindow.Active:SetResult(args)
        end
    elseif command == "TalkResult" then
        Client.TalkSessions[traderID] = args
        log("INFO", "talk_result trader=" .. traderID
            .. " accepted=" .. tostring(args.accepted)
            .. " reason=" .. tostring(args.reason))
        if type(Client.OnTalkResult) == "function" then
            Client.OnTalkResult(args)
        end
    end
end

if Events and Events.OnServerCommand
    and type(Events.OnServerCommand.Add) == "function"
then
    Events.OnServerCommand.Add(onServerCommand)
end

return Client
