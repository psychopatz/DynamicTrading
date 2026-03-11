-- =============================================================================
-- DYNAMIC TRADING V1: RADIO TRADING WINDOW WRAPPER
-- =============================================================================
-- Provides V1_Radio_DataProvider for DT_TradingWindow integration with Radio traders.
-- Uses server-authoritative pricing via synced ModData cache from Common.
-- =============================================================================

require "DT/Common/UI/Trading/DT_TradingWindow"
require "DT/Common/Config"
require "Utils/DT_CoreUtils"
require "DT/Common/Utils/DT_AudioManager"
require "DT/Common/Trading/DT_Economy_Common"

local DEBUG_PREFIX = "[DT-V1-TradingWrapper]"

-- Stock version tracking for polling-based refresh
local _lastStockVersion = nil
local _currentTraderID = nil

-- =============================================================================
-- POLLING: Auto-refresh when stock cache changes
-- =============================================================================
local function OnPreUIDraw()
    if not DT_TradingWindow or not DT_TradingWindow.instance then return end
    if not DT_TradingWindow.instance:getIsVisible() then return end
    
    local ui = DT_TradingWindow.instance
    local traderID = ui.traderID
    if not traderID then return end
    
    -- Get current stock from cache
    local stockData = (DynamicTrading_Client and DynamicTrading_Client.Cache and DynamicTrading_Client.Cache.Stocks) 
                      or ModData.get("DynamicTrading_Stock")
    
    if not stockData or not stockData[traderID] then return end
    
    local stock = stockData[traderID]
    
    -- Build a version fingerprint from factionWealth + total qty
    local totalQty = 0
    if stock.items then
        for _, item in pairs(stock.items) do
            if type(item) == "table" then
                totalQty = totalQty + (item.qty or 0)
            else
                totalQty = totalQty + (item or 0)
            end
        end
    end
    
    -- Track player inventory count for sell mode refreshing
    local playerItemCount = 0
    if not ui.isBuying then
        local player = getSpecificPlayer(0)
        if player and not player:isDead() and player:getInventory() then
            playerItemCount = player:getInventory():getItems():size()
        end
    end
    local version = tostring(stock.factionWealth or 0) .. "_" .. tostring(totalQty) .. "_" .. tostring(playerItemCount)
    
    -- Check if version changed
    if _currentTraderID == traderID and _lastStockVersion and _lastStockVersion ~= version then
        print(DEBUG_PREFIX .. " Stock version changed, refreshing UI")
        _lastStockVersion = version
        ui:populateList()
    elseif _currentTraderID ~= traderID then
        _currentTraderID = traderID
        _lastStockVersion = version
    elseif not _lastStockVersion then
        _lastStockVersion = version
    end
end

Events.OnPreUIDraw.Add(OnPreUIDraw)

-- =============================================================================
-- V1 RADIO DATA PROVIDER
-- =============================================================================
V1_Radio_DataProvider = {}

function V1_Radio_DataProvider:getTrader(traderID, archetype)
    local stockData = (DynamicTrading_Client and DynamicTrading_Client.Cache and DynamicTrading_Client.Cache.Stocks) 
                      or ModData.get("DynamicTrading_Stock")
    
    if not stockData or not stockData[traderID] then
        return nil
    end
    
    local stock = stockData[traderID]
    local processedStocks = {}
    if stock.items then
        for key, itemStock in pairs(stock.items) do
            processedStocks[key] = itemStock
        end
    end
    
    self._stockItems = stock.items or {}
    local factionWealth = stock.factionWealth or 0
    
    if factionWealth == 0 and stock.factionID then
        local factionData = (DynamicTrading_Client and DynamicTrading_Client.Cache and DynamicTrading_Client.Cache.Factions)
                            or ModData.get("DynamicTrading_Factions")
        if factionData and factionData[stock.factionID] then
            factionWealth = factionData[stock.factionID].wealth or 0
        end
    end
    
    local trader = {
        traderID = traderID,
        archetype = stock.archetype or archetype or "General",
        name = stock.name or "Trader",
        wallet = stock.wallet or factionWealth or 0,
        budget = factionWealth,
        stocks = processedStocks,
        deflation = stock.deflation or {},
        factionID = stock.factionID,
        identitySeed = stock.identitySeed,
        gender = stock.gender or "Male",
        returnTime = stock.returnTime,
        radioObj = self.radioObj
    }
    
    -- Fallback: Fetch from Radio Manager if missing in stock
    if DynamicTrading and DynamicTrading.Manager and DynamicTrading.Manager.GetTrader then
        local fallbackTrader = DynamicTrading.Manager.GetTrader(traderID)
        if fallbackTrader then
            trader.returnTime = trader.returnTime or fallbackTrader.returnTime
        end
    end
    
    return trader
end

-- -----------------------------------------------------------------------------
-- DIALOGUE (Delegates to Common DialogueManager)
-- -----------------------------------------------------------------------------
function V1_Radio_DataProvider:getAmbientMessage(trader, event)
    if not DynamicTrading.DialogueManager then return nil end
    return DynamicTrading.DialogueManager.GenerateAmbientMessage(trader, event)
end

function V1_Radio_DataProvider:getGreeting(trader)
    if not DynamicTrading.DialogueManager then return "Hello." end
    return DynamicTrading.DialogueManager.GenerateGreeting(trader)
end

function V1_Radio_DataProvider:getPlayerMessage(category, diagArgs)
    if not DynamicTrading.DialogueManager then return "..." end
    return DynamicTrading.DialogueManager.GeneratePlayerMessage(category, diagArgs)
end

function V1_Radio_DataProvider:getTransactionMessage(trader, isBuy, diagArgs)
    if not DynamicTrading.DialogueManager then return isBuy and "Done." or "No deal." end
    return DynamicTrading.DialogueManager.GenerateTransactionMessage(trader, isBuy, diagArgs)
end

function V1_Radio_DataProvider:getSellAskDialogue(trader)
    if DynamicTrading.DialogueManager and DynamicTrading.DialogueManager.GenerateSellAskDialogue then
        return DynamicTrading.DialogueManager.GenerateSellAskDialogue(trader)
    end
    return "What do you have for me?"
end

function V1_Radio_DataProvider:getIdleMessage(trader)
    if not DynamicTrading.DialogueManager then return nil end
    return DynamicTrading.DialogueManager.GenerateIdleMessage(trader)
end

-- -----------------------------------------------------------------------------
-- PRICING (Delegates to Common Economy)
-- -----------------------------------------------------------------------------
function V1_Radio_DataProvider:getItemData(key)
    return DynamicTrading.Config.MasterList[key]
end

function V1_Radio_DataProvider:getBuyPrice(key, customData, verbose)
    local itemData = DynamicTrading.Config.MasterList[key]
    if not itemData then return 99999 end
    local diff = DynamicTrading.Config.GetDifficultyData()
    local modifiers = {
        tagsConfig = DynamicTrading.Config.Tags,
        customData = customData,
        getPriceModifier = function(tags) return self:getPriceModifier(tags, verbose) end
    }
    if DynamicTrading.Economy and DynamicTrading.Economy.Common then
        return DynamicTrading.Economy.Common.GetBuyPrice(key, itemData, diff, modifiers, verbose)
    end
    return 99999
end

function V1_Radio_DataProvider:getSellPrice(invItem, masterKey, trader, verbose)
    local itemData = DynamicTrading.Config.MasterList[masterKey]
    if not itemData then return 0 end
    local diff = DynamicTrading.Config.GetDifficultyData()
    local archetypeID = trader.archetype or "General"
    local archetype = DynamicTrading.Archetypes[archetypeID]
    local modifiers = {
        tagsConfig = DynamicTrading.Config.Tags,
        getPriceModifier = function(tags) return self:getPriceModifier(tags, verbose) end
    }
    if DynamicTrading.Economy and DynamicTrading.Economy.Common then
        return DynamicTrading.Economy.Common.GetSellPrice(masterKey, itemData, invItem, diff, archetype, modifiers, verbose)
    end
    return 0
end

function V1_Radio_DataProvider:getPriceModifier(tags, verbose)
    if DynamicTrading.Events and DynamicTrading.Events.GetFactionPriceModifier then
        local factionID = self._currentFactionID
        local stockData = (DynamicTrading_Client and DynamicTrading_Client.Cache and DynamicTrading_Client.Cache.Stocks) 
                          or ModData.get("DynamicTrading_Stock")
        if stockData and stockData[self._currentTraderID] then
            factionID = stockData[self._currentTraderID].factionID
        end
        local factionData = (DynamicTrading_Client and DynamicTrading_Client.Cache and DynamicTrading_Client.Cache.Factions)
                            or ModData.get("DynamicTrading_Factions")
        local faction = factionData and factionID and factionData[factionID]
        return DynamicTrading.Events.GetFactionPriceModifier(faction, tags, verbose)
    end
    return 1.0
end

-- -----------------------------------------------------------------------------
-- UTILS
-- -----------------------------------------------------------------------------
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

function V1_Radio_DataProvider:getArchetypeName(archetype)
    if DynamicTrading.Archetypes and DynamicTrading.Archetypes[archetype] then
        return DynamicTrading.Archetypes[archetype].name
    end
    return archetype or "Survivor"
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
            print("[DynamicTrading] Window is NOT visible, returning false")
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
    print(DEBUG_PREFIX .. " Opening Radio Trading Window for " .. tostring(traderID))
    V1_Radio_DataProvider._currentTraderID = traderID
    V1_Radio_DataProvider.radioObj = radioObj
    DT_TradingWindow.ToggleWindow(traderID, archetype, radioObj, V1_Radio_DataProvider)
end

print(DEBUG_PREFIX .. " V1 Radio Trading Wrapper loaded")
return V1_Radio_DataProvider
