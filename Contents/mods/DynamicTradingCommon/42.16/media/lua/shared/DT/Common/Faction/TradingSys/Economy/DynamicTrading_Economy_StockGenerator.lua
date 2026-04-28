local V2 = DynamicTrading.Economy.V2
local Common = DynamicTrading.Economy.Common

local function getResolvedArchetypeForSoul(soul)
    local archetypeID = soul and soul.archetypeID or "General"
    local archetype = DynamicTrading.Archetypes[archetypeID]
    if not archetype and DynamicTrading.IsLotteryAgent and DynamicTrading.IsLotteryAgent(soul) then
        archetype = DynamicTrading.Archetypes["LotteryAgent"]
    end
    return archetypeID, archetype or DynamicTrading.Archetypes["General"]
end

local function isLotteryTicketItem(item)
    if not item then
        return false
    end

    local fullType = string.lower(tostring(item.getFullType and item:getFullType() or ""))
    local displayName = string.lower(tostring(item.getDisplayName and item:getDisplayName() or item.getName and item:getName() or ""))

    local fullHasTicket = string.find(fullType, "ticket", 1, true) ~= nil
    local displayHasTicket = string.find(displayName, "ticket", 1, true) ~= nil

    return string.find(fullType, "lottery", 1, true) ~= nil
        or string.find(fullType, "lotto", 1, true) ~= nil
        or string.find(displayName, "lottery", 1, true) ~= nil
        or string.find(displayName, "lotto", 1, true) ~= nil
        or (string.find(fullType, "scratch", 1, true) ~= nil and fullHasTicket)
        or (string.find(displayName, "scratch", 1, true) ~= nil and displayHasTicket)
end

local function getFallbackInventoryPrice(item)
    local weight = tonumber(item and item.getActualWeight and item:getActualWeight() or item and item.getWeight and item:getWeight() or 0.1) or 0.1
    return math.max(10, math.floor((weight * 100) + 25))
end

local function isLotteryMasterListEntry(itemKey, itemData)
    local keyText = string.lower(tostring(itemKey or itemData and itemData.item or ""))
    if string.find(keyText, "lottery", 1, true)
        or string.find(keyText, "lotto", 1, true)
        or (string.find(keyText, "scratch", 1, true) and string.find(keyText, "ticket", 1, true)) then
        return true
    end

    for _, tag in ipairs(itemData and itemData.tags or {}) do
        local tagText = string.lower(tostring(tag or ""))
        if string.find(tagText, "lottery", 1, true) or string.find(tagText, "lotto", 1, true) then
            return true
        end
    end

    return false
end

local function mergeLotteryInventoryStock(finalItems, masterList, traderUUID, soul)
    if not (DynamicTrading.IsLotteryAgent and DynamicTrading.IsLotteryAgent(soul)) then
        return
    end

    local zombie = nil
    local npcData = nil
    if DTNPCServerCore and DTNPCServerCore.GetNPCDataByUUID then
        zombie, npcData = DTNPCServerCore.GetNPCDataByUUID(traderUUID)
    end

    if not (DynamicTrading.IsLotteryAgent and DynamicTrading.IsLotteryAgent(npcData or soul)) then
        return
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
            if isLotteryTicketItem(item) then
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
        if isLotteryMasterListEntry(itemKey, itemData) then
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

    mergeLotteryInventoryStock(finalItems, masterList, traderUUID, soul)

    return finalItems
end
