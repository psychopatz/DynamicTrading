-- ==============================================================================
-- media/lua/client/DT/UI/Shared/DT_UIUtils.lua
-- Dynamic Trading UI Utilities
-- Reusable components and drawing logic for consistent styling
-- ==============================================================================

DT_UIUtils = DT_UIUtils or {}

--- Draws a consistent selection highlight for list items.
--- @param listbox ISScrollingListBox the listbox instance
--- @param y number the vertical position
--- @param item table the list item table (from self.items[i])
--- @param alt boolean whether this is an alternate row
--- @return boolean whether the item was highlighted as selected
function DT_UIUtils.drawSelectionHighlight(listbox, y, item, alt)
    local isSelected = (item.selected == true)
    
    -- Robust detection: sync with listbox.selected index if flag is missing
    if not isSelected and listbox.selected ~= -1 and listbox.items[listbox.selected] == item then
        isSelected = true
    end

    if isSelected then
        -- Consistent Green Highlight
        listbox:drawRect(0, y, listbox.width, listbox.itemheight, 0.4, 0.05, 0.5, 0.05)
        listbox:drawRectBorder(0, y, listbox.width, listbox.itemheight, 1, 0.1, 0.8, 0.1)
        return true
    elseif alt then
        -- Standard Zebra Striping (Subtle)
        listbox:drawRect(0, y, listbox.width, listbox.itemheight, 0.1, 1, 1, 1)
    else
        -- Standard Transparent/Dark Background
        listbox:drawRect(0, y, listbox.width, listbox.itemheight, 0.1, 0, 0, 0)
    end
    
    return false
end

DynamicTrading.Log("DTCommons", "UI", "Utility", "Shared UI Utils Loaded")
