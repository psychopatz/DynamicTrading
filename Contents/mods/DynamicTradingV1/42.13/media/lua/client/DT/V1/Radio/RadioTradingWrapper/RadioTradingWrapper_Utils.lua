-- =============================================================================
-- DYNAMIC TRADING V1: RADIO TRADING WRAPPER - UTILS
-- =============================================================================
-- Utility functions for audio, connection validation, and window toggling.
-- =============================================================================

V1_RadioTradingWrapper_Utils_logic = {}

function V1_Radio_DataProvider:lockItem(itemID)
    local player = getSpecificPlayer(0)
    if not player then return end
    local modData = player:getModData()
    if not modData.DT_LockedItems then modData.DT_LockedItems = {} end
    modData.DT_LockedItems[itemID] = true
end

function V1_Radio_DataProvider:openHub(trader, parentUI)
    if parentUI then parentUI:close() end
    if DT_V1_Dialogue_Hub then
        DT_V1_Dialogue_Hub.Init(nil, self.radioObj, trader.traderID, getSpecificPlayer(0))
    end
end

function V1_Radio_DataProvider:getFavorStatus(trader)
    return { canRequest = true, tooltip = "Return to conversation" }
end

function V1_Radio_DataProvider:getAskButtonConfig(isBuying)
    return { title = isBuying and "Talk" or "Ask What They Want", visible = true }
end

function V1_Radio_DataProvider:onAsk(trader, isBuying, ui)
    if isBuying then
        self:openHub(trader, ui)
    else
        local playerMsg = self:getPlayerMessage("SellAsk", {})
        ui:queueMessage(playerMsg, false, true, 0)
        local npcMsg = self:getSellAskDialogue(trader)
        ui:queueMessage(npcMsg, false, false, 30)
    end
end

function V1_Radio_DataProvider:playSound(soundName)
    if DT_AudioManager then
        DT_AudioManager.PlaySound(soundName, false, 1.0)
    else
        getSoundManager():PlaySound(soundName, false, 1.0)
    end
end

function V1_Radio_DataProvider:getLockButtonVisible(isBuying)
    return not isBuying
end

function V1_Radio_DataProvider:getWindowTitle(trader)
    if not trader then return "Radio Trading" end
    return (trader.name or "Unknown") .. " - " .. self:getArchetypeName(trader.archetype)
end

function V1_Radio_DataProvider:isConnectionValid(radioObj)
    -- [OPTIMIZATION]
    -- 1. Check if we have a radio obj.
    if not radioObj then
        return self.radioObj ~= nil
    end

    -- 2. VISIBILITY CHECK (The "Kill Switch")
    if DT_TradingWindow and DT_TradingWindow.instance then
        if not DT_TradingWindow.instance:getIsVisible() then
            return false
        end
    end

    -- 3. DISTANCE CHECK
    -- Delegate to core util, which handles nil objects safely by returning true
    return DynamicTrading.Utils.IsInteractionValid(radioObj, nil, nil)
end

function V1_Radio_DataProvider:getPlayerWealth(player)
    if not player then return 0 end
    local inv = player:getInventory()
    local loose = inv:getItemsFromType("Base.Money", true)
    local bundles = inv:getItemsFromType("Base.MoneyBundle", true)
    return (loose and loose:size() or 0) + ((bundles and bundles:size() or 0) * 100)
end

function V1_Radio_DataProvider:getDailyStatus()
    return 0, 999
end

-- =============================================================================
-- TOGGLE WINDOW HELPER
-- =============================================================================
function V1_Radio_DataProvider.Open(traderID, archetype, radioObj)
    DynamicTrading.Log("DTV1", "UI", "Open", "Opening Radio Trading Window for " .. tostring(traderID))
    V1_Radio_DataProvider._currentTraderID = traderID
    V1_Radio_DataProvider.radioObj = radioObj
    DT_TradingWindow.ToggleWindow(traderID, archetype, radioObj, V1_Radio_DataProvider)
end

DynamicTrading.Log("DTV1", "Init", "Utils", "V1 Radio Trading Utility Logic Loaded")
