-- =============================================================================
-- DYNAMIC TRADING: SHARED ECONOMY LOGIC
-- =============================================================================
-- This module contains the core math and logic for trading, stripped of 
-- specific data dependencies (like specific Events or Soul lookups).
-- V1 and V2 wrappers should gather the data and pass it here.

DynamicTrading = DynamicTrading or {}
DynamicTrading.Economy = DynamicTrading.Economy or {}
DynamicTrading.Economy.Common = {}

require "DT/Common/Items/DT_Fluids"

local Common = DynamicTrading.Economy.Common

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
            local qty = math.floor(qty * diffData.stockMult * volumeMult * globalStockMult)
            
            if qty < 1 then qty = 1 end 
            
            -- V1 Structure update: 
            -- V1 resultStock was { [key] = qty }.
            -- To support customData, we might need to change the structure OR
            -- store it in a separate table? 
            -- But Economy.V1.GenerateStock returns resultStock directly.
            -- If we change the return type to { [key] = { qty=.., customData=.. } }, check if V1 UI breaks.
            
            -- Checking V1 consumers: 
            -- Manager.lua uses it.
            -- DT_ServerCommands writes it to 'trader.stocks'.
            -- GetStock sends it to client.
            -- V1 UI (DT_TradingWindow) iterates it.
            
            -- If we change V1 structure now, it's a breaking change for V1 UI.
            -- USER INTENT: "I want the trader to sell me a random amount... how do we approach this"
            -- USER defined: "since this is being used by both mod versions, I would recommend you to put it on commons"
            
            -- For V1, keeping simple maps {key=qty} makes it hard to store per-item data.
            -- However, we can store it in a parallel structure in the Trader Object?
            -- Or, since V1 is legacy/maintenance, maybe we just enable it for V2?
            -- Wait, the user said "It would price the liquid itself... when I sell... Also same as buying too".
            
            -- If we want V1 to have this, we MUST update the stock structure.
            -- V1 UI iterates `for k,v in pairs(stock)`. If v is table, UI might break if it expects number.
            
            -- Let's stick to V2 implementation primarily unless user explicitly asked to Refactor V1 UI.
            -- User said: "It would price the liquid itself... Also same as buying too".
            -- The "Buying" part requires the stock data to exist.
            
            -- DECISION: For V1, we will NOT change the stock structure to avoid breaking legacy UI.
            -- V1 will get the "Sell" improvements (Price logic in Common), but maybe not the "Buy Randomized" feature
            -- unless we do a massive V1 refactor. 
            
            -- BUT, I can inject it into a separate field if needed? 
            -- Actually, let's look at `DT_Economy_Common.GenerateStock`. It returns `resultStock` as { key = qty }.
            -- I can't easily change Common.GenerateStock return type without breaking V1 if V1 relies on it being strict.
            -- Common.GenerateStock is already returning { key = qty }.
            
            -- To support V2, V2 wrapper iterates this and converts it.
            -- So `Common` doesn't need to change to return complex objects.
            -- `Common` is fine.
            
            -- V2 Wrapper (`DynamicTrading.Economy.V2.GenerateStock`) is where we add the complexity.
            -- V1 Wrapper (`DynamicTrading.Economy.V1.GenerateStock`) calls Common.
            
            resultStock[key] = qty
        end
    end

    return resultStock
end

--- Generates random condition/fluid data for an item if applicable.
-- @param itemData (Table) MasterList entry
-- @return (Table|nil) customData { usedDelta=0.5, fluidAmount=... } or nil
function Common.GenerateItemCondition(itemData)
    if not itemData then return nil end
    
    -- We can't easily check 'isDrainable' from just the MasterList entry without looking up the ScriptItem.
    -- However, we can use a heuristic or just always return nil unless we want to force something.
    -- Better approach: The caller (Stock Generator) might check ScriptManager.
    
    local scriptItem = getScriptManager():getItem(itemData.item)
    if not scriptItem then return nil end
    
    local data = {}
    local hasData = false
    
    -- 1. Fluid Container (e.g. Gas Can, Water Bottle)
    -- We want to randomize the amount, but maybe bias towards full for shops? 
    -- Let's do random for now as requested.
    if scriptItem:getFluidContainer() then
        local capacity = scriptItem:getFluidContainer():getCapacity()
        -- Randomize: 0 to Capacity (or maybe 10% to 100%?)
        -- Let's do 0.1 to 1.0 multiplier
        local mult = (ZombRand(10, 101) / 100.0) 
        data.fluidAmount = capacity * mult

        -- [NEW] Store default fluid type
        if scriptItem:getFluidContainer().getFluidType then
            data.fluidType = scriptItem:getFluidContainer():getFluidType()
        end

        hasData = true
    end
    
    -- 2. Drainable (e.g. Bleach, Vitamins)
    -- Only if it's NOT a fluid container (usually distinct, but check IsDrainable)
    if scriptItem:IsDrainable() and not data.fluidAmount then
        local mult = (ZombRand(1, 101) / 100.0)
        data.usedDelta = mult
        hasData = true
    end
    
    -- 3. Food (e.g. Apple, Steak)
    if scriptItem.getHungerChange and not data.fluidAmount and not data.usedDelta then
        local baseHunger = Common.GetNormalizedHunger(scriptItem)
        if baseHunger < 0 then
            -- Randomize: 10% to 100% of base hunger
            local mult = (ZombRand(1, 11) / 10.0)
            data.hungerChange = baseHunger * mult
            hasData = true
        end
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
    local debugLog = "[DT DEBUG] Sell Price Calc: " .. itemKey .. " | Base: " .. price

    -- 2. Condition & State Penalty
    if itemObj then
        -- ROTTEN CHECK
        -- Safety: isRotten might not exist on all item types or older API versions
        if itemObj.isRotten and itemObj:isRotten() then
            -- [NEW] Add a virtual tag for Rotten items so archetypes can target them
            table.insert(itemData.tags, "Rotten")
            print(debugLog .. " | STATE: ROTTEN (PRICE = 1)")
            return 1
        end

        local maxCond = itemObj:getConditionMax()
        if maxCond > 0 then
             local condRatio = itemObj:getCondition() / maxCond
             price = price * condRatio
             debugLog = debugLog .. " | Condition: " .. math.floor(condRatio * 100) .. "%"
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
                fluidValue = (fluidData.basePrice * currentAmount) * diffData.sellMult
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
            debugLog = debugLog .. " | FLUID: " .. tostring(fluidType) .. " (" .. math.floor(ratio*100) .. "%) | NewPrice: " .. price

        -- B. Food Consumption (Partially eaten)
        elseif itemObj.getHungerChange and scriptItem and scriptItem.getHungerChange then
            local currentHunger = itemObj:getHungerChange()
            local baseHunger = Common.GetNormalizedHunger(scriptItem)
            
            if baseHunger < 0 then
                local ratio = currentHunger / baseHunger
                price = price * math.max(0, math.min(1, ratio))
                debugLog = debugLog .. " | FOOD: " .. math.floor(ratio*100) .. "% | NewPrice: " .. price
            end

        -- C. Standard Drainable (Pills, Batteries, Flashlights, etc.)
        elseif itemObj.IsDrainable and itemObj:IsDrainable() then
            local delta = Common.GetItemCharge(itemObj)
            price = price * delta
            debugLog = debugLog .. " | DRAINABLE: " .. math.floor(delta*100) .. "% | NewPrice: " .. price
        end
    end

    -- 3. Event Modifiers
    if getPriceMod then
        local eventMult = getPriceMod(itemData.tags)
        price = price * eventMult
        if eventMult ~= 1.0 then debugLog = debugLog .. " | EventMult: " .. eventMult end
    end

    -- 4. Global Inflation (Heat)
    for _, tag in ipairs(itemData.tags) do
        local heat = globalHeat[tag]
        if heat and heat ~= 0 then
            price = price * (1.0 + heat)
            debugLog = debugLog .. " | Heat(" .. tag .. "): " .. heat
        end
    end

    -- 5. Local Deflation (Trader Saturation)
    if localDeflationCount > 0 then
        local penaltyPerItem = 0.05
        local localMult = 1.0 - (localDeflationCount * penaltyPerItem)
        if localMult < 0.2 then localMult = 0.2 end
        price = price * localMult
        debugLog = debugLog .. " | Deflation: " .. localMult
    end

    -- 6. Archetype Bonus ("Wants")
    if archetype and archetype.wants then
        for _, tag in ipairs(itemData.tags) do
            if archetype.wants[tag] then
                price = price * archetype.wants[tag]
                debugLog = debugLog .. " | Want(" .. tag .. "): " .. archetype.wants[tag]
                break 
            end
        end
    end

    if price < 0 then price = 0 end
    
    if isDebugEnabled() then print(debugLog .. " | FINAL: " .. math.floor(price)) end

    return math.floor(price)
end
