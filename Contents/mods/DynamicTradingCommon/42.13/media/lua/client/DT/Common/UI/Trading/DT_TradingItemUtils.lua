if not DT_TradingItemUtils then DT_TradingItemUtils = {} end
require "DT/Common/Trading/DT_Economy_Common"

-- =============================================================================
-- DT_TradingItemUtils: Logic for Trading Items
-- =============================================================================
-- This file contains the logic for checking items, generating status strings,
-- and extracting data for both Buying and Selling lists.


--- Recursively finds an item by ID in a container and its sub-containers.
function DT_TradingItemUtils.findItemRecursively(container, itemID)
    if not container or not itemID then return nil end
    local items = container:getItems()
    for i = 0, items:size() - 1 do
        local it = items:get(i)
        if it:getID() == itemID then return it end
        if instanceof(it, "InventoryContainer") then
            local found = DT_TradingItemUtils.findItemRecursively(it:getItemContainer(), itemID)
            if found then return found end
        end
    end
    return nil
end

--- Internal helper to get the strict Fluid ID string (e.g. "Base.Water") in B42.
local function getFluidTypeID(fluidContainer)
    if not fluidContainer then return nil end
    local fType = nil
    
    -- Try B42 Primary Fluid logic
    if fluidContainer.getPrimaryFluid then
        local pFluid = fluidContainer:getPrimaryFluid()
        if pFluid then
            if pFluid.getFluidType then 
                fType = pFluid:getFluidType() -- Usually returns the string ID in B42
            end
            -- If still nil, try getting it from the Fluid object itself
            if (not fType or fType == "") and pFluid.getFluid then
                local fluidObj = pFluid:getFluid()
                if fluidObj and fluidObj.getName then
                    fType = fluidObj:getName()
                end
            end
        end
    end
    
    -- Fallback to legacy/direct method
    if (not fType or fType == "") and fluidContainer.getFluidType then
        fType = fluidContainer:getFluidType()
    end
    
    return fType
end

--- Internal helper to get a readable fluid name in B42.
local function getFluidName(fluidContainer, typeStr)
    local fType = typeStr or getFluidTypeID(fluidContainer)
    
    if not fType or fType == "" then 
        -- Last ditch: If we have a PrimaryFluid but no ID, maybe it has a display name?
        if fluidContainer and fluidContainer.getPrimaryFluid then
            local pf = fluidContainer:getPrimaryFluid()
            if pf and pf.getDisplayName then return pf:getDisplayName() end
        end
        return "" 
    end
    
    -- Case A: It's a string (e.g. "Base.Water")
    if type(fType) == "string" then
        local scriptFluid = getScriptManager():getFluid(fType)
        if scriptFluid then
            return scriptFluid:getDisplayName()
        end
        -- Fallback: Translation check
        local shortName = fType:gsub("Base%.", "")
        local trans = getText("IGUI_Fluid_" .. shortName)
        if trans and trans ~= ("IGUI_Fluid_" .. shortName) then
            return trans
        end
        return shortName
    end
    
    -- Case B: It's a Java Fluid object
    if fType.getDisplayName then return fType:getDisplayName() end
    if fType.getName then return fType:getName() end
    
    return tostring(fType)
end

--- Returns the most appropriate display name, handling fluid renaming.
function DT_TradingItemUtils.getItemDisplayName(listItem, invItem, scriptItem)
    local isBuy = listItem.isBuy
    
    -- Construction logic for both sides if it's a fluid container
    local fluidContainer = nil
    if isBuy then
        if scriptItem and scriptItem.getFluidContainer then 
            fluidContainer = scriptItem:getFluidContainer() 
        end
    else
        if invItem and invItem.getFluidContainer then 
            fluidContainer = invItem:getFluidContainer() 
        end
    end
    
    if fluidContainer then
        local amt = 0
        if isBuy then
            amt = (listItem.customData and listItem.customData.fluidAmount or 0)
        elseif fluidContainer.getAmount then 
            amt = fluidContainer:getAmount()
        end

        if amt > 0 then
            local fType = isBuy and listItem.customData.fluidType or nil
            local fName = getFluidName(fluidContainer, fType)
            
            if fName and fName ~= "" then
                local containerName = scriptItem and scriptItem.getDisplayName and scriptItem:getDisplayName() or ""
                -- Try to find Empty counterpart for a cleaner container name (e.g. "Glass Bottle")
                if scriptItem and scriptItem.getReplaceOnDeplete then
                    local emptyType = scriptItem:getReplaceOnDeplete()
                    if emptyType then
                        local emptyScript = getScriptManager():getItem(emptyType)
                        if emptyScript and emptyScript.getDisplayName then 
                            containerName = emptyScript:getDisplayName() 
                        end
                    end
                end
                
                local finalName = fName .. " (" .. containerName .. ")"
                return finalName
            end
        end
    end

    -- Fallback to standard names
    if not isBuy and invItem and invItem.getDisplayName then
        return invItem:getDisplayName()
    end
    
    return listItem.name or (scriptItem and scriptItem.getDisplayName and scriptItem:getDisplayName()) or "Unknown Item"
end

--- Generates a suffix like " (Rotten)" or " (50%)" for display.
function DT_TradingItemUtils.getStatusSuffix(listItem, invItem, scriptItem)
    local statusSuffix = ""
    local isRotten = false
    local isFluid = false

    if listItem.isBuy then
        local customData = listItem.customData
        if customData then
            if (customData.fluidAmount or 0) > 0 then
                if scriptItem and scriptItem.getFluidContainer and scriptItem:getFluidContainer() then
                    local fc = scriptItem:getFluidContainer()
                    if fc.getCapacity then
                        local cap = fc:getCapacity()
                        if cap > 0 then
                            local amt = customData.fluidAmount
                            -- [DISPLAY CHANGE] Show Liters instead of %
                            -- Round to 2 decimals for amount, 1 for capacity
                            local amtStr = string.format("%.2f", amt)
                            local capStr = string.format("%.1f", cap)
                            statusSuffix = " (" .. amtStr .. "/" .. capStr .. "L)"
                            isFluid = true
                        end
                    end
                end
            elseif customData.usedDelta then
                local pct = math.floor(customData.usedDelta * 100)
                if pct < 100 then statusSuffix = " (" .. pct .. "%)" end
            elseif customData.hungerChange then
                if scriptItem and scriptItem.getHungerChange then
                    local base = DynamicTrading.Economy.Common.GetNormalizedHunger(scriptItem)
                    if base < 0 then
                        local pct = math.floor((customData.hungerChange / base) * 100)
                        if pct < 100 then statusSuffix = " (" .. pct .. "%)" end
                    end
                end
            elseif customData.condition then
                if scriptItem and scriptItem.getConditionMax and scriptItem:getConditionMax() > 0 then
                    local pct = math.floor((customData.condition / scriptItem:getConditionMax()) * 100)
                    if pct < 100 then statusSuffix = " (" .. pct .. "%)" end
                end
            end
        end
    else
        if invItem then
            -- DEBUG: FLUID CONTAINER CHECK
            if invItem.getFluidContainer and invItem:getFluidContainer() then
                local fluidContainer = invItem:getFluidContainer()
                local cap = fluidContainer.getCapacity and fluidContainer:getCapacity() or 0
                local amt = fluidContainer.getAmount and fluidContainer:getAmount() or 0
                
                local fType = getFluidTypeID(fluidContainer)
                
                if cap > 0 then
                    -- [DISPLAY CHANGE] Show Liters instead of %
                    local amtStr = string.format("%.2f", amt)
                    local capStr = string.format("%.1f", cap)
                    statusSuffix = " (" .. amtStr .. "/" .. capStr .. "L)"
                    isFluid = true
                end
            end

            if invItem.isRotten and invItem:isRotten() then
                statusSuffix = " (Rotten)"
                isRotten = true
            elseif invItem.getHungerChange and scriptItem and scriptItem.getHungerChange then
                local current = invItem:getHungerChange()
                local base = DynamicTrading.Economy.Common.GetNormalizedHunger(scriptItem)
                if base < 0 then
                    local pct = math.floor((current / base) * 100)
                    if pct < 100 then statusSuffix = " (" .. pct .. "%)" end
                end
            elseif invItem.IsDrainable and invItem:IsDrainable() then
                -- Use shared robust B42 logic
                local delta = 0
                if DynamicTrading.Economy and DynamicTrading.Economy.Common and DynamicTrading.Economy.Common.GetItemCharge then
                    delta = DynamicTrading.Economy.Common.GetItemCharge(invItem)
                else
                    -- Fallback local logic
                    delta = invItem.getDrainableUsesFloat and invItem:getDrainableUsesFloat() or (invItem.getUsedDelta and invItem:getUsedDelta() or 0)
                end
                
                local pct = math.floor(delta * 100)
                if pct < 100 then statusSuffix = " (" .. pct .. "%)" end
            end
        end
    end

    return statusSuffix, isRotten
end

--- Determines the R, G, B colors for the price text.
function DT_TradingItemUtils.getPriceColors(listItem, isLocked)
    local r, g, b = 0.6, 1.0, 0.6 -- Default Green
    
    if isLocked then
        return 0.4, 0.4, 0.4 -- Grey
    end

    if listItem.isBuy then
        if listItem.priceMod > 1.01 then
            r, g, b = 1.0, 0.4, 0.4 -- Red (Expensive)
        elseif listItem.priceMod < 0.99 then
            r, g, b = 0.2, 1.0, 1.0 -- Cyan (Bargain)
        end
    else
        if listItem.priceMod > 1.01 then
            r, g, b = 1.0, 0.8, 0.2 -- Gold (Good Sell)
        end
    end

    return r, g, b
end

--- Populates a table with items sellable by the player.
function DT_TradingItemUtils.scanSellableItems(player, trader, dataProvider, categorized, categories, activeRadioID, rejections)
    local inv = player:getInventory()
    local itemList = {}
    
    -- Truly recursive container scanning
    local function collectItems(container)
        local items = container:getItems()
        for i = 0, items:size() - 1 do
            local item = items:get(i)
            table.insert(itemList, item)
            if instanceof(item, "InventoryContainer") then
                local subContainer = item:getItemContainer()
                if subContainer then
                    collectItems(subContainer) -- Recursive call
                end
            end
        end
    end
    collectItems(inv)

    for _, invItem in ipairs(itemList) do
        if invItem then
            -- Sync favorite to lock
            if invItem:isFavorite() then
                dataProvider:lockItem(invItem:getID())
            end

            local fullType = invItem:getFullType()
            if fullType ~= "Base.Money" and fullType ~= "Base.MoneyBundle" and invItem:getID() ~= activeRadioID then
                local masterKey = dataProvider:getMasterKey(fullType)
                if masterKey then
                    -- Prevent reselling trader's own stock items
                    local isInTraderStock = trader.stocks and trader.stocks[masterKey] ~= nil
                    if not isInTraderStock then
                        local itemData = dataProvider:getItemData(masterKey)
                        local price = dataProvider:getSellPrice(invItem, masterKey, trader)

                        if price > 0 then
                            local cat = itemData.tags[1] or "Misc"
                            
                            if invItem.getFluidContainer and invItem:getFluidContainer() then
                                local fc = invItem:getFluidContainer()
                                if fc:getAmount() > 0 then
                                    local fType = getFluidTypeID(fc)
                                    if fType and DynamicTrading.Fluids then
                                        -- Try direct lookup or Base. lookup
                                        local fTypeStr = tostring(fType)
                                        local fData = DynamicTrading.Fluids[fTypeStr] or DynamicTrading.Fluids["Base." .. fTypeStr]
                                        if fData and fData.tags and fData.tags[1] then
                                            cat = fData.tags[1]
                                        end
                                    end
                                end
                            end

                            if invItem.isRotten and invItem:isRotten() then
                                cat = "Rotten"
                            end
                            if not categorized[cat] then
                                categorized[cat] = {}
                                table.insert(categories, cat)
                            end

                            table.insert(categorized[cat], {
                                key = masterKey,
                                itemID = invItem:getID(),
                                name = invItem:getDisplayName(),
                                price = tonumber(price) or 0,
                                data = itemData,
                                scriptItem = getScriptManager():getItem(itemData.item), -- [PERFORMANCE] Cache script reference
                                isBuy = false,
                                priceMod = dataProvider:getPriceModifier(itemData.tags),
                                -- [PERFORMANCE] Pre-calculate display data to avoid recursion in render loop
                                invItem = invItem,
                                displayName = DT_TradingItemUtils.getItemDisplayName({isBuy=false}, invItem, getScriptManager():getItem(itemData.item)),
                                statusSuffix = DT_TradingItemUtils.getStatusSuffix({isBuy=false}, invItem, getScriptManager():getItem(itemData.item)),
                                isRotten = (invItem.isRotten and invItem:isRotten()) or false
                            })
                        else
                            if rejections then table.insert(rejections, "[Sell] " .. fullType .. " | REJECTED: Price is 0") end
                        end
                    else
                        if rejections then table.insert(rejections, "[Sell] " .. fullType .. " | REJECTED: Trader already has this key in stock") end
                    end
                else
                    if rejections then table.insert(rejections, "[Sell] " .. fullType .. " | REJECTED: Item not found in Master Registry") end
                end
            end
        end
    end
end

--- Populates a table with items buyable from the trader.
function DT_TradingItemUtils.scanBuyableItems(trader, dataProvider, categorized, categories, rejections)
    if not trader.stocks then return end

    for key, qty in pairs(trader.stocks) do
        local itemData = dataProvider:getItemData(key)
        if itemData then
            local scriptItem = getScriptManager():getItem(itemData.item)
            local sortName = scriptItem and scriptItem:getDisplayName() or key
            local cat = itemData.tags[1] or "Misc"
            
            -- [NEW] Content-Based Tagging for Fluids (Buy Side)
            -- We need to check customData inside the loop, but it's extracted later. 
            -- Let's peek at qty table if it is one.
            if type(qty) == "table" and qty.customData and qty.customData.fluidType then
                local fType = qty.customData.fluidType
                if DynamicTrading.Fluids then
                    local fTypeStr = tostring(fType)
                    local fData = DynamicTrading.Fluids[fTypeStr] or DynamicTrading.Fluids["Base." .. fTypeStr]
                    if fData and fData.tags and fData.tags[1] then
                        cat = fData.tags[1]
                    end
                end
            end

            if not categorized[cat] then
                categorized[cat] = {}
                table.insert(categories, cat)
            end

            local stockQty = 0
            local customData = nil
            if type(qty) == "table" then
                stockQty = tonumber(qty.qty) or 0
                customData = qty.customData
                
            else
                stockQty = tonumber(qty) or 0
                -- print("[DT DEBUG] Client Scan: " .. key .. " is OLD FORMAT (number only)")
            end

            local price = dataProvider:getBuyPrice(key, customData)

            table.insert(categorized[cat], {
                key = key,
                name = sortName,
                qty = stockQty,
                price = tonumber(price) or 0,
                data = itemData,
                isBuy = true,
                priceMod = dataProvider:getPriceModifier(itemData.tags),
                customData = customData,
                -- [PERFORMANCE] Pre-calculate display data
                displayName = DT_TradingItemUtils.getItemDisplayName({isBuy=true, customData=customData, name=sortName}, nil, scriptItem),
                statusSuffix = DT_TradingItemUtils.getStatusSuffix({isBuy=true, customData=customData}, nil, scriptItem),
                isRotten = false
            })
        end
    end
end

return DT_TradingItemUtils
