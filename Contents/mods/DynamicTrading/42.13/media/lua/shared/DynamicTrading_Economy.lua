DynamicTrading = DynamicTrading or {}
DynamicTrading.Economy = {}

print("[DynamicTrading] Loading Economy...")

-- =================================================
-- HELPER: SHUFFLE & COUNT
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
-- LOGIC: GENERATE DAILY STOCK
-- =================================================
function DynamicTrading.Economy.GenerateDailyStock(forceMerchantKey)
    print("[DynamicTrading] STARTING STOCK GENERATION...")

    -- 1. Safety Checks
    if not DynamicTrading.Config or not DynamicTrading.Config.MasterList then
        print("[DynamicTrading] CRITICAL ERROR: MasterList is missing or nil!")
        return {}, "Error: No Config"
    end

    local totalItemsInDb = tableSize(DynamicTrading.Config.MasterList)
    if totalItemsInDb == 0 then
        print("[DynamicTrading] CRITICAL ERROR: MasterList is EMPTY! Populate DTItems folder.")
        return {}, "Error: No Items"
    end

    -- 2. Determine Archetype
    local merchantKey, merchantData
    if forceMerchantKey and DynamicTrading.Config.MerchantTypes[forceMerchantKey] then
        merchantKey = forceMerchantKey
        merchantData = DynamicTrading.Config.MerchantTypes[forceMerchantKey]
    else
        merchantKey, merchantData = DynamicTrading.Economy.PickRandomMerchant()
    end
    
    print("[DynamicTrading] DEBUG: Selected Trader: " .. (merchantData.name or "Unknown"))

    -- 3. Determine Slot Count
    local minSlots = SandboxVars.DynamicTrading and SandboxVars.DynamicTrading.TraderCapacityMin or 15
    local maxSlots = SandboxVars.DynamicTrading and SandboxVars.DynamicTrading.TraderCapacityMax or 25
    if minSlots < 1 then minSlots = 1 end
    if maxSlots < minSlots then maxSlots = minSlots end
    local totalSlots = ZombRand(minSlots, maxSlots + 1)
    
    -- 4. Build Pools
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

    for k, list in pairs(poolByCategory) do shuffleList(list) end
    for k, list in pairs(poolByTag) do shuffleList(list) end
    shuffleList(wildCardPool)

    -- 5. Fill Allocations
    local newStock = {} 
    local activeItems = {}
    local slotsFilled = 0
    
    if merchantData.allocations then
        for criteria, count in pairs(merchantData.allocations) do
            local validKeys = poolByTag[criteria] or poolByCategory[criteria]
            
            if validKeys and #validKeys > 0 then
                for i = 1, #validKeys do
                    if slotsFilled >= totalSlots then break end
                    
                    local key = validKeys[i]
                    if not activeItems[key] then
                        local itemData = DynamicTrading.Config.MasterList[key]
                        
                        -- GENERATE QUANTITY
                        local qty = ZombRand(itemData.stockRange.min, itemData.stockRange.max + 1)
                        
                        -- === FIX: FORCE MINIMUM 1 ===
                        if qty < 1 then qty = 1 end
                        
                        newStock[key] = qty
                        activeItems[key] = true
                        slotsFilled = slotsFilled + 1
                    end
                end
            end
        end
    end

    -- 6. Fill Wildcards
    if slotsFilled < totalSlots then
        for _, key in ipairs(wildCardPool) do
            if slotsFilled >= totalSlots then break end
            
            if not activeItems[key] then
                local itemData = DynamicTrading.Config.MasterList[key]
                
                -- GENERATE QUANTITY
                local qty = ZombRand(itemData.stockRange.min, itemData.stockRange.max + 1)
                
                -- === FIX: FORCE MINIMUM 1 ===
                if qty < 1 then qty = 1 end
                
                newStock[key] = qty
                activeItems[key] = true
                slotsFilled = slotsFilled + 1
            end
        end
    end

    -- 7. Emergency Failsafe (Force Fill if Empty)
    if slotsFilled == 0 and totalItemsInDb > 0 then
        print("[DynamicTrading] FAILSAFE TRIGGERED: Stock was empty! Forcing random items...")
        for _, key in ipairs(wildCardPool) do
            if slotsFilled >= 5 then break end 
            
            local itemData = DynamicTrading.Config.MasterList[key]
            
            -- GENERATE QUANTITY
            local min = itemData.stockRange.min
            if min < 1 then min = 1 end -- Ensure generated range allows at least 1
            
            local qty = ZombRand(min, itemData.stockRange.max + 1)
            
            -- === FIX: FORCE MINIMUM 1 ===
            if qty < 1 then qty = 1 end
            
            newStock[key] = qty
            slotsFilled = slotsFilled + 1
        end
    end

    print("[DynamicTrading] FINISHED: Total unique items generated: " .. slotsFilled)
    return newStock, merchantData.name
end

-- =================================================
-- LOGIC: ENVIRONMENT & PRICE
-- =================================================
function DynamicTrading.Economy.GetEnvironmentModifier(tags)
    local modifier = 0.0
    local gt = GameTime:getInstance()
    local climate = ClimateManager:getInstance()
    
    local isWinter = (climate:getSeasonName() == "Winter")
    local elecMod = (SandboxVars.ElecShutModifier or 14)
    local waterMod = (SandboxVars.WaterShutModifier or 14)
    local elecShut = (gt:getNightsSurvived() > elecMod) and (elecMod > -1)
    local waterShut = (gt:getNightsSurvived() > waterMod) and (waterMod > -1)

    for _, tag in ipairs(tags) do
        if (tag == "Fresh" or tag == "Crop") and isWinter then modifier = modifier + 1.5 end
        if tag == "Fuel" and elecShut then modifier = modifier + 1.0 end
        if tag == "Water" and waterShut then modifier = modifier + 2.0 end
    end
    
    local seasonMult = SandboxVars.DynamicTrading and SandboxVars.DynamicTrading.SeasonImpact or 1.0
    return modifier * seasonMult
end

function DynamicTrading.Economy.CalculatePrice(key, currentStock, categoryHeatData)
    local data = DynamicTrading.Config.MasterList[key]
    if not data then return 1 end

    local base = data.basePrice
    local catHeat = (categoryHeatData and data.category) and (categoryHeatData[data.category] or 0) or 0
    local envMod = DynamicTrading.Economy.GetEnvironmentModifier(data.tags or {})
    
    local scarcityMod = 0
    -- If stock is below 20%, increase price by 25%
    if currentStock < (data.stockRange.max * 0.2) then scarcityMod = 0.25 end

    local finalPrice = math.floor(base * (1.0 + catHeat + envMod + scarcityMod))
    if finalPrice < 1 then finalPrice = 1 end
    return finalPrice
end

function DynamicTrading.Economy.UpdateCategoryHeat(category)
    local data = DynamicTrading.Shared.GetData()
    if not data.categoryHeat then data.categoryHeat = {} end
    local step = SandboxVars.DynamicTrading and SandboxVars.DynamicTrading.CategoryInflation or 0.05
    data.categoryHeat[category] = (data.categoryHeat[category] or 0) + step
end

print("[DynamicTrading] Economy Loaded Successfully.")