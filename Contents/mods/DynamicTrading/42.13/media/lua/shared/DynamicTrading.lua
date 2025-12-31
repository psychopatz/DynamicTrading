-- ==========================================================
-- File: Contents\mods\DynamicTrading\42.13\media\lua\shared\DynamicTrading.lua
-- CORE CONTROLLER
-- ==========================================================

require "DynamicTrading_Economy"
require "DynamicTrading_Config"

DynamicTrading = DynamicTrading or {}
DynamicTrading.Shared = {}
DynamicTrading.Client = {}

print("[DynamicTrading] Loading Core Controller...")

-- =================================================
-- HELPER: GET MOD DATA
-- =================================================
function DynamicTrading.Shared.GetData()
    return ModData.getOrCreate("DynamicTradingData")
end

-- =================================================
-- INITIALIZATION HOOK
-- =================================================
function DynamicTrading.Shared.OnInit()
    local data = DynamicTrading.Shared.GetData()
    
    -- Check if data is empty or invalid
    local isStockEmpty = true
    if data.stocks then
        for k, v in pairs(data.stocks) do
            isStockEmpty = false
            break
        end
    end

    if not data.init or isStockEmpty then
        print("[DynamicTrading] Data missing or empty. Generating initial market stock...")
        DynamicTrading.Shared.RestockMarket(data)
    else
        print("[DynamicTrading] Market data loaded successfully.")
    end
end

Events.OnInitGlobalModData.Add(DynamicTrading.Shared.OnInit)

-- =================================================
-- LOGIC: DAILY RESTOCK (RESET)
-- =================================================
function DynamicTrading.Shared.RestockMarket(data)
    if not DynamicTrading.Economy or not DynamicTrading.Economy.GenerateDailyStock then
        print("[DynamicTrading] ERROR: Economy script not loaded yet.")
        return
    end

    print("[DynamicTrading] Performing Daily Restock...")

    -- 1. Reset Data Structures
    data.stocks = {}        -- Current Shop Inventory
    data.prices = {}        -- Current Buy Prices
    data.salesHistory = {}  -- Items Bought BY Player (for stats)
    data.buyHistory = {}    -- Items Sold BY Player (for Quotas)
    
    -- 2. Decay Category Heat (Inflation cools down over time)
    if not data.categoryHeat then data.categoryHeat = {} end
    for cat, val in pairs(data.categoryHeat) do
        data.categoryHeat[cat] = val * 0.5
        if data.categoryHeat[cat] < 0.01 then data.categoryHeat[cat] = 0 end
    end

    -- 3. Generate New Stock
    local newStock, merchantName = DynamicTrading.Economy.GenerateDailyStock()
    data.stocks = newStock
    data.currentMerchant = merchantName 

    -- 4. Calculate Initial Prices with Volatility
    local noiseBase = 0.1
    if SandboxVars.DynamicTrading and SandboxVars.DynamicTrading.PriceVolatility then
         noiseBase = SandboxVars.DynamicTrading.PriceVolatility 
    end

    for key, qty in pairs(newStock) do
        local rawPrice = DynamicTrading.Economy.CalculatePrice(key, qty, data.categoryHeat)
        -- Add daily randomness (Noise) to the calculated price
        local randomFactor = ZombRandFloat(1.0 - (noiseBase/2), 1.0 + noiseBase)
        local finalPrice = math.floor(rawPrice * randomFactor)
        
        if finalPrice < 1 then finalPrice = 1 end
        data.prices[key] = finalPrice
    end
    
    -- 5. Finalize
    data.lastResetDay = GameTime:getInstance():getDaysSurvived()
    data.init = true
    
    -- Sync to Client
    if isClient() then ModData.transmit("DynamicTradingData") end
end

-- =================================================
-- LOGIC: DAILY TIMER CHECK
-- =================================================
function DynamicTrading.Shared.CheckDailyReset()
    local gameTime = GameTime:getInstance()
    local currentDay = math.floor(gameTime:getDaysSurvived())
    local data = DynamicTrading.Shared.GetData()

    local interval = 1
    if SandboxVars.DynamicTrading and SandboxVars.DynamicTrading.RestockInterval then
        interval = SandboxVars.DynamicTrading.RestockInterval
    end
    
    local lastReset = data.lastResetDay or 0

    if (currentDay - lastReset) >= interval then
        print("[DynamicTrading] Interval reached. Triggering Restock.")
        DynamicTrading.Shared.RestockMarket(data)
        
        -- Close UI if open to prevent visual desync
        if DynamicTradingUI and DynamicTradingUI.instance and DynamicTradingUI.instance:isVisible() then
            DynamicTradingUI.instance:close()
        end
        
        -- Notification
        local player = getSpecificPlayer(0)
        if player then
            player:Say("Market Restocked: New Trader has arrived!")
            player:playSound("PZ_UI_MarketRestock") -- Optional sound (ensure it exists or remove)
        end
    end
end

Events.EveryDays.Add(DynamicTrading.Shared.CheckDailyReset)

-- =================================================
-- TRANSACTION: BUY (Trader -> Player)
-- =================================================
function DynamicTrading.Shared.PerformTrade(player, recipeKey)
    if not player or not recipeKey then return end
    
    local config = DynamicTrading.Config.MasterList[recipeKey]
    if not config then return end

    local data = DynamicTrading.Shared.GetData()
    local currentStock = data.stocks[recipeKey] or 0
    local currentPrice = data.prices[recipeKey] or config.basePrice
    
    local inventory = player:getInventory()
    -- Calculate Wealth (Cash + Bundles)
    local wealth = inventory:getItemCount("Base.Money") + (inventory:getItemCount("Base.MoneyBundle") * 100)

    -- 1. Validation
    if currentStock <= 0 then
        player:Say("This item is Sold Out!")
        return
    end

    if wealth < currentPrice then
        player:Say("I need $" .. currentPrice .. " (You have $" .. wealth .. ")")
        return
    end

    -- 2. Process Payment
    local moneyNeeded = currentPrice
    local moneyCount = inventory:getItemCount("Base.Money")

    -- Break bundles if needed
    while moneyCount < moneyNeeded do
        local bundle = inventory:getFirstType("Base.MoneyBundle")
        if bundle then
            inventory:Remove(bundle)
            inventory:AddItems("Base.Money", 100)
            moneyCount = moneyCount + 100
        else break end
    end

    for i = 1, moneyNeeded do
        inventory:RemoveOneOf("Base.Money")
    end

    -- 3. Give Item
    inventory:AddItem(config.item)

    -- 4. Update Data
    data.stocks[recipeKey] = currentStock - 1
    data.salesHistory[recipeKey] = (data.salesHistory[recipeKey] or 0) + 1
    
    -- Increase Inflation/Heat for this category
    if DynamicTrading.Economy then
        DynamicTrading.Economy.UpdateCategoryHeat(config.category)
    end
    
    -- Feedback
    player:playSound("Transaction") -- Default generic sound
    player:Say("Bought " .. (config.item:match(".*%.(.*)") or config.item))

    -- 5. Force UI Refresh
    if isClient() then ModData.transmit("DynamicTradingData") end
    if DynamicTradingUI and DynamicTradingUI.instance then
        DynamicTradingUI.instance:populateList()
    end
end

-- =================================================
-- TRANSACTION: SELL (Player -> Trader)
-- =================================================
function DynamicTrading.Shared.PerformSell(player, itemObj, price, masterKey)
    if not player or not itemObj or not price then return end
    
    local data = DynamicTrading.Shared.GetData()
    if not data.buyHistory then data.buyHistory = {} end

    local inventory = player:getInventory()
    
    -- 1. Validation
    if not inventory:contains(itemObj) then return end

    -- 2. Give Money
    -- Optimize by giving bundles for large amounts
    local remaining = price
    while remaining >= 100 do
        inventory:AddItem("Base.MoneyBundle")
        remaining = remaining - 100
    end
    
    if remaining > 0 then
        inventory:AddItems("Base.Money", remaining)
    end

    -- 3. Remove Item
    inventory:Remove(itemObj)

    -- 4. Update Quota History
    -- Used to track if player is flooding the market
    if masterKey then
        data.buyHistory[masterKey] = (data.buyHistory[masterKey] or 0) + 1
    end

    -- 5. Feedback
    player:playSound("Transaction") 
    player:Say("Sold for $" .. price)

    -- 6. Refresh UI
    if isClient() then ModData.transmit("DynamicTradingData") end
    if DynamicTradingUI and DynamicTradingUI.instance then
        DynamicTradingUI.instance:populateList()
    end
end

-- =================================================
-- CONTEXT MENU INTEGRATION
-- =================================================
local function OnFillWorldObjectContextMenu(player, context, worldObjects, test)
    -- Add "Check Market" to right-click menu
    if DynamicTradingUI then
        context:addOption("Check Market Prices", nil, DynamicTradingUI.ToggleWindow)
    end
    
    -- Add Debug Menu if in Debug Mode
    if isDebugEnabled() and DynamicTradingDebugUI then
        context:addOption("[DEBUG] Market Economy", nil, DynamicTradingDebugUI.ToggleWindow)
    end
end

Events.OnFillWorldObjectContextMenu.Add(OnFillWorldObjectContextMenu)

-- =================================================
-- LEGACY SUPPORT (Crafting Menu)
-- =================================================
-- Keeps compatibility if you still use recipe-based trading
function DynamicTrading.Client.OnCheckStock(arg1, arg2, arg3) return true end

function DynamicTrading.Shared.OnTradeTransaction(craftRecipeData, character)
    if not character then return end
    local createdItems = craftRecipeData:getAllCreatedItems()
    if createdItems:isEmpty() then return end
    
    local resultItem = createdItems:get(0)
    local resultType = resultItem:getFullType()
    
    -- Find Key
    local recipeKey
    for key, cfg in pairs(DynamicTrading.Config.MasterList) do
        if cfg.item == resultType then recipeKey = key; break end
    end
    
    if recipeKey then
        -- We manually call PerformTrade logic, but since item is already created
        -- by the recipe engine, we just deduct money/stock.
        -- (Simplified for brevity, ideally redirect completely)
        DynamicTrading.Shared.PerformTrade(character, recipeKey)
    end
end

print("[DynamicTrading] Core Controller Loaded Successfully.")