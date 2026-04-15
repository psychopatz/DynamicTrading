-- =============================================================================
-- WINDOW MANAGEMENT
-- =============================================================================
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

    local trader = dataProvider:getTrader(traderID, archetype)

    if dataProvider.getWindowTitle then
        ui:setTitle(dataProvider:getWindowTitle(trader))
    else
        ui:setTitle("Trading Window")
    end

    if dataProvider.getDefaultTradingMode then
        ui.isBuying = dataProvider:getDefaultTradingMode(trader)
    end
    ui:coerceTradeMode(trader)
    ui:relayout()
    ui:populateList()

    local gameTime = GameTime:getInstance()
    local climate = ClimateManager:getInstance()
    ui.lastHour = gameTime:getHour()
    ui.wasRaining = climate:getRainIntensity() > 0.4
    ui.wasFoggy = climate:getFogIntensity() > 0.4

    if trader then
        if ui.refreshPortraitWithTrader then
            ui:refreshPortraitWithTrader(trader, true)
        end
        local introMsg = dataProvider:getPlayerMessage("Intro", {})
        ui:queueMessage(introMsg, false, true, 0)

        local greeting = dataProvider:getGreeting(trader)
        ui:queueMessage(greeting, false, false, 20)
    end

    DT_TradingWindow.instance = ui
end

local function onInventoryChange()
    if DT_TradingWindow.instance and DT_TradingWindow.instance:getIsVisible() then
        if not DT_TradingWindow.instance.isBuying then
            DT_TradingWindow.instance.inventoryDirty = true
        end
    end
end

Events.OnContainerUpdate.Add(onInventoryChange)
Events.OnRefreshInventoryWindowContainers.Add(onInventoryChange)

local function onPriceConfigUpdated()
    if DT_TradingWindow.instance and DT_TradingWindow.instance:getIsVisible() then
        DT_TradingWindow.instance:populateList()
    end
end

Events.OnDynamicTradingPriceConfigUpdated.Add(onPriceConfigUpdated)
