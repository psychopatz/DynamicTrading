-- =============================================================================
-- DYNAMIC TRADING V1: UI WRAPPER (FACTION PARITY)
-- =============================================================================
-- V1 uses the shared faction economy (Engine v2, Roster, Stock, Economy V2).
-- This wrapper provides V1-specific UI behavior (radio connection, window title).
-- =============================================================================
require "DT/Common/UI/Trading/DT_TradingWindow"
require "DT/V1/Manager"
require "DT/Common/Events/DT_EventManager"
require "DT/V1/DT_DialogueManager" 
require "DT/V1/Utils/DT_OptionsManager" 

V1_DataProvider = {}

function V1_DataProvider:getTrader(traderID, archetype)
    return DynamicTrading.Manager.GetTrader(traderID, archetype)
end

function V1_DataProvider:getDailyStatus()
    return DynamicTrading.Manager.GetDailyStatus()
end

function V1_DataProvider:getAmbientMessage(trader, event)
    if not DynamicTrading.DialogueManager then return nil end
    return DynamicTrading.DialogueManager.GenerateAmbientMessage(trader, event)
end

function V1_DataProvider:getGreeting(trader)
    if not DynamicTrading.DialogueManager then return "Channels open." end
    return DynamicTrading.DialogueManager.GenerateGreeting(trader)
end

function V1_DataProvider:getPlayerMessage(category, diagArgs)
    if not DynamicTrading.DialogueManager then return "Hailing..." end
    return DynamicTrading.DialogueManager.GeneratePlayerMessage(category, diagArgs)
end

function V1_DataProvider:getTransactionMessage(trader, isSuccess, diagArgs)
    if not DynamicTrading.DialogueManager then return isSuccess and "Done." or "No deal." end
    return DynamicTrading.DialogueManager.GenerateTransactionMessage(trader, isSuccess, diagArgs)
end

function V1_DataProvider:getSellAskDialogue(trader)
    if not DynamicTrading.DialogueManager then return "What you got?" end
    return DynamicTrading.DialogueManager.GenerateSellAskDialogue(trader)
end

function V1_DataProvider:getIdleMessage(trader)
    if not DynamicTrading.DialogueManager then return nil end
    return DynamicTrading.DialogueManager.GenerateIdleMessage(trader)
end

function V1_DataProvider:getItemData(key)
    return DynamicTrading.Config.MasterList[key]
end

-- PRICING: Uses shared V2 Economy (faction-aware, globalHeat from Engine v2)
function V1_DataProvider:getBuyPrice(key, customData, verbose)
    -- V1_DataProvider receives a traderID from the trading window context
    local traderID = self._currentTraderID
    if traderID and DynamicTrading.Economy and DynamicTrading.Economy.V2 then
        return DynamicTrading.Economy.V2.GetBuyPrice(traderID, key, customData, verbose)
    end
    -- Fallback: use base price
    local itemData = DynamicTrading.Config.MasterList[key]
    return itemData and itemData.basePrice or 99999
end

function V1_DataProvider:getSellPrice(invItem, masterKey, trader, verbose)
    local traderID = trader and trader.id or self._currentTraderID
    if traderID and DynamicTrading.Economy and DynamicTrading.Economy.V2 then
        return DynamicTrading.Economy.V2.GetSellPrice(traderID, invItem, masterKey, verbose)
    end
    return 0
end

function V1_DataProvider:getPriceModifier(tags)
    -- Faction-aware event modifier
    local traderID = self._currentTraderID
    if traderID and DynamicTrading.Events and DynamicTrading.Events.GetFactionPriceModifier then
        local soul = DynamicTrading_Roster and DynamicTrading_Roster.GetSoulRegistry(traderID)
        if soul then
            local faction = DynamicTrading_Factions and DynamicTrading_Factions.GetFaction(soul.factionID)
            return DynamicTrading.Events.GetFactionPriceModifier(faction, tags)
        end
    end
    -- Fallback to global event modifier
    if DynamicTrading.Events and DynamicTrading.Events.GetPriceModifier then
        return DynamicTrading.Events.GetPriceModifier(tags)
    end
    return 1.0
end

function V1_DataProvider:lockItem(itemID)
    local player = getSpecificPlayer(0)
    if not player then return end -- Crash fix
    local modData = player:getModData()
    if not modData.DT_LockedItems then modData.DT_LockedItems = {} end
    modData.DT_LockedItems[itemID] = true
end

function V1_DataProvider:getMasterKey(fullType)
    for k, v in pairs(DynamicTrading.Config.MasterList) do
        if v.item == fullType then return k end
    end
    return nil
end

function V1_DataProvider:openHub(trader, parentUI)
    require "DT/V1/UI/DT_TraderDialogue_Hub"
    DT_TraderDialogue_Hub.Init(nil, trader, parentUI)
end

function V1_DataProvider:getArchetypeName(archetype)
    if DynamicTrading.Archetypes and DynamicTrading.Archetypes[archetype] then
        return DynamicTrading.Archetypes[archetype].name
    end
    return "Survivor"
end

function V1_DataProvider:getFavorStatus(trader)
    local current, limit = DynamicTrading.Manager.GetDailyStatus()
    local canRequest = true
    local tooltip = nil

    if current >= limit then
        canRequest = false
        tooltip = "Network Busy (Max Requests Reached)"
    elseif trader.hasRequestedFavor then
        canRequest = false
        tooltip = "Favor already requested from this contact."
    end

    return { canRequest = canRequest, tooltip = tooltip }
end

function V1_DataProvider:getAskButtonConfig(isBuying)
    if isBuying then
        return { title = "Talk", visible = true }
    else
        return { title = "ASK WHAT THEY WANT", visible = true }
    end
end

function V1_DataProvider:onAsk(trader, isBuying, ui)
    if isBuying then
        -- V1 Hub Flow
        require "DT/V1/UI/DT_TraderDialogue_Hub"
        DT_TraderDialogue_Hub.Init(nil, trader, ui)
    else
        -- V1 Sell Ask Flow
        local playerMsg = self:getPlayerMessage("SellAsk", {})
        ui:queueMessage(playerMsg, false, true, 0)
    
        local npcMsg = self:getSellAskDialogue(trader)
        ui:queueMessage(npcMsg, false, false, 30) 
    end
end

function V1_DataProvider:playSound(soundName)
    if DT_AudioManager then
        DT_AudioManager.PlaySound(soundName, false, 0.1)
    end
end

function V1_DataProvider:getLockButtonVisible(isBuying)
    return not isBuying
end

function V1_DataProvider:getWindowTitle(trader)
    if not trader then return "Trading Terminal" end
    
    local name = trader.name or "Unknown Trader"
    local postfixes = {
        "Store", "Emporium", "Outpost", "Supplies", "Direct", 
        "Exchange", "Market", "Corner", "Trading Co.", "Depot",
        "Wares", "Bazaar", "Stockpile", "General Store"
    }
    
    -- Use traderID as seed for consistency (so it doesn't change every time we open window)
    local seed = 0
    if trader.traderID then
        for i = 1, #trader.traderID do
            seed = seed + string.byte(trader.traderID, i)
        end
    end
    
    local index = (seed % #postfixes) + 1
    local postfix = postfixes[index]
    
    return name .. "'s " .. postfix
end

function V1_DataProvider:isConnectionValid(obj)
    local player = getSpecificPlayer(0)
    -- [CRASH FIX]
    if not player or player:isDead() then return false end
    if not obj then return false end

    local data = nil
    if obj.getDeviceData then
        data = obj:getDeviceData()
    end
    
    if not data or not data:getIsTurnedOn() then return false end

    if instanceof(obj, "IsoWaveSignal") then
        local sq = obj:getSquare()
        if not sq then return false end
        if IsoUtils.DistanceTo(player:getX(), player:getY(), obj:getX(), obj:getY()) > 5.0 then return false end
        if data:getIsBatteryPowered() and data:getPower() <= 0 then return false end
        if not data:getIsBatteryPowered() and not sq:haveElectricity() then return false end
    else
        if obj:getContainer() ~= player:getInventory() then return false end
        if data:getPower() <= 0.001 then return false end
    end
    return true
end

function V1_DataProvider:getPlayerWealth(player)
    -- [CRASH FIX] Handle nil player
    if not player then return 0 end
    local inv = player:getInventory()
    local loose = inv:getItemsFromType("Base.Money", true)
    local bundles = inv:getItemsFromType("Base.MoneyBundle", true)
    local looseCount = loose and loose:size() or 0
    local bundleCount = bundles and bundles:size() or 0
    return looseCount + (bundleCount * 100)
end

-- V1 Specific Toggle Implementation
local originalToggle = DT_TradingWindow.ToggleWindow
function DT_TradingWindow.ToggleWindow(traderID, archetype, radioObj)
    -- Set the current trader ID so pricing functions can look up the soul
    V1_DataProvider._currentTraderID = traderID
    originalToggle(traderID, archetype, radioObj, V1_DataProvider)
end
