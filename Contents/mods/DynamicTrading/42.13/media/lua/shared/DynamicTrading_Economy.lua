DynamicTrading = DynamicTrading or {}
DynamicTrading.Economy = {}

print("[DynamicTrading] Loading Economy...")

local function shuffleList(list)
    for i = #list, 2, -1 do
        local j = ZombRand(i) + 1
        list[i], list[j] = list[j], list[i]
    end
    return list
end

-- =================================================
-- LOGIC: GENERATE DAILY STOCK
-- =================================================
function DynamicTrading.Economy.GenerateDailyStock()
    -- Safety Check: Ensure Config is ready
    if not DynamicTrading.Config or not DynamicTrading.Config.MasterList then
        print("[DynamicTrading] ERROR: Config missing during stock generation!")
        return {}
    end

    local config = DynamicTrading.Config
    local masterList = config.MasterList
    local profile = config.StockProfile
    
    local newStock = {} 
    local activeItems = {}

    -- Sandbox Handling
    local minSlots = 15
    local maxSlots = 25
    if SandboxVars.DynamicTrading then
        minSlots = SandboxVars.DynamicTrading.TraderCapacityMin or 15
        maxSlots = SandboxVars.DynamicTrading.TraderCapacityMax or 25
    end
    if minSlots > maxSlots then minSlots = maxSlots end
    local totalSlots = ZombRand(minSlots, maxSlots + 1)
    
    -- Sorting
    local poolByCategory = {}
    local wildCardPool = {} 

    for key, data in pairs(masterList) do
        local cat = data.category or "Other"
        if not poolByCategory[cat] then poolByCategory[cat] = {} end
        table.insert(poolByCategory[cat], key)
        table.insert(wildCardPool, key)
    end

    for cat, list in pairs(poolByCategory) do shuffleList(list) end
    shuffleList(wildCardPool)

    local slotsFilled = 0
    
    -- Guarantees
    if profile and profile.Allocations then
        for category, count in pairs(profile.Allocations) do
            local availableKeys = poolByCategory[category]
            if availableKeys then
                for i = 1, count do
                    if slotsFilled >= totalSlots then break end
                    
                    local key = availableKeys[i]
                    -- FIX: Check if we actually have an item here!
                    -- If we asked for 8 Food but only defined 4, this stops the loop safely.
                    if not key then break end 

                    local itemData = masterList[key]
                    if itemData then
                        local qty = ZombRand(itemData.stockRange.min, itemData.stockRange.max + 1)
                        newStock[key] = qty
                        activeItems[key] = true
                        slotsFilled = slotsFilled + 1
                    end
                end
            end
        end
    end

    -- Wildcards
    if slotsFilled < totalSlots then
        for _, key in ipairs(wildCardPool) do
            if slotsFilled >= totalSlots then break end
            if not activeItems[key] then
                local itemData = masterList[key]
                if itemData then
                    local qty = ZombRand(itemData.stockRange.min, itemData.stockRange.max + 1)
                    newStock[key] = qty
                    activeItems[key] = true
                    slotsFilled = slotsFilled + 1
                end
            end
        end
    end

    return newStock
end

-- =================================================
-- LOGIC: ENVIRONMENT
-- =================================================
function DynamicTrading.Economy.GetEnvironmentModifier(tags)
    local modifier = 0.0
    local gt = GameTime:getInstance()
    local climate = ClimateManager:getInstance()
    
    local isWinter = (climate:getSeasonName() == "Winter")
    local isSummer = (climate:getSeasonName() == "Summer")
    
    local elecMod = (SandboxVars.ElecShutModifier or 14)
    local waterMod = (SandboxVars.WaterShutModifier or 14)
    local elecShut = (gt:getNightsSurvived() > elecMod) and (elecMod > -1)
    local waterShut = (gt:getNightsSurvived() > waterMod) and (waterMod > -1)

    for _, tag in ipairs(tags) do
        if tag == "Fresh" or tag == "Crop" then
            if isWinter then modifier = modifier + 1.5 end
            if isSummer then modifier = modifier - 0.2 end
        end
        if tag == "Fuel" then
            if isWinter then modifier = modifier + 0.5 end
            if elecShut then modifier = modifier + 1.0 end
        end
        if tag == "Water" and waterShut then modifier = modifier + 2.0 end
        if tag == "Electric" and elecShut then modifier = modifier + 0.5 end
    end

    local seasonMult = 1.0
    if SandboxVars.DynamicTrading and SandboxVars.DynamicTrading.SeasonImpact then
        seasonMult = SandboxVars.DynamicTrading.SeasonImpact
    end

    return modifier * seasonMult
end

-- =================================================
-- LOGIC: PRICE
-- =================================================
function DynamicTrading.Economy.CalculatePrice(key, currentStock, categoryHeatData)
    if not DynamicTrading.Config.MasterList then return 1 end
    local data = DynamicTrading.Config.MasterList[key]
    if not data then return 1 end

    local base = data.basePrice
    local catHeat = 0
    if categoryHeatData and data.category then
        catHeat = categoryHeatData[data.category] or 0
    end
    
    local envMod = DynamicTrading.Economy.GetEnvironmentModifier(data.tags or {})
    local maxStock = data.stockRange.max
    local scarcityMod = 0
    if currentStock < (maxStock * 0.2) then scarcityMod = 0.25 end

    local finalMultiplier = 1.0 + catHeat + envMod + scarcityMod
    local finalPrice = math.floor(base * finalMultiplier)
    if finalPrice < 1 then finalPrice = 1 end
    return finalPrice
end

function DynamicTrading.Economy.UpdateCategoryHeat(category)
    local data = DynamicTrading.Shared.GetData()
    if not data.categoryHeat then data.categoryHeat = {} end
    
    local inflationStep = 0.05
    if SandboxVars.DynamicTrading and SandboxVars.DynamicTrading.CategoryInflation then
        inflationStep = SandboxVars.DynamicTrading.CategoryInflation
    end

    local current = data.categoryHeat[category] or 0
    data.categoryHeat[category] = current + inflationStep
end

print("[DynamicTrading] Economy Loaded Successfully.")