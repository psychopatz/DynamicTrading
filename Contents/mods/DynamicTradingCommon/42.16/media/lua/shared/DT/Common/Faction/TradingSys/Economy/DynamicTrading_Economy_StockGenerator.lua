local V2 = DynamicTrading.Economy.V2
local Common = DynamicTrading.Economy.Common

-- =============================================================================
-- 1. V2 STOCK GENERATOR (Wrapper) - SERVER ONLY
-- =============================================================================
function V2.GenerateStock(traderUUID)
    if isClient() and not isServer() then return {} end

    local soul = DynamicTrading_Roster.GetSoulRegistry(traderUUID)
    if not soul then return {} end

    local faction = DynamicTrading_Factions.GetFaction(soul.factionID)
    local archetype = DynamicTrading.Archetypes[soul.archetypeID] or DynamicTrading.Archetypes["General"]

    local masterList = DynamicTrading.Config.MasterList
    if not masterList then return {} end

    local diff = DynamicTrading.Config.GetDifficultyData()
    local modifiers = {
        tagsConfig = DynamicTrading.Config.Tags,
        globalStockMult = 1.0
    }

    if DynamicTrading.Events and DynamicTrading.Events.UpdateFaction then
        modifiers.getVolumeModifier = function(tags)
            return DynamicTrading.Events.GetFactionVolumeModifier(faction, tags)
        end
        modifiers.eventInjections = DynamicTrading.Events.GetFactionInjections(faction)
        modifiers.expertTags = DynamicTrading.Events.GetFactionExpertTags(faction)
        modifiers.forbidTags = DynamicTrading.Events.GetFactionForbidTags(faction)
    end

    local rawStock = Common.GenerateStock(archetype, masterList, diff, modifiers)
    local finalItems = {}

    for itemKey, entry in pairs(rawStock) do
        local itemData = masterList[itemKey]
        if itemData then
            local basePrice = itemData.basePrice
            if DynamicTrading.PriceConfig and DynamicTrading.PriceConfig.GetEffectiveBasePrice then
                basePrice = DynamicTrading.PriceConfig.GetEffectiveBasePrice(itemKey, itemData)
            end

            finalItems[itemKey] = {
                qty = entry.qty,
                basePrice = basePrice,
                dynamicMod = 1.0,
                customData = entry.customData,
                fixedPrice = entry.fixedPrice
            }
        end
    end

    return finalItems
end
