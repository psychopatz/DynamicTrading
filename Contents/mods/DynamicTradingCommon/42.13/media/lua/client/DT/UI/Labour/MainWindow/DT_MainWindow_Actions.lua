DT_MainWindow = DT_MainWindow or {}
DT_MainWindow.Internal = DT_MainWindow.Internal or {}

local Internal = DT_MainWindow.Internal

function DT_MainWindow:onRefresh()
    self:updateStatus("Refreshing labour roster...")

    if isClient() and not isServer() then
        if not self:sendLabourCommand("RequestPlayerWorkers", {}) then
            self:updateStatus("Unable to request worker data.")
        end
        return
    end

    self:populateWorkerList(Internal.resolveWorkerSummaries())
    self:updateStatus("Loaded local worker data.")
end

function DT_MainWindow:onCollectOutput()
    if not self.selectedWorkerSummary then
        self:updateStatus("Select a worker first.")
        return
    end

    self:sendLabourCommand("CollectWorkerOutput", { workerID = self.selectedWorkerSummary.workerID })
    self:updateStatus("Collecting worker output...")
end

function DT_MainWindow:onToggleJob()
    if not self.selectedWorkerSummary then
        self:updateStatus("Select a worker first.")
        return
    end

    local enabled = not (self.selectedWorker and self.selectedWorker.jobEnabled)
    self:sendLabourCommand("SetWorkerJobEnabled", {
        workerID = self.selectedWorkerSummary.workerID,
        enabled = enabled
    })
    self:updateStatus(enabled and "Starting job..." or "Stopping job...")
end

function DT_MainWindow:onCycleJob()
    if not self.selectedWorkerSummary then
        self:updateStatus("Select a worker first.")
        return
    end

    local config = Internal.Config
    local currentJobType = self.selectedWorker and self.selectedWorker.jobType or self.selectedWorkerSummary.jobType
    local nextJobType = config.GetNextJobType and config.GetNextJobType(currentJobType) or currentJobType
    self:sendLabourCommand("SetWorkerJobType", {
        workerID = self.selectedWorkerSummary.workerID,
        jobType = nextJobType
    })
    self:updateStatus("Changing worker job to " .. tostring(nextJobType) .. "...")
end

function DT_MainWindow:onAssignHeldTool()
    if not self.selectedWorkerSummary then
        self:updateStatus("Select a worker first.")
        return
    end

    local config = Internal.Config
    for _, itemObj in ipairs(Internal.getHeldItems()) do
        if config.IsToolItem and config.IsToolItem(itemObj) then
            self:sendLabourCommand("AssignWorkerToolset", {
                workerID = self.selectedWorkerSummary.workerID,
                itemID = itemObj:getID()
            })
            self:updateStatus("Assigning held tool to " .. tostring(self.selectedWorkerSummary.name or self.selectedWorkerSummary.workerID) .. "...")
            return
        end
    end

    self:updateStatus("Hold a tool in your primary or secondary hand first.")
end

function DT_MainWindow:onManageSupplies()
    if not self.selectedWorkerSummary then
        self:updateStatus("Select a worker first.")
        return
    end

    DT_SupplyWindow.Open(self.selectedWorker or self.selectedWorkerSummary)
    self:updateStatus("Opening supply manager...")
end

function DT_MainWindow:onGiveMoney()
    if not self.selectedWorkerSummary then
        self:updateStatus("Select a worker first.")
        return
    end

    local config = Internal.Config
    local player = config.GetPlayerObject and config.GetPlayerObject() or getSpecificPlayer(0)
    local wealth = Internal.getPlayerWealth(player)
    if wealth <= 0 then
        self:updateStatus("You do not have any money to give.")
        return
    end

    local workerName = tostring((self.selectedWorker and self.selectedWorker.name) or self.selectedWorkerSummary.name or self.selectedWorkerSummary.workerID)
    DT_LabourQuantityModal.Open({
        title = "Give Money",
        promptText = "How much money do you want to give to " .. workerName .. "?",
        maxValue = wealth,
        defaultValue = wealth,
        onConfirm = function(quantity)
            self:sendLabourCommand("GiveWorkerMoney", {
                workerID = self.selectedWorkerSummary.workerID,
                amount = quantity
            })
            self:updateStatus("Giving $" .. tostring(quantity) .. " to " .. workerName .. "...")
        end
    })
end

function DT_MainWindow:onOpenHelp()
    DT_LabourHelpWindow.Open()
    self:updateStatus("Opened scavenging help.")
end
