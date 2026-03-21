DT_SupplyWindow = DT_SupplyWindow or {}
DT_SupplyWindow.Internal = DT_SupplyWindow.Internal or {}

local Internal = DT_SupplyWindow.Internal

function DT_SupplyWindow:setActiveTab(tabID)
    local targetTab = tabID or Internal.Tabs.Provisions
    if self.activeTab == targetTab then
        return
    end

    self.activeTab = targetTab
    self.selectedWorkerEntry = nil

    if self.refreshTabButtons then
        self:refreshTabButtons()
    end
    if self.updateTransferControls then
        self:updateTransferControls()
    end

    self:refreshWorkerEntries()
end

function DT_SupplyWindow:refreshDetailSelection()
    local entry = nil
    local side = self.activeSelectionSide

    if side == "worker" then
        entry = self.selectedWorkerEntry
    else
        side = "player"
        entry = self.selectedPlayerEntry
    end

    if not entry then
        if self.selectedPlayerEntry then
            side = "player"
            entry = self.selectedPlayerEntry
        elseif self.selectedWorkerEntry then
            side = "worker"
            entry = self.selectedWorkerEntry
        else
            side = nil
        end
    end

    self.activeSelectionSide = side
    self:updateItemDetail(entry, side)
end

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

function DT_SupplyWindow:registerVisiblePlayerEntry(entry)
    if not self.playerList or not entry then
        return
    end

    if not Internal.matchesFilter(entry, Internal.getSearchText(self.playerSearch)) then
        return
    end

    self.playerList:addItem(Internal.formatEntryLabel(entry), entry)
    entry.rowIndex = #self.playerList.items

    if not self.selectedPlayerEntry then
        self.playerList.selected = entry.rowIndex
        self.selectedPlayerEntry = entry
        if self.activeSelectionSide ~= "worker" then
            self.activeSelectionSide = "player"
            self:updateItemDetail(entry, "player")
        end
    end
end

function DT_SupplyWindow:addScannedItem(invItem)
    if not invItem then
        return false
    end

    local fullType = invItem.getFullType and invItem:getFullType() or nil
    if fullType == "Base.Money" or fullType == "Base.MoneyBundle" then
        return false
    end

    local entry = Internal.buildInventoryEntry(invItem)
    self.playerEntries[#self.playerEntries + 1] = entry
    self.playerEntriesByID[entry.itemID] = entry
    self:registerVisiblePlayerEntry(entry)
    return true
end

function DT_SupplyWindow:rebuildPlayerList()
    if not self.playerList then
        return
    end

    local selectedID = self.selectedPlayerEntry and self.selectedPlayerEntry.itemID or nil
    local filterText = Internal.getSearchText(self.playerSearch)

    self.playerList:clear()
    self.playerList.selected = -1
    self.selectedPlayerEntry = nil

    local selectedIndex = nil
    for _, entry in ipairs(self.playerEntries or {}) do
        if Internal.matchesFilter(entry, filterText) then
            self.playerList:addItem(Internal.formatEntryLabel(entry), entry)
            local rowIndex = #self.playerList.items
            entry.rowIndex = rowIndex
            if selectedID and entry.itemID == selectedID then
                selectedIndex = rowIndex
            end
        end
    end

    if self.playerList.items and #self.playerList.items > 0 then
        local targetIndex = selectedIndex or 1
        self.playerList.selected = targetIndex
        self.selectedPlayerEntry = self.playerList.items[targetIndex].item
    end

    self:refreshDetailSelection()
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
        if Internal.matchesFilter(entry, filterText) then
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

function DT_SupplyWindow:syncSearchFilters()
    local playerFilter = Internal.normalizeFilterText(Internal.getSearchText(self.playerSearch))
    if playerFilter ~= (self.lastPlayerFilter or "") then
        self.lastPlayerFilter = playerFilter
        self:rebuildPlayerList()
    end

    local workerFilter = Internal.normalizeFilterText(Internal.getSearchText(self.workerSearch))
    if workerFilter ~= (self.lastWorkerFilter or "") then
        self.lastWorkerFilter = workerFilter
        self:rebuildWorkerList()
    end
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

function DT_SupplyWindow:removePlayerEntryByID(itemID)
    if not itemID then
        return nil
    end

    self.playerEntriesByID[itemID] = nil
    for index = #self.playerEntries, 1, -1 do
        local entry = self.playerEntries[index]
        if entry and entry.itemID == itemID then
            return table.remove(self.playerEntries, index)
        end
    end

    return nil
end

function DT_SupplyWindow:applyOptimisticDeposit(entries)
    local changed = false
    self.workerData = self.workerData or {}
    self.workerData.nutritionLedger = self.workerData.nutritionLedger or {}

    for _, entry in ipairs(entries or {}) do
        local removed = self:removePlayerEntryByID(entry.itemID)
        if removed then
            self.workerData.nutritionLedger[#self.workerData.nutritionLedger + 1] = {
                fullType = removed.fullType,
                displayName = removed.displayName,
                itemID = removed.itemID,
                caloriesRemaining = removed.calories,
                hydrationRemaining = removed.hydration,
                pending = true,
            }
            changed = true
        end
    end

    if changed then
        self:rebuildPlayerList()
        self:refreshWorkerEntries()
    end
end

function DT_SupplyWindow:applyOptimisticToolAssign(entries)
    local changed = false
    self.workerData = self.workerData or {}
    self.workerData.toolLedger = self.workerData.toolLedger or {}

    for _, entry in ipairs(entries or {}) do
        local removed = self:removePlayerEntryByID(entry.itemID)
        if removed then
            self.workerData.toolLedger[#self.workerData.toolLedger + 1] = {
                fullType = removed.fullType,
                displayName = removed.displayName,
                tags = removed.tags or {},
                pending = true,
            }
            changed = true
        end
    end

    if changed then
        self:rebuildPlayerList()
        self:refreshWorkerEntries()
    end
end

function DT_SupplyWindow:startInventoryScan()
    local player = Internal.getLocalPlayer()
    local rootContainer = player and player.getInventory and player:getInventory() or nil

    self.playerEntries = {}
    self.playerEntriesByID = {}
    self.selectedPlayerEntry = nil
    self.scanStack = {}
    self.scanProcessed = 0
    self.scanning = false

    if self.playerList then
        self.playerList:clear()
        self.playerList.selected = -1
    end

    if not rootContainer then
        self:refreshDetailSelection()
        self:updateStatus("No player inventory found.")
        return
    end

    self.scanStack[#self.scanStack + 1] = {
        container = rootContainer,
        index = 0
    }
    self.scanning = true
    self:updateStatus("Scanning inventory for labour supplies...")
end

function DT_SupplyWindow:finishInventoryScan()
    self.scanning = false
    table.sort(self.playerEntries, Internal.compareEntries)
    self:rebuildPlayerList()

    self:updateStatus(
        "Loaded "
        .. tostring(#(self.playerEntries or {}))
        .. " visible entries from "
        .. tostring(self.scanProcessed or 0)
        .. " inventory items."
    )
end

function DT_SupplyWindow:processInventoryScan(batchSize)
    if not self.scanning then
        return
    end

    local visibleProcessed = 0
    local rawSteps = 0
    while #self.scanStack > 0
        and visibleProcessed < (batchSize or Internal.ENTRY_SCAN_BATCH_SIZE)
        and rawSteps < Internal.RAW_SCAN_STEP_LIMIT do
        local frame = self.scanStack[#self.scanStack]
        local container = frame and frame.container or nil
        local items = container and container.getItems and container:getItems() or nil

        if not items then
            table.remove(self.scanStack)
        elseif frame.index >= items:size() then
            table.remove(self.scanStack)
        else
            local invItem = items:get(frame.index)
            frame.index = frame.index + 1
            rawSteps = rawSteps + 1

            if invItem then
                local addedVisibleEntry = self:addScannedItem(invItem)
                if addedVisibleEntry then
                    visibleProcessed = visibleProcessed + 1
                end
                self.scanProcessed = self.scanProcessed + 1

                if instanceof(invItem, "InventoryContainer") then
                    local subContainer = invItem:getItemContainer()
                    if subContainer then
                        self.scanStack[#self.scanStack + 1] = {
                            container = subContainer,
                            index = 0
                        }
                    end
                end
            end
        end
    end

    if #self.scanStack <= 0 then
        self:finishInventoryScan()
    elseif self.scanProcessed % 120 == 0 then
        self:updateStatus(
            "Scanning inventory... "
            .. tostring(self.scanProcessed)
            .. " items checked, "
            .. tostring(#(self.playerEntries or {}))
            .. " visible entries."
        )
    end
end

function DT_SupplyWindow:update()
    ISCollapsableWindow.update(self)
    self:syncSearchFilters()

    if self.scanning then
        self:processInventoryScan(Internal.ENTRY_SCAN_BATCH_SIZE)
    end
end
