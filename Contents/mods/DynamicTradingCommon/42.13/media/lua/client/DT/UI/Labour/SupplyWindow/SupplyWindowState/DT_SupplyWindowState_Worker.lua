DT_SupplyWindow = DT_SupplyWindow or {}
DT_SupplyWindow.Internal = DT_SupplyWindow.Internal or {}

local Internal = DT_SupplyWindow.Internal

function DT_SupplyWindow:refreshWorkerEntries()
    self.workerEntries = {}

    local worker = self.workerData
    local activeTab = self.activeTab or Internal.Tabs.Provisions

    if activeTab == Internal.Tabs.Equipment then
        for index, ledgerEntry in ipairs(worker and worker.toolLedger or {}) do
            local entry = Internal.buildWorkerToolEntry(ledgerEntry, index)
            if entry then
                self.workerEntries[#self.workerEntries + 1] = entry
            end
        end
    elseif activeTab == Internal.Tabs.Output then
        for index, ledgerEntry in ipairs(worker and worker.outputLedger or {}) do
            local entry = Internal.buildWorkerOutputEntry(ledgerEntry, index)
            if entry then
                self.workerEntries[#self.workerEntries + 1] = entry
            end
        end
    else
        for index, ledgerEntry in ipairs(worker and worker.nutritionLedger or {}) do
            local entry = Internal.buildWorkerSupplyEntry(ledgerEntry, index)
            if entry then
                self.workerEntries[#self.workerEntries + 1] = entry
            end
        end
    end

    table.sort(self.workerEntries, Internal.compareEntries)
    self:rebuildWorkerList()
end

function DT_SupplyWindow:rebuildWorkerList()
    if not self.workerList then
        return
    end

    local selectedKey = self.selectedWorkerEntry and (self.selectedWorkerEntry.itemID or self.selectedWorkerEntry.ledgerIndex) or nil
    local filterText = Internal.getSearchText(self.workerSearch)

    self.workerList:clear()
    self.workerList.selected = -1
    self.selectedWorkerEntry = nil

    local selectedIndex = nil
    for _, entry in ipairs(self.workerEntries or {}) do
        if Internal.shouldShowWorkerEntry(entry, self.activeTab or Internal.Tabs.Provisions)
            and Internal.matchesFilter(entry, filterText) then
            self.workerList:addItem(Internal.formatEntryLabel(entry), entry)
            local rowIndex = #self.workerList.items
            entry.rowIndex = rowIndex
            local entryKey = entry.itemID or entry.ledgerIndex
            if selectedKey and entryKey == selectedKey then
                selectedIndex = rowIndex
            end
        end
    end

    if self.workerList.items and #self.workerList.items > 0 then
        local targetIndex = selectedIndex or 1
        self.workerList.selected = targetIndex
        self.selectedWorkerEntry = self.workerList.items[targetIndex].item
    end

    self:refreshDetailSelection()
end

function DT_SupplyWindow:setWorkerData(worker)
    self.workerData = worker
    if self.refreshTabButtons then
        self:refreshTabButtons()
    end
    if self.updateTransferControls then
        self:updateTransferControls()
    end
    self:refreshWorkerEntries()
end

