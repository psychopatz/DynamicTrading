if isClient() and not isServer() then return end

require "DT/V2/Faction/TradingSys/DynamicTrading_Factions"
require "DT/V2/Faction/TradingSys/DynamicTrading_Roster"
require "DT/V2/Config"

DynamicTrading = DynamicTrading or {}
DynamicTrading.Economy = {}

-- =============================================================================
-- 1. V2 STOCK GENERATOR
-- =============================================================================
function DynamicTrading.Economy.GenerateStock(traderUUID)
    local soul = DynamicTrading_Roster.GetSoulRegistry(traderUUID)
    if not soul then return {} end
    
    local faction = DynamicTrading_Factions.GetFaction(soul.factionID)
    local archetype = DynamicTrading.Archetypes[soul.archetypeID] or DynamicTrading.Archetypes["General"]
    
    local masterList = DynamicTrading.Config.MasterList
    if not masterList then return {} end

    local resultStock = {}
    
    -- Determine Shop Size
    local baseMin, baseMax = 15, 25
    local totalSlots = ZombRand(baseMin, baseMax + 1)
    
    local slotsFilled = 0
    
    -- PHASE 1: ALLOCATIONS (Archetype based)
    if archetype.allocations then
        for tag, count in pairs(archetype.allocations) do
            local validItems = {}
            for itemKey, itemData in pairs(masterList) do
                for _, t in ipairs(itemData.tags) do
                    if t == tag then
                        table.insert(validItems, itemKey)
                        break
                    end
                end
            end
            
            if #validItems > 0 then
                for i=1, count do
                    if slotsFilled >= totalSlots then break end
                    local pick = validItems[ZombRand(#validItems) + 1]
                    resultStock[pick] = true
                    slotsFilled = slotsFilled + 1
                end
            end
        end
    end
    
    -- PHASE 2: FILLER (Random from MasterList, respecting forbidden tags)
    -- Simplified for now: just pick random items until full
    local itemKeys = {}
    for k, _ in pairs(masterList) do table.insert(itemKeys, k) end
    
    while slotsFilled < totalSlots do
        local pick = itemKeys[ZombRand(#itemKeys) + 1]
        if not resultStock[pick] then
            resultStock[pick] = true
            slotsFilled = slotsFilled + 1
        end
    end
    
    -- PHASE 3: QUANTITIES & PRICING
    local finalItems = {}
    for itemKey, _ in pairs(resultStock) do
        local itemData = masterList[itemKey]
        local qty = ZombRand(itemData.stockRange.min, itemData.stockRange.max + 1)
        
        -- Apply Faction Stockpile Multiplier (Optional enhancement)
        -- If faction has high food stockpile, food items might be more abundant
        
        finalItems[itemKey] = {
            qty = math.max(1, qty),
            basePrice = itemData.basePrice,
            dynamicMod = 1.0
        }
    end
    
    return finalItems
end

-- =============================================================================
-- 2. V2 PRICING LOGIC
-- =============================================================================

function DynamicTrading.Economy.GetBuyPrice(traderUUID, itemFullType)
    local soul = DynamicTrading_Roster.GetSoulRegistry(traderUUID)
    local itemData = DynamicTrading.Config.MasterList[itemFullType]
    if not itemData or not soul then return 99999 end
    
    local price = itemData.basePrice
    
    -- Tag Multipliers
    local maxTagMult = 1.0
    for _, tag in ipairs(itemData.tags) do
        local tagConfig = DynamicTrading.Config.Tags[tag]
        if tagConfig and tagConfig.priceMult and tagConfig.priceMult > maxTagMult then
            maxTagMult = tagConfig.priceMult
        end
    end
    price = price * maxTagMult
    
    -- Faction Reputation (Placeholder/Basic implementation)
    local faction = DynamicTrading_Factions.GetFaction(soul.factionID)
    -- Logic for reputation adjustment could go here
    
    return math.ceil(price)
end

function DynamicTrading.Economy.GetSellPrice(traderUUID, itemObj, itemFullType)
    local soul = DynamicTrading_Roster.GetSoulRegistry(traderUUID)
    local itemData = DynamicTrading.Config.MasterList[itemFullType]
    if not itemData or not soul then return 0 end
    
    local price = itemData.basePrice * 0.5 -- Base 50% sell-back
    
    -- Condition Penalty
    if itemObj:IsDrainable() or itemObj:isBroken() then
        local cond = itemObj:getCondition() / itemObj:getConditionMax()
        price = price * cond
    end
    
    -- Archetype Interest (Wants)
    local archetype = DynamicTrading.Archetypes[soul.archetypeID]
    if archetype and archetype.wants then
        for _, tag in ipairs(itemData.tags) do
            if archetype.wants[tag] then
                price = price * archetype.wants[tag]
                break
            end
        end
    end
    
    return math.floor(price)
end
