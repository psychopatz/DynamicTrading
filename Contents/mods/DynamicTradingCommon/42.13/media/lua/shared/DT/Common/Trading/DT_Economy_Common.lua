-- =============================================================================
-- DYNAMIC TRADING: SHARED ECONOMY LOGIC
-- =============================================================================
-- This module contains the core math and logic for trading, stripped of 
-- specific data dependencies (like specific Events or Soul lookups).
-- V1 and V2 wrappers should gather the data and pass it here.

DynamicTrading = DynamicTrading or {}
DynamicTrading.Economy = DynamicTrading.Economy or {}
DynamicTrading.Economy.Common = {}

local Common = DynamicTrading.Economy.Common

-- =============================================================================
-- 1. UTILITIES
-- =============================================================================

-- Picks an item key from a pool based on 'weight' property.
-- pool = { {key="Base.Apple", weight=100}, {key="Base.Axe", weight=10} }
function Common.PickFromWeightedPool(pool)
    if not pool or #pool == 0 then return nil end
    
    -- 1. Calculate Total Weight
    local totalWeight = 0
    for _, entry in ipairs(pool) do
        totalWeight = totalWeight + entry.weight
    end
    
    -- Fallback if weights are busted
    if totalWeight <= 0 then return pool[ZombRand(#pool)+1].key end 
    
    -- 2. Roll the Dice
    local roll = ZombRandFloat(0, totalWeight)
    
    -- 3. Find the Winner
    local current = 0
    for _, entry in ipairs(pool) do
        current = current + entry.weight
        if roll <= current then
            return entry.key
        end
    end
    
    return pool[#pool].key
end

-- =============================================================================
-- 2. STOCK GENERATION
-- =============================================================================

--- Generates a stock list based on archetype and difficulty.
-- @param archetype (Table) The fully resolved archetype definition (allocations, forbid, etc.)
-- @param masterList (Table) The MasterList of items from Config.
-- @param diffData (Table) Difficulty settings {stockMult, rarityBonus, etc.}
-- @param modifiers (Table) Optional. { globalStockMult=1.0, eventInjections={}, tagsConfig={} }
-- @return (Table) resultStock { ["Base.Axe"] = 5, ... }
function Common.GenerateStock(archetype, masterList, diffData, modifiers)
    if not masterList then return {} end
    archetype = archetype or {}
    diffData = diffData or { stockMult = 1.0, rarityBonus = 0 }
    modifiers = modifiers or {}
    
    local tagsConfig = modifiers.tagsConfig or {}
    local globalStockMult = modifiers.globalStockMult or 1.0
    local eventInjections = modifiers.eventInjections or {}
    
    local resultStock = {}

    -- A. Determine Shop Size (Slots)
    -- Base range (15-25) modified by Difficulty AND Global Events
    local minSlots = math.floor(15 * diffData.stockMult * globalStockMult)
    local maxSlots = math.floor(25 * diffData.stockMult * globalStockMult)
    local totalSlots = ZombRand(minSlots, maxSlots + 1)
    if totalSlots < 1 then totalSlots = 1 end

    local slotsFilled = 0

    -- ---------------------------------------------------------
    -- PHASE 1: ALLOCATIONS & INJECTIONS (Guaranteed Items)
    -- ---------------------------------------------------------
    local priorityList = {}
    
    -- Add Archetype defaults
    if archetype.allocations then
        for criteria, count in pairs(archetype.allocations) do
            priorityList[criteria] = count
        end
    end
    
    -- Add Event Injections
    for tag, count in pairs(eventInjections) do
        priorityList[tag] = (priorityList[tag] or 0) + count
    end

    -- Process the merged list
    for criteria, count in pairs(priorityList) do
        local validItems = {}
        
        for key, itemData in pairs(masterList) do
            local hasTag = false
            local isForbidden = false
            
            -- Check Tags
            for _, t in ipairs(itemData.tags) do
                if t == criteria then hasTag = true end
                -- Check Forbidden
                if archetype.forbid then
                    for _, f in ipairs(archetype.forbid) do 
                        if t == f then isForbidden = true end 
                    end
                end
            end
            
            if hasTag and not isForbidden then
                table.insert(validItems, key)
            end
        end
        
        -- Pick 'count' random items
        if #validItems > 0 then
            for i=1, count do
                if slotsFilled >= totalSlots then break end
                local pick = validItems[ZombRand(#validItems)+1]
                resultStock[pick] = (resultStock[pick] or 0) -- Placeholder
                slotsFilled = slotsFilled + 1
            end
        end
    end

    -- ---------------------------------------------------------
    -- PHASE 2: WILDCARDS (The Weighted Lottery)
    -- ---------------------------------------------------------
    if slotsFilled < totalSlots then
        local lotteryPool = {}
        
        for key, itemData in pairs(masterList) do
            local isForbidden = false
            
            -- Check Forbidden Tags
            if archetype.forbid then
                for _, t in ipairs(itemData.tags) do
                    for _, f in ipairs(archetype.forbid) do
                        if t == f then isForbidden = true break end
                    end
                end
            end

            if not isForbidden then
                -- CALCULATE WEIGHT
                local baseWeight = 0
                
                if itemData.chance then
                    baseWeight = itemData.chance
                else
                    -- Fallback to Tag Weight from Config
                    local primaryTag = itemData.tags[1] or "Misc"
                    if tagsConfig[primaryTag] then
                        baseWeight = tagsConfig[primaryTag].weight or 50
                    else
                        baseWeight = 50
                    end
                end
                
                local finalWeight = baseWeight + diffData.rarityBonus
                
                if finalWeight > 0 then
                    table.insert(lotteryPool, { key=key, weight=finalWeight })
                end
            end
        end

        -- Spin the wheel
        while slotsFilled < totalSlots do
            local pickKey = Common.PickFromWeightedPool(lotteryPool)
            if pickKey then
                resultStock[pickKey] = (resultStock[pickKey] or 0)
                slotsFilled = slotsFilled + 1
            else
                break 
            end
        end
    end

    -- ---------------------------------------------------------
    -- PHASE 3: QUANTITY & FINALIZATION
    -- ---------------------------------------------------------
    -- Modifiers function for volume
    local getVolumeMod = modifiers.getVolumeModifier
    
    for key, _ in pairs(resultStock) do
        local itemData = masterList[key]
        if itemData then
            local min = itemData.stockRange.min
            local max = itemData.stockRange.max
            
            -- Event Volume Multiplier
            local volumeMult = 1.0
            if getVolumeMod then
                -- Check if it's a function or a value? No, passed as function from caller ideally?
                -- Or caller resolves it. 
                -- Wait, in V1 it was DynamicTrading.Events.GetVolumeModifier(itemData.tags)
                -- So `getVolumeMod` should be a function that takes tags and returns float.
                volumeMult = getVolumeMod(itemData.tags)
            end
            
            local qty = ZombRand(min, max + 1)
            
            -- Apply factors
            qty = math.floor(qty * diffData.stockMult * volumeMult * globalStockMult)
            
            if qty < 1 then qty = 1 end 
            
            resultStock[key] = qty
        end
    end

    return resultStock
end

-- =============================================================================
-- 3. PRICING LOGIC
-- =============================================================================

--- Calculates the BUY price (Trader selling to Player)
-- @param itemKey (String) Item FullType
-- @param itemData (Table) MasterList entry
-- @param diffData (Table) Difficulty settings
-- @param modifiers (Table) { tagsConfig={}, getPriceModifier=func, globalHeat={} }
function Common.GetBuyPrice(itemKey, itemData, diffData, modifiers)
    if not itemData then return 99999 end
    diffData = diffData or { buyMult = 1.0 }
    modifiers = modifiers or {}
    
    local tagsConfig = modifiers.tagsConfig or {}
    local globalHeat = modifiers.globalHeat or {}
    local getPriceMod = modifiers.getPriceModifier
    
    local price = itemData.basePrice

    -- 1. Tag Multipliers (Highest Wins)
    local maxTagMult = 1.0
    for _, tag in ipairs(itemData.tags) do
        local tagConfig = tagsConfig[tag]
        if tagConfig and tagConfig.priceMult then
            if tagConfig.priceMult > maxTagMult then
                maxTagMult = tagConfig.priceMult
            end
        end
    end
    price = price * maxTagMult

    -- 2. Event Modifiers
    if getPriceMod then
        local eventMult = getPriceMod(itemData.tags)
        price = price * eventMult
    end

    -- 3. Global Inflation (Heat)
    for _, tag in ipairs(itemData.tags) do
        local heat = globalHeat[tag]
        if heat and heat ~= 0 then
            price = price * (1.0 + heat)
        end
    end

    -- 4. Difficulty
    price = price * diffData.buyMult

    if price < 1 then price = 1 end

    return math.ceil(price)
end

--- Calculates the SELL price (Player selling to Trader)
-- @param itemKey (String) Item FullType
-- @param itemData (Table) MasterList entry
-- @param itemObj (InventoryItem) Actual item object (for condition)
-- @param diffData (Table) Difficulty settings
-- @param archetype (Table) Archetype def (for 'wants')
-- @param modifiers (Table) { tagsConfig={}, getPriceModifier=func, globalHeat={}, localDeflationCount=int }
function Common.GetSellPrice(itemKey, itemData, itemObj, diffData, archetype, modifiers)
    if not itemData then return 0 end
    diffData = diffData or { sellMult = 0.5 }
    modifiers = modifiers or {}
    archetype = archetype or {}
    
    local globalHeat = modifiers.globalHeat or {}
    local getPriceMod = modifiers.getPriceModifier
    local localDeflationCount = modifiers.localDeflationCount or 0

    -- 1. Base & Difficulty
    local price = itemData.basePrice * diffData.sellMult

    -- 2. Condition Penalty
    if itemObj and (itemObj:IsDrainable() or itemObj:isBroken()) then
        local cond = itemObj:getCondition() / itemObj:getConditionMax()
        price = price * cond
    end

    -- 3. Event Modifiers
    if getPriceMod then
        local eventMult = getPriceMod(itemData.tags)
        price = price * eventMult
    end

    -- 4. Global Inflation (Heat)
    for _, tag in ipairs(itemData.tags) do
        local heat = globalHeat[tag]
        if heat and heat ~= 0 then
            price = price * (1.0 + heat)
        end
    end

    -- 5. Local Deflation (Trader Saturation)
    if localDeflationCount > 0 then
        local penaltyPerItem = 0.05
        local localMult = 1.0 - (localDeflationCount * penaltyPerItem)
        if localMult < 0.2 then localMult = 0.2 end
        price = price * localMult
    end

    -- 6. Archetype Bonus ("Wants")
    if archetype and archetype.wants then
        for _, tag in ipairs(itemData.tags) do
            if archetype.wants[tag] then
                price = price * archetype.wants[tag]
                break 
            end
        end
    end

    if price < 0 then price = 0 end

    return math.floor(price)
end
