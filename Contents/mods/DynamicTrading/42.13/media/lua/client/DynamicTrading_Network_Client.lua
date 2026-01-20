if not isClient() then return end

DynamicTrading_Client = {}
DynamicTrading_Client.Cache = {
    Traders = {},
    Factions = {},
    Stocks = {}
}

local COMMAND_MODULE = "DynamicTrading_V2"

-- =============================================================================
-- API METHODS (UI Should Call These)
-- =============================================================================

function DynamicTrading_Client.RequestTraderData(traderID)
    sendClientCommand(getPlayer(), COMMAND_MODULE, "RequestTrader", { traderID = traderID })
end

function DynamicTrading_Client.RequestFactionData(factionID)
    sendClientCommand(getPlayer(), COMMAND_MODULE, "RequestFaction", { factionID = factionID })
end

function DynamicTrading_Client.RequestStock(traderID)
    sendClientCommand(getPlayer(), COMMAND_MODULE, "RequestStock", { traderID = traderID })
end

function DynamicTrading_Client.PerformTrade(type, traderID, itemFullType, qty)
    local args = {
        type = type,
        traderID = traderID,
        itemFullType = itemFullType,
        qty = qty
    }
    sendClientCommand(getPlayer(), COMMAND_MODULE, "PerformTrade", args)
end

-- =============================================================================
-- SERVER RESPONSE HANDLERS
-- =============================================================================

local function OnServerCommand(module, command, args)
    if module ~= COMMAND_MODULE then return end

    if command == "SyncTrader" then
        local id = args.id
        if id then
            DynamicTrading_Client.Cache.Traders[id] = args
            Events.OnCustomUIEvent.Trigger("DynamicTrading_TraderUpdated", id)
        end

    elseif command == "SyncFaction" then
        -- args is { [ID] = data }
        for id, data in pairs(args) do
            DynamicTrading_Client.Cache.Factions[id] = data
            Events.OnCustomUIEvent.Trigger("DynamicTrading_FactionUpdated", id)
        end

    elseif command == "SyncStock" then
        local id = args.id
        if id then
            DynamicTrading_Client.Cache.Stocks[id] = args -- contains items, restock
            Events.OnCustomUIEvent.Trigger("DynamicTrading_StockUpdated", id)
        end

    elseif command == "TradeResult" then
        if args.success then
            HaloTextHelper.addText(getPlayer(), "Trade Successful", HaloTextHelper.getColorGreen())
            -- Refresh stock automatically
            -- DynamicTrading_Client.RequestStock(lastTraderID) -- If we tracked context
        else
            HaloTextHelper.addText(getPlayer(), "Trade Failed: " .. tostring(args.reason), HaloTextHelper.getColorRed())
        end
        Events.OnCustomUIEvent.Trigger("DynamicTrading_TradeCompleted", args)
    end
end

Events.OnServerCommand.Add(OnServerCommand)
print("DynamicTrading: Client Network Layer V2 Initialized")
