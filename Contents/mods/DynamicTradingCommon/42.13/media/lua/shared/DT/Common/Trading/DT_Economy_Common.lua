-- =============================================================================
-- DYNAMIC TRADING: SHARED ECONOMY LOGIC
-- =============================================================================
-- This module contains the core math and logic for trading, stripped of 
-- specific data dependencies (like specific Events or Soul lookups).
-- V1 and V2 wrappers should gather the data and pass it here.

DynamicTrading = DynamicTrading or {}
DynamicTrading.Economy = DynamicTrading.Economy or {}
DynamicTrading.Economy.Common = DynamicTrading.Economy.Common or {}

require "DT/Common/Items/DT_Fluids"

local Common = DynamicTrading.Economy.Common
print("[DynamicTrading] Common Economy Module initialized.")

-- =============================================================================
-- 1. UTILITIES
-- =============================================================================

-- Helper to handle the Build 42 hunger/thirst normalization discrepancy.
-- Script values are often integers (e.g. -15) while instance values are floats (e.g. -0.15).
function Common.GetNormalizedHunger(scriptItem)
    if not scriptItem or not scriptItem.getHungerChange then return 0 end
    
    local val = scriptItem:getHungerChange()
    if math.abs(val) > 1.0 then return val / 100.0 end
    return val
end

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
-- 2. DRAINABLE & CHARGE HELPERS (B42 Compatible)
-- =============================================================================

function Common.GetItemCharge(itemObj)
    if not itemObj then return 0 end
    
    local d_maxUses = itemObj.getMaxUses and itemObj:getMaxUses() or 0
    local d_curUses = itemObj.getCurrentUses and itemObj:getCurrentUses() or nil
    local d_delta = itemObj.getDelta and itemObj:getDelta() or nil
    local d_usedDelta = itemObj.getUsedDelta and itemObj:getUsedDelta() or nil
    local d_drainUses = itemObj.getDrainableUsesFloat and itemObj:getDrainableUsesFloat() or nil

    -- 1. Try B42 Specific Getters found in diagnostic
    if d_curUses and d_maxUses > 0 then
        return d_curUses / d_maxUses
    end

    -- 2. Try Standard Float Getters
    if d_drainUses and d_drainUses > 0 then return d_drainUses end
    if d_delta and d_delta > 0 then return d_delta end
    if d_usedDelta and d_usedDelta > 0 then return d_usedDelta end
    
    -- 3. Try other potential Integer Uses / Max (B42 style)
    local d_drainInt = itemObj.getDrainableUsesInt and itemObj:getDrainableUsesInt() or nil
    local d_drainUsesRaw = itemObj.getDrainableUses and itemObj:getDrainableUses() or nil
    local d_remUsesInt = itemObj.getRemainingUsesInt and itemObj:getRemainingUsesInt() or nil
    
    if d_drainInt and d_maxUses > 0 then return d_drainInt / d_maxUses end
    if d_drainUsesRaw and d_maxUses > 0 then return d_drainUsesRaw / d_maxUses end
    if d_remUsesInt and d_maxUses > 0 then return d_remUsesInt / d_maxUses end
    
    -- Safe Fallback: If we detect no usage data but the item is considered drainable, assume full.
    -- This prevents pricing items like Twine at 0 if they haven't been used yet.
    if d_maxUses > 0 then
        return 1.0
    end
    
    return 0
end

-- =============================================================================
-- 3. STOCK GENERATION
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
                -- Check Forbidden (Archetype + Event Banned)
                if archetype.forbid then
                    for _, f in ipairs(archetype.forbid) do 
                        if t == f then isForbidden = true end 
                    end
                end
                if modifiers.forbidTags and modifiers.forbidTags[t] then
                    isForbidden = true
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
                    if isForbidden then break end
                end
            end

            -- Check Event Forbidden Tags
            if not isForbidden and modifiers.forbidTags then
                for _, t in ipairs(itemData.tags) do
                    if modifiers.forbidTags[t] then
                        isForbidden = true
                        break
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
            
            -- [NEW] EXPERT TAG CHECK (Agnostic variation system: Archetype + Events)
            local isExpert = false
            if archetype and archetype.expertTags then
                for _, tag in ipairs(itemData.tags) do
                    for _, eTag in ipairs(archetype.expertTags) do
                        if tag == eTag then isExpert = true break end
                    end
                    if isExpert then break end
                end
            end
            if not isExpert and modifiers.expertTags then
                 for _, tag in ipairs(itemData.tags) do
                    if modifiers.expertTags[tag] then isExpert = true break end
                end
            end

            -- [NEW] Unified Table Structure {qty=X, customData=Y}
            local conditionData = Common.GenerateItemCondition(itemData, isExpert)
            
            print("[DT DEBUG] GenerateStock: " .. key .. " | Qty: " .. qty .. " | CustomData: " .. (conditionData and "YES" or "NO") .. " | IsExpert: " .. tostring(isExpert))
            
            resultStock[key] = {
                qty = qty,
                customData = conditionData
            }
        end
    end

    -- [DEBUG FINAL STRUCTURE]
    for k, v in pairs(resultStock) do
        print("[DT DEBUG] GenerateStock Result Sample: " .. tostring(k) .. " -> type is " .. type(v))
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
    print("[DT DEBUG] GenerateItemCondition for: " .. tostring(itemData.item) .. " | IsExpert: " .. tostring(isExpert))
    
    -- 1. Fluid Container (e.g. Gas Can, Water Bottle)
    local fc = scriptItem.getFluidContainer and scriptItem:getFluidContainer()
    if fc then
        local capacity = (fc.getCapacity and fc:getCapacity()) or 0
        -- Expert/Perfect Item check
        local mult = isExpert and 1.0 or (ZombRand(10, 101) / 100.0) 
        data.fluidAmount = capacity * mult
        
        print("  - FLUID detected. Capacity: " .. capacity .. " | Amount: " .. data.fluidAmount)

        -- Store default fluid type
        if fc.getFluidType then
            data.fluidType = fc:getFluidType()
            print("  - Fluid Type: " .. tostring(data.fluidType))
        end

        hasData = true
    end
    
    -- 2. Drainable (e.g. Bleach, Vitamins)
    if not hasData and scriptItem.IsDrainable and scriptItem:IsDrainable() then
        local mult = isExpert and 1.0 or (ZombRand(1, 101) / 100.0)
        data.usedDelta = mult
        print("  - DRAINABLE detected. usedDelta: " .. mult)
        hasData = true
    end
    
    -- 3. Food (e.g. Apple, Steak)
    if not hasData and scriptItem.getHungerChange then
        local baseHunger = Common.GetNormalizedHunger(scriptItem)
        if baseHunger and baseHunger < 0 then
            local mult = isExpert and 1.0 or (ZombRand(1, 11) / 10.0)
            data.hungerChange = baseHunger * mult
            print("  - FOOD detected. baseHunger: " .. baseHunger .. " | hungerChange: " .. data.hungerChange)
            hasData = true
        end
    end
    
    -- 4. Condition (Durability, Weapons, Tools)
    if not hasData and scriptItem.getConditionMax and scriptItem:getConditionMax() > 0 then
        local max = scriptItem:getConditionMax()
        local mult = isExpert and 1.0 or (ZombRand(2, 11) / 10.0) -- 20% to 100%
        data.condition = math.floor(max * mult)
        if data.condition < 1 then data.condition = 1 end
        print("  - CONDITION detected. Value: " .. data.condition .. "/" .. max)
        hasData = true
    end
    
    if not hasData then
        print("  - NO dynamic data generated for this item.")
    end
    
    if hasData then return data end
    return nil
end

-- =============================================================================
-- 3. PRICING LOGIC
-- =============================================================================

--- Calculates the BUY price (Trader selling to Player)
-- @param itemKey (String) Item FullType
-- @param itemData (Table) MasterList entry
-- @param diffData (Table) Difficulty settings
-- @param modifiers (Table) { tagsConfig={}, getPriceModifier=func, globalHeat={} }
function Common.GetBuyPrice(itemKey, itemData, diffData, modifiers, verbose)
    if not itemData then return 99999 end
    diffData = diffData or { buyMult = 1.0 }
    modifiers = modifiers or {}
    
    local tagsConfig = modifiers.tagsConfig or {}
    local globalHeat = modifiers.globalHeat or {}
    local getPriceMod = modifiers.getPriceModifier
    
    local price = itemData.basePrice
    
    if verbose then
        print("[DT TRACE] Buy Price Calc: " .. itemKey .. " | Base: " .. price)
    end

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
    if verbose and maxTagMult ~= 1.0 then print("[DT TRACE] | TagMult: " .. maxTagMult) end

    -- 2. Event Modifiers
    if getPriceMod then
        local eventMult = getPriceMod(itemData.tags)
        price = price * eventMult
        if verbose and eventMult ~= 1.0 then print("[DT TRACE] | EventMult: " .. eventMult) end
    end

    -- 3. Global Inflation (Heat)
    for _, tag in ipairs(itemData.tags) do
        local heat = globalHeat[tag]
        if heat and heat ~= 0 then
            price = price * (1.0 + heat)
            if verbose then print("[DT TRACE] | Heat(" .. tag .. "): " .. heat) end
        end
    end

    -- 4. Difficulty
    price = price * diffData.buyMult
    if verbose and diffData.buyMult ~= 1.0 then print("[DT TRACE] | DiffMult: " .. diffData.buyMult) end

    -- [NEW] Condition/Charge Scaler (Dynamic Buying Variation)
    if modifiers.customData then
        local cd = modifiers.customData
        local scale = 1.0
        
        -- A. Fluid(Per-Liter Pricing)
        if cd.fluidAmount and itemData.item then
            -- [NEW] Calculate Price = Container + (FluidPrice * Amount)
            local script = getScriptManager():getItem(itemData.item)
            local containerBase = 0
            local fluidTotal = 0
            
            -- 1. Determine Container Price
            if script and script.getReplaceOnDeplete then
                local emptyID = script:getReplaceOnDeplete()
                if emptyID and DynamicTrading.Config and DynamicTrading.Config.MasterList then
                    local emptyData = DynamicTrading.Config.MasterList[emptyID]
                    if emptyData then containerBase = emptyData.basePrice end
                end
            end
            -- Fallback: Assume container is ~20% of the filled item's base price if empty not found
            if containerBase == 0 then
                containerBase = itemData.basePrice * 0.2
            end

            -- 2. Determine Fluid Price
            local fType = cd.fluidType
            if fType and DynamicTrading.Fluids then
                -- Try direct lookup or Base. lookup
                local fTypeStr = tostring(fType)
                local fData = DynamicTrading.Fluids[fTypeStr] or DynamicTrading.Fluids["Base." .. fTypeStr]
                if fData then
                    fluidTotal = fData.basePrice * cd.fluidAmount
                end
            end
            
            -- 3. Calculate separate multipliers for Container and Fluid
            -- A. Container Multipliers (Base Logic)
            -- 'price' currently holds value calculated from ITEM keys/tags.
            -- This is effectively 'Container + Default Content' price.
            -- We want pure Container price mults. Ideally we'd scan empty container tags.
            -- Approximating: Use default item tags for container part.
            local containerMults = 1.0
            if itemData.basePrice > 0 then
                 containerMults = price / itemData.basePrice
            end
            
            -- B. Fluid Multipliers (Dynamic based on Fluid Tags)
            local fluidMults = diffData.buyMult or 1.0
            
            if fData and fData.tags then
                -- 1. Tags Config
                local maxFluidTagMult = 1.0
                for _, tag in ipairs(fData.tags) do
                    local tagConfig = tagsConfig[tag]
                    if tagConfig and tagConfig.priceMult then
                        if tagConfig.priceMult > maxFluidTagMult then
                            maxFluidTagMult = tagConfig.priceMult
                        end
                    end
                end
                fluidMults = fluidMults * maxFluidTagMult
                
                -- 2. Event Modifiers
                if getPriceMod then
                    local eventMult = getPriceMod(fData.tags)
                    fluidMults = fluidMults * eventMult
                end
                
                -- 3. Global Heat
                for _, tag in ipairs(fData.tags) do
                    local heat = globalHeat[tag]
                    if heat and heat ~= 0 then
                        fluidMults = fluidMults * (1.0 + heat)
                        if verbose then print("[DT TRACE] | FluidHeat(" .. tag .. "): " .. heat) end
                    end
                end
            end
            
            price = (containerBase * containerMults) + (fluidTotal * fluidMults)
            
            if verbose then
                 print("[DT TRACE] | DYNAMIC CONTENT DETECTED")
                 print("[DT TRACE] |   Container Price: " .. math.floor(containerBase * containerMults))
                 print("[DT TRACE] |   FluidTotal: " .. math.floor(fluidTotal * fluidMults) .. " (" .. tostring(fType) .. ")")
            end

            return math.ceil(price)

        -- B. Drainable
        elseif cd.usedDelta then
            scale = cd.usedDelta
        -- C. Food
        elseif cd.hungerChange then
            local script = getScriptManager():getItem(itemData.item)
            if script then
                local base = Common.GetNormalizedHunger(script)
                if base < 0 then
                    scale = cd.hungerChange / base
                end
            end
        -- D. Condition
        elseif cd.condition and itemData.item then
            local script = getScriptManager():getItem(itemData.item)
            if script and script.getConditionMax and script:getConditionMax() > 0 then
                scale = cd.condition / script:getConditionMax()
            end
        end

        -- Scaled price (minimum 20% value even if near empty, for the container)
        price = price * math.max(0.2, scale)
        if verbose and scale ~= 1.0 then print("[DT TRACE] | ItemScale: " .. scale) end
    end

    if price < 1 then price = 1 end
    
    if verbose then print("[DT TRACE] | FINAL: " .. math.floor(price)) end

    return math.ceil(price)
end

--- Calculates the SELL price (Player selling to Trader)
-- @param itemKey (String) Item FullType
-- @param itemData (Table) MasterList entry
-- @param itemObj (InventoryItem) Actual item object (for condition)
-- @param diffData (Table) Difficulty settings
-- @param archetype (Table) Archetype def (for 'wants')
-- @param modifiers (Table) { tagsConfig={}, getPriceModifier=func, globalHeat={}, localDeflationCount=int }
function Common.GetSellPrice(itemKey, itemData, itemObj, diffData, archetype, modifiers, verbose)
    if not itemData then return 0 end
    diffData = diffData or { sellMult = 0.5 }
    modifiers = modifiers or {}
    archetype = archetype or {}
    
    local globalHeat = modifiers.globalHeat or {}
    local getPriceMod = modifiers.getPriceModifier
    local localDeflationCount = modifiers.localDeflationCount or 0

    -- 1. Base & Difficulty
    local price = itemData.basePrice * diffData.sellMult
    
    if verbose then
        print("[DT TRACE] Sell Price Calc: " .. itemKey .. " | Base: " .. price)
    end

    -- 2. Condition & State Penalty
    if itemObj then
        -- ROTTEN CHECK
        -- Safety: isRotten might not exist on all item types or older API versions
        if itemObj.isRotten and itemObj:isRotten() then
            -- [NEW] Add a virtual tag for Rotten items so archetypes can target them
            table.insert(itemData.tags, "Rotten")
            if verbose then print("[DT TRACE] | STATE: ROTTEN (PRICE = 1)") end
            return 1
        end

        local maxCond = itemObj:getConditionMax()
        if maxCond > 0 then
             local condRatio = itemObj:getCondition() / maxCond
             price = price * condRatio
             if verbose then print("[DT TRACE] | Condition: " .. math.floor(condRatio * 100) .. "%") end
        end
        
        -- DRAINABLE / FLUID PRICING
        local scriptItem = nil
        if itemObj.getScriptItem then scriptItem = itemObj:getScriptItem() end
        
        -- A. Fluid Container
        if itemObj.getFluidContainer and itemObj:getFluidContainer() then
            local fluidContainer = itemObj:getFluidContainer()
            local capacity = fluidContainer:getCapacity()
            local currentAmount = fluidContainer:getAmount()
            local ratio = 0
            if capacity > 0 then ratio = currentAmount / capacity end

            -- Identify the Fluid Type (B42 Robust Way)
            local fluidType = nil
            if fluidContainer.getPrimaryFluid then
                local pFluid = fluidContainer:getPrimaryFluid()
                if pFluid then
                    if pFluid.getFluidType then fluidType = pFluid:getFluidType() end
                    if (not fluidType or fluidType == "") and pFluid.getFluid then
                        local fluidObj = pFluid:getFluid()
                        if fluidObj and fluidObj.getName then
                            fluidType = fluidObj:getName()
                        end
                    end
                end
            end

            if (not fluidType or fluidType == "") and fluidContainer.getFluidType then
                fluidType = fluidContainer:getFluidType()
            end

            local fluidValue = 0
            local fluidData = nil
            if fluidType and DynamicTrading.Fluids then
                local typeStr = tostring(fluidType)
                fluidData = DynamicTrading.Fluids[typeStr]
                
                if not fluidData and not typeStr:find("%.") then
                    fluidData = DynamicTrading.Fluids["Base." .. typeStr]
                end
            end

            if fluidData then
                -- [NEW] Apply dynamic multipliers to FLUID portion based on FLUID TAGS
                local fluidMults = diffData.sellMult or 0.5
                
                if fluidData.tags then
                    -- 1. Event Modifiers
                    if getPriceMod then
                        local eventMult = getPriceMod(fluidData.tags)
                        fluidMults = fluidMults * eventMult
                    end
                    
                    -- 2. Global Heat
                    for _, tag in ipairs(fluidData.tags) do
                        local heat = globalHeat[tag]
                        if heat and heat ~= 0 then
                            fluidMults = fluidMults * (1.0 + heat)
                        end
                    end
                    
                    -- 3. Archetype 'Wants'
                    if archetype and archetype.wants then
                        for _, tag in ipairs(fluidData.tags) do
                            if archetype.wants[tag] then
                                fluidMults = fluidMults * archetype.wants[tag]
                                break 
                            end
                        end
                    end
                    if verbose then print("[DT TRACE] | FLUID_MULTS: " .. fluidMults) end
                end
                
                fluidValue = (fluidData.basePrice * currentAmount) * fluidMults
            else
                local unknownFluidBase = 1.0
                fluidValue = (unknownFluidBase * currentAmount) * diffData.sellMult
            end

            local containerValue = price * 0.2
            if scriptItem and scriptItem.getReplaceOnDeplete then
                local emptyID = scriptItem:getReplaceOnDeplete()
                if emptyID and DynamicTrading.Config.MasterList[emptyID] then
                    local emptyData = DynamicTrading.Config.MasterList[emptyID]
                    containerValue = emptyData.basePrice * diffData.sellMult
                end
            end

            price = containerValue + fluidValue
            if verbose then 
                print("[DT TRACE] | FLUID: " .. tostring(fluidType) .. " (" .. math.floor(ratio*100) .. "%) | NewPrice: " .. price) 
            end

        -- B. Food Consumption (Partially eaten)
        elseif itemObj.getHungerChange and scriptItem and scriptItem.getHungerChange then
            local currentHunger = itemObj:getHungerChange()
            local baseHunger = Common.GetNormalizedHunger(scriptItem)
            
            if baseHunger < 0 then
                local ratio = currentHunger / baseHunger
                price = price * math.max(0, math.min(1, ratio))
                if verbose then print("[DT TRACE] | FOOD: " .. math.floor(ratio*100) .. "% | NewPrice: " .. price) end
            end

        -- C. Standard Drainable (Pills, Batteries, Flashlights, etc.)
        elseif itemObj.IsDrainable and itemObj:IsDrainable() then
            local delta = Common.GetItemCharge(itemObj)
            price = price * delta
            if verbose then print("[DT TRACE] | DRAINABLE: " .. math.floor(delta*100) .. "% | NewPrice: " .. price) end
        end
    end

    -- 3. Event Modifiers
    if getPriceMod then
        local eventMult = getPriceMod(itemData.tags)
        price = price * eventMult
        if verbose and eventMult ~= 1.0 then print("[DT TRACE] | EventMult: " .. eventMult) end
    end

    -- 4. Global Inflation (Heat)
    for _, tag in ipairs(itemData.tags) do
        local heat = globalHeat[tag]
        if heat and heat ~= 0 then
            price = price * (1.0 + heat)
            if verbose then print("[DT TRACE] | Heat(" .. tag .. "): " .. heat) end
        end
    end

    -- 5. Local Deflation (Trader Saturation)
    if localDeflationCount > 0 then
        local penaltyPerItem = 0.05
        local localMult = 1.0 - (localDeflationCount * penaltyPerItem)
        if localMult < 0.2 then localMult = 0.2 end
        price = price * localMult
        if verbose then print("[DT TRACE] | Deflation: " .. localMult) end
    end

    -- 6. Archetype Bonus ("Wants")
    if archetype and archetype.wants then
        for _, tag in ipairs(itemData.tags) do
            if archetype.wants[tag] then
                price = price * archetype.wants[tag]
                if verbose then print("[DT TRACE] | Want(" .. tag .. "): " .. archetype.wants[tag]) end
                break 
            end
        end
    end

    if price < 0 then price = 0 end
    
    if verbose then print("[DT TRACE] | FINAL: " .. math.floor(price)) end
    
    return math.floor(price)
end
