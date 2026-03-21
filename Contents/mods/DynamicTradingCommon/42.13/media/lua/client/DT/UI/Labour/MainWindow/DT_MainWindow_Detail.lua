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

    if self.reservePanel and self.reservePanel.setWorker then
        self.reservePanel:setWorker(worker)
    end

    if not self.detailText then
        return
    end

    if not worker then
        self.detailText:setText(" <RGB:0.6,0.6,0.6> No worker selected. Recruit one from ConversationUI or pick an existing labour worker from the list. ")
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
    local dailyCaloriesNeed = config.GetEffectiveDailyCaloriesNeed and config.GetEffectiveDailyCaloriesNeed(worker, profile)
        or tonumber(worker.dailyCaloriesNeed)
        or tonumber(profile.dailyCaloriesNeed)
        or 0
    local dailyHydrationNeed = config.GetEffectiveDailyHydrationNeed and config.GetEffectiveDailyHydrationNeed(worker, profile)
        or tonumber(worker.dailyHydrationNeed)
        or tonumber(profile.dailyHydrationNeed)
        or 0
    local caloriesDays = Internal.getReserveDaysLeft(worker.caloriesCached, dailyCaloriesNeed)
    local hydrationDays = Internal.getReserveDaysLeft(worker.hydrationCached, dailyHydrationNeed)
    local caloriesHoursLeft = Internal.getReserveHoursLeft(worker.caloriesCached, (dailyCaloriesNeed / (config.HOURS_PER_DAY or 24)))
    local hydrationHoursLeft = Internal.getReserveHoursLeft(worker.hydrationCached, (dailyHydrationNeed / (config.HOURS_PER_DAY or 24)))
    local refillHoursLeft = Internal.getNextRefillHours(caloriesHoursLeft, hydrationHoursLeft)
    local caloriesBarData = Internal.getReserveBarData(worker.caloriesCached, dailyCaloriesNeed)
    local hydrationBarData = Internal.getReserveBarData(worker.hydrationCached, dailyHydrationNeed)
    local toolSummary = (#toolTags > 0) and table.concat(toolTags, ", ") or "None"
    local caloriesForecast = (worker.state == config.States.Dead) and "Already dead" or Internal.formatDaysAndEta(caloriesDays, caloriesHoursLeft)
    local hydrationForecast = (worker.state == config.States.Dead) and "Already dead" or Internal.formatDaysAndEta(hydrationDays, hydrationHoursLeft)
    local refillForecast = (worker.state == config.States.Dead) and "Already dead" or Internal.formatDurationHours(refillHoursLeft)

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
    text = text .. " <RGB:0.72,0.72,0.72> Pending Output: <RGB:1,1,1> " .. tostring(worker.outputCount or 0) .. " <LINE> <LINE> "

    text = text .. " <RGB:1,1,1> <SIZE:Medium> Survival Forecast <LINE> "
    text = text .. " <RGB:0.72,0.72,0.72> Calories Stored: <RGB:1,1,1> " .. Internal.formatReserveValue(worker.caloriesCached) .. " <LINE> "
    text = text .. " <RGB:0.72,0.72,0.72> Daily Hunger Use: <RGB:1,1,1> " .. Internal.formatReserveValue(dailyCaloriesNeed) .. "/day <LINE> "
    text = text .. " <RGB:0.72,0.72,0.72> Calories Overflow: <RGB:1,1,1> " .. Internal.formatReserveValue(caloriesBarData.overflow) .. " <LINE> "
    text = text .. " <RGB:0.72,0.72,0.72> Days Until Starving: <RGB:1,1,1> " .. caloriesForecast .. " <LINE> "
    text = text .. " <RGB:0.72,0.72,0.72> Hydration Stored: <RGB:1,1,1> " .. Internal.formatReserveValue(worker.hydrationCached) .. " <LINE> "
    text = text .. " <RGB:0.72,0.72,0.72> Daily Hydration Use: <RGB:1,1,1> " .. Internal.formatReserveValue(dailyHydrationNeed) .. "/day <LINE> "
    text = text .. " <RGB:0.72,0.72,0.72> Hydration Overflow: <RGB:1,1,1> " .. Internal.formatReserveValue(hydrationBarData.overflow) .. " <LINE> "
    text = text .. " <RGB:0.72,0.72,0.72> Days Until Dehydrated: <RGB:1,1,1> " .. hydrationForecast .. " <LINE> "
    text = text .. " <RGB:0.72,0.72,0.72> Suggested Refill In: <RGB:1,1,1> " .. refillForecast .. " <LINE> "
    text = text .. " <RGB:0.72,0.72,0.72> Consumption Cadence: <RGB:1,1,1> Every in-game hour <LINE> "
    text = text .. " <RGB:0.72,0.72,0.72> Fatal Threshold: <RGB:1,1,1> 3 days at zero calories or hydration <LINE> "
    if (tonumber(worker.starvationHours) or 0) > 0 then
        text = text .. " <RGB:0.72,0.72,0.72> Starvation Counter: <RGB:1,1,1> " .. Internal.formatDurationHours(worker.starvationHours) .. " <LINE> "
    end
    if (tonumber(worker.dehydrationHours) or 0) > 0 then
        text = text .. " <RGB:0.72,0.72,0.72> Dehydration Counter: <RGB:1,1,1> " .. Internal.formatDurationHours(worker.dehydrationHours) .. " <LINE> "
    end
    text = text .. " <LINE> <RGB:1,1,1> <SIZE:Medium> Inputs And Storage <LINE> "
    text = text .. " <RGB:0.72,0.72,0.72> Nutrition Entries: <RGB:1,1,1> " .. tostring(#(worker.nutritionLedger or {})) .. " <LINE> "
    text = text .. " <RGB:0.72,0.72,0.72> Assigned Tools: <RGB:1,1,1> " .. tostring(#(worker.toolLedger or {})) .. " <LINE> "
    text = text .. " <RGB:0.72,0.72,0.72> Tool Inputs: <RGB:1,1,1> " .. Internal.buildToolInputText(worker) .. " <LINE> "
    text = text .. " <RGB:0.72,0.72,0.72> Food / Water Inputs: <RGB:1,1,1> " .. Internal.buildSupplyInputText(worker) .. " <LINE> "
    text = text .. " <RGB:0.72,0.72,0.72> Productive Consumables: <RGB:1,1,1> TODO after foundation polish <LINE> "

    self.detailText:setText(text)
    self.detailText:paginate()
    if self.detailText.vscroll then
        self.detailText.vscroll:setHeight(self.detailText:getHeight())
    end
    if self.detailText.setYScroll then
        self.detailText:setYScroll(0)
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
