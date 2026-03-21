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
