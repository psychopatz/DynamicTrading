DynamicTrading = DynamicTrading or {}
DynamicTrading.Shared = {}
DynamicTrading.Client = {}

-- =================================================
-- CONFIGURATION
-- =================================================
DynamicTrading.Config = {
    BuyAxe = {
        item = "Base.Axe",
        basePrice = 50, 
        maxStock = 5
    },
    BuyApple = {
        item = "Base.Apple",
        basePrice = 5,
        maxStock = 20
    }
}

-- =================================================
-- DATA MANAGEMENT
-- =================================================
function DynamicTrading.Shared.GetData()
    local data = ModData.getOrCreate("DynamicTradingData")
    if not data.init then
        data.stocks = {}
        data.prices = {}
        data.salesHistory = {}
        
        for recipe, config in pairs(DynamicTrading.Config) do
            data.stocks[recipe] = config.maxStock
            data.prices[recipe] = config.basePrice
            data.salesHistory[recipe] = 0
        end
        
        data.lastResetDay = GameTime:getInstance():getDaysSurvived()
        data.init = true
    end
    return data
end

-- =================================================
-- LOGIC: Check Stock & Price
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
    for key, cfg in pairs(DynamicTrading.Config) do
        if cfg.item == resultType then
            recipeKey = key
            config = cfg
            break
        end
    end
    if not config then return true end 

    local data = DynamicTrading.Shared.GetData()
    local currentStock = data.stocks[recipeKey] or 0
    local currentPrice = data.prices[recipeKey] or config.basePrice

    if currentStock <= 0 then return false end

    local player = getSpecificPlayer(0)
    if not player then return true end
    local inventory = player:getInventory()
    local wealth = inventory:getItemCount("Base.Money") + (inventory:getItemCount("Base.MoneyBundle") * 100)

    if wealth < currentPrice then return false end

    return true
end

-- =================================================
-- LOGIC: Transaction
-- =================================================
function DynamicTrading.Shared.OnTradeTransaction(craftRecipeData, character)
    if not character then return end
    local createdItems = craftRecipeData:getAllCreatedItems()
    if createdItems:isEmpty() then return end
    
    local resultItem = createdItems:get(0)
    local resultType = resultItem:getFullType()
    local inventory = character:getInventory()

    local recipeKey, config
    for key, cfg in pairs(DynamicTrading.Config) do
        if cfg.item == resultType then
            recipeKey = key
            config = cfg
            break
        end
    end
    if not config then return end

    local data = DynamicTrading.Shared.GetData()
    local currentStock = data.stocks[recipeKey] or 0
    local currentPrice = data.prices[recipeKey] or config.basePrice

    local wealth = inventory:getItemCount("Base.Money") + (inventory:getItemCount("Base.MoneyBundle") * 100)
    
    -- Safety Check
    if currentStock <= 0 or wealth < currentPrice then
        if resultItem:getContainer() then resultItem:getContainer():Remove(resultItem)
        else inventory:Remove(resultItem) end
        character:Say("Trade Cancelled: Price changed or Out of Stock")
        character:StopAllActionQueue()
        return
    end

    -- Process Payment
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

    -- Update Data
    data.stocks[recipeKey] = currentStock - 1
    data.salesHistory[recipeKey] = (data.salesHistory[recipeKey] or 0) + 1

    character:Say("Paid $" .. currentPrice .. " for " .. resultItem:getName())
    
    if DynamicTradingUI and DynamicTradingUI.instance then
        DynamicTradingUI.instance:populateList()
    end
end

-- =================================================
-- LOGIC: Daily Restock
-- =================================================
function DynamicTrading.Shared.CheckDailyReset()
    local gameTime = GameTime:getInstance()
    local currentDay = math.floor(gameTime:getDaysSurvived())
    local data = DynamicTrading.Shared.GetData()

    -- SAFE SANDBOX VARS ACCESS
    local interval = 1
    local inflation = 1.0

    if SandboxVars.DynamicTrading then
        interval = SandboxVars.DynamicTrading.RestockInterval or 1
        inflation = SandboxVars.DynamicTrading.PriceInflation or 1.0
    end

    if data.lastResetDay and (currentDay - data.lastResetDay) >= interval then
        print("DynamicTrading: Restocking Market...")

        for recipe, config in pairs(DynamicTrading.Config) do
            -- Restock
            data.stocks[recipe] = config.maxStock
            
            -- Dynamic Price Calculation
            local sold = data.salesHistory[recipe] or 0
            local randomVar = ZombRandFloat(0.9, 1.15)
            local demandCost = sold * (config.basePrice * (0.1 * inflation))
            local newPrice = math.floor((config.basePrice * randomVar) + demandCost)
            
            if newPrice < 1 then newPrice = 1 end

            data.prices[recipe] = newPrice
            data.salesHistory[recipe] = 0
        end
        
        data.lastResetDay = currentDay
        if isClient() then ModData.transmit("DynamicTradingData") end
        
        getSpecificPlayer(0):Say("Market Restocked!")
    end
end

Events.EveryDays.Add(DynamicTrading.Shared.CheckDailyReset)