function DT_TradingWindow:onToggleLock()
    if not self.selectedItemID or self.selectedItemID == -1 then return end

    local player = getSpecificPlayer(0)
    local modData = player:getModData()

    if not modData.DT_LockedItems then
        modData.DT_LockedItems = {}
    end

    if modData.DT_LockedItems[self.selectedItemID] then
        modData.DT_LockedItems[self.selectedItemID] = nil
        player:setHaloNote("Item Unlocked", 200, 200, 200, 300)
        player:playSound("UnlockDoor")
    else
        modData.DT_LockedItems[self.selectedItemID] = true
        player:setHaloNote("Item Locked (Protected)", 255, 255, 100, 300)
        player:playSound("LockDoor")
    end

    if DT_TradingItemUtils and DT_TradingItemUtils.Internal and DT_TradingItemUtils.Internal.invalidateSellScanCaches then
        DT_TradingItemUtils.Internal.invalidateSellScanCaches("lock-toggle")
    end

    self:populateList()
end
