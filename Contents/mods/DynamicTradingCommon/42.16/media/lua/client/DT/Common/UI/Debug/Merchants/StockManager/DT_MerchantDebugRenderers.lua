require "DT/UI/Shared/DT_UIUtils"

DT_MerchantDebugRenderers = DT_MerchantDebugRenderers or {}

-- ==========================================================
-- MERCHANT LIST ITEM RENDERER
-- ==========================================================
function DT_MerchantDebugRenderers.drawMerchantItem(listbox, y, item, alt)
    local ok, nextY = pcall(function()
        local data = item and item.item
        if not data then return y end

        -- Selection / Background (Unified Utility)
        DT_UIUtils.drawSelectionHighlight(listbox, y, item, alt)
        
        listbox:drawText(tostring(data.name or "Unknown"), 10, y + 2, 1, 1, 1, 1, UIFont.Medium)
        
        -- Draw Status Line
        local statusStr = "Faction: " .. tostring(data.faction or "Independent") .. " | " .. tostring(data.archetype or "N/A")
        local hasStock = data.hasStock == true

        -- Show only [Ready] when stock exists to reduce UI clutter.
        if hasStock then
            statusStr = statusStr .. " | [Ready]"
        end
        
        listbox:drawText(statusStr, 10, y + 22, 0.7, 0.7, 0.7, 1, UIFont.Small)

        return y + listbox.itemheight
    end)

    if ok then
        return nextY
    end

    DynamicTrading.Log("DTCommons", "Debug", "UI", "drawMerchantItem failed: " .. tostring(nextY))
    return y + (listbox and listbox.itemheight or 45)
end

-- ==========================================================
-- STOCK ITEM RENDERER
-- ==========================================================
function DT_MerchantDebugRenderers.drawStockItem(listbox, y, item, alt)
    local itemType = item.text
    local stockItem = item.item
    local effectiveBasePrice = stockItem and stockItem.basePrice or 0
    local itemData = itemType and DynamicTrading and DynamicTrading.Config and DynamicTrading.Config.MasterList
        and DynamicTrading.Config.MasterList[itemType]
        or nil

    if itemData and DynamicTrading.PriceConfig and DynamicTrading.PriceConfig.GetEffectiveBasePrice then
        effectiveBasePrice = DynamicTrading.PriceConfig.GetEffectiveBasePrice(itemType, itemData)
    end

    -- Selection / Background (Unified Utility)
    DT_UIUtils.drawSelectionHighlight(listbox, y, item, alt)

    listbox:drawText(itemType, 10, y + 5, 1, 1, 1, 1, UIFont.Small)
    local detailStr = string.format("Qty: %d | Pr: %d | Mod: %.1f", stockItem.qty, effectiveBasePrice or 0, stockItem.dynamicMod or 1.0)
    listbox:drawText(detailStr, listbox.width - 250, y + 5, 0.8, 1, 0.8, 1, UIFont.Small)

    return y + listbox.itemheight
end

DynamicTrading.Log("DTCommons", "Debug", "UI", "Merchant Debug Renderers Loaded")
