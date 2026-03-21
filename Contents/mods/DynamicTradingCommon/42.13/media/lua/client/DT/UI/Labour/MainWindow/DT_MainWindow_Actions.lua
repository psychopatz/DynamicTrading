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

function DT_MainWindow:onToggleJob()
    if not self.selectedWorkerSummary then
        self:updateStatus("Select a worker first.")
        return
    end

    local config = Internal.Config or {}
    local state = tostring((self.selectedWorker and self.selectedWorker.state) or self.selectedWorkerSummary.state or "")
    if state == tostring((config.States or {}).Dead or "Dead") then
        self:sendLabourCommand("DeleteDeadWorker", {
            workerID = self.selectedWorkerSummary.workerID
        })
        self:updateStatus("Removing deceased worker record...")
        return
    end

    local normalizedJob = config.NormalizeJobType and config.NormalizeJobType((self.selectedWorker and self.selectedWorker.jobType) or self.selectedWorkerSummary.jobType) or tostring((self.selectedWorker and self.selectedWorker.jobType) or self.selectedWorkerSummary.jobType or "")
    local presenceState = (self.selectedWorker and self.selectedWorker.presenceState) or self.selectedWorkerSummary.presenceState or nil
    local currentEnabled = self.selectedWorker and self.selectedWorker.jobEnabled
    if currentEnabled == nil then
        currentEnabled = self.selectedWorkerSummary.jobEnabled == true
    end
    local enabled = not currentEnabled
    self:sendLabourCommand("SetWorkerJobEnabled", {
        workerID = self.selectedWorkerSummary.workerID,
        enabled = enabled
    })
    if normalizedJob == ((config.JobTypes or {}).Scavenge) then
        self:updateStatus(
            enabled and "Sending worker out from home..."
                or ((presenceState and presenceState ~= ((config.PresenceStates or {}).Home))
                    and "Calling worker home..."
                    or "Cancelling the scavenging trip...")
        )
        return
    end
    self:updateStatus(enabled and "Starting job..." or "Stopping job...")
end

function DT_MainWindow:onCycleJob()
    if not self.selectedWorkerSummary then
        self:updateStatus("Select a worker first.")
        return
    end

    local config = Internal.Config
    local worker = self.selectedWorker or self.selectedWorkerSummary
    local workerID = self.selectedWorkerSummary.workerID
    local currentJobType = worker and worker.jobType or self.selectedWorkerSummary.jobType
    local normalizedJobType = config.NormalizeJobType and config.NormalizeJobType(currentJobType) or tostring(currentJobType or "")
    local workerName = tostring((worker and worker.name) or self.selectedWorkerSummary.name or self.selectedWorkerSummary.workerID)

    local modal = DT_LabourJobModal.Open({
        title = "Change Job",
        promptText = "Choose a new job for " .. workerName .. ".",
        selectedJobType = normalizedJobType,
        onConfirm = function(jobType, option)
            local selectedJobType = config.NormalizeJobType and config.NormalizeJobType(jobType) or tostring(jobType or "")
            if selectedJobType == normalizedJobType then
                self:updateStatus(workerName .. " is already assigned to " .. tostring(option and option.label or selectedJobType) .. ".")
                return
            end

            self:sendLabourCommand("SetWorkerJobType", {
                workerID = workerID,
                jobType = selectedJobType
            })
            self:updateStatus("Changing worker job to " .. tostring(option and option.label or selectedJobType) .. "...")
        end
    })

    if not modal then
        self:updateStatus("No labour jobs are currently available.")
    end
end

function DT_MainWindow:onManageSupplies()
    if not self.selectedWorkerSummary then
        self:updateStatus("Select a worker first.")
        return
    end

    DT_SupplyWindow.Open(self.selectedWorker or self.selectedWorkerSummary)
    self:updateStatus("Opening supply manager...")
end

function DT_MainWindow:onOpenHelp()
    DT_LabourHelpWindow.Open()
    self:updateStatus("Opened scavenging help.")
end
