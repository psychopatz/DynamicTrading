-- =============================================================================
-- DYNAMIC TRADING V1: RADIO TRADER DIALOGUE HUB
-- =============================================================================
-- Logic: Handles conversation flow for radio-based traders in V1.
-- Uses Common DT_ConversationUI for the interface.
-- =============================================================================

require "UI/DT_ConversationUI"
require "DT/V1/Radio/DT_V1_TradingWrapper"

local DEBUG_PREFIX = "[DT-V1-Hub]"

DT_V1_Dialogue_Hub = {}
DT_V1_Dialogue_Hub.PendingTrade = nil

-- =============================================================================
-- 1. INITIALIZATION
-- =============================================================================
function DT_V1_Dialogue_Hub.Init(ui, radioObj, traderID, player)
    print(DEBUG_PREFIX .. " Initializing dialogue for " .. tostring(traderID))
    
    if not ui then
        if not DT_ConversationUI then return end
        
        -- Resolve Trader Data from V1/Common
        local trader = nil
        if DynamicTrading and DynamicTrading.Manager and DynamicTrading.Manager.GetTrader then
            trader = DynamicTrading.Manager.GetTrader(traderID)
        end
        
        if not trader then
            print(DEBUG_PREFIX .. " ERROR: Trader data not found for " .. tostring(traderID))
            return
        end

        local traderProxy = {
            id = traderID,
            name = trader.name or "Survivor",
            archetype = trader.archetype or "Survivor",
            gender = trader.gender or "Male",
            portraitID = trader.portraitID or 1,
            factionID = trader.factionID,
            returnTime = trader.returnTime
        }
        
        ui = DT_ConversationUI.Open(traderProxy, nil, nil, true, radioObj) -- isRadio = true, interactionObj = radioObj
    end
    
    if not traderID or not player then return end
    
    -- Speak Intro
    ui:speak("Hello. This is " .. (traderProxy and traderProxy.name or "The Trader") .. " on the line.")

    -- Generate Options
    DT_V1_Dialogue_Hub.GenerateOptions(ui, radioObj, traderID, player)
end

-- =============================================================================
-- 2. OPTIONS GENERATION
-- =============================================================================
function DT_V1_Dialogue_Hub.GenerateOptions(ui, radioObj, traderID, player)
    local options = {}
    
    -- Cache trader data for logic
    local trader = DynamicTrading.Manager.GetTrader(traderID)
    local isTrading = (trader and trader.status == "Trading")
    
    -- OPTION 1: CHAT
    table.insert(options, {
        text = "Chat",
        message = "Can you hear me clearly?",
        onSelect = function(ui)
            ui:speak("Signal is strong. I'm ready to trade if you have the goods.")
            DT_V1_Dialogue_Hub.GenerateOptions(ui, radioObj, traderID, player)
        end
    })

    -- OPTION 2: TRADE
    table.insert(options, {
        text = "Trade",
        message = "I'm looking to do some business.",
        onSelect = function(ui)
            if isTrading then
                print(DEBUG_PREFIX .. " Trade option selected")
                
                -- Check for cached stock
                local stockData = (DynamicTrading_Client and DynamicTrading_Client.Cache and DynamicTrading_Client.Cache.Stocks) 
                                  or ModData.get("DynamicTrading_Stock")
                
                if stockData and stockData[traderID] then
                    print(DEBUG_PREFIX .. " Stock cached, opening TradingWindow")
                    ui:close()
                    V1_Radio_DataProvider.Open(traderID, trader.archetype, radioObj)
                else
                    print(DEBUG_PREFIX .. " Requesting stock generation...")
                    ui:speak("Let me check my inventory list... one moment.")
                    
                    -- Request stock from server (Uses "DynamicTrading" module handled by Common Network)
                    local args = { traderID = traderID }
                    sendClientCommand(player, "DynamicTrading", "GenerateStock", args)
                    
                    -- Store pending trade context
                    DT_V1_Dialogue_Hub.PendingTrade = {
                        traderID = traderID,
                        archetype = trader.archetype,
                        radioObj = radioObj,
                        ui = ui,
                        startTime = getGameTime():getWorldAgeHours()
                    }
                end
            else
                ui:speak("Signal is cutting out... call me back later.")
                DT_V1_Dialogue_Hub.GenerateOptions(ui, radioObj, traderID, player)
            end
        end
    })

    -- OPTION 3: LEAVE
    table.insert(options, {
        text = "End Call",
        message = "Over and out.",
        onSelect = function(ui)
            ui:close()
        end
    })
    
    ui:updateOptions(options)
end

-- =============================================================================
-- 3. NETWORK LISTENER (Common / V2 Compatibility)
-- =============================================================================
-- We listen for SyncStock from the server, which can come as "DynamicTrading_V2" 
-- or "DynamicTrading". This ensures V1 works even when V2 is disabled.

DynamicTrading_Client = DynamicTrading_Client or {}
DynamicTrading_Client.Cache = DynamicTrading_Client.Cache or {}
DynamicTrading_Client.Cache.Stocks = DynamicTrading_Client.Cache.Stocks or {}

function DT_V1_Dialogue_Hub.OnServerCommand(module, command, args)
    if (module == "DynamicTrading_V2" or module == "DynamicTrading") then
        if command == "SyncStock" then
            local id = args.id
            if id then
                print(DEBUG_PREFIX .. " Received SyncStock for " .. tostring(id))
                DynamicTrading_Client.Cache.Stocks[id] = args
                
                -- Update ModData for fallback/persistence
                local stockData = ModData.get("DynamicTrading_Stock")
                if stockData then
                    stockData[id] = args
                end
                
                -- Trigger Event for UI (if needed)
                if LuaEventManager and LuaEventManager.triggerEvent then
                    triggerEvent("OnDynamicTradingStockUpdated", id)
                end
            end
        elseif command == "TradeResult" then
            print(DEBUG_PREFIX .. " Received TradeResult: " .. tostring(args.success) .. " (" .. tostring(args.reason) .. ")")
        end
    end
end

-- =============================================================================
-- 4. PENDING TRADE POLLING
-- =============================================================================
local function OnTick()
    if not DT_V1_Dialogue_Hub.PendingTrade then return end
    
    local pending = DT_V1_Dialogue_Hub.PendingTrade
    local uiValid = pending.ui and pending.ui:getIsVisible()
    
    if not uiValid then
        DT_V1_Dialogue_Hub.PendingTrade = nil
        return
    end
    
    -- Check local cache (updated by OnServerCommand above)
    local stockData = DynamicTrading_Client.Cache.Stocks
    
    if stockData and stockData[pending.traderID] then
        print(DEBUG_PREFIX .. " Stock arrived! Opening TradingWindow")
        pending.ui:close()
        V1_Radio_DataProvider.Open(pending.traderID, pending.archetype, pending.radioObj)
        DT_V1_Dialogue_Hub.PendingTrade = nil
        return
    end
    
    local gt = getGameTime()
    local elapsed = gt:getWorldAgeHours() - pending.startTime
    
    if elapsed > 0.005 and not pending.hasSpokenShortWait then
        pending.ui:speak("Still reading the manifest... stay on the line.")
        pending.hasSpokenShortWait = true
    end

    if gt and elapsed > 0.02 then
        print(DEBUG_PREFIX .. " Stock request timeout")
        if uiValid then
            pending.ui:speak("Sorry, I'm having trouble with the connection. Try again.")
        end
        DT_V1_Dialogue_Hub.PendingTrade = nil
    end
end

Events.OnTick.Remove(OnTick)
Events.OnTick.Add(OnTick)

Events.OnServerCommand.Remove(DT_V1_Dialogue_Hub.OnServerCommand)
Events.OnServerCommand.Add(DT_V1_Dialogue_Hub.OnServerCommand)

print(DEBUG_PREFIX .. " V1 Radio Dialogue Hub loaded")
return DT_V1_Dialogue_Hub
