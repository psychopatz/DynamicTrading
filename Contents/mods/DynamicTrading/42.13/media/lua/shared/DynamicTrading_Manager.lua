require "DynamicTrading_Config"
-- We will require "DynamicTrading_Economy" in the next step, 
-- but the Manager calls functions that will exist there.

DynamicTrading = DynamicTrading or {}
DynamicTrading.Manager = {}

-- =============================================================================
-- 1. DATA RETRIEVAL (ModData)
-- =============================================================================
function DynamicTrading.Manager.GetData()
    local data = ModData.getOrCreate("DynamicTrading_Engine_v1")
    
    -- Initialize Root Structure if missing
    if not data.init then
        data.globalHeat = {}   -- Stores inflation: { ["Food"] = 1.10 }
        data.Traders = {}      -- Stores instances: { ["Muldraugh_Farmer"] = { ... } }
        data.init = true
    end
    
    return data
end

-- =============================================================================
-- 2. TRADER INSTANCE MANAGEMENT
-- =============================================================================
-- This is the function the UI calls to get the stock for a specific NPC/Object.
-- If the trader doesn't exist yet, it creates them on the fly.
-- 
-- traderID:  Unique String (e.g., "Npc_505" or "Muldraugh_Market_Stall_1")
-- archetype: (Optional) Which type to create if they are new (e.g., "Farmer")
function DynamicTrading.Manager.GetTrader(traderID, archetype)
    if not traderID then return nil end
    
    local data = DynamicTrading.Manager.GetData()
    
    -- 1. Check if Trader exists
    if not data.Traders[traderID] then
        print("[DynamicTrading] New Trader Detected: " .. traderID)
        
        -- Create New Instance
        data.Traders[traderID] = {
            id = traderID,
            archetype = archetype or "General", -- Default to General if not specified
            stocks = {},
            lastRestockDay = -1
        }
        
        -- Generate Initial Stock immediately
        DynamicTrading.Manager.RestockTrader(traderID, true)
    end
    
    return data.Traders[traderID]
end

-- =============================================================================
-- 3. RESTOCK LOGIC
-- =============================================================================
function DynamicTrading.Manager.RestockTrader(traderID, force)
    local data = DynamicTrading.Manager.GetData()
    local trader = data.Traders[traderID]
    if not trader then return end
    
    -- Check Interval (Sandbox)
    local gt = GameTime:getInstance()
    local currentDay = math.floor(gt:getDaysSurvived())
    local interval = SandboxVars.DynamicTrading and SandboxVars.DynamicTrading.RestockInterval or 1
    
    if force or (currentDay - trader.lastRestockDay >= interval) then
        
        -- CALL THE ECONOMY ENGINE (We will write this in Step 4)
        if DynamicTrading.Economy and DynamicTrading.Economy.GenerateStock then
            local newStock = DynamicTrading.Economy.GenerateStock(trader.archetype)
            trader.stocks = newStock
            trader.lastRestockDay = currentDay
            print("[DynamicTrading] Restocked Trader: " .. traderID .. " (" .. trader.archetype .. ")")
        else
            print("[DynamicTrading] Error: Economy Engine not loaded yet.")
        end
        
        if isClient() then ModData.transmit("DynamicTrading_Engine_v1") end
    end
end

-- =============================================================================
-- 4. GLOBAL HEAT (INFLATION) MANAGER
-- =============================================================================
-- Updates the "Heat" for a specific category when players buy items.
function DynamicTrading.Manager.UpdateHeat(category, amount)
    if not category or category == "Misc" then return end
    
    local data = DynamicTrading.Manager.GetData()
    local current = data.globalHeat[category] or 0
    
    -- Add heat (e.g., +0.02)
    data.globalHeat[category] = current + amount
    
    -- Cap inflation (Safety limit: Max +200% price increase)
    if data.globalHeat[category] > 2.0 then data.globalHeat[category] = 2.0 end
    
    -- Cap deflation (Safety limit: Min -50% price discount)
    if data.globalHeat[category] < -0.5 then data.globalHeat[category] = -0.5 end
    
    if isClient() then ModData.transmit("DynamicTrading_Engine_v1") end
end

-- =============================================================================
-- 5. TRANSACTION HANDLERS
-- =============================================================================
-- Called when Player BUYS an item
function DynamicTrading.Manager.OnBuyItem(traderID, itemKey, category, qty)
    local data = DynamicTrading.Manager.GetData()
    local trader = data.Traders[traderID]
    if not trader or not trader.stocks[itemKey] then return end

    -- 1. Remove Stock
    trader.stocks[itemKey] = trader.stocks[itemKey] - qty
    if trader.stocks[itemKey] < 0 then trader.stocks[itemKey] = 0 end

    -- 2. Trigger Global Inflation (Real-time "Slippage")
    -- Sandbox setting determines how sensitive the market is
    local sensitivity = SandboxVars.DynamicTrading and SandboxVars.DynamicTrading.CategoryInflation or 0.05
    DynamicTrading.Manager.UpdateHeat(category, sensitivity * qty)
    
    if isClient() then ModData.transmit("DynamicTrading_Engine_v1") end
end

-- Called when Player SELLS an item
function DynamicTrading.Manager.OnSellItem(traderID, itemKey, category, qty)
    -- Optional: Selling could LOWER inflation slightly?
    -- For now, we'll keep it simple. Maybe selling huge bulk reduces demand?
    -- Let's apply a tiny cooling effect.
    DynamicTrading.Manager.UpdateHeat(category, -0.01 * qty)
end

-- =============================================================================
-- 6. DAILY TICK (Decay & Restock)
-- =============================================================================
function DynamicTrading.Manager.OnDailyTick()
    local data = DynamicTrading.Manager.GetData()
    if not data or not data.init then return end

    -- 1. Decay Global Heat (Market stabilizes over time)
    -- Every day, heat moves 10% closer to 0.
    for cat, val in pairs(data.globalHeat) do
        if val ~= 0 then
            data.globalHeat[cat] = val * 0.90
            -- Clean up tiny decimals
            if math.abs(data.globalHeat[cat]) < 0.01 then data.globalHeat[cat] = 0 end
        end
    end
    
    -- [NEW] Update Events for the new day
    if DynamicTrading.Events and DynamicTrading.Events.CheckEvents then
        DynamicTrading.Events.CheckEvents()
    end

    -- 2. Check Restocks for ALL Traders
    if data.Traders then
        for id, trader in pairs(data.Traders) do
            DynamicTrading.Manager.RestockTrader(id, false)
        end
    end
    
    if isClient() then ModData.transmit("DynamicTrading_Engine_v1") end
end

Events.EveryDays.Add(DynamicTrading.Manager.OnDailyTick)

print("[DynamicTrading] Manager Loaded.")