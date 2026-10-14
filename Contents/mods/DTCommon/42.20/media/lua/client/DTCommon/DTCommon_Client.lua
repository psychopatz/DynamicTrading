DTCommon = DTCommon or {}
DTCommon.Client = DTCommon.Client or {}

local Client = DTCommon.Client
Client.Snapshots = Client.Snapshots or {}
Client.PendingOpen = Client.PendingOpen or {}
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
        -- OpenTrade() requests one fresh snapshot through its endpoint. Do
        -- not issue a second request here when the UI is available.
        local opened = Client.OpenSnapshot(traderID, snapshot)
        if opened == true and PNC and PNC.InventoryWindow
            and PNC.InventoryWindow.OpenTrade
        then
            return true
        end
    end
    return Client.RequestSnapshot(traderID)
end

function Client.OpenSnapshot(traderID, snapshot)
    traderID = tostring(traderID or "")
    local pending = Client.PendingOpen[traderID]
    if pending and pending.mode == "trade"
        and PNC and PNC.InventoryWindow
        and PNC.InventoryWindow.OpenTrade
    then
        local npcID = pending.npcID
            or snapshot and snapshot.physicalNpcID
            or snapshot and snapshot.leaderNPCID
        local window = PNC.InventoryWindow.OpenTrade(
            npcID,
            traderID,
            snapshot,
            {
                requestSnapshot = function()
                    return Client.RequestSnapshot(traderID)
                end,
                commit = function(_, buyRows, sellRows)
                    return Client.SubmitTradeBasket(
                        traderID, buyRows, sellRows
                    )
                end,
            }
        )
        if window then
            log("INFO", "trade_window_opened trader=" .. traderID
                .. " npc=" .. tostring(npcID)
                .. " items=" .. tostring(#((snapshot and snapshot.items) or {})))
            return true
        end
        log("WARN", "trade_window_unavailable trader=" .. traderID)
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
            local opened = false
            if Client.PendingOpen[traderID].mode == "trade"
                and PNC and PNC.InventoryWindow
                and PNC.InventoryWindow.instance
                and PNC.InventoryWindow.instance.tradeMode
                and PNC.InventoryWindow.instance.transferEndpoint
                and tostring(PNC.InventoryWindow.instance.transferEndpoint.id
                    or "") == traderID
            then
                local window = PNC.InventoryWindow.instance
                if window.transferEndpoint
                    and window.transferEndpoint.setSnapshot
                then
                    window.transferEndpoint:setSnapshot(args)
                    window:refreshInventory(true)
                    opened = true
                end
            else
                opened = Client.OpenSnapshot(traderID, args)
            end
            if not opened then
                log("WARN", "trade_open_failed trader=" .. traderID
                    .. " reason=" .. tostring(args.reason))
            end
            Client.PendingOpen[traderID] = nil
        elseif PNC and PNC.InventoryWindow
            and PNC.InventoryWindow.instance
            and PNC.InventoryWindow.instance.tradeMode
            and PNC.InventoryWindow.instance.transferEndpoint
            and tostring(PNC.InventoryWindow.instance.transferEndpoint.id or "")
                == traderID
        then
            local window = PNC.InventoryWindow.instance
            if window.transferEndpoint.setSnapshot then
                window.transferEndpoint:setSnapshot(args)
                window:refreshInventory(true)
            end
        end
    elseif command == "TradeResult" then
        if args.snapshot then Client.Snapshots[traderID] = args.snapshot end
        log("INFO", "trade_result trader=" .. traderID
            .. " accepted=" .. tostring(args.accepted)
            .. " reason=" .. tostring(args.reason))
        if PNC and PNC.InventoryWindow
            and PNC.InventoryWindow.OnTradeResult
            and PNC.InventoryWindow.instance
            and PNC.InventoryWindow.instance.tradeMode
        then
            PNC.InventoryWindow.OnTradeResult(args)
        elseif DTCommon.TradeWindow and DTCommon.TradeWindow.Active then
            if args.snapshot then DTCommon.TradeWindow.Active:SetSnapshot(args.snapshot) end
            DTCommon.TradeWindow.Active:SetResult(args)
        end
    end
end

if Events and Events.OnServerCommand
    and type(Events.OnServerCommand.Add) == "function"
then
    Events.OnServerCommand.Add(onServerCommand)
end

return Client
