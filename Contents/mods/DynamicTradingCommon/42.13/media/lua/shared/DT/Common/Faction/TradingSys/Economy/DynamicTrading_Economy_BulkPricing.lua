local V2 = DynamicTrading.Economy.V2
local Internal = V2._Internal
local Common = DynamicTrading.Economy.Common

function V2.GetBulkBuyPreview(traderUUID, itemFullType, customData, qty, verbose)
    local itemData = DynamicTrading.Config.MasterList[itemFullType]
    if not itemData then
        return { qty = 0, totalPrice = 0, totalBasePrice = 0, firstUnitPrice = 0, lastUnitPrice = 0 }
    end

    local requestedQty = math.max(0, math.floor(tonumber(qty) or 0))
    if requestedQty <= 0 then
        return { qty = 0, totalPrice = 0, totalBasePrice = 0, firstUnitPrice = 0, lastUnitPrice = 0 }
    end

    local fixedPrice = Internal.GetFixedStockPrice(traderUUID, itemFullType)
    if fixedPrice ~= nil then
        local totalPrice = fixedPrice * requestedQty
        return {
            qty = requestedQty,
            totalPrice = totalPrice,
            totalBasePrice = totalPrice,
            firstUnitPrice = fixedPrice,
            lastUnitPrice = fixedPrice
        }
    end

    local engineData = DynamicTrading_Engine.GetEngineData()
    local simulatedHeat = Internal.CopyHeatTable(engineData and engineData.WorldEconomy and engineData.WorldEconomy.GlobalHeat or {})
    local category = Common.GetPrimaryTradeTag(itemData, customData and customData.fluidType, customData and customData.fluidAmount)
    local sensitivity = (SandboxVars.DynamicTrading and SandboxVars.DynamicTrading.CategoryInflation) or 0.05

    local totalPrice = 0
    local totalBasePrice = 0
    local firstUnitPrice = 0
    local lastUnitPrice = 0

    for i = 1, requestedQty do
        local unitPrice = Internal.ResolveBuyPriceWithHeat(traderUUID, itemFullType, customData, simulatedHeat, verbose, false)
        local baseUnitPrice = Internal.ResolveBuyPriceWithHeat(traderUUID, itemFullType, customData, simulatedHeat, false, true)

        if i == 1 then
            firstUnitPrice = unitPrice
        end

        lastUnitPrice = unitPrice
        totalPrice = totalPrice + unitPrice
        totalBasePrice = totalBasePrice + baseUnitPrice

        if category and category ~= "Misc" then
            simulatedHeat[category] = Internal.ClampHeatValue((simulatedHeat[category] or 0) + sensitivity)
        end
    end

    return {
        qty = requestedQty,
        totalPrice = totalPrice,
        totalBasePrice = totalBasePrice,
        firstUnitPrice = firstUnitPrice,
        lastUnitPrice = lastUnitPrice
    }
end

function V2.GetMaxAffordableBuyQuantity(traderUUID, itemFullType, customData, maxQty, budget)
    local itemData = DynamicTrading.Config.MasterList[itemFullType]
    local maxAllowed = math.max(0, math.floor(tonumber(maxQty) or 0))
    local availableBudget = math.max(0, math.floor(tonumber(budget) or 0))

    if not itemData or maxAllowed <= 0 then
        return { qty = 0, totalPrice = 0, totalBasePrice = 0 }
    end

    local fixedPrice = Internal.GetFixedStockPrice(traderUUID, itemFullType)
    if fixedPrice ~= nil then
        if fixedPrice <= 0 then
            return {
                qty = maxAllowed,
                totalPrice = 0,
                totalBasePrice = 0
            }
        end

        local quantity = math.min(maxAllowed, math.floor(availableBudget / fixedPrice))
        local totalPrice = quantity * fixedPrice
        return {
            qty = quantity,
            totalPrice = totalPrice,
            totalBasePrice = totalPrice
        }
    end

    if availableBudget <= 0 then
        return { qty = 0, totalPrice = 0, totalBasePrice = 0 }
    end

    local engineData = DynamicTrading_Engine.GetEngineData()
    local simulatedHeat = Internal.CopyHeatTable(engineData and engineData.WorldEconomy and engineData.WorldEconomy.GlobalHeat or {})
    local category = Common.GetPrimaryTradeTag(itemData, customData and customData.fluidType, customData and customData.fluidAmount)
    local sensitivity = (SandboxVars.DynamicTrading and SandboxVars.DynamicTrading.CategoryInflation) or 0.05

    local totalPrice = 0
    local totalBasePrice = 0
    local quantity = 0

    for _ = 1, maxAllowed do
        local unitPrice = Internal.ResolveBuyPriceWithHeat(traderUUID, itemFullType, customData, simulatedHeat, false, false)
        local baseUnitPrice = Internal.ResolveBuyPriceWithHeat(traderUUID, itemFullType, customData, simulatedHeat, false, true)

        if totalPrice + unitPrice > availableBudget then
            break
        end

        quantity = quantity + 1
        totalPrice = totalPrice + unitPrice
        totalBasePrice = totalBasePrice + baseUnitPrice

        if category and category ~= "Misc" then
            simulatedHeat[category] = Internal.ClampHeatValue((simulatedHeat[category] or 0) + sensitivity)
        end
    end

    return {
        qty = quantity,
        totalPrice = totalPrice,
        totalBasePrice = totalBasePrice
    }
end
