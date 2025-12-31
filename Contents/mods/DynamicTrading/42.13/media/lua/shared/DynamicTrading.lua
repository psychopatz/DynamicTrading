DynamicTrading = DynamicTrading or {}
DynamicTrading.Shared = {}
DynamicTrading.Client = {}

print("[DynamicTrading] Loading Core...")

-- =================================================
-- INITIALIZATION HOOK (Fixes Empty Shop Issue)
-- =================================================
function DynamicTrading.Shared.OnInit()
    local data = ModData.getOrCreate("DynamicTradingData")
    
    -- 1. Check if stocks are empty (Fix for broken saves/first load)
    local isStockEmpty = true
    if data.stocks then
        for k, v in pairs(data.stocks) do
            isStockEmpty = false
            break
        end
    end

    -- 2. Initialize if new game, uninitialized, or empty
    if not data.init or isStockEmpty then
        print("[DynamicTrading] Data missing or empty. Generating initial market stock...")
        DynamicTrading.Shared.RestockMarket(data)
    else
        print("[DynamicTrading] Market data loaded successfully.")
    end
end

-- Hook into the Global Mod Data initialization event
Events.OnInitGlobalModData.Add(DynamicTrading.Shared.OnInit)

-- =================================================
-- SHARED: RESTOCK LOGIC
-- =================================================
function DynamicTrading.Shared.RestockMarket(data)
    -- Verify Economy script is ready
    if not DynamicTrading.Economy or not DynamicTrading.Economy.GenerateDailyStock then
        print("[DynamicTrading] ERROR: Economy script not loaded yet. Retrying next tick...")
        return
    end

    data.stocks = {}
    data.prices = {}
    if not data.categoryHeat then data.categoryHeat = {} end
    if not data.salesHistory then data.salesHistory = {} end

    -- 1. Decay Category Heat (Market Recovery)
    for cat, val in pairs(data.categoryHeat) do
        data.categoryHeat[cat] = val * 0.5
        if data.categoryHeat[cat] < 0.01 then data.categoryHeat[cat] = 0 end
    end

    -- 2. Generate Stock & Get Merchant Archetype
    local newStock, merchantName = DynamicTrading.Economy.GenerateDailyStock()
    
    data.stocks = newStock
    data.currentMerchant = merchantName -- Save this for the UI!

    -- 3. Calculate Prices
    local noiseBase = 1.0
    if SandboxVars.DynamicTrading and SandboxVars.DynamicTrading.PriceVolatility then
         noiseBase = SandboxVars.DynamicTrading.PriceVolatility 
    end

    for key, qty in pairs(newStock) do
        local rawPrice = DynamicTrading.Economy.CalculatePrice(key, qty, data.categoryHeat)
        
        -- Apply random noise for daily variance
        local randomFactor = ZombRandFloat(1.0 - (noiseBase/2), 1.0 + noiseBase)
        local finalPrice = math.floor(rawPrice * randomFactor)
        if finalPrice < 1 then finalPrice = 1 end
        
        data.prices[key] = finalPrice
        data.salesHistory[key] = 0 
    end
    
    data.lastResetDay = GameTime:getInstance():getDaysSurvived()
    data.init = true
    
    if isClient() then ModData.transmit("DynamicTradingData") end
end

-- =================================================
-- HELPER: GET DATA
-- =================================================
function DynamicTrading.Shared.GetData()
    return ModData.getOrCreate("DynamicTradingData")
end

-- =================================================
-- LOGIC: CHECK STOCK (For Recipe Validation)
-- =================================================
function DynamicTrading.Client.OnCheckStock(arg1, arg2, arg3)
    local resultType = nil
    if arg2 and arg2.getFullType then resultType = arg2:getFullType()
    elseif arg1 and arg1.getOutput then 
        local output = arg1:getOutput()
        if output then resultType = output:getFullType() end
    end
    if not resultType then return true end

    local recipeKey, config
    if DynamicTrading.Config and DynamicTrading.Config.MasterList then
        for key, cfg in pairs(DynamicTrading.Config.MasterList) do
            if cfg.item == resultType then
                recipeKey = key
                config = cfg
                break
            end
        end
    end
    if not config then return true end 

    local data = DynamicTrading.Shared.GetData()
    local currentStock = data.stocks and data.stocks[recipeKey] or 0
    
    -- Block only if specifically sold out
    if currentStock <= 0 then return false end
    
    return true
end

-- =================================================
-- LOGIC: TRANSACTION
-- =================================================
function DynamicTrading.Shared.OnTradeTransaction(craftRecipeData, character)
    if not character then return end
    local createdItems = craftRecipeData:getAllCreatedItems()
    if createdItems:isEmpty() then return end
    
    local resultItem = createdItems:get(0)
    local resultType = resultItem:getFullType()
    local inventory = character:getInventory()

    -- 1. Identify Item
    local recipeKey, config
    if DynamicTrading.Config and DynamicTrading.Config.MasterList then
        for key, cfg in pairs(DynamicTrading.Config.MasterList) do
            if cfg.item == resultType then
                recipeKey = key
                config = cfg
                break
            end
        end
    end
    if not config then return end

    local data = DynamicTrading.Shared.GetData()
    local currentStock = data.stocks[recipeKey] or 0
    local currentPrice = data.prices[recipeKey] or config.basePrice
    local wealth = inventory:getItemCount("Base.Money") + (inventory:getItemCount("Base.MoneyBundle") * 100)
    
    -- 2. Validation: Stock
    if currentStock <= 0 then
        if resultItem:getContainer() then resultItem:getContainer():Remove(resultItem)
        else inventory:Remove(resultItem) end
        
        character:Say("Transaction Failed: Item is Sold Out!")
        character:StopAllActionQueue()
        return
    end

    -- 3. Validation: Money
    if wealth < currentPrice then
        if resultItem:getContainer() then resultItem:getContainer():Remove(resultItem)
        else inventory:Remove(resultItem) end
        
        character:Say("Transaction Failed: Need $" .. currentPrice .. " (You have $" .. wealth .. ")")
        character:StopAllActionQueue()
        return
    end

    -- 4. Process Payment
    local moneyNeeded = currentPrice
    local moneyCount = inventory:getItemCount("Base.Money")

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

    -- 5. Update Data
    data.stocks[recipeKey] = currentStock - 1
    data.salesHistory[recipeKey] = (data.salesHistory[recipeKey] or 0) + 1
    
    if DynamicTrading.Economy then
        DynamicTrading.Economy.UpdateCategoryHeat(config.category)
    end

    character:Say("Paid $" .. currentPrice .. " for " .. resultItem:getName())
    
    -- Refresh UI live
    if DynamicTradingUI and DynamicTradingUI.instance and DynamicTradingUI.instance:isVisible() then
         DynamicTradingUI.instance:populateList()
    end
end

-- =================================================
-- DAILY RESET TIMER
-- =================================================
function DynamicTrading.Shared.CheckDailyReset()
    local gameTime = GameTime:getInstance()
    local currentDay = math.floor(gameTime:getDaysSurvived())
    local data = DynamicTrading.Shared.GetData()

    local interval = 1
    if SandboxVars.DynamicTrading and SandboxVars.DynamicTrading.RestockInterval then
        interval = SandboxVars.DynamicTrading.RestockInterval
    end

    if data.lastResetDay and (currentDay - data.lastResetDay) >= interval then
        print("[DynamicTrading] Daily Reset Triggered.")
        
        -- 1. RESTOCK
        DynamicTrading.Shared.RestockMarket(data)
        
        -- 2. CLOSE UI (Simulate vendor leaving)
        if DynamicTradingUI and DynamicTradingUI.instance and DynamicTradingUI.instance:isVisible() then
            DynamicTradingUI.instance:close()
        end
        
        getSpecificPlayer(0):Say("Market Restocked: New Trader has arrived!")
    end
end

Events.EveryDays.Add(DynamicTrading.Shared.CheckDailyReset)

-- =================================================
-- CONTEXT MENU
-- =================================================
local function OnFillWorldObjectContextMenu(player, context, worldObjects, test)
    if DynamicTradingUI then
        context:addOption("Check Market Prices", nil, DynamicTradingUI.ToggleWindow)
    end
    
    if isDebugEnabled() and DynamicTradingDebugUI then
        context:addOption("[DEBUG] Market Sales History", nil, DynamicTradingDebugUI.ToggleWindow)
    end
end

Events.OnFillWorldObjectContextMenu.Add(OnFillWorldObjectContextMenu)

print("[DynamicTrading] Core Loaded Successfully.")