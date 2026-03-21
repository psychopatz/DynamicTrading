DT_SupplyWindow = DT_SupplyWindow or {}
DT_SupplyWindow.Internal = DT_SupplyWindow.Internal or {}

local Internal = DT_SupplyWindow.Internal

function DT_SupplyWindow:canTransferWithWorker(showStatus)
    local allowed = Internal.canTransferWithWorker(self.workerData)
    if allowed then
        return true
    end

    if showStatus ~= false then
        self:updateStatus(Internal.getTransferBlockedReason(self.workerData))
    end
    return false
end

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

function DT_SupplyWindow:updateTransferControls()
    if not self.btnWithdrawSelected or not self.btnWithdrawVisible or not self.btnDepositSelected or not self.btnDepositVisible then
        return
    end

    local activeTab = self.activeTab or Internal.Tabs.Provisions
    local transferAllowed = self:canTransferWithWorker(false)
    local depositEnabled = transferAllowed and activeTab ~= Internal.Tabs.Output
    local hasWorkerEntries = #(self.workerEntries or {}) > 0

    self.btnWithdrawSelected:setEnable(transferAllowed and hasWorkerEntries)
    self.btnWithdrawVisible:setEnable(transferAllowed and hasWorkerEntries)
    self.btnDepositSelected:setEnable(depositEnabled)
    self.btnDepositVisible:setEnable(depositEnabled)

    if activeTab == Internal.Tabs.Equipment then
        self.btnDepositSelected:setTitle("Use")
        self.btnDepositVisible:setTitle("All")
    else
        self.btnDepositSelected:setTitle(">")
        self.btnDepositVisible:setTitle(">>")
    end

    self.btnWithdrawSelected:setTitle("<")
    self.btnWithdrawVisible:setTitle("<<")
end

function DT_SupplyWindow:openDepositMoneyModal()
    if not self.workerID then
        self:updateStatus("No worker selected.")
        return
    end
    if not self:canTransferWithWorker(true) then
        return
    end

    local wealth = Internal.getPlayerWealth and Internal.getPlayerWealth(Internal.getLocalPlayer and Internal.getLocalPlayer() or nil) or 0
    if wealth <= 0 then
        self:updateStatus("You do not have any money to deposit.")
        return
    end

    local workerName = tostring(self.workerName or self.workerID or "this worker")
    DT_LabourQuantityModal.Open({
        title = "Deposit Cash",
        promptText = "How much money do you want to give to " .. workerName .. "?",
        maxValue = wealth,
        defaultValue = wealth,
        onConfirm = function(quantity)
            self:sendLabourCommand("GiveWorkerMoney", {
                workerID = self.workerID,
                amount = quantity
            })
            self:updateStatus("Depositing $" .. tostring(quantity) .. " to " .. workerName .. "...")
        end
    })
end

function DT_SupplyWindow:openWithdrawMoneyModal()
    if not self.workerID then
        self:updateStatus("No worker selected.")
        return
    end
    if not self:canTransferWithWorker(true) then
        return
    end

    local stored = math.max(0, math.floor(tonumber(self.workerData and self.workerData.moneyStored) or 0))
    if stored <= 0 then
        self:updateStatus(tostring(self.workerName or self.workerID or "This worker") .. " does not have any stored cash.")
        return
    end

    local workerName = tostring(self.workerName or self.workerID or "this worker")
    DT_LabourQuantityModal.Open({
        title = "Withdraw Cash",
        promptText = "How much money do you want to take from " .. workerName .. "?",
        maxValue = stored,
        defaultValue = stored,
        onConfirm = function(quantity)
            self:sendLabourCommand("WithdrawWorkerMoney", {
                workerID = self.workerID,
                amount = quantity
            })
            self:updateStatus("Withdrawing $" .. tostring(quantity) .. " from " .. workerName .. "...")
        end
    })
end

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

function DT_SupplyWindow:withdrawWorkerEntries(entries)
    if not self.workerID then
        self:updateStatus("No worker selected.")
        return
    end
    if not self:canTransferWithWorker(true) then
        return
    end

    local selectedEntries = {}
    local seenIndexes = {}
    for _, entry in ipairs(entries or {}) do
        local ledgerIndex = math.floor(tonumber(entry and entry.ledgerIndex) or 0)
        if ledgerIndex > 0 and not seenIndexes[ledgerIndex] then
            seenIndexes[ledgerIndex] = true
            selectedEntries[#selectedEntries + 1] = entry
        end
    end

    if #selectedEntries <= 0 then
        local activeTab = self.activeTab or Internal.Tabs.Provisions
        if activeTab == Internal.Tabs.Output then
            local config = Internal.Config or {}
            local normalizedJob = config.NormalizeJobType and config.NormalizeJobType(self.workerData and self.workerData.jobType) or tostring(self.workerData and self.workerData.jobType or "")
            if normalizedJob == ((config.JobTypes or {}).Scavenge) and (tonumber(self.workerData and self.workerData.haulCount) or 0) > 0 then
                self:updateStatus("This worker is still carrying haul. Wait for them to get home first.")
                return
            end
        end
        self:updateStatus("No worker items are available for transfer.")
        return
    end

    local activeTab = self.activeTab or Internal.Tabs.Provisions
    local command = nil
    if activeTab == Internal.Tabs.Equipment then
        command = "WithdrawWorkerTools"
    elseif activeTab == Internal.Tabs.Output then
        command = "WithdrawWorkerOutput"
    else
        command = "WithdrawWorkerSupplies"
    end

    local payload = {}
    for _, entry in ipairs(selectedEntries) do
        payload[#payload + 1] = entry.ledgerIndex
    end

    if not self:sendLabourCommand(command, {
            workerID = self.workerID,
            ledgerIndexes = payload
        }) then
        self:updateStatus("Unable to collect worker items.")
        return
    end

    if #selectedEntries == 1 then
        self:updateStatus("Taking " .. tostring(selectedEntries[1].displayName or selectedEntries[1].fullType or "item") .. " from " .. tostring(self.workerName or self.workerID) .. "...")
    else
        self:updateStatus("Taking " .. tostring(#selectedEntries) .. " worker entries from " .. tostring(self.workerName or self.workerID) .. "...")
    end
end

function DT_SupplyWindow:onWithdrawSelected()
    local selectedEntry = self.selectedWorkerEntry
    if not selectedEntry then
        self:updateStatus("Select an item on the worker side first.")
        return
    end

    if selectedEntry.kind == "money" then
        self:openWithdrawMoneyModal()
        return
    end

    self:withdrawWorkerEntries({ selectedEntry })
end

function DT_SupplyWindow:onWithdrawVisible()
    local visibleEntries = {}
    for _, row in ipairs(self.workerList and self.workerList.items or {}) do
        local entry = row and row.item or nil
        if entry and entry.kind ~= "money" then
            visibleEntries[#visibleEntries + 1] = entry
        end
    end

    if #visibleEntries <= 0 then
        self:updateStatus("No visible worker items matched the current filter. Select the cash entry to transfer money.")
        return
    end

    self:withdrawWorkerEntries(visibleEntries)
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
