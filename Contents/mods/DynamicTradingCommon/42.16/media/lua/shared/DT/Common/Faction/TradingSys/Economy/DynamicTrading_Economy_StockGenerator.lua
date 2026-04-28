local V2 = DynamicTrading.Economy.V2
local Common = DynamicTrading.Economy.Common

local function getResolvedArchetypeForSoul(soul)
    local archetypeID = soul and soul.archetypeID or "General"
    local stockArchetypeID = DynamicTrading.GetArchetypeStockSourceID
        and DynamicTrading.GetArchetypeStockSourceID(soul, archetypeID)
        or archetypeID
    local archetype = DynamicTrading.Archetypes[stockArchetypeID] or DynamicTrading.Archetypes[archetypeID]
    return stockArchetypeID, archetype or DynamicTrading.Archetypes["General"]
end

local function normalizeStockMatchText(value)
    local text = string.lower(tostring(value or ""))
    return string.gsub(text, "[%s%._%-]+", "")
end

local function textMatchesKeywords(text, keywords)
    local normalizedText = normalizeStockMatchText(text)
    if normalizedText == "" or type(keywords) ~= "table" then
        return false
    end

    for _, keyword in ipairs(keywords) do
        local normalizedKeyword = normalizeStockMatchText(keyword)
        if normalizedKeyword ~= "" and string.find(normalizedText, normalizedKeyword, 1, true) ~= nil then
            return true
        end
    end

    return false
end

local function itemMatchesSpecializedStock(item, keywords)
    if not item or type(keywords) ~= "table" then
        return false
    end

    local fullType = tostring(item.getFullType and item:getFullType() or "")
    local displayName = tostring(item.getDisplayName and item:getDisplayName() or item.getName and item:getName() or "")
    return textMatchesKeywords(fullType, keywords) or textMatchesKeywords(displayName, keywords)
end

local function getFallbackInventoryPrice(item)
    local weight = tonumber(item and item.getActualWeight and item:getActualWeight() or item and item.getWeight and item:getWeight() or 0.1) or 0.1
    return math.max(10, math.floor((weight * 100) + 25))
end

local function masterListEntryMatchesSpecializedStock(itemKey, itemData, keywords)
    if textMatchesKeywords(itemKey or itemData and itemData.item or "", keywords) then
        return true
    end

    for _, tag in ipairs(itemData and itemData.tags or {}) do
        if textMatchesKeywords(tag, keywords) then
            return true
        end
    end

    return false
end

local function mergeSpecializedInventoryStock(finalItems, masterList, traderUUID, soul)
    local inventoryKeywords = DynamicTrading.GetArchetypeInventoryStockKeywords
        and DynamicTrading.GetArchetypeInventoryStockKeywords(soul)
        or nil
    if type(inventoryKeywords) ~= "table" or #inventoryKeywords == 0 then
        return
    end

    local fallbackKeywords = DynamicTrading.GetArchetypeFallbackStockKeywords
        and DynamicTrading.GetArchetypeFallbackStockKeywords(soul)
        or inventoryKeywords

    local zombie = nil
    if DTNPCServerCore and DTNPCServerCore.GetNPCDataByUUID then
        zombie = DTNPCServerCore.GetNPCDataByUUID(traderUUID)
    end

    local inventory = zombie and zombie.getInventory and zombie:getInventory() or nil
    local items = inventory and inventory.getItems and inventory:getItems() or nil
    if not items then
        items = nil
    end

    local mergedCount = 0
    if items then
        for index = 0, items:size() - 1 do
            local item = items:get(index)
            if itemMatchesSpecializedStock(item, inventoryKeywords) then
                local itemKey = tostring(item:getFullType())
                local itemData = masterList and masterList[itemKey] or nil
                local basePrice = itemData and itemData.basePrice or getFallbackInventoryPrice(item)
                if DynamicTrading.PriceConfig and DynamicTrading.PriceConfig.GetEffectiveBasePrice and itemData then
                    basePrice = DynamicTrading.PriceConfig.GetEffectiveBasePrice(itemKey, itemData)
                end

                local existing = finalItems[itemKey]
                if existing then
                    existing.qty = math.max(1, tonumber(existing.qty) or 0) + 1
                else
                    finalItems[itemKey] = {
                        qty = 1,
                        basePrice = basePrice,
                        dynamicMod = 1.0,
                        fixedPrice = basePrice,
                    }
                end
                mergedCount = mergedCount + 1
            end
        end
    end

    if mergedCount > 0 or type(masterList) ~= "table" then
        return
    end

    for itemKey, itemData in pairs(masterList) do
        if masterListEntryMatchesSpecializedStock(itemKey, itemData, fallbackKeywords) then
            local basePrice = itemData.basePrice
            if DynamicTrading.PriceConfig and DynamicTrading.PriceConfig.GetEffectiveBasePrice then
                basePrice = DynamicTrading.PriceConfig.GetEffectiveBasePrice(itemKey, itemData)
            end
            local stockRange = itemData.stockRange or {}
            finalItems[itemKey] = finalItems[itemKey] or {
                qty = math.max(1, tonumber(stockRange.min) or 1),
                basePrice = basePrice,
                dynamicMod = 1.0,
                fixedPrice = basePrice,
            }
        end
    end
end

-- =============================================================================
-- 1. V2 STOCK GENERATOR (Wrapper) - SERVER ONLY
-- =============================================================================
function V2.GenerateStock(traderUUID)
    if isClient() and not isServer() then return {} end

    local soul = DynamicTrading_Roster.GetSoulRegistry(traderUUID)
    if not soul then return {} end

    local faction = DynamicTrading_Factions.GetFaction(soul.factionID)
    local _, archetype = getResolvedArchetypeForSoul(soul)

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

    mergeSpecializedInventoryStock(finalItems, masterList, traderUUID, soul)

    return finalItems
end
