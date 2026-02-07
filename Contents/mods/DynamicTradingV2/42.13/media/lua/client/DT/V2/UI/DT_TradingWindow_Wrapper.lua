-- =============================================================================
-- DYNAMIC TRADING V2: TRADING WINDOW WRAPPER
-- =============================================================================
-- Provides V2_DataProvider for DT_TradingWindow integration with NPC traders.
-- Uses server-authoritative pricing via synced ModData cache.
-- =============================================================================

require "DT/Common/UI/Trading/DT_TradingWindow"
require "DT/Common/Archetypes"
require "DT/Common/Config"
require "Utils/DT_CoreUtils"
require "DT/V2/Dialog/DT_DialogueManager"
require "DT/V2/NPC/DTNPC_ClientCache"

local DEBUG_PREFIX = "[DT-V2-TradingWrapper]"


-- =============================================================================
-- V2 DATA PROVIDER
-- =============================================================================
V2_DataProvider = {}

-- -----------------------------------------------------------------------------
-- TRADER DATA
-- -----------------------------------------------------------------------------
function V2_DataProvider:getTrader(traderID, archetype)
    print(DEBUG_PREFIX .. " getTrader called for ID: " .. tostring(traderID))
    
    -- Get stock data from synced ModData
    local stockData = (DynamicTrading_Client and DynamicTrading_Client.Cache and DynamicTrading_Client.Cache.Stocks) 
                      or ModData.get("DynamicTrading_Stock")
    
    if not stockData or not stockData[traderID] then
        print(DEBUG_PREFIX .. " WARNING: No stock data found for trader " .. tostring(traderID))
        return nil
    end
    
    local stock = stockData[traderID]
    print(DEBUG_PREFIX .. " Stock found. Items: " .. tostring(V2_DataProvider:countTable(stock.items or {})))
    
    -- Convert V2 stock format {key: {qty, price}} to V1 format {key: qty}
    local flattenedStocks = {}
    if stock.items then
        for key, itemStock in pairs(stock.items) do
            if type(itemStock) == "table" then
                flattenedStocks[key] = itemStock.qty or 0
            else
                flattenedStocks[key] = itemStock
            end
        end
    end
    
    -- Store original stock data for price lookups
    self._stockItems = stock.items or {}
    
    -- Get faction wealth for budget display
    local factionWealth = 0
    if stock.factionID then
        local factionData = ModData.get("DynamicTrading_Factions")
        if factionData and factionData[stock.factionID] then
            factionWealth = factionData[stock.factionID].wealth or 0
            print(DEBUG_PREFIX .. " Faction wealth: $" .. tostring(factionWealth))
        end
    end
    
    -- Build merged trader proxy (using 'stocks' and 'budget' as expected by TradingWindow)
    local trader = {
        traderID = traderID,
        archetype = archetype or stock.archetype or "General",
        name = stock.name or "Trader",
        wallet = stock.wallet or factionWealth or 0,  -- V2 individual wallet
        budget = factionWealth,  -- TradingWindow expects 'budget' for display
        stocks = flattenedStocks,  -- TradingWindow expects 'stocks', not 'items'
        deflation = stock.deflation or {},
        factionID = stock.factionID,
        portraitID = stock.portraitID,
        gender = stock.gender or "Male",
        -- V2-specific: reference to NPC for distance checks
        npcRef = self._currentNPC
    }
    
    print(DEBUG_PREFIX .. " Trader proxy built: " .. trader.name .. " (" .. trader.archetype .. ")")
    print(DEBUG_PREFIX .. " Stocks count: " .. tostring(V2_DataProvider:countTable(flattenedStocks)))
    print(DEBUG_PREFIX .. " Budget: $" .. tostring(trader.budget))
    return trader
end



function V2_DataProvider:countTable(t)
    local count = 0
    if t then for _ in pairs(t) do count = count + 1 end end
    return count
end

-- -----------------------------------------------------------------------------
-- DIALOGUE
-- -----------------------------------------------------------------------------
function V2_DataProvider:getAmbientMessage(trader, event)
    if not DynamicTrading.DialogueManager then return nil end
    return DynamicTrading.DialogueManager.GenerateAmbientMessage(trader, event)
end

function V2_DataProvider:getGreeting(trader)
    if not DynamicTrading.DialogueManager then return "Hello." end
    return DynamicTrading.DialogueManager.GenerateGreeting(trader)
end

function V2_DataProvider:getPlayerMessage(category, diagArgs)
    if not DynamicTrading.DialogueManager then return "..." end
    return DynamicTrading.DialogueManager.GeneratePlayerMessage(category, diagArgs)
end

function V2_DataProvider:getTransactionMessage(trader, isSuccess, diagArgs)
    if not DynamicTrading.DialogueManager then return isSuccess and "Done." or "No deal." end
    return DynamicTrading.DialogueManager.GenerateTransactionMessage(trader, isSuccess, diagArgs)
end

function V2_DataProvider:getSellAskDialogue(trader)
    -- Uses Common archetypes wants/forbid
    if DynamicTrading.DialogueManager and DynamicTrading.DialogueManager.GenerateSellAskDialogue then
        return DynamicTrading.DialogueManager.GenerateSellAskDialogue(trader)
    end
    return "What do you have for me?"
end

function V2_DataProvider:getIdleMessage(trader)
    if not DynamicTrading.DialogueManager then return nil end
    return DynamicTrading.DialogueManager.GenerateIdleMessage(trader)
end

-- -----------------------------------------------------------------------------
-- PRICING (Server-authoritative, read from cache)
-- -----------------------------------------------------------------------------
function V2_DataProvider:getItemData(key)
    return DynamicTrading.Config.MasterList[key]
end

function V2_DataProvider:getBuyPrice(key)
    print(DEBUG_PREFIX .. " getBuyPrice: " .. tostring(key))
    
    -- First try cached stock items (fastest)
    if self._stockItems and self._stockItems[key] then
        local itemStock = self._stockItems[key]
        if type(itemStock) == "table" then
            local price = itemStock.price or itemStock.basePrice or 0
            print(DEBUG_PREFIX .. " Price from _stockItems: $" .. tostring(price))
            return price
        end
    end
    
    -- Fallback: Get from ModData
    local stockData = (DynamicTrading_Client and DynamicTrading_Client.Cache and DynamicTrading_Client.Cache.Stocks) 
                      or ModData.get("DynamicTrading_Stock")
    
    if stockData and self._currentTraderID and stockData[self._currentTraderID] then
        local items = stockData[self._currentTraderID].items
        if items and items[key] then
            local price = items[key].price or items[key].basePrice or 99999
            print(DEBUG_PREFIX .. " Price from ModData: $" .. tostring(price))
            return price
        end
    end
    
    -- Fallback to base price from MasterList
    local itemData = DynamicTrading.Config.MasterList[key]
    if itemData then
        print(DEBUG_PREFIX .. " Price from MasterList (fallback): $" .. tostring(itemData.basePrice))
        return itemData.basePrice
    end
    
    print(DEBUG_PREFIX .. " WARNING: No price found for " .. tostring(key))
    return 99999
end

function V2_DataProvider:getSellPrice(invItem, masterKey, trader)
    print(DEBUG_PREFIX .. " getSellPrice: " .. tostring(masterKey))
    
    local itemData = DynamicTrading.Config.MasterList[masterKey]
    if not itemData then
        print(DEBUG_PREFIX .. " WARNING: Item not in MasterList")
        return 0
    end
    
    local basePrice = itemData.basePrice or 0
    local price = basePrice * 0.5 -- Base 50% sell-back
    
    -- Condition penalty
    if invItem and (invItem.IsDrainable or invItem.getCondition) then
        if invItem:getCondition() and invItem:getConditionMax() and invItem:getConditionMax() > 0 then
            local cond = invItem:getCondition() / invItem:getConditionMax()
            price = price * cond
            print(DEBUG_PREFIX .. " Condition modifier: " .. string.format("%.2f", cond))
        end
    end
    
    -- Apply deflation from cache if available
    if trader and trader.deflation and trader.deflation[masterKey] then
        local deflationCount = trader.deflation[masterKey]
        local deflationMod = math.max(0.5, 1.0 - (deflationCount * 0.05)) -- 5% per sale, min 50%
        price = price * deflationMod
        print(DEBUG_PREFIX .. " Deflation modifier: " .. string.format("%.2f", deflationMod) .. " (sold " .. deflationCount .. "x)")
    end
    
    local finalPrice = math.floor(price)
    print(DEBUG_PREFIX .. " Final sell price: $" .. tostring(finalPrice))
    return finalPrice
end

function V2_DataProvider:getPriceModifier(tags)
    -- Skip for now - will implement later
    return 1.0
end

-- -----------------------------------------------------------------------------
-- ITEM LOCKING
-- -----------------------------------------------------------------------------
function V2_DataProvider:lockItem(itemID)
    print(DEBUG_PREFIX .. " Locking item: " .. tostring(itemID))
    local player = getSpecificPlayer(0)
    local modData = player:getModData()
    if not modData.DT_LockedItems then modData.DT_LockedItems = {} end
    modData.DT_LockedItems[itemID] = true
end

function V2_DataProvider:getMasterKey(fullType)
    for k, v in pairs(DynamicTrading.Config.MasterList) do
        if v.item == fullType then return k end
    end
    return nil
end

-- -----------------------------------------------------------------------------
-- HUB / ASK BUTTON (Agnostic - returns to parent)
-- -----------------------------------------------------------------------------
function V2_DataProvider:openHub(trader, parentUI)
    print(DEBUG_PREFIX .. " openHub called - returning to dialogue hub")
    if parentUI then parentUI:close() end
    
    if trader.npcRef and DTNPC_TraderDialogue_Hub then
        DTNPC_TraderDialogue_Hub.Init(nil, trader.npcRef, getSpecificPlayer(0))
    end
end

function V2_DataProvider:getArchetypeName(archetype)
    if DynamicTrading.Archetypes and DynamicTrading.Archetypes[archetype] then
        return DynamicTrading.Archetypes[archetype].name
    end
    return archetype or "Survivor"
end

function V2_DataProvider:getFavorStatus(trader)
    -- V2: "Talk" button always enabled, returns to Hub
    return { canRequest = true, tooltip = "Return to conversation" }
end

function V2_DataProvider:getAskButtonConfig(isBuying)
    if isBuying then
        return { title = "Talk", visible = true }
    else
        return { title = "Ask What They Want", visible = true }
    end
end

function V2_DataProvider:onAsk(trader, isBuying, ui)
    print(DEBUG_PREFIX .. " onAsk called, isBuying: " .. tostring(isBuying))
    
    if isBuying then
        -- Return to Hub
        self:openHub(trader, ui)
    else
        -- Show what they want (sell ask dialogue)
        local playerMsg = self:getPlayerMessage("SellAsk", {})
        ui:queueMessage(playerMsg, false, true, 0)
        
        local npcMsg = self:getSellAskDialogue(trader)
        ui:queueMessage(npcMsg, false, false, 30)
    end
end

-- -----------------------------------------------------------------------------
-- AUDIO
-- -----------------------------------------------------------------------------
function V2_DataProvider:playSound(soundName)
    getSoundManager():PlaySound(soundName, false, 0.1)
end

-- -----------------------------------------------------------------------------
-- UI CONFIGURATION
-- -----------------------------------------------------------------------------
function V2_DataProvider:getLockButtonVisible(isBuying)
    return not isBuying
end

function V2_DataProvider:getWindowTitle(trader)
    if not trader then return "Trading" end
    local name = trader.name or "Unknown"
    local archName = self:getArchetypeName(trader.archetype)
    return name .. " - " .. archName
end

-- -----------------------------------------------------------------------------
-- CONNECTION VALIDATION (NPC Distance)
-- -----------------------------------------------------------------------------
function V2_DataProvider:isConnectionValid(npc)
    if not npc then
        print(DEBUG_PREFIX .. " isConnectionValid: No NPC reference")
        return self._currentNPC ~= nil
    end
    
    -- Use common utility (4 tiles for NPCs)
    local valid = DynamicTrading.Utils.IsInteractionValid(npc, nil, nil)
    if not valid then
        print(DEBUG_PREFIX .. " Connection invalid - NPC out of range or dead")
    end
    return valid
end

-- -----------------------------------------------------------------------------
-- PLAYER WEALTH
-- -----------------------------------------------------------------------------
function V2_DataProvider:getPlayerWealth(player)
    local inv = player:getInventory()
    local loose = inv:getItemsFromType("Base.Money", true)
    local bundles = inv:getItemsFromType("Base.MoneyBundle", true)
    local looseCount = loose and loose:size() or 0
    local bundleCount = bundles and bundles:size() or 0
    local total = looseCount + (bundleCount * 100)
    print(DEBUG_PREFIX .. " Player wealth: $" .. tostring(total))
    return total
end

-- -----------------------------------------------------------------------------
-- DAILY STATUS (V2 doesn't use this, return unlimited)
-- -----------------------------------------------------------------------------
function V2_DataProvider:getDailyStatus()
    return 0, 999 -- current, limit (effectively unlimited)
end

-- =============================================================================
-- TOGGLE WINDOW OVERRIDE
-- =============================================================================
local originalToggle = DT_TradingWindow.ToggleWindow

function DT_TradingWindow.ToggleWindowV2(traderID, archetype, npcRef)
    print(DEBUG_PREFIX .. " ToggleWindowV2 called")
    print(DEBUG_PREFIX .. " TraderID: " .. tostring(traderID))
    print(DEBUG_PREFIX .. " Archetype: " .. tostring(archetype))
    
    -- Store context for provider methods
    V2_DataProvider._currentTraderID = traderID
    V2_DataProvider._currentNPC = npcRef
    
    -- Call original with V2 provider (nil for radioObj since V2 uses NPC)
    originalToggle(traderID, archetype, npcRef, V2_DataProvider)
end

print(DEBUG_PREFIX .. " V2 Trading Window Wrapper loaded successfully")
