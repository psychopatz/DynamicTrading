require "DynamicTrading_Events"
require "DynamicTrading_Config" -- Ensure MasterList is loaded

DynamicTrading = DynamicTrading or {}
DynamicTrading.Economy = {}

print("[DynamicTrading] Loading Economy Engine...")

-- =================================================
-- HELPER: UTILITY FUNCTIONS
-- =================================================
local function shuffleList(list)
    for i = #list, 2, -1 do
        local j = ZombRand(i) + 1
        list[i], list[j] = list[j], list[i]
    end
    return list
end

local function tableSize(tbl)
    local count = 0
    for _ in pairs(tbl) do count = count + 1 end
    return count
end

-- =================================================
-- LOGIC: PICK RANDOM MERCHANT ARCHETYPE
-- =================================================
function DynamicTrading.Economy.PickRandomMerchant()
    local types = {}
    if DynamicTrading.Config and DynamicTrading.Config.MerchantTypes then
        for key, _ in pairs(DynamicTrading.Config.MerchantTypes) do
            table.insert(types, key)
        end
    end
    
    if #types == 0 then 
        print("[DynamicTrading] WARNING: No MerchantTypes defined! Using default.")
        return "General", { name = "General Trader", allocations = { Food = 5, Material = 5 } } 
    end
    
    local key = types[ZombRand(#types) + 1]
    return key, DynamicTrading.Config.MerchantTypes[key]
end

-- =================================================
-- LOGIC: GENERATE DAILY STOCK (Restock)
-- =================================================
function DynamicTrading.Economy.GenerateDailyStock(forceMerchantKey)
    print("[DynamicTrading] STARTING STOCK GENERATION...")

    -- 1. Validation
    if not DynamicTrading.Config or not DynamicTrading.Config.MasterList then
        return {}, "Error: No Config"
    end
    
    -- 2. Determine Archetype
    local merchantKey, merchantData
    if forceMerchantKey and DynamicTrading.Config.MerchantTypes[forceMerchantKey] then
        merchantKey = forceMerchantKey
        merchantData = DynamicTrading.Config.MerchantTypes[forceMerchantKey]
    else
        merchantKey, merchantData = DynamicTrading.Economy.PickRandomMerchant()
    end

    -- 3. Determine Slot Count (How many unique items)
    local minSlots = SandboxVars.DynamicTrading.TraderCapacityMin or 15
    local maxSlots = SandboxVars.DynamicTrading.TraderCapacityMax or 25
    local totalSlots = ZombRand(minSlots, maxSlots + 1)

    -- 4. Build Pools for Selection
    local poolByCategory = {}
    local poolByTag = {}
    local wildCardPool = {} 

    for key, data in pairs(DynamicTrading.Config.MasterList) do
        local cat = data.category or "Other"
        if not poolByCategory[cat] then poolByCategory[cat] = {} end
        table.insert(poolByCategory[cat], key)
        
        if data.tags then
            for _, tag in ipairs(data.tags) do
                if not poolByTag[tag] then poolByTag[tag] = {} end
                table.insert(poolByTag[tag], key)
            end
        end
        table.insert(wildCardPool, key)
    end

    -- Shuffle pools for randomness
    for k, list in pairs(poolByCategory) do shuffleList(list) end
    for k, list in pairs(poolByTag) do shuffleList(list) end
    shuffleList(wildCardPool)

    -- 5. STOCK FILLING LOGIC
    local newStock = {} 
    local activeItems = {}
    local slotsFilled = 0
    
    -- Inner Helper to Add Item to Stock
    local function AddToStock(key)
        if activeItems[key] then return end
        
        local itemData = DynamicTrading.Config.MasterList[key]
        
        -- EVENT SYSTEM: Get Modifiers
        local state = DynamicTrading.Events.GetActiveState(itemData.tags)
        
        -- Calculate Quantity based on Event Volume
        local min = math.floor(itemData.stockRange.min * state.volume)
        local max = math.floor(itemData.stockRange.max * state.volume)
        
        -- Safety Clamps
        if min < 1 then min = 1 end
        if max < min then max = min end
        
        local qty = ZombRand(min, max + 1)
        if qty < 1 then qty = 1 end
        
        newStock[key] = qty
        activeItems[key] = true
        slotsFilled = slotsFilled + 1
    end

    -- A. Fill via Archetype Allocations
    if merchantData.allocations then
        for criteria, count in pairs(merchantData.allocations) do
            local validKeys = poolByTag[criteria] or poolByCategory[criteria]
            
            if validKeys and #validKeys > 0 then
                for i = 1, #validKeys do
                    -- Allocation logic usually picks 'count' items, but we respect totalSlots cap
                    if slotsFilled >= totalSlots then break end
                    -- Simple probability: 50% chance to skip an item to vary the selection within the tag
                    if ZombRand(100) < 50 or i == 1 then
                        AddToStock(validKeys[i])
                    end
                end
            end
        end
    end

    -- B. Fill Wildcards (Remaining Slots)
    if slotsFilled < totalSlots then
        for _, key in ipairs(wildCardPool) do
            if slotsFilled >= totalSlots then break end
            AddToStock(key)
        end
    end

    -- C. Failsafe (Force at least 1 item if empty)
    if slotsFilled == 0 and #wildCardPool > 0 then
         AddToStock(wildCardPool[1])
    end

    return newStock, merchantData.name
end

-- =================================================
-- LOGIC: CALCULATE BUY PRICE (Trader selling to Player)
-- =================================================
function DynamicTrading.Economy.CalculatePrice(key, currentStock, categoryHeatData)
    local data = DynamicTrading.Config.MasterList[key]
    if not data then return 1 end

    local base = data.basePrice
    
    -- 1. Category Inflation (Heat)
    local catHeat = (categoryHeatData and data.category) and (categoryHeatData[data.category] or 0) or 0
    
    -- 2. Scarcity (Low Stock = Higher Price)
    local scarcityMod = 0
    if currentStock < (data.stockRange.max * 0.2) then scarcityMod = 0.25 end

    -- 3. Event System (Stackable Modifiers)
    local state = DynamicTrading.Events.GetActiveState(data.tags or {})

    -- Final Calculation
    local finalPrice = math.floor(base * (1.0 + catHeat + scarcityMod) * state.price)
    
    if finalPrice < 1 then finalPrice = 1 end
    return finalPrice
end

-- =================================================
-- LOGIC: GET DEMAND LIMIT (Quota for Selling)
-- =================================================
function DynamicTrading.Economy.GetDemandLimit(key, currentMerchantName)
    local data = DynamicTrading.Config.MasterList[key]
    if not data then return 0 end
    
    -- Start with Configured Max Stock
    local limit = data.stockRange.max
    
    -- 1. Sandbox Multipliers (Global Economy size)
    local sbMult = SandboxVars.DynamicTrading.DemandMultiplier or 1.0
    local sbBase = SandboxVars.DynamicTrading.DemandBase or 2
    limit = (limit * sbMult) + sbBase
    
    -- 2. Event Modifiers (Volume affects Demand Limit too)
    -- If "Winter" reduces stock volume to 0.5, it also reduces buying limit!
    local state = DynamicTrading.Events.GetActiveState(data.tags or {})
    limit = limit * state.volume
    
    -- 3. Archetype Preference
    -- If the Merchant specializes in this item, they buy MORE of it.
    if currentMerchantName then
        local merchantData = nil
        for _, m in pairs(DynamicTrading.Config.MerchantTypes) do
            if m.name == currentMerchantName then merchantData = m break end
        end
        
        if merchantData and merchantData.allocations then
            local matches = false
            -- Check Category
            if merchantData.allocations[data.category] then matches = true end
            -- Check Tags
            if not matches and data.tags then
                for _, tag in ipairs(data.tags) do
                    if merchantData.allocations[tag] then matches = true break end
                end
            end
            
            if matches then 
                limit = limit * 1.5 -- 50% Higher Quota for preferred items
            end
        end
    end

    -- Ensure at least 1 if base was > 0
    if limit < 1 and data.stockRange.max > 0 then limit = 1 end
    
    return math.ceil(limit)
end

-- =================================================
-- LOGIC: CALCULATE SELL PRICE (Player selling to Trader)
-- =================================================
function DynamicTrading.Economy.CalculateSellPrice(playerItem, masterData, currentMerchantName, soldCount)
    if not playerItem or not masterData then return 0 end
    
    local base = masterData.basePrice
    
    -- 1. Condition Penalty (Durability)
    if playerItem:IsDrainable() or playerItem:isBroken() then
        local cond = playerItem:getCondition() / playerItem:getConditionMax()
        base = base * cond
    end

    -- 2. Event Modifiers (Price)
    -- If Winter makes Food expensive, you can Sell food for more too.
    local state = DynamicTrading.Events.GetActiveState(masterData.tags or {})
    base = base * state.price
    
    -- 3. RARE ITEM BONUS (80% Markup)
    -- If the item naturally has a MaxStock of 1, it is rare.
    -- Rare items hold value better.
    if masterData.stockRange.max <= 1 then
        base = base * 1.8 
    end

    -- 4. Archetype Bonus (The "Wants")
    -- Check if this trader specializes in this item
    if SandboxVars.DynamicTrading.ArchetypeBonus and currentMerchantName then
        local bonus = 0.8 -- Default penalty for non-matching items
        local merchantData = nil
        
        for _, m in pairs(DynamicTrading.Config.MerchantTypes) do
            if m.name == currentMerchantName then merchantData = m break end
        end
        
        if merchantData and merchantData.allocations then
            local matches = false
            if merchantData.allocations[masterData.category] then matches = true end
            if not matches and masterData.tags then
                for _, tag in ipairs(masterData.tags) do
                    if merchantData.allocations[tag] then matches = true break end
                end
            end
            
            if matches then 
                bonus = 1.25 -- 25% Bonus for matching items
            end
        end
        
        base = base * bonus
    end

    -- 5. Global Markdown (Sandbox Setting)
    -- "The Pawn Shop effect" - you never get full retail price.
    local markdown = SandboxVars.DynamicTrading.SellMarkdown or 0.5
    local finalPrice = base * markdown

    -- 6. OVERSTOCK PENALTY (Quota Check)
    -- If player has sold more than the Trader wants, price crashes.
    local limit = DynamicTrading.Economy.GetDemandLimit(masterData.key, currentMerchantName)
    
    if soldCount >= limit then
        finalPrice = finalPrice * 0.2 -- Scrap value (20%)
    end

    return math.floor(finalPrice)
end

function DynamicTrading.Economy.UpdateCategoryHeat(category)
    local data = DynamicTrading.Shared.GetData()
    if not data.categoryHeat then data.categoryHeat = {} end
    local step = SandboxVars.DynamicTrading.CategoryInflation or 0.05
    data.categoryHeat[category] = (data.categoryHeat[category] or 0) + step
end

print("[DynamicTrading] Economy Loaded Successfully.")