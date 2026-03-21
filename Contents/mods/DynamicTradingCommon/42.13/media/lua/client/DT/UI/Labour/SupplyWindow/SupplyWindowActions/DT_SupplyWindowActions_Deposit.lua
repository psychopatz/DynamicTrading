DT_SupplyWindow = DT_SupplyWindow or {}
DT_SupplyWindow.Internal = DT_SupplyWindow.Internal or {}

local Internal = DT_SupplyWindow.Internal

function DT_SupplyWindow:depositEntries(entries)
    if not self.workerID then
        self:updateStatus("No worker selected.")
        return
    end
    if not self:canTransferWithWorker(true) then
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

function DT_SupplyWindow:assignToolEntries(entries)
    if not self.workerID then
        self:updateStatus("No worker selected.")
        return
    end
    if not self:canTransferWithWorker(true) then
        return
    end

    local selectedEntries = {}
    local seenIDs = {}

    for _, entry in ipairs(entries or {}) do
        local itemID = entry and entry.itemID or nil
        if itemID and not seenIDs[itemID] and self.playerEntriesByID[itemID] and entry.canAssignTool then
            seenIDs[itemID] = true
            selectedEntries[#selectedEntries + 1] = entry
        end
    end

    if #selectedEntries <= 0 then
        self:updateStatus("No valid labour tools selected.")
        return
    end

    local sentEntries = {}
    for _, entry in ipairs(selectedEntries) do
        if self:sendLabourCommand("AssignWorkerToolset", {
                workerID = self.workerID,
                itemID = entry.itemID
            }) then
            sentEntries[#sentEntries + 1] = entry
        end
    end

    if #sentEntries <= 0 then
        self:updateStatus("Unable to send equipment assignment.")
        return
    end

    self:applyOptimisticToolAssign(sentEntries)

    if #sentEntries == 1 then
        self:updateStatus("Assigning " .. tostring(sentEntries[1].displayName or sentEntries[1].fullType or "selected tool") .. "...")
    else
        self:updateStatus("Assigning " .. tostring(#sentEntries) .. " tools...")
    end
end

function DT_SupplyWindow:onDepositSelected()
    local selectedEntry = self.selectedPlayerEntry
    local activeTab = self.activeTab or Internal.Tabs.Provisions

    if activeTab == Internal.Tabs.Output then
        self:updateStatus("This tab is worker-side storage only.")
        return
    end

    if not selectedEntry then
        if self.scanning then
            self:updateStatus("Inventory scan still in progress.")
            return
        end
        self:updateStatus("Select an item on the player side first.")
        return
    end

    if selectedEntry.kind == "money" then
        self:openDepositMoneyModal()
        return
    end

    if activeTab == Internal.Tabs.Equipment then
        if not selectedEntry.canAssignTool then
            self:updateStatus("Select a valid labour tool first.")
            return
        end
        self:assignToolEntries({ selectedEntry })
        return
    end

    if not selectedEntry.canDeposit then
        self:updateStatus("That item is visible for preview, but upkeep only accepts food and water.")
        return
    end

    self:depositEntries({ selectedEntry })
end

function DT_SupplyWindow:onDepositVisible()
    local activeTab = self.activeTab or Internal.Tabs.Provisions

    if activeTab == Internal.Tabs.Output then
        self:updateStatus("This tab is worker-side storage only.")
        return
    end

    if self.scanning then
        self:updateStatus("Wait for the inventory scan to finish before bulk depositing filtered supplies.")
        return
    end

    local visibleEntries = {}
    for _, row in ipairs(self.playerList and self.playerList.items or {}) do
        local entry = row and row.item or nil
        if entry
            and entry.kind ~= "money"
            and ((activeTab == Internal.Tabs.Equipment and entry.canAssignTool) or (activeTab ~= Internal.Tabs.Equipment and entry.canDeposit)) then
            visibleEntries[#visibleEntries + 1] = entry
        end
    end

    if #visibleEntries <= 0 then
        if activeTab == Internal.Tabs.Equipment then
            self:updateStatus("No visible labour tools matched the current filter.")
        elseif activeTab == Internal.Tabs.Provisions then
            self:updateStatus("No visible food or water supplies matched the current filter. Select the cash entry to transfer money.")
        else
            self:updateStatus("No visible food or water supplies matched the current filter.")
        end
        return
    end

    if activeTab == Internal.Tabs.Equipment then
        self:assignToolEntries(visibleEntries)
    else
        self:depositEntries(visibleEntries)
    end
end
