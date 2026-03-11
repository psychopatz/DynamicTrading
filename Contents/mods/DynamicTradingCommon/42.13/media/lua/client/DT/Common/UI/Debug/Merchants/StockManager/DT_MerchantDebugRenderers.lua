-- ==============================================================================
-- DT_MerchantDebugRenderers.lua
-- Merchant Debug Tool: Rendering Layer
-- Custom drawing functions for merchant and stock lists
-- ==============================================================================

DT_MerchantDebugRenderers = DT_MerchantDebugRenderers or {}

-- ==========================================================
-- MERCHANT LIST ITEM RENDERER
-- ==========================================================
function DT_MerchantDebugRenderers.drawMerchantItem(listbox, y, item, alt)
    local ok, nextY = pcall(function()
        local data = item and item.item
        if not data then return y end

        if item.selected then
            -- Strong highlight for clear click feedback.
            listbox:drawRect(0, y, listbox.width, listbox.itemheight, 0.45, 0.2, 0.65, 1.0)
            listbox:drawRectBorder(0, y, listbox.width, listbox.itemheight, 1.0, 0.3, 0.8, 1.0)
        elseif alt then
            listbox:drawRect(0, y, listbox.width, listbox.itemheight, 0.1, 1, 1, 1)
        else
            listbox:drawRect(0, y, listbox.width, listbox.itemheight, 0.1, 0, 0, 0)
        end
        
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

    if alt then
        listbox:drawRect(0, y, listbox.width, listbox.itemheight, 0.1, 1, 1, 1)
    end

    listbox:drawText(itemType, 10, y + 5, 1, 1, 1, 1, UIFont.Small)
    local detailStr = string.format("Qty: %d | Pr: %d | Mod: %.1f", stockItem.qty, stockItem.basePrice or 0, stockItem.dynamicMod or 1.0)
    listbox:drawText(detailStr, listbox.width - 250, y + 5, 0.8, 1, 0.8, 1, UIFont.Small)

    return y + listbox.itemheight
end

DynamicTrading.Log("DTCommons", "Debug", "UI", "Merchant Debug Renderers Loaded")
