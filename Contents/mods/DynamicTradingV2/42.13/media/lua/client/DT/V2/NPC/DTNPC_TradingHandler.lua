-- =============================================================================
-- DYNAMIC TRADING V2: NPC TRADING HANDLER
-- Handles the logic for initiating trades and managing stock generation requests
-- =============================================================================

-- Fixed Guard: Run in Client OR Single Player. Exclude only Dedicated Server.
if isServer() and not isClient() then return end

-- Use "or {}" pattern to prevent wiping table during double-load (auto-load + require)
DTNPC_TradingHandler = DTNPC_TradingHandler or {}
DTNPC_TradingHandler.PendingTrades = DTNPC_TradingHandler.PendingTrades or {}

-- Helper to display stock in the UI speech
function DTNPC_TradingHandler.DisplayStock(ui, id, stockData)
    if not ui then return end
    
    local debugStr = "I got these items:\n"
    if stockData and stockData[id] and stockData[id].items then
        local hasItems = false
        for k, v in pairs(stockData[id].items) do
            debugStr = debugStr .. k .. " Quantity: " .. tostring(v.qty) .. "\n"
            hasItems = true
        end
        if not hasItems then debugStr = debugStr .. "Nothing at the moment." end
    else
        debugStr = debugStr .. "Empty"
    end
    ui:speak(debugStr)
end

-- Initiates the trade flow from the Dialogue Hub
function DTNPC_TradingHandler.InitiateTrade(ui, npc, player)
    if not npc or not player then return end
    
    local brain = npc:getModData().DTNPCBrain
    -- Build 42: Prioritize persistent ID from brain
    local id = (brain and brain.uuid) or npc:getPersistentOutfitID() or npc:getID()
    local name = brain and brain.name or "Survivor"

    -- Check if we already have stock cached
    -- In MP, use the client network cache. In SP, fall back to global ModData.
    local stockData = (DynamicTrading_Client and DynamicTrading_Client.Cache and DynamicTrading_Client.Cache.Stocks) or ModData.get("DynamicTrading_Stock")
    
    if stockData and stockData[id] then
        DTNPC_TradingHandler.DisplayStock(ui, id, stockData)
        print("DTNPC_TradingHandler: Stock cached for " .. tostring(id))
    else
        -- No stock, request generation
        if ui then
            ui:speak("Let me see what I have...")
        end
        
        -- Register as pending
        DTNPC_TradingHandler.PendingTrades[id] = {
            ui = ui,
            npc = npc,
            player = player,
            startTime = getGameTime():getWorldAgeHours()
        }
        
        local args = { traderID = id }
        sendClientCommand(player, "DynamicTrading_V2", "GenerateStock", args)
        print("DTNPC_TradingHandler: Requesting stock for " .. name)
    end
end

-- Polling logic to check for arrived stock
local function OnTick()
    -- Safety check for early initialization and empty table
    if not DTNPC_TradingHandler or not DTNPC_TradingHandler.PendingTrades then return end
    
    -- Check if we have any pending trades without using next() which can be problematic in some B42 contexts
    local hasPending = false
    for _ in pairs(DTNPC_TradingHandler.PendingTrades) do
        hasPending = true
        break
    end
    if not hasPending then return end
    
    local gt = getGameTime()
    if not gt then return end
    
    -- Safety check: getWorldAgeHours is a method on the GameTime object
    local currentHours = gt:getWorldAgeHours()
    if not currentHours then return end
    
    -- In MP, use the client network cache. In SP, fall back to global ModData.
    local stockData = (DynamicTrading_Client and DynamicTrading_Client.Cache and DynamicTrading_Client.Cache.Stocks) or ModData.get("DynamicTrading_Stock")
    
    for id, data in pairs(DTNPC_TradingHandler.PendingTrades) do
        -- Check if UI still exists and is valid (ISPanel check)
        local uiValid = data.ui and data.ui:getIsVisible()
        
        -- Check if stock arrived in ModData
        if stockData and stockData[id] then
            DTNPC_TradingHandler.PendingTrades[id] = nil
            if uiValid then
                DTNPC_TradingHandler.DisplayStock(data.ui, id, stockData)
                print("DTNPC_TradingHandler: Stock arrived for " .. tostring(id))
            end
        
        -- Timeout logic (roughly 5-10 seconds real time depending on day length)
        elseif (currentHours - data.startTime) > 0.005 then 
            DTNPC_TradingHandler.PendingTrades[id] = nil
            if uiValid then
                data.ui:speak("Sorry, I'm having trouble checking my inventory right now.")
            end
            print("DTNPC_TradingHandler: Timeout for " .. tostring(id))
        
        -- If UI is closed, stop tracking this trade
        elseif not uiValid then
            DTNPC_TradingHandler.PendingTrades[id] = nil
            print("DTNPC_TradingHandler: UI closed, cancelling pending trade for " .. tostring(id))
        end
    end
end

-- Clear old listener if present (B42 strategy for hot-reload safety)
Events.OnTick.Remove(OnTick)
Events.OnTick.Add(OnTick)

return DTNPC_TradingHandler
