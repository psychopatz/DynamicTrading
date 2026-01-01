require "DynamicTrading_Config"
require "DynamicTrading_Tags"
require "DynamicTrading_Archetypes"
require "DynamicTrading_Events"
require "DynamicTrading_Manager"
require "DynamicTrading_Economy"


DynamicTrading = DynamicTrading or {}
DynamicTrading.Shared = {}
DynamicTrading.Client = {}

print("[DynamicTrading] Loading Core...")

function DynamicTrading.Shared.GetData()
    return ModData.getOrCreate("DynamicTradingData")
end

function DynamicTrading.Shared.OnInit()
    local data = DynamicTrading.Shared.GetData()
    local isStockEmpty = true
    if data.stocks then
        for k, v in pairs(data.stocks) do isStockEmpty = false; break end
    end

    if not data.init or isStockEmpty then
        DynamicTrading.Shared.RestockMarket(data)
    end
end
Events.OnInitGlobalModData.Add(DynamicTrading.Shared.OnInit)

function DynamicTrading.Shared.RestockMarket(data)
    if not DynamicTrading.Economy then return end
    
    data.stocks = {}
    data.prices = {}
    data.buyHistory = {} 
    if not data.categoryHeat then data.categoryHeat = {} end
    if not data.salesHistory then data.salesHistory = {} end

    -- Decay Heat
    for cat, val in pairs(data.categoryHeat) do
        data.categoryHeat[cat] = val * 0.5
        if data.categoryHeat[cat] < 0.01 then data.categoryHeat[cat] = 0 end
    end

    local newStock, merchantName = DynamicTrading.Economy.GenerateDailyStock()
    data.stocks = newStock
    data.currentMerchant = merchantName 

    local noiseBase = SandboxVars.DynamicTrading and SandboxVars.DynamicTrading.PriceVolatility or 0.1
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
-- TRANSACTION: BUY
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

    if currentStock <= 0 then
        player:Say("This item is Sold Out!")
        return
    end

    if wealth < currentPrice then
        player:Say("I need $" .. currentPrice .. " (You have $" .. wealth .. ")")
        return
    end

    -- Payment Logic
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

    -- Give Item
    inventory:AddItem(config.item)

    -- Update Data
    data.stocks[recipeKey] = currentStock - 1
    data.salesHistory[recipeKey] = (data.salesHistory[recipeKey] or 0) + 1
    if DynamicTrading.Economy then DynamicTrading.Economy.UpdateCategoryHeat(config.category) end
    
    -- Feedback
    player:playSound("Transaction") 
    local displayName = config.item
    local scriptItem = getScriptManager():getItem(config.item)
    if scriptItem then displayName = scriptItem:getDisplayName() end
    
    player:Say("Bought " .. displayName .. " for $" .. currentPrice, 1.0, 0.2, 0.2, UIFont.Medium, 10, "default")

    if isClient() then ModData.transmit("DynamicTradingData") end
    
    -- REFRESH UI
    -- We call populateList, which triggers clear(), then populateBuyList(), 
    -- which reads DynamicTradingUI.instance.selectedBuyKey to restore selection.
    if DynamicTradingUI and DynamicTradingUI.instance and DynamicTradingUI.instance:isVisible() then 
        DynamicTradingUI.instance:populateList() 
    end
end

-- =================================================
-- TRANSACTION: SELL
-- =================================================
function DynamicTrading.Shared.PerformSell(player, itemObj, price, masterKey, itemName)
    if not player or not itemObj or not price then return end
    
    local data = DynamicTrading.Shared.GetData()
    if not data.buyHistory then data.buyHistory = {} end

    local inventory = player:getInventory()
    if not inventory:contains(itemObj) then return end

    local remaining = price
    while remaining >= 100 do
        inventory:AddItem("Base.MoneyBundle")
        remaining = remaining - 100
    end
    if remaining > 0 then inventory:AddItems("Base.Money", remaining) end

    inventory:Remove(itemObj)

    if masterKey then data.buyHistory[masterKey] = (data.buyHistory[masterKey] or 0) + 1 end

    player:playSound("Transaction") 
    player:Say("Sold " .. (itemName or "Item") .. " for $" .. price, 0.2, 1.0, 0.2, UIFont.Medium, 10, "default")

    if isClient() then ModData.transmit("DynamicTradingData") end
    if DynamicTradingUI and DynamicTradingUI.instance then DynamicTradingUI.instance:populateList() end
end

function DynamicTrading.Shared.CheckDailyReset()
    local gameTime = GameTime:getInstance()
    local currentDay = math.floor(gameTime:getDaysSurvived())
    local data = DynamicTrading.Shared.GetData()
    local interval = SandboxVars.DynamicTrading and SandboxVars.DynamicTrading.RestockInterval or 1

    if data.lastResetDay and (currentDay - data.lastResetDay) >= interval then
        DynamicTrading.Shared.RestockMarket(data)
        if DynamicTradingUI and DynamicTradingUI.instance and DynamicTradingUI.instance:isVisible() then
            DynamicTradingUI.instance:close()
        end
        local p = getSpecificPlayer(0)
        if p then p:Say("Market Restocked: New Trader has arrived!") end
    end
end
Events.EveryDays.Add(DynamicTrading.Shared.CheckDailyReset)

local function OnFillWorldObjectContextMenu(player, context, worldObjects, test)
    if DynamicTradingUI then context:addOption("Check Market Prices", nil, DynamicTradingUI.ToggleWindow) end
    if DynamicTradingInfoUI then context:addOption("Market Economy", nil, DynamicTradingInfoUI.ToggleWindow) end
end
Events.OnFillWorldObjectContextMenu.Add(OnFillWorldObjectContextMenu)

function DynamicTrading.Client.OnCheckStock(arg1, arg2, arg3) return true end
function DynamicTrading.Shared.OnTradeTransaction(craftRecipeData, character) end