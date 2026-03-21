DT_MainWindow = DT_MainWindow or {}
DT_MainWindow.Internal = DT_MainWindow.Internal or {}

local Internal = DT_MainWindow.Internal
local MainWindowLayout = Internal.MainWindowLayout or {}

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
        MainWindowLayout.refreshRichTextPanel(self.detailText)
        self.activityLogText:setText(" <RGB:0.62,0.62,0.62> No recent worker activity yet. ")
        MainWindowLayout.refreshRichTextPanel(self.activityLogText)
        if self.applyDynamicLayout then
            self:applyDynamicLayout()
        end
        if self.detailText.vscroll then
            self.detailText.vscroll:setHeight(self.detailText:getHeight())
        end
        if self.detailText.setYScroll then
            self.detailText:setYScroll(0)
        end
        if self.activityLogText.vscroll then
            self.activityLogText.vscroll:setHeight(self.activityLogText:getHeight())
        end
        if self.activityLogText.setYScroll then
            self.activityLogText:setYScroll(0)
        end
        if self.btnToggleJob then
            self.btnToggleJob:setTitle("Start Job")
        end
        return
    end

    local config = Internal.Config
    local profile = (config.GetJobProfile and config.GetJobProfile(worker.jobType)) or {}
    local toolTags = profile.requiredToolTags or {}
    local bonusMultiplier = config.GetJobSpeedMultiplier and config.GetJobSpeedMultiplier(worker.archetypeID, worker.jobType) or 1
    local toolSummary = (#toolTags > 0) and table.concat(toolTags, ", ") or "None"
    local text = ""
    text = text .. " <RGB:1,1,1> <SIZE:Medium> Overview <LINE> "
    text = text .. " <RGB:0.72,0.72,0.72> Job Enabled: <RGB:1,1,1> " .. Internal.formatBool(worker.jobEnabled == true) .. " <LINE> "
    text = text .. " <RGB:0.72,0.72,0.72> Specialist Bonus: <RGB:1,1,1> x" .. Internal.formatDecimal(bonusMultiplier, 2) .. " <LINE> "
    text = text .. " <RGB:0.72,0.72,0.72> Stored Money: <RGB:1,1,1> $" .. Internal.formatReserveValue(worker.moneyStored) .. " <LINE> <LINE> "

    text = text .. " <RGB:1,1,1> <SIZE:Medium> Work Status <LINE> "
    text = text .. " <RGB:0.72,0.72,0.72> Current Job: <RGB:1,1,1> " .. Internal.getJobDisplayName(worker, profile) .. " <LINE> "
    text = text .. " <RGB:0.72,0.72,0.72> Site State: <RGB:1,1,1> " .. tostring(worker.siteState or "Deferred") .. " <LINE> "
    text = text .. " <RGB:0.72,0.72,0.72> Tool State: <RGB:1,1,1> " .. tostring(worker.toolState or "Missing") .. " <LINE> "
    text = text .. " <RGB:0.72,0.72,0.72> Required Tools: <RGB:1,1,1> " .. toolSummary .. " <LINE> "
    text = text .. " <RGB:0.72,0.72,0.72> Work Coordinates: <RGB:1,1,1> " .. Internal.formatCoords(worker.workX, worker.workY, worker.workZ) .. " <LINE> "
    text = text .. " <RGB:0.72,0.72,0.72> Pending Output: <RGB:1,1,1> " .. tostring(worker.outputCount or 0) .. " <LINE> "

    self.detailText:setText(text)
    MainWindowLayout.refreshRichTextPanel(self.detailText)
    self.activityLogText:setText(buildActivityLogText(worker))
    MainWindowLayout.refreshRichTextPanel(self.activityLogText)
    if self.applyDynamicLayout then
        self:applyDynamicLayout()
    end
    if self.detailText.vscroll then
        self.detailText.vscroll:setHeight(self.detailText:getHeight())
    end
    if self.detailText.setYScroll then
        self.detailText:setYScroll(0)
    end
    if self.activityLogText.vscroll then
        self.activityLogText.vscroll:setHeight(self.activityLogText:getHeight())
    end
    if self.activityLogText.setYScroll then
        self.activityLogText:setYScroll(0)
    end

    if self.btnToggleJob then
        self.btnToggleJob:setTitle(worker.jobEnabled and "Stop Job" or "Start Job")
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
