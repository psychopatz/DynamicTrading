require "DynamicTrading_Config"
require "DynamicTrading_Tags"
require "DynamicTrading_Events"

DynamicTrading = DynamicTrading or {}
DynamicTrading.Economy = {}

-- =============================================================================
-- 1. HELPER: WEIGHTED RANDOM PICKER
-- =============================================================================
-- Picks an item key from a pool based on 'weight' property.
-- pool = { {key="Base.Apple", weight=100}, {key="Base.Axe", weight=10} }
local function PickFromWeightedPool(pool)
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
-- 2. STOCK GENERATOR
-- =============================================================================
function DynamicTrading.Economy.GenerateStock(archetypeKey)
    local resultStock = {}
    local masterList = DynamicTrading.Config.MasterList
    
    if not masterList then 
        print("[DynamicTrading] Error: MasterList is empty.")
        return {} 
    end

    -- A. Load Context
    local diff = DynamicTrading.Config.GetDifficultyData() -- Easy/Hard/Insane logic
    local archetype = DynamicTrading.Archetypes[archetypeKey] or DynamicTrading.Archetypes["General"]
    
    -- B. Determine Shop Size (Slots)
    -- Base range (15-25) modified by Difficulty
    local minSlots = math.floor(15 * diff.stockMult)
    local maxSlots = math.floor(25 * diff.stockMult)
    local totalSlots = ZombRand(minSlots, maxSlots + 1)
    if totalSlots < 1 then totalSlots = 1 end

    local slotsFilled = 0

    -- ---------------------------------------------------------
    -- PHASE 1: ALLOCATIONS & INJECTIONS (Guaranteed Items)
    -- ---------------------------------------------------------
    -- 1. Merge Archetype Allocations with Event Injections
    local priorityList = {}
    
    -- Add Archetype defaults (e.g., Butcher needs Meat)
    if archetype.allocations then
        for criteria, count in pairs(archetype.allocations) do
            priorityList[criteria] = count
        end
    end
    
    -- Add Event Injections (e.g., Harvest Season forces Vegetables)
    if DynamicTrading.Events and DynamicTrading.Events.GetInjections then
        local injections = DynamicTrading.Events.GetInjections()
        for tag, count in pairs(injections) do
            priorityList[tag] = (priorityList[tag] or 0) + count
        end
    end

    -- 2. Process the merged list
    for criteria, count in pairs(priorityList) do
        -- Find all valid items for this Tag/Category
        local validItems = {}
        
        for key, itemData in pairs(masterList) do
            local hasTag = false
            local isForbidden = false
            
            -- Check Tags
            for _, t in ipairs(itemData.tags) do
                if t == criteria then hasTag = true end
                -- Check Forbidden (Trader Overrules Events)
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
        
        -- Pick 'count' random items from this specific list
        if #validItems > 0 then
            for i=1, count do
                if slotsFilled >= totalSlots then break end
                local pick = validItems[ZombRand(#validItems)+1]
                resultStock[pick] = (resultStock[pick] or 0) -- Quantity calc comes later
                slotsFilled = slotsFilled + 1
            end
        end
    end

    -- ---------------------------------------------------------
    -- PHASE 2: WILDCARDS (The Weighted Lottery)
    -- ---------------------------------------------------------
    -- Fill remaining slots based on Rarity and Difficulty
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
                
                -- Check for explicit chance override first
                if itemData.chance then
                    baseWeight = itemData.chance
                else
                    -- Fallback to Tag Weight
                    local primaryTag = itemData.tags[1] or "Misc"
                    if DynamicTrading.Config.Tags[primaryTag] then
                        baseWeight = DynamicTrading.Config.Tags[primaryTag].weight
                    else
                        baseWeight = 50 -- Safety default
                    end
                end
                
                -- Difficulty Bonus
                -- Easy mode (+20) makes everything common.
                -- Hard mode (-5) makes rare things (weight < 5) disappear completely.
                local finalWeight = baseWeight + diff.rarityBonus
                
                -- Ensure items with 0 weight (like "Winter" tags out of season) are skipped
                -- unless they have a positive weight override.
                if finalWeight > 0 then
                    table.insert(lotteryPool, { key=key, weight=finalWeight })
                end
            end
        end

        -- Spin the wheel until full
        while slotsFilled < totalSlots do
            local pickKey = PickFromWeightedPool(lotteryPool)
            if pickKey then
                resultStock[pickKey] = (resultStock[pickKey] or 0)
                slotsFilled = slotsFilled + 1
            else
                break -- No valid items in pool?
            end
        end
    end

    -- ---------------------------------------------------------
    -- PHASE 3: QUANTITY & FINALIZATION
    -- ---------------------------------------------------------
    for key, _ in pairs(resultStock) do
        local itemData = masterList[key]
        if itemData then
            local min = itemData.stockRange.min
            local max = itemData.stockRange.max
            
            -- Event Volume Multiplier (e.g., Famine = 0.5x Food)
            local volumeMult = 1.0
            if DynamicTrading.Events and DynamicTrading.Events.GetVolumeModifier then
                volumeMult = DynamicTrading.Events.GetVolumeModifier(itemData.tags)
            end
            
            -- Calculate Quantity
            local qty = ZombRand(min, max + 1)
            
            -- Apply Difficulty & Event Modifiers
            qty = math.floor(qty * diff.stockMult * volumeMult)
            
            -- Always ensure at least 1 if it was picked
            if qty < 1 then qty = 1 end 
            
            resultStock[key] = qty
        end
    end

    return resultStock
end

-- =============================================================================
-- 3. BUY PRICE CALCULATOR (Trader -> Player)
-- =============================================================================
-- Formula: Base * (Highest Tag Mod) * (Event Mod) * (Inflation) * (Difficulty)
function DynamicTrading.Economy.GetBuyPrice(itemKey, globalHeat)
    local itemData = DynamicTrading.Config.MasterList[itemKey]
    if not itemData then return 1 end
    
    local diff = DynamicTrading.Config.GetDifficultyData()
    local price = itemData.basePrice

    -- 1. Tag Multipliers (Rarity/Quality)
    -- We take the HIGHEST multiplier found on the item to avoid compounding explosion.
    -- e.g. "Food"(1.0) and "Rare"(2.0) -> Result 2.0. Not 2.0.
    local maxTagMult = 1.0
    for _, tag in ipairs(itemData.tags) do
        local tagConfig = DynamicTrading.Config.Tags[tag]
        if tagConfig and tagConfig.priceMult then
            if tagConfig.priceMult > maxTagMult then
                maxTagMult = tagConfig.priceMult
            end
        end
    end
    price = price * maxTagMult

    -- 2. Event Modifiers (Stacked)
    -- Events usually represent external forces (War, Winter), so they stack on top.
    if DynamicTrading.Events and DynamicTrading.Events.GetPriceModifier then
        local eventMult = DynamicTrading.Events.GetPriceModifier(itemData.tags)
        price = price * eventMult
    end

    -- 3. Global Inflation (Heat)
    if globalHeat then
        for _, tag in ipairs(itemData.tags) do
            local heat = globalHeat[tag]
            if heat and heat ~= 0 then
                -- heat 0.1 means +10% price
                price = price * (1.0 + heat)
            end
        end
    end

    -- 4. Difficulty (The final punish/reward)
    price = price * diff.buyMult

    -- Safety Clamp: Price cannot be 0
    if price < 1 then price = 1 end

    return math.ceil(price)
end

-- =============================================================================
-- 4. SELL PRICE CALCULATOR (Player -> Trader)
-- =============================================================================
function DynamicTrading.Economy.GetSellPrice(itemObj, itemKey, archetypeKey)
    local itemData = DynamicTrading.Config.MasterList[itemKey]
    if not itemData then return 0 end

    local diff = DynamicTrading.Config.GetDifficultyData()
    local archetype = DynamicTrading.Archetypes[archetypeKey]

    -- 1. Base Value & Difficulty
    local price = itemData.basePrice * diff.sellMult

    -- 2. Condition Penalty
    if itemObj:IsDrainable() or itemObj:isBroken() then
        local cond = itemObj:getCondition() / itemObj:getConditionMax()
        price = price * cond
    end

    -- 3. Event Modifiers (Supply/Demand)
    -- If "Winter" makes food expensive to buy (x2.0), it should also be expensive to sell (x2.0).
    if DynamicTrading.Events and DynamicTrading.Events.GetPriceModifier then
        local eventMult = DynamicTrading.Events.GetPriceModifier(itemData.tags)
        price = price * eventMult
    end

    -- 4. Archetype Bonus ("Wants")
    -- If the trader specializes in this, they pay a premium.
    if archetype and archetype.wants then
        for _, tag in ipairs(itemData.tags) do
            if archetype.wants[tag] then
                price = price * archetype.wants[tag]
                -- Apply bonus only once per item
                break 
            end
        end
    end
    
    -- Safety: Don't allow free money exploits or negatives
    if price < 0 then price = 0 end

    return math.floor(price)
end