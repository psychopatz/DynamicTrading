DT_SupplyWindow = DT_SupplyWindow or {}
DT_SupplyWindow.Internal = DT_SupplyWindow.Internal or {}

local Internal = DT_SupplyWindow.Internal

function DT_SupplyWindow:onRefresh()
    self:startInventoryScan()
    if self.workerID then
        self:sendLabourCommand("RequestWorkerDetails", {
            workerID = self.workerID
        })
    end
end

function DT_SupplyWindow:requestWorkerDetails()
    if not self.workerID then
        return
    end
    self:sendLabourCommand("RequestWorkerDetails", {
        workerID = self.workerID
    })
end

function DT_SupplyWindow:depositEntries(entries)
    if not self.workerID then
        self:updateStatus("No worker selected.")
        return
    end

    local payload = {}
    local selectedEntries = {}
    local seenIDs = {}

    for _, entry in ipairs(entries or {}) do
        local itemID = entry and entry.itemID or nil
        if itemID and not seenIDs[itemID] and self.playerEntriesByID[itemID] then
            seenIDs[itemID] = true
            if entry.canDeposit then
                payload[#payload + 1] = itemID
                selectedEntries[#selectedEntries + 1] = entry
            end
        end
    end

    if #selectedEntries <= 0 then
        self:updateStatus("No valid food or water supplies selected.")
        return
    end

    if not self:sendLabourCommand("DepositWorkerSupplies", {
            workerID = self.workerID,
            itemIDs = payload
        }) then
        self:updateStatus("Unable to send labour supply transfer.")
        return
    end

    self:applyOptimisticDeposit(selectedEntries)

    if #selectedEntries == 1 then
        local entry = selectedEntries[1]
        self:updateStatus("Depositing " .. tostring(entry.displayName or entry.fullType or "selected item") .. "...")
    else
        self:updateStatus("Depositing " .. tostring(#selectedEntries) .. " visible supplies...")
    end
end

function DT_SupplyWindow:onDepositSelected()
    local selectedEntry = self.selectedPlayerEntry

    if not selectedEntry then
        if self.scanning then
            self:updateStatus("Inventory scan still in progress.")
            return
        end
        self:updateStatus("Select an item on the player side first.")
        return
    end

    if not selectedEntry.canDeposit then
        self:updateStatus("That item is visible for preview, but upkeep only accepts food and water.")
        return
    end

    self:depositEntries({ selectedEntry })
end

function DT_SupplyWindow:onDepositVisible()
    if self.scanning then
        self:updateStatus("Wait for the inventory scan to finish before bulk depositing filtered supplies.")
        return
    end

    local visibleEntries = {}
    for _, row in ipairs(self.playerList and self.playerList.items or {}) do
        local entry = row and row.item or nil
        if entry and entry.canDeposit then
            visibleEntries[#visibleEntries + 1] = entry
        end
    end

    if #visibleEntries <= 0 then
        self:updateStatus("No visible food or water supplies matched the current filter.")
        return
    end

    self:depositEntries(visibleEntries)
end

function DT_SupplyWindow.onPlayerListMouseDown(target, item)
    if not target or not item then
        return
    end

    local entry = item.item or item
    target.selectedPlayerEntry = entry
    target.activeSelectionSide = "player"
    target:updateItemDetail(entry, "player")
end

function DT_SupplyWindow.onWorkerListMouseDown(target, item)
    if not target or not item then
        return
    end

    local entry = item.item or item
    target.selectedWorkerEntry = entry
    target.activeSelectionSide = "worker"
    target:updateItemDetail(entry, "worker")
end
