DynamicTrading = DynamicTrading or {}
DynamicTrading.Shared = {}
DynamicTrading.Client = {}

print("[DynamicTrading] Loading Core...")

-- =================================================
-- INITIALIZATION HOOK
-- =================================================
function DynamicTrading.Shared.OnInit()
    local data = ModData.getOrCreate("DynamicTradingData")
    
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
-- SHARED: RESTOCK LOGIC
-- =================================================
function DynamicTrading.Shared.RestockMarket(data)
    if not DynamicTrading.Economy or not DynamicTrading.Economy.GenerateDailyStock then
        print("[DynamicTrading] ERROR: Economy script not loaded yet.")
        return
    end

    data.stocks = {}
    data.prices = {}
    if not data.categoryHeat then data.categoryHeat = {} end
    if not data.salesHistory then data.salesHistory = {} end

    for cat, val in pairs(data.categoryHeat) do
        data.categoryHeat[cat] = val * 0.5
        if data.categoryHeat[cat] < 0.01 then data.categoryHeat[cat] = 0 end
    end

    local newStock, merchantName = DynamicTrading.Economy.GenerateDailyStock()
    data.stocks = newStock
    data.currentMerchant = merchantName 

    local noiseBase = 1.0
    if SandboxVars.DynamicTrading and SandboxVars.DynamicTrading.PriceVolatility then
         noiseBase = SandboxVars.DynamicTrading.PriceVolatility 
    end

    for key, qty in pairs(newStock) do
        local rawPrice = DynamicTrading.Economy.CalculatePrice(key, qty, data.categoryHeat)
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
-- LOGIC: DIRECT UI TRANSACTION (NEW)
-- =================================================
function DynamicTrading.Shared.PerformTrade(player, recipeKey)
    if not player or not recipeKey then return end
    
    local config = DynamicTrading.Config.MasterList[recipeKey]
    if not config then return end

    local data = DynamicTrading.Shared.GetData()
    local currentStock = data.stocks[recipeKey] or 0
    local currentPrice = data.prices[recipeKey] or config.basePrice
    
    local inventory = player:getInventory()
    local wealth = inventory:getItemCount("Base.Money") + (inventory:getItemCount("Base.MoneyBundle") * 100)

    -- 1. Validation (Double Check)
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
    
    if DynamicTrading.Economy then
        DynamicTrading.Economy.UpdateCategoryHeat(config.category)
    end
    
    -- Play Sound (Optional)
    player:playSound("Transaction") -- Default generic sound, change if needed
    player:Say("Bought " .. config.item .. " for $" .. currentPrice)

    -- 5. Force UI Refresh
    if isClient() then ModData.transmit("DynamicTradingData") end
    if DynamicTradingUI and DynamicTradingUI.instance then
        DynamicTradingUI.instance:populateList()
    end
end

-- =================================================
-- LOGIC: EXISTING RECIPE TRANSACTION (Kept for compatibility)
-- =================================================
function DynamicTrading.Shared.OnTradeTransaction(craftRecipeData, character)
    -- This function handles the Crafting Menu version of trading
    -- We redirect to PerformTrade if possible, but the crafting system needs specific returns.
    -- For now, keeping the existing logic is safer to avoid breaking the "Crafting" menu access.
    
    if not character then return end
    local createdItems = craftRecipeData:getAllCreatedItems()
    if createdItems:isEmpty() then return end
    
    local resultItem = createdItems:get(0)
    local resultType = resultItem:getFullType()
    
    -- Identify Key
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

    -- Call the main logic, but since OnCreate gives the item automatically, 
    -- we manually handle stock/money here to avoid giving double items.
    
    local data = DynamicTrading.Shared.GetData()
    local currentStock = data.stocks[recipeKey] or 0
    local currentPrice = data.prices[recipeKey] or config.basePrice
    local inventory = character:getInventory()
    local wealth = inventory:getItemCount("Base.Money") + (inventory:getItemCount("Base.MoneyBundle") * 100)

    if currentStock <= 0 or wealth < currentPrice then
        -- Refund item
        if resultItem:getContainer() then resultItem:getContainer():Remove(resultItem)
        else inventory:Remove(resultItem) end
        character:Say("Transaction Failed!")
        character:StopAllActionQueue()
        return
    end
    
    -- Pay
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
    for i = 1, moneyNeeded do inventory:RemoveOneOf("Base.Money") end

    -- Update
    data.stocks[recipeKey] = currentStock - 1
    data.salesHistory[recipeKey] = (data.salesHistory[recipeKey] or 0) + 1
    if DynamicTrading.Economy then DynamicTrading.Economy.UpdateCategoryHeat(config.category) end
    character:Say("Paid $" .. currentPrice)
    
    if DynamicTradingUI and DynamicTradingUI.instance then DynamicTradingUI.instance:populateList() end
end

function DynamicTrading.Client.OnCheckStock(arg1, arg2, arg3)
    -- Kept for Crafting Menu compatibility
    return true
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
        DynamicTrading.Shared.RestockMarket(data)
        if DynamicTradingUI and DynamicTradingUI.instance and DynamicTradingUI.instance:isVisible() then
            DynamicTradingUI.instance:close()
        end
        getSpecificPlayer(0):Say("Market Restocked: New Trader has arrived!")
    end
end

Events.EveryDays.Add(DynamicTrading.Shared.CheckDailyReset)

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