DT_SupplyWindow = DT_SupplyWindow or {}
DT_SupplyWindow.Internal = DT_SupplyWindow.Internal or {}

local Internal = DT_SupplyWindow.Internal

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
