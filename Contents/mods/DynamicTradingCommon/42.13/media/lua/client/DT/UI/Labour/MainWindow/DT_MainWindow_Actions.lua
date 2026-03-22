DT_MainWindow = DT_MainWindow or {}
DT_MainWindow.Internal = DT_MainWindow.Internal or {}

local Internal = DT_MainWindow.Internal

local function getSelectedWorkerForAction(window)
    return window.selectedWorker or window.selectedWorkerSummary or nil
end

local function updateToggleJobStatus(window, enabled, normalizedJob, presenceState)
    local config = Internal.Config or {}

    if normalizedJob == ((config.JobTypes or {}).Scavenge) then
        window:updateStatus(
            enabled and "Sending worker out from home..."
                or ((presenceState and presenceState ~= ((config.PresenceStates or {}).Home))
                    and "Calling worker home..."
                    or "Cancelling the scavenging trip...")
        )
        return
    end

    window:updateStatus(enabled and "Starting job..." or "Stopping job...")
end

local function sendToggleJobCommand(window, enabled, normalizedJob, presenceState)
    window:sendLabourCommand("SetWorkerJobEnabled", {
        workerID = window.selectedWorkerSummary.workerID,
        enabled = enabled
    })

    updateToggleJobStatus(window, enabled, normalizedJob, presenceState)
end

local function getScavengeProvisionWarningText(window)
    local worker = getSelectedWorkerForAction(window)
    local config = Internal.Config or {}
    local profile = config.GetJobProfile and config.GetJobProfile(worker and worker.jobType) or {}
    local workerName = tostring((worker and worker.name) or (window.selectedWorkerSummary and window.selectedWorkerSummary.name) or "this worker")
    local provisionCalories = math.max(0, tonumber(worker and (worker.provisionCaloriesReserve or worker.storedCalories)) or 0)
    local provisionHydration = math.max(0, tonumber(worker and (worker.provisionHydrationReserve or worker.storedHydration)) or 0)
    local totalCalories = math.max(0, tonumber(worker and (worker.combinedCaloriesTotal or worker.totalCaloriesAvailable or worker.storedCalories)) or 0)
    local totalHydration = math.max(0, tonumber(worker and (worker.combinedHydrationTotal or worker.totalHydrationAvailable or worker.storedHydration)) or 0)
    local dailyCaloriesNeed = math.max(0, tonumber(profile and profile.dailyCaloriesNeed) or 0)
    local dailyHydrationNeed = math.max(0, tonumber(profile and profile.dailyHydrationNeed) or 0)
    local calorieDays = Internal.getReserveDaysLeft and Internal.getReserveDaysLeft(totalCalories, dailyCaloriesNeed) or nil
    local hydrationDays = Internal.getReserveDaysLeft and Internal.getReserveDaysLeft(totalHydration, dailyHydrationNeed) or nil
    local lowestDays = nil

    if calorieDays and hydrationDays then
        lowestDays = math.min(calorieDays, hydrationDays)
    else
        lowestDays = calorieDays or hydrationDays
    end

    local warningLine = "Make sure they have enough food and water before leaving."
    if provisionCalories <= 0 and provisionHydration <= 0 then
        warningLine = "This worker has no stored provisions and may turn back quickly."
    elseif lowestDays and lowestDays < 1 then
        warningLine = "This worker has less than one day of total reserves and may return early."
    end

    return "Start scavenging run for " .. workerName .. "?\n\n"
        .. "Be sure to give the NPC provisions first. Scavengers can head back home when calories or hydration run low.\n\n"
        .. "Stored provisions:\n"
        .. "Calories: " .. Internal.formatReserveValue(provisionCalories)
        .. "\nHydration: " .. Internal.formatReserveValue(provisionHydration)
        .. "\n\nTotal reserve:\n"
        .. "Calories: " .. Internal.formatReserveValue(totalCalories)
        .. "\nHydration: " .. Internal.formatReserveValue(totalHydration)
        .. "\n\n"
        .. warningLine
        .. "\n\nPress Yes to start anyway, or No to provision them first."
end

local function openScavengeStartConfirmation(window, enabled, normalizedJob, presenceState)
    local text = getScavengeProvisionWarningText(window)

    local function onConfirm(_, button)
        if button and button.internal == "YES" then
            sendToggleJobCommand(window, enabled, normalizedJob, presenceState)
        else
            window:updateStatus("Scavenging start cancelled. Add provisions first if needed.")
        end
    end

    local modal = ISModalDialog:new(0, 0, 420, 260, text, true, nil, onConfirm, nil)
    modal:initialise()
    modal:addToUIManager()
end

local function getStopJobConfirmationText(window, normalizedJob, presenceState)
    local worker = getSelectedWorkerForAction(window)
    local config = Internal.Config or {}
    local workerName = tostring((worker and worker.name) or (window.selectedWorkerSummary and window.selectedWorkerSummary.name) or "this worker")
    local homeState = tostring((config.PresenceStates or {}).Home or "Home")

    if normalizedJob == ((config.JobTypes or {}).Scavenge) then
        if tostring(presenceState or "") ~= homeState then
            return "Call " .. workerName .. " back home?\n\n"
                .. "They will stop the current scavenging trip and return instead of continuing the run.\n\n"
                .. "Press Yes to recall them, or No to keep them scavenging."
        end

        return "Cancel the scavenging job for " .. workerName .. "?\n\n"
            .. "This prevents them from heading out until you start the job again.\n\n"
            .. "Press Yes to cancel, or No to keep the job active."
    end

    return "Stop the current job for " .. workerName .. "?\n\n"
        .. "Press Yes to stop working, or No to leave the job running."
end

local function openStopJobConfirmation(window, enabled, normalizedJob, presenceState)
    local text = getStopJobConfirmationText(window, normalizedJob, presenceState)

    local function onConfirm(_, button)
        if button and button.internal == "YES" then
            sendToggleJobCommand(window, enabled, normalizedJob, presenceState)
        else
            window:updateStatus("Job stop cancelled.")
        end
    end

    local modal = ISModalDialog:new(0, 0, 400, 200, text, true, nil, onConfirm, nil)
    modal:initialise()
    modal:addToUIManager()
end

function DT_MainWindow:onRefresh()
    self:updateStatus("Refreshing labour roster...")

    if isClient() and not isServer() then
        if not self:sendLabourCommand("RequestPlayerWorkers", {}) then
            self:updateStatus("Unable to request worker data.")
        end
        if DT_System and DT_System.RequestOwnedFactionStatus then
            DT_System.RequestOwnedFactionStatus()
        end
        return
    end

    self:populateWorkerList(Internal.resolveWorkerSummaries())
    if DynamicTrading_Factions and DynamicTrading_Factions.GetOwnedFactionStatus then
        DT_MainWindow.cachedOwnedFactionStatus = DynamicTrading_Factions.GetOwnedFactionStatus(Internal.getOwnerUsername())
        if DT_System then
            DT_System.ownedFactionStatusCache = DT_MainWindow.cachedOwnedFactionStatus
        end
    end
    if self.updateFactionButton then
        self:updateFactionButton()
    end
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

    if enabled and normalizedJob == ((config.JobTypes or {}).Scavenge) then
        openScavengeStartConfirmation(self, enabled, normalizedJob, presenceState)
        return
    end

    if not enabled then
        openStopJobConfirmation(self, enabled, normalizedJob, presenceState)
        return
    end

    sendToggleJobCommand(self, enabled, normalizedJob, presenceState)
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

function DT_MainWindow:onOpenInventory()
    if not self.selectedWorkerSummary then
        self:updateStatus("Select a worker first.")
        return
    end

    DT_SupplyWindow.Open(self.selectedWorker or self.selectedWorkerSummary, "inventory")
    self:updateStatus("Opening NPC inventory...")
end

function DT_MainWindow:onOpenWarehouse()
    if not self.selectedWorkerSummary then
        self:updateStatus("Select a worker first.")
        return
    end

    DT_SupplyWindow.Open(self.selectedWorker or self.selectedWorkerSummary, "warehouse")
    self:updateStatus("Opening warehouse...")
end

function DT_MainWindow:onOpenHelp()
    DT_LabourHelpWindow.Open()
    self:updateStatus("Opened scavenging help.")
end

function DT_MainWindow:updateFactionButton()
    if not self.btnFaction then
        return
    end

    local status = (DT_System and DT_System.GetOwnedFactionStatus and DT_System.GetOwnedFactionStatus()) or DT_MainWindow.cachedOwnedFactionStatus
    if status and status.faction then
        self.btnFaction:setTitle("Open Faction")
        self.btnFaction:setEnable(true)
        return
    end

    if status and status.canCreate == true then
        self.btnFaction:setTitle("Create Faction")
        self.btnFaction:setEnable(true)
        return
    end

    self.btnFaction:setTitle("Faction Locked")
    self.btnFaction:setEnable(false)
end

function DT_MainWindow:onOpenFaction()
    if not DT_System or not DT_System.OpenOwnedFactionManagement then
        self:updateStatus("Faction management is unavailable.")
        return
    end

    local ok, msg = DT_System.OpenOwnedFactionManagement()
    if msg and msg ~= "" then
        self:updateStatus(msg)
    elseif ok then
        self:updateStatus("Opening faction management...")
    end
end
