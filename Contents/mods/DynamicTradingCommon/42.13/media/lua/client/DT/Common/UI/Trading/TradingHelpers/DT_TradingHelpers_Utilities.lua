-- =============================================================================
-- UTILITIES (WRAPPERS)
-- =============================================================================

function DT_TradingWindow.TruncateString(text, font, maxWidth)
    return DynamicTrading.Utils.TruncateString(text, font, maxWidth)
end

function DT_TradingWindow:isItemLocked(itemID)
    if not itemID or itemID == -1 then return false end
    local player = getSpecificPlayer(0)
    if not player then return false end
    local modData = player:getModData()
    if modData.DT_LockedItems and modData.DT_LockedItems[itemID] then
        return true
    end
    return false
end
