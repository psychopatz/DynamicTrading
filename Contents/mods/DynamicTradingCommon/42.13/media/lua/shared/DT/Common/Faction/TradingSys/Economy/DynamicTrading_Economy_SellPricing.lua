local V2 = DynamicTrading.Economy.V2
local Common = DynamicTrading.Economy.Common

function V2.GetSellPrice(traderUUID, itemObj, itemFullType, verbose, skipEvents)
    local soul = DynamicTrading_Roster.GetSoulRegistry(traderUUID)
    local itemData = DynamicTrading.Config.MasterList[itemFullType]
    if not itemData or not soul then return 0 end

    verbose = verbose or DynamicTrading.Debug

    local engineData = DynamicTrading_Engine.GetEngineData()
    local globalHeat = engineData and engineData.WorldEconomy and engineData.WorldEconomy.GlobalHeat or {}

    local localDeflationCount = 0
    if DynamicTrading_Stock then
        local stockData = DynamicTrading_Stock.GetStock(traderUUID)
        if stockData and stockData.deflation then
            localDeflationCount = stockData.deflation[itemFullType] or 0
        end
    end

    local diff = DynamicTrading.Config.GetDifficultyData()
    local archetypeID = soul.archetypeID or soul.archetype
    local archetype = archetypeID and DynamicTrading.Archetypes[archetypeID]
    if DynamicTrading.IsArchetypeSellTabEnabled and not DynamicTrading.IsArchetypeSellTabEnabled(archetype or archetypeID) then
        return 0
    end

    local modifiers = {
        tagsConfig = DynamicTrading.Config.Tags,
        globalHeat = globalHeat,
        localDeflationCount = localDeflationCount,
        getPriceModifier = function(tags)
            if not skipEvents and DynamicTrading.Events and DynamicTrading.Events.GetFactionPriceModifier then
                local faction = DynamicTrading_Factions.GetFaction(soul.factionID)
                return DynamicTrading.Events.GetFactionPriceModifier(faction, tags, verbose)
            end
            return 1.0
        end
    }

    local price = Common.GetSellPrice(itemFullType, itemData, itemObj, diff, archetype, modifiers, verbose)
    return price
end
