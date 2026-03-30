-- =============================================================================
-- 3. STOCK GENERATION
-- =============================================================================

local Common = DynamicTrading.Economy.Common

local function cloneShallowTable(source)
    if type(source) ~= "table" then
        return source
    end

    local copy = {}
    for key, value in pairs(source) do
        copy[key] = value
    end

    return copy
end

local function ensureStockEntry(resultStock, itemKey)
    local entry = resultStock[itemKey]
    if type(entry) ~= "table" then
        entry = { slots = 0 }
        resultStock[itemKey] = entry
    end

    entry.slots = tonumber(entry.slots) or 0
    return entry
end

local function applyAllocationData(stockEntry, allocation)
    if type(stockEntry) ~= "table" or type(allocation) ~= "table" then
        return
    end

    local fixedQty = allocation.fixedQty
    if fixedQty == nil then
        fixedQty = allocation.qty
    end
    if fixedQty ~= nil then
        stockEntry.fixedQty = math.max(0, math.floor(tonumber(fixedQty) or 0))
    end

    local fixedPrice = allocation.fixedPrice
    if fixedPrice == nil then
        fixedPrice = allocation.price
    end
    if fixedPrice ~= nil then
        stockEntry.fixedPrice = math.max(0, math.floor(tonumber(fixedPrice) or 0))
    end

    if allocation.customData ~= nil then
        stockEntry.customData = cloneShallowTable(allocation.customData)
    end

    if allocation.expert ~= nil then
        stockEntry.forceExpert = allocation.expert == true
    end
end

local function pickGeneratedStockFluid()
    if not DynamicTrading or not DynamicTrading.Fluids then
        return nil
    end

    local pool = {}
    for fluidID, fluidData in pairs(DynamicTrading.Fluids) do
        if type(fluidID) == "string" and string.sub(fluidID, 1, 5) ~= "Base." then
            local primaryTag = fluidData and fluidData.tags and fluidData.tags[1] or ""
            if primaryTag ~= "" and (
                Common.TagMatches(primaryTag, "Fluid.Water")
                or Common.TagMatches(primaryTag, "Fluid.Fuel")
                or Common.TagMatches(primaryTag, "Fluid.Drink")
            ) then
                table.insert(pool, fluidID)
            end
        end
    end

    if #pool == 0 then
        return nil
    end

    return pool[ZombRand(#pool) + 1]
end

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
    
    -- Add Archetype defaults (Standardized Table Format Only)
    if archetype.allocations then
        for _, entry in ipairs(archetype.allocations) do
            table.insert(priorityList, entry)
        end
    end
    
    -- Add Event Injections (Normalize to Table Format)
    for tag, count in pairs(eventInjections) do
        table.insert(priorityList, { tags = {tag}, count = count })
    end

    -- Process the merged list
    for _, entry in ipairs(priorityList) do
        local validItems = {}
        local count = entry.count or 0
        
        -- Logic: If it's a specific ItemID
        if entry.item then
            if masterList[entry.item] then
                table.insert(validItems, entry.item)
            end
        else
            -- Logic: It's a Tag Intersection list
            local requiredTags = entry.tags or {}
            
            for key, itemData in pairs(masterList) do
                local isForbidden = false
                
                -- Check Labels / Forbidden (Archetype + Event Banned)
                if archetype.forbid then
                    for _, t in ipairs(itemData.tags) do
                        for _, f in ipairs(archetype.forbid) do 
                            if Common.TagMatches(t, f) then 
                                isForbidden = true 
                                break
                            end 
                        end
                        if isForbidden then break end
                    end
                end
                
                if not isForbidden and modifiers.forbidTags then
                    for _, t in ipairs(itemData.tags) do
                        for fTag, _ in pairs(modifiers.forbidTags) do
                            if Common.TagMatches(t, fTag) then
                                isForbidden = true
                                break
                            end
                        end
                        if isForbidden then break end
                    end
                end
                
                -- Check matching ALL required tags
                if not isForbidden and Common.MatchesAllTags(itemData.tags, requiredTags) then
                    table.insert(validItems, key)
                end
            end
        end
        
        -- Pick 'count' random items
        if #validItems > 0 then
            for i=1, count do
                if slotsFilled >= totalSlots then break end
                local pick = validItems[ZombRand(#validItems)+1]
                local stockEntry = ensureStockEntry(resultStock, pick)
                stockEntry.slots = stockEntry.slots + 1
                applyAllocationData(stockEntry, entry)
                slotsFilled = slotsFilled + 1
            end
        end
    end

    -- ---------------------------------------------------------
    -- PHASE 2: WILDCARDS (The Weighted Lottery)
    -- ---------------------------------------------------------
    if slotsFilled < totalSlots and DynamicTrading.IsArchetypeWildcardStockEnabled(archetype) then
        local lotteryPool = {}
        
        for key, itemData in pairs(masterList) do
            local isForbidden = false
            
            -- Check Forbidden Tags
            if archetype.forbid then
                for _, t in ipairs(itemData.tags) do
                    for _, f in ipairs(archetype.forbid) do
                        if Common.TagMatches(t, f) then 
                            isForbidden = true 
                            break 
                        end
                    end
                    if isForbidden then break end
                end
            end

            -- Check Event Forbidden Tags
            if not isForbidden and modifiers.forbidTags then
                for _, t in ipairs(itemData.tags) do
                    for fTag, _ in pairs(modifiers.forbidTags) do
                        if Common.TagMatches(t, fTag) then
                            isForbidden = true
                            break
                        end
                    end
                    if isForbidden then break end
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
                local stockEntry = ensureStockEntry(resultStock, pickKey)
                stockEntry.slots = stockEntry.slots + 1
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
    
    for key, stockEntry in pairs(resultStock) do
        local itemData = masterList[key]
        if itemData then
            stockEntry = type(stockEntry) == "table" and stockEntry or {}

            local qty = nil
            if stockEntry.fixedQty ~= nil then
                qty = math.max(0, math.floor(tonumber(stockEntry.fixedQty) or 0))
            else
                local min = itemData.stockRange.min
                local max = itemData.stockRange.max

                local volumeMult = 1.0
                if getVolumeMod then
                    volumeMult = getVolumeMod(itemData.tags)
                end

                qty = ZombRand(min, max + 1)
                qty = math.floor(qty * diffData.stockMult * volumeMult * globalStockMult)
                if qty < 1 then qty = 1 end
            end
            
            -- [NEW] EXPERT TAG CHECK (Agnostic variation system: Archetype + Events)
            local isExpert = stockEntry.forceExpert == true
            if not isExpert and archetype and archetype.expertTags then
                for _, eTag in ipairs(archetype.expertTags) do
                    if Common.HasMatchingTag(itemData.tags, eTag) then isExpert = true break end
                    if isExpert then break end
                end
            end
            if not isExpert and modifiers.expertTags then
                for eTag, _ in pairs(modifiers.expertTags) do
                    if Common.HasMatchingTag(itemData.tags, eTag) then isExpert = true break end
                end
            end

            -- [NEW] Unified Table Structure {qty=X, customData=Y}
            local conditionData = stockEntry.customData ~= nil
                and cloneShallowTable(stockEntry.customData)
                or Common.GenerateItemCondition(itemData, isExpert)
            
            DynamicTrading.Log("DTCommons", "Trade", "Debug", "GenerateStock: " .. key .. " | Qty: " .. qty .. " | CustomData: " .. (conditionData and "YES" or "NO") .. " | IsExpert: " .. tostring(isExpert))
            
            resultStock[key] = {
                qty = qty,
                customData = conditionData,
                fixedPrice = stockEntry.fixedPrice
            }
        end
    end

    -- [DEBUG FINAL STRUCTURE]
    for k, v in pairs(resultStock) do
        DynamicTrading.Log("DTCommons", "Trade", "Debug", "GenerateStock Result Sample: " .. tostring(k) .. " -> type is " .. type(v))
        break
    end

    return resultStock
end

--- Generates random condition/fluid data for an item if applicable.
-- @param itemData (Table) MasterList entry
-- @param isExpert (Boolean) If true, returns "perfect" values (100% capacity/charge)
-- @return (Table|nil) customData { usedDelta=0.5, fluidAmount=... } or nil
function Common.GenerateItemCondition(itemData, isExpert)
    if not itemData then return nil end
    
    local scriptItem = getScriptManager():getItem(itemData.item)
    if not scriptItem then return nil end
    
    local data = {}
    local hasData = false
    
    -- [DEBUG]
    DynamicTrading.Log("DTCommons", "Trade", "Debug", "GenerateItemCondition for: " .. tostring(itemData.item) .. " | IsExpert: " .. tostring(isExpert))
    
    -- 1. Fluid Container (e.g. Gas Can, Water Bottle)
    local fc = scriptItem.getFluidContainer and scriptItem:getFluidContainer()
    if fc then
        local capacity = (fc.getCapacity and fc:getCapacity()) or 0
        -- Expert/Perfect Item check
        local mult = isExpert and 1.0 or (ZombRand(10, 101) / 100.0) 
        data.fluidAmount = capacity * mult
        
        DynamicTrading.Log("DTCommons", "Trade", "Trace", "  - FLUID detected. Capacity: " .. capacity .. " | Amount: " .. data.fluidAmount)

        -- Store default fluid type
        if fc.getFluidType then
            data.fluidType = Common.NormalizeFluidType(fc:getFluidType())
        end
        if not data.fluidType then
            data.fluidType = pickGeneratedStockFluid()
        end
        if data.fluidType then
            DynamicTrading.Log("DTCommons", "Trade", "Trace", "  - Fluid Type: " .. tostring(data.fluidType))
        end

        hasData = true
    end
    
    -- 2. Drainable (e.g. Bleach, Vitamins)
    if not hasData and scriptItem.IsDrainable and scriptItem:IsDrainable() then
        local mult = isExpert and 1.0 or (ZombRand(1, 101) / 100.0)
        data.usedDelta = mult
        DynamicTrading.Log("DTCommons", "Trade", "Trace", "  - DRAINABLE detected. usedDelta: " .. mult)
        hasData = true
    end
    
    -- 3. Food (e.g. Apple, Steak)
    if not hasData and scriptItem.getHungerChange then
        local baseHunger = Common.GetNormalizedHunger(scriptItem)
        if baseHunger and baseHunger < 0 then
            local mult = isExpert and 1.0 or (ZombRand(1, 11) / 10.0)
            data.hungerChange = baseHunger * mult
            DynamicTrading.Log("DTCommons", "Trade", "Trace", "  - FOOD detected. baseHunger: " .. baseHunger .. " | hungerChange: " .. data.hungerChange)
            hasData = true
        end
    end
    
    -- 4. Condition (Durability, Weapons, Tools)
    if not hasData and scriptItem.getConditionMax and scriptItem:getConditionMax() > 0 then
        local max = scriptItem:getConditionMax()
        local mult = isExpert and 1.0 or (ZombRand(2, 11) / 10.0) -- 20% to 100%
        data.condition = math.floor(max * mult)
        if data.condition < 1 then data.condition = 1 end
        DynamicTrading.Log("DTCommons", "Trade", "Trace", "  - CONDITION detected. Value: " .. data.condition .. "/" .. max)
        hasData = true
    end
    
    if not hasData then
        DynamicTrading.Log("DTCommons", "Trade", "Trace", "  - NO dynamic data generated for this item.")
    end
    
    if hasData then return data end
    return nil
end
