-- =============================================================================
-- WINDOW MANAGEMENT
-- =============================================================================
local function T(key, params, fallback)
    if DynamicTrading and DynamicTrading.Text and DynamicTrading.Text.Get then
        return DynamicTrading.Text.Get(key, params, fallback)
    end
    return fallback or tostring(key or "")
end

function DT_TradingWindow.ToggleWindow(traderID, archetype, radioObj, dataProvider)
    if DT_TradingWindow.instance then
        DT_TradingWindow.instance:close()
        return
    end

    local player = getSpecificPlayer(0)
    if not player or player:isDead() then return end

    local screenW = getCore():getScreenWidth()
    local screenH = getCore():getScreenHeight()
    local width = math.min(750, screenW * 0.6)
    local height = math.min(750, screenH * 0.7)

    width = math.max(600, width)
    height = math.max(650, height)

    local x = screenW / 2 - width / 2
    local y = screenH / 2 - height / 2

    if DT_ConfigManager and DT_ConfigManager.getWindowState then
        local state = DT_ConfigManager.getWindowState("TradingWindow")
        if state then
            x = state.x
            y = state.y
            width = state.w
            height = state.h

            if x < 0 then x = 0 end
            if y < 0 then y = 0 end
            if x > screenW - 50 then x = screenW - width end
            if y > screenH - 50 then y = screenH - height end
        end
    end

    local ui = DT_TradingWindow:new(x, y, width, height)
    ui:initialise()
    ui.dataProvider = dataProvider
    ui:addToUIManager()
    ui.traderID = traderID
    ui.archetype = archetype or "General"
    ui.radioObj = radioObj
    ui.sessionContext = dataProvider and dataProvider.getTradeSessionContext and dataProvider:getTradeSessionContext(traderID, archetype) or nil

    local trader = dataProvider:getTrader(traderID, archetype)

    if dataProvider.getWindowTitle then
        ui:setTitle(dataProvider:getWindowTitle(trader))
    else
        ui:setTitle(T("DTCommon_UI_Trading_WindowTitle", nil, "Trading Window"))
    end

    if dataProvider.getDefaultTradingMode then
        ui.isBuying = dataProvider:getDefaultTradingMode(trader)
    end
    ui.transactionKind = ui:getTransactionKind()
    ui:coerceTradeMode(trader)
    ui:relayout()
    local openStartedAt = ui.GetNowMs and ui:GetNowMs() or 0
    ui:populateList()
    if ui.logPerf then
        ui:logPerf("WindowOpen", "trader=" .. tostring(traderID) .. " openPopulateMs=" .. tostring((ui:GetNowMs() or 0) - openStartedAt))
    end

    local gameTime = GameTime:getInstance()
    local climate = ClimateManager:getInstance()
    ui.lastHour = gameTime:getHour()
    ui.wasRaining = climate:getRainIntensity() > 0.4
    ui.wasFoggy = climate:getFogIntensity() > 0.4

    local suppressIntroMessages = ui.sessionContext and ui.sessionContext.suppressIntroMessages == true
    if trader then
        if ui.refreshPortraitWithTrader then
            ui:refreshPortraitWithTrader(trader, true)
        end
        if not suppressIntroMessages then
            local introMsg = dataProvider:getPlayerMessage("Intro", {})
            ui:queueMessage(introMsg, false, true, 0)

            local greeting = dataProvider:getGreeting(trader)
            ui:queueMessage(greeting, false, false, 20, nil, "greeting", ui:buildNPCTradeAudio(greeting, {
                hook = "welcome",
                tag = "greeting",
            }))
        end
    end

    DT_TradingWindow.instance = ui

    if DynamicTrading_Client and DynamicTrading_Client.BeginTradeView then
        DynamicTrading_Client.BeginTradeView(traderID)
    end
end

local function onInventoryChange()
    local player = getSpecificPlayer and getSpecificPlayer(0) or getPlayer and getPlayer() or nil
    if player and player.getModData then
        local modData = player:getModData()
        modData.DT_SellScanRevision = (tonumber(modData.DT_SellScanRevision) or 0) + 1
    end

    if DT_TradingWindow.instance and DT_TradingWindow.instance:getIsVisible() then
        if not DT_TradingWindow.instance.isBuying then
            if DT_TradingWindow.instance.sellScanSession then
                DT_TradingWindow.instance.sellScanSession.needsListRefresh = true
            end
            if DT_TradingItemUtils and DT_TradingItemUtils.Internal and DT_TradingItemUtils.Internal.invalidateSellScanCacheForTrader then
                DT_TradingItemUtils.Internal.invalidateSellScanCacheForTrader(DT_TradingWindow.instance.traderID, "inventory-change")
            end
            DT_TradingWindow.instance.inventoryDirty = true
        end
    end
end

Events.OnContainerUpdate.Add(onInventoryChange)
Events.OnRefreshInventoryWindowContainers.Add(onInventoryChange)

local function onPriceConfigUpdated()
    if DT_TradingWindow.instance and DT_TradingWindow.instance:getIsVisible() then
        if DT_TradingItemUtils and DT_TradingItemUtils.Internal and DT_TradingItemUtils.Internal.invalidateSellScanCaches then
            DT_TradingItemUtils.Internal.invalidateSellScanCaches("price-config-update")
        end
        if DT_TradingWindow.instance.dataProvider and DT_TradingWindow.instance.dataProvider.invalidateTradeCaches then
            DT_TradingWindow.instance.dataProvider:invalidateTradeCaches(DT_TradingWindow.instance.traderID)
        end
        DT_TradingWindow.instance:populateList()
    end
end

Events.OnDynamicTradingPriceConfigUpdated.Add(onPriceConfigUpdated)
