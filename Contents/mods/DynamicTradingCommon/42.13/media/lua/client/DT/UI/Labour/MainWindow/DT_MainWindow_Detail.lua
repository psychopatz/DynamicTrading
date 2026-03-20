DT_MainWindow = DT_MainWindow or {}
DT_MainWindow.Internal = DT_MainWindow.Internal or {}

local Internal = DT_MainWindow.Internal

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

    if not self.detailText then
        return
    end

    if not worker then
        self.detailText:setText(" <RGB:0.6,0.6,0.6> No worker selected. Recruit one from ConversationUI or load an existing worker. ")
        self.detailText:paginate()
        if self.btnToggleJob then
            self.btnToggleJob:setTitle("Start Job")
        end
        return
    end

    local config = Internal.Config
    local profile = (config.GetJobProfile and config.GetJobProfile(worker.jobType)) or {}
    local toolTags = profile.requiredToolTags or {}
    local bonusMultiplier = config.GetJobSpeedMultiplier and config.GetJobSpeedMultiplier(worker.archetypeID, worker.jobType) or 1
    local caloriesDays = Internal.getReserveDaysLeft(worker.caloriesCached, worker.dailyCaloriesNeed)
    local hydrationDays = Internal.getReserveDaysLeft(worker.hydrationCached, worker.dailyHydrationNeed)

    local text = ""
    text = text .. " <RGB:1,1,1> <SIZE:Large> " .. tostring(worker.name or "Worker") .. " <LINE> <LINE> "
    text = text .. " <RGB:0.8,0.8,0.8> Archetype: <RGB:0.4,0.8,1> " .. tostring(worker.archetypeID or "Unknown") .. " <LINE> "
    text = text .. " <RGB:0.8,0.8,0.8> Current Job: <RGB:1,1,1> " .. tostring(worker.jobType or worker.profession or "Unknown") .. " <LINE> "
    text = text .. " <RGB:0.8,0.8,0.8> State: <RGB:1,1,1> " .. tostring(worker.state or "Idle") .. " <LINE> "
    text = text .. " <RGB:0.8,0.8,0.8> Job Enabled: <RGB:1,1,1> " .. tostring(worker.jobEnabled == true) .. " <LINE> "
    text = text .. " <RGB:0.8,0.8,0.8> Specialist Bonus: <RGB:1,1,1> x" .. string.format("%.2f", bonusMultiplier) .. " <LINE> "
    text = text .. " <RGB:0.8,0.8,0.8> Workplace: <RGB:1,1,1> TODO / deferred <LINE> "
    text = text .. " <RGB:0.8,0.8,0.8> Required Tools: <RGB:1,1,1> " .. table.concat(toolTags, ", ") .. " <LINE> "
    text = text .. " <RGB:0.8,0.8,0.8> Work Coordinates: <RGB:1,1,1> " .. tostring(worker.workX or "-") .. ", " .. tostring(worker.workY or "-") .. ", " .. tostring(worker.workZ or 0) .. " <LINE> "
    text = text .. " <RGB:0.8,0.8,0.8> Site State: <RGB:1,1,1> " .. tostring(worker.siteState or "Deferred") .. " <LINE> "
    text = text .. " <RGB:0.8,0.8,0.8> Tool State: <RGB:1,1,1> " .. tostring(worker.toolState or "Missing") .. " <LINE> <LINE> "
    text = text .. " <RGB:0.8,0.8,0.8> Calories Stored: <RGB:1,1,1> " .. Internal.formatReserveValue(worker.caloriesCached) .. " <LINE> "
    text = text .. " <RGB:0.8,0.8,0.8> Hydration Stored: <RGB:1,1,1> " .. Internal.formatReserveValue(worker.hydrationCached) .. " <LINE> "
    text = text .. " <RGB:0.8,0.8,0.8> Calories Days Left: <RGB:1,1,1> " .. caloriesDays .. " <LINE> "
    text = text .. " <RGB:0.8,0.8,0.8> Hydration Days Left: <RGB:1,1,1> " .. hydrationDays .. " <LINE> "
    text = text .. " <RGB:0.8,0.8,0.8> Fatal Threshold: <RGB:1,1,1> 3 days at zero calories or hydration <LINE> "
    text = text .. " <RGB:0.8,0.8,0.8> Nutrition Entries: <RGB:1,1,1> " .. tostring(#(worker.nutritionLedger or {})) .. " <LINE> "
    text = text .. " <RGB:0.8,0.8,0.8> Assigned Tools: <RGB:1,1,1> " .. tostring(#(worker.toolLedger or {})) .. " <LINE> "
    text = text .. " <RGB:0.8,0.8,0.8> Pending Output: <RGB:1,1,1> " .. tostring(worker.outputCount or 0) .. " <LINE> "
    text = text .. " <RGB:0.8,0.8,0.8> Stored Money: <RGB:1,1,1> $" .. tostring(math.floor(tonumber(worker.moneyStored) or 0)) .. " <LINE> "
    text = text .. " <LINE> <RGB:1,1,1> <SIZE:Medium> Foundation Inputs <LINE> "
    text = text .. " <RGB:0.8,0.8,0.8> Tool Inputs: <RGB:1,1,1> " .. Internal.buildToolInputText(worker) .. " <LINE> "
    text = text .. " <RGB:0.8,0.8,0.8> Food / Water Inputs: <RGB:1,1,1> " .. Internal.buildSupplyInputText(worker) .. " <LINE> "
    text = text .. " <RGB:0.8,0.8,0.8> Money Reserve: <RGB:1,1,1> $" .. tostring(math.floor(tonumber(worker.moneyStored) or 0)) .. " <LINE> "
    text = text .. " <RGB:0.8,0.8,0.8> Productive Consumables: <RGB:1,1,1> TODO after foundation polish <LINE> "

    self.detailText:setText(text)
    self.detailText:paginate()

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
