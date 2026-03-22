DT_MainWindow = DT_MainWindow or {}
DT_MainWindow.Internal = DT_MainWindow.Internal or {}

local Internal = DT_MainWindow.Internal
local MainWindowLayout = Internal.MainWindowLayout or {}

local SCAVENGE_CAPABILITY_LABELS = {
    ["Scavenge.Access.LockedHome"] = "Locked homes",
    ["Scavenge.Access.ElectronicStore"] = "Electronics stores",
    ["Scavenge.Access.HeavyEntry"] = "Secure shutters and vaults",
    ["Scavenge.Extraction.CarpentryHammer"] = "Carpentry hammer",
    ["Scavenge.Extraction.CarpentrySaw"] = "Carpentry saw",
    ["Scavenge.Extraction.Plumbing"] = "Plumbing salvage",
    ["Scavenge.Extraction.MetalTorch"] = "Metal torch",
    ["Scavenge.Extraction.MetalMask"] = "Welding mask",
    ["Scavenge.Haul.Bag"] = "Hauling bag",
    ["Scavenge.Haul.Bulk"] = "Bulk loose loot",
    ["Scavenge.Haul.Bundle"] = "Bundle heavy items",
    ["Scavenge.Utility.Light"] = "Interior lighting",
    ["Scavenge.Utility.Map"] = "Route map",
    ["Scavenge.Utility.Pen"] = "Route notes"
}

local function getScavengeCapabilitySummary(worker)
    local names = {}
    local seen = {}

    for _, capability in ipairs(worker and worker.scavengeCapabilities or {}) do
        local label = SCAVENGE_CAPABILITY_LABELS[capability] or tostring(capability)
        if not seen[label] then
            seen[label] = true
            names[#names + 1] = label
        end
    end

    if #names <= 0 then
        return "Open containers only"
    end

    return table.concat(names, ", ")
end

local function getScavengePresenceDetailLabel(worker)
    local config = Internal.Config or {}
    local presenceState = tostring(worker and worker.presenceState or (config.PresenceStates and config.PresenceStates.Home) or "Home")
    local states = config.PresenceStates or {}
    if presenceState == states.AwayToSite then
        return "Away To Site"
    end
    if presenceState == states.AwayToHome then
        return "Away To Home"
    end
    if presenceState == states.Scavenging then
        return "Scavenging"
    end
    return "Home"
end

local function getReturnReasonLabel(worker)
    local config = Internal.Config or {}
    local reason = tostring(worker and worker.returnReason or "")
    local reasons = config.ReturnReasons or {}
    if reason == reasons.FullHaul then
        return "Backpack Full"
    end
    if reason == reasons.LowFood then
        return "Low Food"
    end
    if reason == reasons.LowDrink then
        return "Low Drink"
    end
    if reason == reasons.MissingTool then
        return "Missing Tool"
    end
    if reason == reasons.MissingSite then
        return "Missing Site"
    end
    if reason == reasons.Manual then
        return "Manual Recall"
    end
    return "None"
end

local function buildActivityLogText(worker)
    local entries = worker and worker.activityLog or {}
    if not entries or #entries <= 0 then
        return " <RGB:0.62,0.62,0.62> No recent worker activity yet. <LINE> "
    end

    local text = ""
    for index = #entries, 1, -1 do
        local entry = entries[index]
        local timestamp = Internal.formatActivityTimestamp(entry and entry.hour)
        local message = tostring((entry and (entry.text or entry.message)) or "Activity recorded.")
        text = text
            .. " <RGB:0.62,0.62,0.62> ["
            .. timestamp
            .. "] <RGB:0.9,0.9,0.9> "
            .. message
            .. " <LINE> "
    end

    return text
end

function DT_MainWindow:populateWorkerList(workers)
    if not self.workerList then
        return
    end

    self.workerList:clear()

    local preferredID = self.selectedWorkerSummary and self.selectedWorkerSummary.workerID or nil
    local selectedIndex = nil

    for _, worker in ipairs(workers or {}) do
        self.workerList:addItem(worker.name or worker.workerID, worker)
        if preferredID and preferredID == worker.workerID then
            selectedIndex = #self.workerList.items
        end
    end

    if self.workerList.items and #self.workerList.items > 0 then
        local targetIndex = selectedIndex or 1
        self.workerList.selected = targetIndex
        self:applyWorkerSelection(self.workerList.items[targetIndex].item, false)
    else
        self.selectedWorkerSummary = nil
        self.selectedWorker = nil
        self:updateWorkerDetail(nil)
    end
end

function DT_MainWindow:updateWorkerDetail(worker)
    local previousWorkerID = self.selectedWorker and self.selectedWorker.workerID or nil
    local nextWorkerID = worker and worker.workerID or nil
    local shouldResetScroll = previousWorkerID ~= nextWorkerID

    self.selectedWorker = worker

    if self.reservePanel and self.reservePanel.setWorker then
        self.reservePanel:setWorker(worker)
    end

    if not self.detailText or not self.activityLogText then
        return
    end

    if self.applyDynamicLayout then
        self:applyDynamicLayout()
    end

    if not worker then
        self.detailText:setText(" <RGB:0.6,0.6,0.6> No worker selected. Recruit one from ConversationUI or pick an existing labour worker from the list. ")
        MainWindowLayout.refreshRichTextPanel(self.detailText, 0)
        self.activityLogText:setText(" <RGB:0.62,0.62,0.62> No recent worker activity yet. ")
        MainWindowLayout.refreshRichTextPanel(self.activityLogText, 0)
        if self.applyDynamicLayout then
            self:applyDynamicLayout()
        end
        if self.btnToggleJob then
            self.btnToggleJob:setTitle("Start Job")
            if MainWindowLayout.applyToggleButtonStyle then
                MainWindowLayout.applyToggleButtonStyle(self.btnToggleJob, false)
            end
        end
        if self.btnCycleJob then
            self.btnCycleJob:setEnable(false)
        end
        if self.btnManageSupplies then
            self.btnManageSupplies:setEnable(false)
        end
        return
    end

    local config = Internal.Config
    local profile = (config.GetJobProfile and config.GetJobProfile(worker.jobType)) or {}
    local toolTags = profile.requiredToolTags or {}
    local bonusMultiplier = config.GetJobSpeedMultiplier and config.GetJobSpeedMultiplier(worker.archetypeID, worker.jobType) or 1
    local normalizedJobType = config.NormalizeJobType and config.NormalizeJobType(worker.jobType) or worker.jobType
    local stateLabel = tostring(worker.state or "")
    local deadState = tostring((config.States or {}).Dead or "Dead")
    local workProgressData = Internal.getWorkerProgressData and Internal.getWorkerProgressData(worker, profile) or nil
    local toolSummary = (#toolTags > 0) and table.concat(toolTags, ", ")
        or ((normalizedJobType == (config.JobTypes and config.JobTypes.Scavenge)) and "Optional scavenger kit" or "Optional")
    local text = ""
    text = text .. " <RGB:1,1,1> <SIZE:Medium> Overview <LINE> "
    text = text .. " <RGB:0.72,0.72,0.72> Job Enabled: <RGB:1,1,1> " .. Internal.formatBool(worker.jobEnabled == true) .. " <LINE> "
    text = text .. " <RGB:0.72,0.72,0.72> Specialist Bonus: <RGB:1,1,1> x" .. Internal.formatDecimal(bonusMultiplier, 2) .. " <LINE> "
    text = text .. " <RGB:0.72,0.72,0.72> Stored Money: <RGB:1,1,1> $" .. Internal.formatReserveValue(worker.moneyStored) .. " <LINE> <LINE> "

    if stateLabel == deadState and tostring(worker.deathCause or "") ~= "" then
        text = text .. " <RGB:0.88,0.52,0.52> Cause Of Death: <RGB:1,1,1> " .. tostring(worker.deathCause) .. " <LINE> <LINE> "
    end

    text = text .. " <RGB:1,1,1> <SIZE:Medium> Work Status <LINE> "
    text = text .. " <RGB:0.72,0.72,0.72> Current Job: <RGB:1,1,1> " .. Internal.getJobDisplayName(worker, profile) .. " <LINE> "
    if normalizedJobType == (config.JobTypes and config.JobTypes.Scavenge) then
        text = text .. " <RGB:0.72,0.72,0.72> Location State: <RGB:1,1,1> " .. getScavengePresenceDetailLabel(worker) .. " <LINE> "
        text = text .. " <RGB:0.72,0.72,0.72> Travel ETA: <RGB:1,1,1> " .. Internal.formatDecimal(worker.travelHoursRemaining or 0, 2) .. "h <LINE> "
        text = text .. " <RGB:0.72,0.72,0.72> Return Reason: <RGB:1,1,1> " .. getReturnReasonLabel(worker) .. " <LINE> "
        text = text .. " <RGB:0.72,0.72,0.72> Home Coordinates: <RGB:1,1,1> " .. Internal.formatCoords(worker.homeX, worker.homeY, worker.homeZ) .. " <LINE> "
    end
    text = text .. " <RGB:0.72,0.72,0.72> Site State: <RGB:1,1,1> " .. tostring(worker.siteState or "Deferred") .. " <LINE> "
    text = text .. " <RGB:0.72,0.72,0.72> Tool State: <RGB:1,1,1> " .. tostring(worker.toolState or "Missing") .. " <LINE> "
    text = text .. " <RGB:0.72,0.72,0.72> Required Tools: <RGB:1,1,1> " .. toolSummary .. " <LINE> "
    text = text .. " <RGB:0.72,0.72,0.72> Work Coordinates: <RGB:1,1,1> " .. Internal.formatCoords(worker.workX, worker.workY, worker.workZ) .. " <LINE> "
    text = text .. " <RGB:0.72,0.72,0.72> Pending Output: <RGB:1,1,1> " .. tostring(worker.outputCount or 0) .. " <LINE> "
    if workProgressData then
        text = text .. " <RGB:0.72,0.72,0.72> Current Activity: <RGB:1,1,1> " .. tostring(workProgressData.displayText or workProgressData.label or "Working") .. " <LINE> "
        text = text .. " <RGB:0.72,0.72,0.72> Activity Progress: <RGB:1,1,1> "
            .. Internal.formatDecimal(workProgressData.progressHours or 0, 1)
            .. " / "
            .. Internal.formatDecimal(workProgressData.cycleHours or 0, 1)
            .. "h <LINE> "
        text = text .. " <RGB:0.72,0.72,0.72> Activity ETA: <RGB:1,1,1> "
            .. Internal.formatDurationHours(workProgressData.remainingWorldHours)
            .. " <LINE> "
    end

    if normalizedJobType == (config.JobTypes and config.JobTypes.Scavenge) then
        text = text .. " <LINE> <RGB:1,1,1> <SIZE:Medium> Scavenge Profile <LINE> "
        text = text .. " <RGB:0.72,0.72,0.72> Tier: <RGB:1,1,1> " .. tostring(worker.scavengeTierLabel or "Tier 0 - Open Containers") .. " <LINE> "
        text = text .. " <RGB:0.72,0.72,0.72> Site Profile: <RGB:1,1,1> " .. tostring(worker.scavengeSiteProfileLabel or "Unsorted Location") .. " <LINE> "
        text = text .. " <RGB:0.72,0.72,0.72> Room Context: <RGB:1,1,1> " .. tostring(worker.scavengeSiteRoomName or "Unknown") .. " <LINE> "
        text = text .. " <RGB:0.72,0.72,0.72> Zone Context: <RGB:1,1,1> " .. tostring(worker.scavengeSiteZoneType or "Unknown") .. " <LINE> "
        text = text .. " <RGB:0.72,0.72,0.72> Loot Rolls: <RGB:1,1,1> " .. tostring(worker.scavengePoolRolls or 0) .. " <LINE> "
        text = text .. " <RGB:0.72,0.72,0.72> Failure Weight: <RGB:1,1,1> " .. tostring(worker.scavengeFailureWeight or 0) .. " <LINE> "
        text = text .. " <RGB:0.72,0.72,0.72> Gear Search Speed: <RGB:1,1,1> x" .. Internal.formatDecimal(worker.scavengeSearchSpeedMultiplier or 1, 2) .. " <LINE> "
        if workProgressData and workProgressData.effectiveSpeedMultiplier then
            text = text .. " <RGB:0.72,0.72,0.72> Speed Breakdown: <RGB:1,1,1> Base x"
                .. Internal.formatDecimal(workProgressData.baseSpeedMultiplier or 1, 2)
                .. " | Archetype x"
                .. Internal.formatDecimal(workProgressData.archetypeSpeedMultiplier or 1, 2)
                .. " | Gear x"
                .. Internal.formatDecimal(workProgressData.equipmentSpeedMultiplier or 1, 2)
                .. " | Effective x"
                .. Internal.formatDecimal(workProgressData.effectiveSpeedMultiplier or 1, 2)
                .. " <LINE> "
        end
        text = text .. " <RGB:0.72,0.72,0.72> Carry Load (Raw): <RGB:1,1,1> "
            .. Internal.formatDecimal(worker.haulRawWeight or 0, 2)
            .. " / "
            .. Internal.formatDecimal(worker.maxCarryWeight or 0, 2)
            .. " <LINE> "
        text = text .. " <RGB:0.72,0.72,0.72> Base Carry Limit: <RGB:1,1,1> " .. Internal.formatDecimal(worker.baseCarryWeight or worker.maxCarryWeight or 0, 2) .. " <LINE> "
        text = text .. " <RGB:0.72,0.72,0.72> Effective Burden: <RGB:1,1,1> "
            .. Internal.formatDecimal(worker.haulEffectiveWeight or 0, 2)
            .. " / "
            .. Internal.formatDecimal(worker.effectiveCarryLimit or worker.baseCarryWeight or 0, 2)
            .. " <LINE> "
        text = text .. " <RGB:0.72,0.72,0.72> Raw Carry Allowance: <RGB:1,1,1> " .. Internal.formatDecimal(worker.rawCarryAllowance or worker.maxCarryWeight or 0, 2) .. " <LINE> "
        text = text .. " <RGB:0.72,0.72,0.72> Carry Containers: <RGB:1,1,1> " .. tostring(worker.carryContainerCount or 0) .. " <LINE> "
        text = text .. " <RGB:0.72,0.72,0.72> Completed Runs: <RGB:1,1,1> " .. tostring(worker.dumpTrips or 0) .. " <LINE> "
        text = text .. " <RGB:0.72,0.72,0.72> Stored Haul Weight: <RGB:1,1,1> " .. Internal.formatDecimal(worker.outputWeight or 0, 2) .. " <LINE> "
        text = text .. " <RGB:0.72,0.72,0.72> Unlocked Pools: <RGB:1,1,1> " .. getScavengeCapabilitySummary(worker) .. " <LINE> "
    end

    self.detailText:setText(text)
    MainWindowLayout.refreshRichTextPanel(self.detailText, shouldResetScroll and 0 or nil)
    self.activityLogText:setText(buildActivityLogText(worker))
    MainWindowLayout.refreshRichTextPanel(self.activityLogText, shouldResetScroll and 0 or nil)
    if self.applyDynamicLayout then
        self:applyDynamicLayout()
    end

    if self.btnToggleJob then
        if stateLabel == deadState then
            self.btnToggleJob:setTitle("Bury Person")
            if MainWindowLayout.applyToggleButtonStyle then
                MainWindowLayout.applyToggleButtonStyle(self.btnToggleJob, true)
            end
        elseif normalizedJobType == (config.JobTypes and config.JobTypes.Scavenge) then
            local presenceState = tostring(worker.presenceState or "")
            local homeState = tostring((config.PresenceStates or {}).Home or "Home")
            if worker.jobEnabled and presenceState ~= homeState then
                self.btnToggleJob:setTitle("Return Home")
            elseif worker.jobEnabled then
                self.btnToggleJob:setTitle("Cancel Job")
            else
                self.btnToggleJob:setTitle("Start Job")
            end
            if MainWindowLayout.applyToggleButtonStyle then
                MainWindowLayout.applyToggleButtonStyle(self.btnToggleJob, worker.jobEnabled == true)
            end
        else
            self.btnToggleJob:setTitle(worker.jobEnabled and "Stop Job" or "Start Job")
            if MainWindowLayout.applyToggleButtonStyle then
                MainWindowLayout.applyToggleButtonStyle(self.btnToggleJob, worker.jobEnabled == true)
            end
        end
    end

    if self.btnCycleJob then
        self.btnCycleJob:setEnable(stateLabel ~= deadState)
    end

    if self.btnManageSupplies then
        self.btnManageSupplies:setEnable(true)
    end
end

function DT_MainWindow:applyWorkerSelection(summary, requestDetail)
    if not summary then
        return
    end

    self.selectedWorkerSummary = summary

    local detail = Internal.resolveWorkerDetail(summary.workerID) or summary
    self:updateWorkerDetail(detail)

    if requestDetail and isClient() and not isServer() then
        self:updateStatus("Requesting worker details for " .. tostring(summary.name or summary.workerID) .. "...")
        self:sendLabourCommand("RequestWorkerDetails", { workerID = summary.workerID })
    end
end
