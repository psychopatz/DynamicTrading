local V2 = DynamicTrading.Economy.V2
local Internal = V2._Internal
local Common = DynamicTrading.Economy.Common

Internal.Common = Common

function Internal.ClampHeatValue(value)
    if value > 2.0 then return 2.0 end
    if value < -0.8 then return -0.8 end
    return value
end

function Internal.CopyHeatTable(source)
    local clone = {}
    for key, value in pairs(source or {}) do
        clone[key] = value
    end
    return clone
end

function Internal.GetTraderStockEntry(traderUUID, itemFullType)
    if not DynamicTrading_Stock or not DynamicTrading_Stock.GetStock then
        return nil
    end

    local stockData = DynamicTrading_Stock.GetStock(traderUUID)
    if not stockData or not stockData.items then
        return nil
    end

    local entry = stockData.items[itemFullType]
    if type(entry) ~= "table" then
        return nil
    end

    return entry
end

function Internal.GetFixedStockPrice(traderUUID, itemFullType)
    local entry = Internal.GetTraderStockEntry(traderUUID, itemFullType)
    if not entry or entry.fixedPrice == nil then
        return nil
    end

    return math.max(0, math.floor(tonumber(entry.fixedPrice) or 0))
end

function Internal.BuildBuyPriceModifiers(soul, customData, globalHeat, verbose, skipEvents)
    return {
        tagsConfig = DynamicTrading.Config.Tags,
        customData = customData,
        globalHeat = globalHeat or {},
        getPriceModifier = function(tags)
            if not skipEvents and DynamicTrading.Events and DynamicTrading.Events.GetFactionPriceModifier then
                local faction = DynamicTrading_Factions.GetFaction(soul.factionID)
                return DynamicTrading.Events.GetFactionPriceModifier(faction, tags, verbose)
            end
            return 1.0
        end
    }
end

function Internal.ResolveBuyPriceWithHeat(traderUUID, itemFullType, customData, globalHeat, verbose, skipEvents)
    local soul = DynamicTrading_Roster.GetSoulRegistry(traderUUID)
    local itemData = DynamicTrading.Config.MasterList[itemFullType]
    if not itemData or not soul then return 99999 end

    local fixedPrice = Internal.GetFixedStockPrice(traderUUID, itemFullType)
    if fixedPrice ~= nil then
        return fixedPrice
    end

    verbose = verbose or DynamicTrading.Debug

    if not customData and soul.stocks and soul.stocks[itemFullType] then
        customData = soul.stocks[itemFullType].customData
    end

    local diff = DynamicTrading.Config.GetDifficultyData()
    local modifiers = Internal.BuildBuyPriceModifiers(soul, customData, globalHeat, verbose, skipEvents)

    return Common.GetBuyPrice(itemFullType, itemData, diff, modifiers, verbose)
end
