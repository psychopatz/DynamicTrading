-- Hoomans-specific client trade presentation registered behind DTCommon.
-- DTCommon owns snapshot/trade transport; this adapter owns the PNC window.

DTHoomans = DTHoomans or {}

local Presentations = DTCommon and DTCommon.TradePresentations
    or require "DTCommon/DTCommon_TradePresentationRegistry"

local function windowAPI()
    return PNC and PNC.InventoryWindow or nil
end

local function activeFor(traderID)
    local api = windowAPI()
    local window = api and api.instance or nil
    return window
        and window.tradeMode
        and window.transferEndpoint
        and tostring(window.transferEndpoint.id or "")
            == tostring(traderID or "")
        and window or nil
end

Presentations.Register("DTHoomans", {
    priority = 200,
    canHandle = function(context)
        local api = windowAPI()
        return context
            and context.pending
            and context.pending.mode == "trade"
            and api
            and type(api.OpenTrade) == "function"
            and (context.pending.npcID ~= nil
                or context.snapshot
                    and (context.snapshot.physicalNpcID
                        or context.snapshot.leaderNPCID))
    end,
    open = function(context)
        local api = windowAPI()
        if not api or type(api.OpenTrade) ~= "function" then
            return false, "hoomans_trade_window_unavailable"
        end
        local traderID = tostring(context.traderID or "")
        local snapshot = context.snapshot
        local pending = context.pending or {}
        local client = context.client
        local npcID = pending.npcID
            or snapshot and snapshot.physicalNpcID
            or snapshot and snapshot.leaderNPCID
        local window = api.OpenTrade(
            npcID,
            traderID,
            snapshot,
            {
                requestSnapshot = function()
                    return client.RequestSnapshot(traderID)
                end,
                commit = function(_, buyRows, sellRows)
                    return client.SubmitTradeBasket(
                        traderID, buyRows, sellRows)
                end,
            }
        )
        return window ~= nil,
            window and "hoomans_trade_window_opened"
                or "hoomans_trade_window_failed"
    end,
    updateSnapshot = function(context)
        local window = activeFor(context and context.traderID)
        if not window or not window.transferEndpoint
            or type(window.transferEndpoint.setSnapshot) ~= "function"
        then
            return false
        end
        window.transferEndpoint:setSnapshot(context.snapshot)
        if type(window.refreshInventory) == "function" then
            window:refreshInventory(true)
        end
        return true
    end,
    handleResult = function(context)
        local api = windowAPI()
        local window = activeFor(context and context.traderID)
        if not window or not api
            or type(api.OnTradeResult) ~= "function"
        then
            return false
        end
        api.OnTradeResult(context.result)
        return true
    end,
})

return DTHoomans
