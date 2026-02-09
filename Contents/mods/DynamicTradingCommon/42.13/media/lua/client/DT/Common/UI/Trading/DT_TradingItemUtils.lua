if not DT_TradingItemUtils then DT_TradingItemUtils = {} end

-- =============================================================================
-- DT_TradingItemUtils: Logic for Trading Items
-- =============================================================================
-- This file contains the logic for checking items, generating status strings,
-- and extracting data for both Buying and Selling lists.
local DEBUG = true

--- Internal helper to check debug state.
local function isDebugEnabled() return DEBUG end

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

--- Internal helper to get a readable fluid name in B42.
local function getFluidName(fluidContainer, typeStr)
    local fType = typeStr
    if (not fType or fType == "") and fluidContainer and fluidContainer.getFluidType then
        fType = fluidContainer:getFluidType()
    end
    
    if not fType or fType == "" then return "" end
    
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
    -- DEBUG: SELLING LOGIC
    if not listItem.isBuy then
        if invItem then
            local dName = invItem:getDisplayName()
            local iType = invItem:getFullType()
            if isDebugEnabled() then
                print("[DT DEBUG] Selling Item: " .. iType .. " | ID: " .. invItem:getID() .. " | DisplayName: " .. dName)
            end
            return dName
        else
            if isDebugEnabled() then
                print("[DT DEBUG] Selling Item: NO invItem FOUND for ID: " .. (listItem.itemID or "NIL"))
            end
        end
    end
    
    -- BUYING: Construct name if fluid exists
    if listItem.isBuy and listItem.customData and (listItem.customData.fluidAmount or 0) > 0 then
        local fName = getFluidName(nil, listItem.customData.fluidType)
        if fName and fName ~= "" then
            local containerName = scriptItem and scriptItem:getDisplayName() or ""
            -- Try to find Empty counterpart for a cleaner container name (e.g. "Glass Bottle")
            if scriptItem and scriptItem.getReplaceOnDeplete then
                local emptyType = scriptItem:getReplaceOnDeplete()
                if emptyType then
                    local emptyScript = getScriptManager():getItem(emptyType)
                    if emptyScript then containerName = emptyScript:getDisplayName() end
                end
            end
            if isDebugEnabled() then
                print("[DT DEBUG] Buying Fluid Item: " .. fName .. " (" .. containerName .. ")")
            end
            return fName .. " (" .. containerName .. ")"
        end
    end
    
    return listItem.name or (scriptItem and scriptItem:getDisplayName()) or "Unknown Item"
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
                if scriptItem and scriptItem:getFluidContainer() then
                    local cap = scriptItem:getFluidContainer():getCapacity()
                    if cap > 0 then
                        local pct = math.floor((customData.fluidAmount / cap) * 100)
                        statusSuffix = " (" .. pct .. "%)"
                        isFluid = true
                    end
                end
            elseif customData.usedDelta then
                local pct = math.floor(customData.usedDelta * 100)
                if pct < 100 then statusSuffix = " (" .. pct .. "%)" end
            elseif customData.hungerChange then
                if scriptItem and scriptItem.getHungerChange then
                    local base = scriptItem:getHungerChange()
                    if base < 0 then
                        local pct = math.floor((customData.hungerChange / base) * 100)
                        if pct < 100 then statusSuffix = " (" .. pct .. "%)" end
                    end
                end
            end
        end
    else
        if invItem then
            -- DEBUG: FLUID CONTAINER CHECK
            if invItem.getFluidContainer and invItem:getFluidContainer() then
                local fluidContainer = invItem:getFluidContainer()
                local cap = fluidContainer:getCapacity()
                local amt = fluidContainer:getAmount()
                local fType = nil
                if fluidContainer.getFluidType then
                    fType = fluidContainer:getFluidType()
                end
                
                if isDebugEnabled() then
                    print("[DT DEBUG] invItem Fluid: " .. tostring(fType) .. " | Amt: " .. amt .. "/" .. cap)
                end
                
                if cap > 0 then
                    local pct = math.floor((amt / cap) * 100)
                    statusSuffix = " (" .. pct .. "%)"
                    isFluid = true
                end
            end

            if invItem.isRotten and invItem:isRotten() then
                statusSuffix = " (Rotten)"
                isRotten = true
            elseif invItem.getHungerChange and scriptItem and scriptItem.getHungerChange then
                local current = invItem:getHungerChange()
                local base = scriptItem:getHungerChange()
                if base < 0 then
                    local pct = math.floor((current / base) * 100)
                    if pct < 100 then statusSuffix = " (" .. pct .. "%)" end
                end
            elseif invItem.IsDrainable and invItem:IsDrainable() then
                local delta = invItem:getUsedDelta()
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
function DT_TradingItemUtils.scanSellableItems(player, trader, dataProvider, categorized, categories, activeRadioID)
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
                                isBuy = false,
                                priceMod = dataProvider:getPriceModifier(itemData.tags)
                            })
                        end
                    end
                end
            end
        end
    end
end

--- Populates a table with items buyable from the trader.
function DT_TradingItemUtils.scanBuyableItems(trader, dataProvider, categorized, categories)
    if not trader.stocks then return end

    for key, qty in pairs(trader.stocks) do
        local itemData = dataProvider:getItemData(key)
        if itemData then
            local scriptItem = getScriptManager():getItem(itemData.item)
            local sortName = scriptItem and scriptItem:getDisplayName() or key
            local price = dataProvider:getBuyPrice(key)
            local cat = itemData.tags[1] or "Misc"

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
            end

            table.insert(categorized[cat], {
                key = key,
                name = sortName,
                qty = stockQty,
                price = tonumber(price) or 0,
                data = itemData,
                isBuy = true,
                priceMod = dataProvider:getPriceModifier(itemData.tags),
                customData = customData
            })
        end
    end
end

return DT_TradingItemUtils
