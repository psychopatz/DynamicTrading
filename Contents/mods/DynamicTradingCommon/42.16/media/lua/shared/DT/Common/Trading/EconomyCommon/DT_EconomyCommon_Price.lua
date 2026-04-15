-- =============================================================================
-- 4. PRICING LOGIC
-- =============================================================================

local Common = DynamicTrading.Economy.Common

local function getEffectiveBasePrice(itemKey, itemData)
    if DynamicTrading and DynamicTrading.PriceConfig and DynamicTrading.PriceConfig.GetEffectiveBasePrice then
        return DynamicTrading.PriceConfig.GetEffectiveBasePrice(itemKey, itemData)
    end
    return itemData and itemData.basePrice or 0
end

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
    
    local effectiveBasePrice = getEffectiveBasePrice(itemKey, itemData)
    local price = effectiveBasePrice
    
    if verbose then
        DynamicTrading.Log("DTCommons", "Trade", "Trace", "Buy Price Calc: " .. itemKey .. " | Base: " .. price)
    end

    -- 1. Tag Multipliers (Highest Wins)
    local maxTagMult = 1.0
    for _, tag in ipairs(itemData.tags) do
        local tagConfig = Common.ResolveMappedValue({ tag }, tagsConfig)
        if tagConfig and tagConfig.priceMult then
            if tagConfig.priceMult > maxTagMult then
                maxTagMult = tagConfig.priceMult
            end
        end
    end
    price = price * maxTagMult
    if verbose and maxTagMult ~= 1.0 then DynamicTrading.Log("DTCommons", "Trade", "Trace", "| TagMult: " .. maxTagMult) end

    -- 2. Event Modifiers (Supports Hierarchy)
    if getPriceMod then
        -- The Event Manager usually expects tags to match, we pass the raw table.
        -- We assume the caller (Event Manager) handles its own matching logic or we do it here.
        local eventMult = getPriceMod(itemData.tags)
        price = price * eventMult
        if verbose and eventMult ~= 1.0 then DynamicTrading.Log("DTCommons", "Trade", "Trace", "| EventMult: " .. eventMult) end
    end

    -- 3. Global Inflation (Heat)
    for _, tag in ipairs(itemData.tags) do
        local heat = globalHeat[tag]
        if heat and heat ~= 0 then
            price = price * (1.0 + heat)
            if verbose then DynamicTrading.Log("DTCommons", "Trade", "Trace", "| Heat(" .. tag .. "): " .. heat) end
        end
    end

    -- 4. Difficulty
    price = price * diffData.buyMult
    if verbose and diffData.buyMult ~= 1.0 then DynamicTrading.Log("DTCommons", "Trade", "Trace", "| DiffMult: " .. diffData.buyMult) end

    -- [NEW] Condition/Charge Scaler (Dynamic Buying Variation)
    if modifiers.customData then
        local cd = modifiers.customData
        local scale = 1.0
        
        -- A. Fluid(Per-Liter Pricing)
        if cd.fluidAmount ~= nil and itemData.item then
            -- [NEW] Calculate Price = Container + (FluidPrice * Amount)
            local script = getScriptManager():getItem(itemData.item)
            local containerBase = 0
            local fluidTotal = 0
            local fData = nil
            local fluidAmount = math.max(0, tonumber(cd.fluidAmount) or 0)
            
            -- 1. Determine Container Price
            containerBase = Common.ResolveContainerBasePrice(itemData, script)

            -- 2. Determine Fluid Price
            local fType = Common.NormalizeFluidType(cd.fluidType)
            if fType then
                fData = Common.GetFluidData(fType)
                if fData then
                    fluidTotal = Common.GetFluidUnitPrice(fType) * fluidAmount
                end
            end
            
            -- 3. Calculate separate multipliers for Container and Fluid
            -- A. Container Multipliers (Base Logic)
            -- 'price' currently holds value calculated from ITEM keys/tags.
            -- This is effectively 'Container + Default Content' price.
            -- We want pure Container price mults. Ideally we'd scan empty container tags.
            -- Approximating: Use default item tags for container part.
            local containerMults = 1.0
            if effectiveBasePrice > 0 then
                 containerMults = price / effectiveBasePrice
            end
            
            -- B. Fluid Multipliers (Dynamic based on Fluid Tags)
            local fluidMults = diffData.buyMult or 1.0
            
            if fData and fData.tags then
                -- 1. Tags Config
                local maxFluidTagMult = 1.0
                for _, tag in ipairs(fData.tags) do
                    local tagConfig = Common.ResolveMappedValue({ tag }, tagsConfig)
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
                        if verbose then DynamicTrading.Log("DTCommons", "Trade", "Trace", "| FluidHeat(" .. tag .. "): " .. heat) end
                    end
                end
            end
            
            price = (containerBase * containerMults) + (fluidTotal * fluidMults)
            
            if verbose then
                 DynamicTrading.Log("DTCommons", "Trade", "Trace", "| DYNAMIC CONTENT DETECTED")
                 DynamicTrading.Log("DTCommons", "Trade", "Trace", "|   Container Price: " .. math.floor(containerBase * containerMults))
                 DynamicTrading.Log("DTCommons", "Trade", "Trace", "|   FluidTotal: " .. math.floor(fluidTotal * fluidMults) .. " (" .. tostring(fType) .. ")")
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
        if verbose and scale ~= 1.0 then DynamicTrading.Log("DTCommons", "Trade", "Trace", "| ItemScale: " .. scale) end
    end

    if price < 1 then price = 1 end
    
    if verbose then DynamicTrading.Log("DTCommons", "Trade", "Trace", "| FINAL: " .. math.floor(price)) end

    return math.ceil(price)
end

local function applyEventAndHeat(value, tags, getPriceMod, globalHeat, verbose, label)
    local result = value

    if getPriceMod then
        local eventMult = getPriceMod(tags or {})
        result = result * eventMult
        if verbose and eventMult ~= 1.0 then
            DynamicTrading.Log("DTCommons", "Trade", "Trace", "| " .. tostring(label or "Event") .. "EventMult: " .. eventMult)
        end
    end

    for _, tag in ipairs(tags or {}) do
        local heat = globalHeat[tag]
        if heat and heat ~= 0 then
            result = result * (1.0 + heat)
            if verbose then
                DynamicTrading.Log("DTCommons", "Trade", "Trace", "| " .. tostring(label or "") .. "Heat(" .. tag .. "): " .. heat)
            end
        end
    end

    return result
end

local function findWantMultiplier(tags, archetype)
    if not archetype or not archetype.wants then
        return 1.0
    end

    for _, t in ipairs(tags or {}) do
        for wantTag, bonus in pairs(archetype.wants) do
            if Common.TagMatches(t, wantTag) then
                return bonus, wantTag
            end
        end
    end

    return 1.0
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
    local effectiveBasePrice = getEffectiveBasePrice(itemKey, itemData)
    local price = effectiveBasePrice * diffData.sellMult
    
    if verbose then
        DynamicTrading.Log("DTCommons", "Trade", "Trace", "Sell Price Calc: " .. itemKey .. " | Base: " .. price)
    end

    -- 2. Condition & State Penalty
    if itemObj then
        local conditionScale = 1.0
        -- ROTTEN CHECK
        -- Safety: isRotten might not exist on all item types or older API versions
        if itemObj.isRotten and itemObj:isRotten() then
            if verbose then DynamicTrading.Log("DTCommons", "Trade", "Trace", "| STATE: ROTTEN (PRICE = 1)") end
            return 1
        end

        local maxCond = itemObj:getConditionMax()
        if maxCond > 0 then
             conditionScale = itemObj:getCondition() / maxCond
             price = price * conditionScale
             if verbose then DynamicTrading.Log("DTCommons", "Trade", "Trace", "| Condition: " .. math.floor(conditionScale * 100) .. "%") end
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

            fluidType = Common.NormalizeFluidType(fluidType)
            local fluidValue = 0
            local fluidData = Common.GetFluidData(fluidType)
            local containerBase = Common.ResolveContainerBasePrice(itemData, scriptItem)
            local containerValue = (containerBase * diffData.sellMult) * conditionScale
            containerValue = applyEventAndHeat(containerValue, itemData.tags, getPriceMod, globalHeat, verbose, "Container")
            local containerWantMult, containerWantTag = findWantMultiplier(itemData.tags, archetype)
            if containerWantMult ~= 1.0 then
                containerValue = containerValue * containerWantMult
                if verbose then
                    DynamicTrading.Log("DTCommons", "Trade", "Trace", "ContainerWant(" .. tostring(containerWantTag) .. "): " .. containerWantMult)
                end
            end

            if fluidData then
                local baseFluidValue = (Common.GetFluidUnitPrice(fluidType) * currentAmount) * (diffData.sellMult or 0.5)
                fluidValue = applyEventAndHeat(baseFluidValue, fluidData.tags, getPriceMod, globalHeat, verbose, "Fluid")
                local fluidWantMult, fluidWantTag = findWantMultiplier(fluidData.tags, archetype)
                if fluidWantMult ~= 1.0 then
                    fluidValue = fluidValue * fluidWantMult
                    if verbose then
                        DynamicTrading.Log("DTCommons", "Trade", "Trace", "FluidWant(" .. tostring(fluidWantTag) .. "): " .. fluidWantMult)
                    end
                end
            else
                local unknownFluidBase = 1.0
                fluidValue = (unknownFluidBase * currentAmount) * diffData.sellMult
            end

            price = containerValue + fluidValue
            if verbose then 
                DynamicTrading.Log("DTCommons", "Trade", "Trace", "| FLUID: " .. tostring(fluidType) .. " (" .. math.floor(ratio*100) .. "%) | NewPrice: " .. price) 
            end

            if localDeflationCount > 0 then
                local penaltyPerItem = 0.05
                local localMult = 1.0 - (localDeflationCount * penaltyPerItem)
                if localMult < 0.2 then localMult = 0.2 end
                price = price * localMult
                if verbose then DynamicTrading.Log("DTCommons", "Trade", "Trace", "| Deflation: " .. localMult) end
            end

            if price < 0 then price = 0 end
            if verbose then DynamicTrading.Log("DTCommons", "Trade", "Trace", "| FINAL: " .. math.floor(price)) end
            return math.floor(price)

        -- B. Food Consumption (Partially eaten)
        elseif itemObj.getHungerChange and scriptItem and scriptItem.getHungerChange then
            local currentHunger = itemObj:getHungerChange()
            local baseHunger = Common.GetNormalizedHunger(scriptItem)
            
            if baseHunger < 0 then
                local ratio = currentHunger / baseHunger
                price = price * math.max(0, math.min(1, ratio))
                if verbose then DynamicTrading.Log("DTCommons", "Trade", "Trace", "| FOOD: " .. math.floor(ratio*100) .. "% | NewPrice: " .. price) end
            end

        -- C. Standard Drainable (Pills, Batteries, Flashlights, etc.)
        elseif itemObj.IsDrainable and itemObj:IsDrainable() then
            local delta = Common.GetItemCharge(itemObj)
            price = price * delta
            if verbose then DynamicTrading.Log("DTCommons", "Trade", "Trace", "| DRAINABLE: " .. math.floor(delta*100) .. "% | NewPrice: " .. price) end
        end
    end

    -- 3. Event Modifiers
    if getPriceMod then
        local eventMult = getPriceMod(itemData.tags)
        price = price * eventMult
        if verbose and eventMult ~= 1.0 then DynamicTrading.Log("DTCommons", "Trade", "Trace", "| EventMult: " .. eventMult) end
    end

    -- 4. Global Inflation (Heat)
    for _, tag in ipairs(itemData.tags) do
        local heat = globalHeat[tag]
        if heat and heat ~= 0 then
            price = price * (1.0 + heat)
            if verbose then DynamicTrading.Log("DTCommons", "Trade", "Trace", "| Heat(" .. tag .. "): " .. heat) end
        end
    end

    -- 5. Local Deflation (Trader Saturation)
    if localDeflationCount > 0 then
        local penaltyPerItem = 0.05
        local localMult = 1.0 - (localDeflationCount * penaltyPerItem)
        if localMult < 0.2 then localMult = 0.2 end
        price = price * localMult
        if verbose then DynamicTrading.Log("DTCommons", "Trade", "Trace", "| Deflation: " .. localMult) end
    end

    -- 6. Archetype Bonus ("Wants")
    local wantMult, wantTag = findWantMultiplier(itemData.tags, archetype)
    if wantMult ~= 1.0 then
        price = price * wantMult
        if verbose then DynamicTrading.Log("DTCommons", "Trade", "Trace", "Want(" .. tostring(wantTag) .. "): " .. wantMult) end
    end

    if price < 0 then price = 0 end
    
    if verbose then DynamicTrading.Log("DTCommons", "Trade", "Trace", "| FINAL: " .. math.floor(price)) end
    
    return math.floor(price)
end
