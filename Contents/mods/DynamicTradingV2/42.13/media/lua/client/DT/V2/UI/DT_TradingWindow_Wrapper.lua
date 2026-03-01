-- =============================================================================
-- DYNAMIC TRADING V2: TRADING WINDOW WRAPPER
-- =============================================================================
-- Provides V2_DataProvider for DT_TradingWindow integration with NPC traders.
-- Uses server-authoritative pricing via synced ModData cache.
-- =============================================================================

require "DT/Common/UI/Trading/DT_TradingWindow"
require "DT/Common/Config"
require "Utils/DT_CoreUtils"
require "DT/V2/Dialog/DT_DialogueManager"
require "DT/V2/NPC/DTNPC_ClientCache"
require "DT/Common/Utils/DT_AudioManager"
require "DT/Common/Trading/DT_Economy_Common"

local DEBUG_PREFIX = "[DT-V2-TradingWrapper]"

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
    
    -- [FIX] Also track player inventory count for sell mode refreshing
    local playerItemCount = 0
    if not ui.isBuying then
        local player = getSpecificPlayer(0)
        -- [CRASH FIX] Check valid player
        if player and not player:isDead() and player:getInventory() then
            playerItemCount = player:getInventory():getItems():size()
        end
    end
    local version = tostring(stock.factionWealth or 0) .. "_" .. tostring(totalQty) .. "_" .. tostring(playerItemCount)
    
    -- Check if version changed
    if _currentTraderID == traderID and _lastStockVersion and _lastStockVersion ~= version then
        print(DEBUG_PREFIX .. " Stock version changed: " .. _lastStockVersion .. " -> " .. version .. ", refreshing UI")
        _lastStockVersion = version
        ui:populateList()
    elseif _currentTraderID ~= traderID then
        -- Different trader, just update tracking
        _currentTraderID = traderID
        _lastStockVersion = version
    elseif not _lastStockVersion then
        _lastStockVersion = version
    end
end

Events.OnPreUIDraw.Add(OnPreUIDraw)

-- =============================================================================
-- V2 DATA PROVIDER
-- =============================================================================
V2_DataProvider = {}

-- -----------------------------------------------------------------------------
-- TRADER DATA
-- -----------------------------------------------------------------------------
function V2_DataProvider:getTrader(traderID, archetype)
    -- print(DEBUG_PREFIX .. " getTrader called for ID: " .. tostring(traderID))
    
    -- Get stock data from synced ModData (prefer client cache)
    local stockData = (DynamicTrading_Client and DynamicTrading_Client.Cache and DynamicTrading_Client.Cache.Stocks) 
                      or ModData.get("DynamicTrading_Stock")
    
    if not stockData or not stockData[traderID] then
        return nil
    end
    
    local stock = stockData[traderID]
    -- print(DEBUG_PREFIX .. " Stock found. Items: " .. tostring(V2_DataProvider:countTable(stock.items or {})))
    
    -- [FIX] Do NOT flatten the stock. Pass the full object so CustomData persists.
    local processedStocks = {}
    if stock.items then
        for key, itemStock in pairs(stock.items) do
            processedStocks[key] = itemStock
        end
    end
    
    -- Store original stock data for price lookups
    self._stockItems = stock.items or {}
    
    -- Get faction wealth for budget display
    -- PRIORITY 1: Use factionWealth from SyncStock (most up-to-date from server)
    local factionWealth = stock.factionWealth or 0
    
    -- DEBUG: Log what value came from server
    -- print(DEBUG_PREFIX .. " Stock factionWealth from server: " .. tostring(stock.factionWealth) .. ", factionID: " .. tostring(stock.factionID))
    
    -- PRIORITY 2: Fallback to ModData lookup if factionID is available
    if factionWealth == 0 and stock.factionID then
        local factionData = (DynamicTrading_Client and DynamicTrading_Client.Cache and DynamicTrading_Client.Cache.Factions)
                            or ModData.get("DynamicTrading_Factions")
        if factionData and factionData[stock.factionID] then
            factionWealth = factionData[stock.factionID].wealth or 0
            -- print(DEBUG_PREFIX .. " Fallback wealth from Factions cache: " .. tostring(factionWealth))
        end
    end
    
    -- print(DEBUG_PREFIX .. " Final faction wealth resolved: $" .. tostring(factionWealth))
    
    -- Build merged trader proxy (using 'stocks' and 'budget' as expected by TradingWindow)
    local trader = {
        traderID = traderID,
        archetype = stock.archetype or archetype or "General",
        name = stock.name or "Trader",
        wallet = stock.wallet or factionWealth or 0,  -- V2 individual wallet
        budget = factionWealth,  -- TradingWindow expects 'budget' for display
        stocks = processedStocks,  -- TradingWindow expects 'stocks', not 'items'
        deflation = stock.deflation or {},
        factionID = stock.factionID,
        portraitID = stock.portraitID,
        gender = stock.gender or "Male",
        -- V2-specific: reference to NPC for distance checks
        npcRef = self._currentNPC
    }
    
    -- print(DEBUG_PREFIX .. " Trader proxy built: " .. trader.name .. " (" .. trader.archetype .. ")")
    -- print(DEBUG_PREFIX .. " Stocks count: " .. tostring(V2_DataProvider:countTable(flattenedStocks)))
    -- print(DEBUG_PREFIX .. " Budget: $" .. tostring(trader.budget))
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

function V2_DataProvider:getTransactionMessage(trader, isBuy, diagArgs)
    if not DynamicTrading.DialogueManager then return isBuy and "Done." or "No deal." end
    return DynamicTrading.DialogueManager.GenerateTransactionMessage(trader, isBuy, diagArgs)
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

function V2_DataProvider:getBuyPrice(key, customData, verbose)
    local traderID = self._currentTraderID
    if not traderID then return 99999 end

    local itemData = DynamicTrading.Config.MasterList[key]
    if not itemData then return 99999 end

    -- Fetch local difficulty context
    local diff = DynamicTrading.Config.GetDifficultyData()
    
    -- Prepare modifiers
    local modifiers = {
        tagsConfig = DynamicTrading.Config.Tags,
        customData = customData,
        -- [NEW] Pass event modifier resolver to common economy
        getPriceModifier = function(tags)
            return self:getPriceModifier(tags, verbose)
        end
    }

    -- Use Shared Common Logic
    if DynamicTrading.Economy and DynamicTrading.Economy.Common then
        if DynamicTrading.Economy.Common.GetBuyPrice then
            return DynamicTrading.Economy.Common.GetBuyPrice(key, itemData, diff, modifiers, verbose)
        else
            print(DEBUG_PREFIX .. " ERROR: DynamicTrading.Economy.Common exists but GetBuyPrice is missing!")
        end
    else
        print(DEBUG_PREFIX .. " ERROR: DynamicTrading.Economy.Common is nil! Attempting emergency require...")
        require "DT/Common/Trading/DT_Economy_Common"
        if DynamicTrading.Economy and DynamicTrading.Economy.Common and DynamicTrading.Economy.Common.GetBuyPrice then
            print(DEBUG_PREFIX .. " Emergency require successful.")
            return DynamicTrading.Economy.Common.GetBuyPrice(key, itemData, diff, modifiers, verbose)
        end
    end
    
    return 99999
end

function V2_DataProvider:getSellPrice(invItem, masterKey, trader, verbose)
    local traderID = self._currentTraderID
    if not traderID or not invItem then return 0 end
    
    local itemData = DynamicTrading.Config.MasterKey and DynamicTrading.Config.MasterList[masterKey]
    if not itemData then itemData = DynamicTrading.Config.MasterList[masterKey] end
    if not itemData then return 0 end

    -- Get Context
    local diff = DynamicTrading.Config.GetDifficultyData()
    local archetypeID = trader.archetype or "General"
    local archetype = DynamicTrading.Archetypes[archetypeID]

    local modifiers = {
        tagsConfig = DynamicTrading.Config.Tags,
        -- [NEW] Pass event modifier resolver
        getPriceModifier = function(tags)
            return self:getPriceModifier(tags, verbose)
        end
    }
    
    -- Use Shared Common Logic
    if DynamicTrading.Economy and DynamicTrading.Economy.Common then
        if DynamicTrading.Economy.Common.GetSellPrice then
            return DynamicTrading.Economy.Common.GetSellPrice(masterKey, itemData, invItem, diff, archetype, modifiers, verbose)
        else
            print(DEBUG_PREFIX .. " ERROR: DynamicTrading.Economy.Common exists but GetSellPrice is missing!")
        end
    else
        print(DEBUG_PREFIX .. " ERROR: DynamicTrading.Economy.Common is nil during Sell Price calc!")
    end
    
    return 0
end

function V2_DataProvider:getPriceModifier(tags, verbose)
    -- V2 Event Integration for UI highlighting
    if DynamicTrading.Events and DynamicTrading.Events.GetFactionPriceModifier then
        -- In V2_DataProvider, we can get factionID from the current trader proxy
        local factionID = self._currentFactionID
        if not factionID and self._currentTraderID then
            -- Fallback: try to find it in the cache
            local stockData = (DynamicTrading_Client and DynamicTrading_Client.Cache and DynamicTrading_Client.Cache.Stocks) 
                              or ModData.get("DynamicTrading_Stock")
            if stockData and stockData[self._currentTraderID] then
                factionID = stockData[self._currentTraderID].factionID
            end
        end
        
        -- Get Faction Object from cache for the modifier logic
        local factionData = (DynamicTrading_Client and DynamicTrading_Client.Cache and DynamicTrading_Client.Cache.Factions)
                            or ModData.get("DynamicTrading_Factions")
        local faction = factionData and factionID and factionData[factionID]
        
        return DynamicTrading.Events.GetFactionPriceModifier(faction, tags, verbose)
    end
    return 1.0
end

-- -----------------------------------------------------------------------------
-- ITEM LOCKING
-- -----------------------------------------------------------------------------
function V2_DataProvider:lockItem(itemID)
    -- print(DEBUG_PREFIX .. " Locking item: " .. tostring(itemID))
    local player = getSpecificPlayer(0)
    if not player then return end -- Crash fix
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
    -- print(DEBUG_PREFIX .. " openHub called - returning to dialogue hub")
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
    if DT_AudioManager then
        DT_AudioManager.PlaySound(soundName, false, 1.0) -- volume 1.0, let manager handle multiplier
    else
        getSoundManager():PlaySound(soundName, false, 1.0)
    end
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
    -- [OPTIMIZATION]
    -- 1. If we don't have an NPC reference (maybe using Radio?), use internal state.
    if not npc then
        return self._currentNPC ~= nil
    end

    -- 2. VISIBILITY CHECK (The "Kill Switch")
    -- If the main trading window exists but is NOT visible, we immediately return false.
    -- This ensures we don't run checks in the background if the window got stuck hidden.
    if DT_TradingWindow and DT_TradingWindow.instance then
        if not DT_TradingWindow.instance:getIsVisible() then
            print("[DynamicTrading] Window is NOT visible, returning false")
            return false
        end
    end
    
    -- 3. DISTANCE CHECK
    -- This math is very fast. The log flooding was the issue, which is now removed.
    -- If this returns false, the Window Logic (Common) will handle closing the UI.
    return DynamicTrading.Utils.IsInteractionValid(npc, nil, nil)
end

-- -----------------------------------------------------------------------------
-- PLAYER WEALTH
-- -----------------------------------------------------------------------------
function V2_DataProvider:getPlayerWealth(player)
    -- [CRASH FIX] Handle nil player
    if not player then return 0 end
    local inv = player:getInventory()
    local loose = inv:getItemsFromType("Base.Money", true)
    local bundles = inv:getItemsFromType("Base.MoneyBundle", true)
    local looseCount = loose and loose:size() or 0
    local bundleCount = bundles and bundles:size() or 0
    local total = looseCount + (bundleCount * 100)
    -- print(DEBUG_PREFIX .. " Player wealth: $" .. tostring(total))
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
