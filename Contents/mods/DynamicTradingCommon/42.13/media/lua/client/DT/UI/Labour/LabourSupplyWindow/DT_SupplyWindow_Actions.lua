DT_LabourSupplyWindow = DT_LabourSupplyWindow or {}
DT_LabourSupplyWindow.Internal = DT_LabourSupplyWindow.Internal or {}

local Internal = DT_LabourSupplyWindow.Internal

function DT_LabourSupplyWindow:onRefresh()
    self:startInventoryScan()
end

function DT_LabourSupplyWindow:onDepositSelected()
    local selectedEntry = self.selectedEntry

    if not self.workerID then
        self:updateStatus("No worker selected.")
        return
    end
    if not selectedEntry then
        if self.scanning then
            self:updateStatus("Inventory scan still in progress.")
            return
        end
        self:updateStatus("Select an item first.")
        return
    end
    if not selectedEntry.canDeposit then
        self:updateStatus("That item is visible for future labour transfer, but upkeep only accepts food and water.")
        return
    end

    local player = Internal.getLocalPlayer()
    if not player then
        self:updateStatus("Missing local player.")
        return
    end

    if isClient() and not isServer() then
        sendClientCommand(player, Internal.getCommandModule(), "DepositWorkerSupplies", {
            workerID = self.workerID,
            itemID = selectedEntry.itemID
        })
    elseif DT_Labour and DT_Labour.Network and DT_Labour.Network.HandleCommand then
        DT_Labour.Network.HandleCommand(player, "DepositWorkerSupplies", {
            workerID = self.workerID,
            itemID = selectedEntry.itemID
        })
    end

    self:updateStatus("Depositing " .. tostring(selectedEntry.displayName or selectedEntry.fullType or "selected item") .. "...")
end

function DT_LabourSupplyWindow.onItemListMouseDown(target, item)
    if not target or not item then
        return
    end
    local entry = item.item or item
    target.selectedEntry = entry
    target:updateItemDetail(entry)
end
