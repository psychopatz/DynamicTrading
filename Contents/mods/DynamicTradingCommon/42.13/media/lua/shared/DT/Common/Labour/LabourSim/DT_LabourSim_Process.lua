local Config = DT_Labour.Config
local Registry = DT_Labour.Registry
local Sites = DT_Labour.Sites
local Interaction = DT_Labour.Interaction
local Warehouse = DT_Labour.Warehouse
local Output = DT_Labour.Output
local Sim = DT_Labour.Sim
local Internal = Sim.Internal

function Sim.ProcessWorker(worker, currentHour)
    if not worker then return end

    Registry.RecalculateWorker(worker)

    local profile = Config.GetJobProfile(worker.jobType)
    local speedMultiplier = Config.GetJobSpeedMultiplier(worker.archetypeID, worker.jobType)
    local normalizedJobType = Config.NormalizeJobType(worker.jobType)
    local scavengeLoadout = nil
    local cycleHours = Config.GetEffectiveWorkTarget and Config.GetEffectiveWorkTarget(worker, profile)
        or (Config.GetEffectiveCycleHours and Config.GetEffectiveCycleHours(worker, profile))
        or (profile.cycleHours or 24)
    local baseWorkSpeedMultiplier = Config.GetBaseWorkSpeedMultiplier and Config.GetBaseWorkSpeedMultiplier(worker, profile) or 1.0
    local scavengeBaseWorkPerHour = Config.GetScavengeBaseWorkPerHour and Config.GetScavengeBaseWorkPerHour() or 1.0
    local lastHour = tonumber(worker.lastSimHour) or tonumber(currentHour) or 0
    local deltaHours = math.max(0, currentHour - lastHour)

    if worker.state == Config.States.Dead then
        worker.jobEnabled = false
        worker.lastNutritionCheckpoint = Config.GetMealCheckpointCountAtHour(currentHour)
        if deltaHours > 0 then
            worker.lastSimHour = currentHour
        end
        Registry.RecalculateWorker(worker)
        return
    end

    Sites.RefreshWorkerSite(worker)
    speedMultiplier = speedMultiplier * (tonumber(baseWorkSpeedMultiplier) or 1)
    worker.workTarget = cycleHours
    worker.workCycleHours = cycleHours
    worker.baseWorkSpeedMultiplier = baseWorkSpeedMultiplier

    if normalizedJobType == Config.JobTypes.Scavenge then
        Internal.ensureWorkerHome(worker)
        worker.presenceState = Internal.getScavengePresenceState(worker)
        if worker.presenceState == Config.PresenceStates.Home and worker.haulLedger and #worker.haulLedger > 0 then
            Internal.completeScavengeReturnHome(worker, currentHour)
        end
        worker.dumpCooldownHours = math.max(0, tonumber(worker.travelHoursRemaining) or 0)
    end

    local dailyCaloriesNeed = Config.GetEffectiveDailyCaloriesNeed(worker, profile)
    local dailyHydrationNeed = Config.GetEffectiveDailyHydrationNeed(worker, profile)

    if worker.presenceState == Config.PresenceStates.Home and Warehouse and Warehouse.RestockWorker then
        local restock = Warehouse.RestockWorker(worker, dailyCaloriesNeed, dailyHydrationNeed)
        if restock and (tonumber(restock.provisionCount) or 0) > 0 then
            local provisionClause = Internal.buildWarehouseProvisionClause(
                restock.provisionSampleNames,
                restock.provisionHiddenCount
            )
            local message = "Restocked " .. tostring(restock.provisionCount) .. " provision"
                .. ((tonumber(restock.provisionCount) or 0) == 1 and "" or "s")
                .. " from warehouse"
            if provisionClause ~= "" then
                message = message .. ": " .. provisionClause .. "."
            else
                message = message .. "."
            end
            Internal.appendWorkerLog(worker, message, currentHour, "warehouse")
        end
    end

    Registry.RecalculateWorker(worker)
    local toolsReady = Registry.WorkerHasRequiredTools(worker)

    if normalizedJobType == Config.JobTypes.Scavenge and Config.GetScavengeLoadout then
        scavengeLoadout = Config.GetScavengeLoadout(worker)
        worker.scavengeTier = scavengeLoadout.tier or 0
        worker.scavengeTierLabel = Config.GetScavengeTierLabel and Config.GetScavengeTierLabel(scavengeLoadout.tier) or nil
        worker.scavengePoolRolls = scavengeLoadout.poolRolls or 0
        worker.scavengeFailureWeight = scavengeLoadout.failureWeight or 0
        worker.scavengeSearchSpeedMultiplier = scavengeLoadout.searchSpeedMultiplier or 1
        worker.scavengeCapabilities = scavengeLoadout.capabilityList or {}
        speedMultiplier = speedMultiplier * (tonumber(scavengeLoadout.searchSpeedMultiplier) or 1)
    else
        worker.scavengeTier = nil
        worker.scavengeTierLabel = nil
        worker.scavengePoolRolls = nil
        worker.scavengeFailureWeight = nil
        worker.scavengeSearchSpeedMultiplier = nil
        worker.scavengeCapabilities = nil
    end

    worker.siteState = worker.siteState or "Deferred"
    worker.toolState = toolsReady and "Ready" or "Missing"

    local canWork = worker.jobEnabled and toolsReady
    if normalizedJobType == Config.JobTypes.Scavenge then
        canWork = canWork and worker.presenceState == Config.PresenceStates.Scavenging
    end
    local workableHours, hasCalories, hasHydration, hp = Internal.processNutrition(
        worker,
        currentHour,
        dailyCaloriesNeed,
        dailyHydrationNeed,
        canWork
    )

    worker.starvationHours = 0
    worker.dehydrationHours = 0

    if normalizedJobType == Config.JobTypes.Scavenge then
        local totalCaloriesAvailable, totalHydrationAvailable = Internal.getAvailableProvisionTotals(worker)
        local returnCaloriesThreshold, returnHydrationThreshold = Internal.getRequiredTravelReserve(worker, profile, 1)
        local outboundCaloriesThreshold, outboundHydrationThreshold = Internal.getRequiredTravelReserve(worker, profile, 2)
        local presenceState = Internal.getScavengePresenceState(worker)

        if hp <= 0 then
            Internal.markWorkerDead(worker, currentHour, normalizedJobType, presenceState, hasCalories, hasHydration)
        else
            if not worker.assignedSiteID and presenceState ~= Config.PresenceStates.Home then
                Internal.beginScavengeReturnHome(worker, currentHour, Config.ReturnReasons.MissingSite, worker.travelHoursRemaining)
                presenceState = Internal.getScavengePresenceState(worker)
            elseif not toolsReady and presenceState ~= Config.PresenceStates.Home then
                Internal.beginScavengeReturnHome(worker, currentHour, Config.ReturnReasons.MissingTool, worker.travelHoursRemaining)
                presenceState = Internal.getScavengePresenceState(worker)
            end

            if presenceState ~= Config.PresenceStates.Home and presenceState ~= Config.PresenceStates.AwayToHome then
                if totalHydrationAvailable < returnHydrationThreshold then
                    Internal.beginScavengeReturnHome(worker, currentHour, Config.ReturnReasons.LowDrink)
                    presenceState = Internal.getScavengePresenceState(worker)
                elseif totalCaloriesAvailable < returnCaloriesThreshold then
                    Internal.beginScavengeReturnHome(worker, currentHour, Config.ReturnReasons.LowFood)
                    presenceState = Internal.getScavengePresenceState(worker)
                end
            end

            if not worker.jobEnabled and presenceState ~= Config.PresenceStates.Home and presenceState ~= Config.PresenceStates.AwayToHome then
                Internal.beginScavengeReturnHome(
                    worker,
                    currentHour,
                    Config.ReturnReasons.Manual,
                    presenceState == Config.PresenceStates.AwayToSite and worker.travelHoursRemaining or nil
                )
                presenceState = Internal.getScavengePresenceState(worker)
            end

            if worker.jobEnabled
                and presenceState == Config.PresenceStates.Home
                and worker.assignedSiteID
                and toolsReady
                and (tonumber(worker.haulCount) or 0) <= 0
                and Internal.hasWarehouseCapacityForScavenge(worker)
                and hasCalories
                and hasHydration
                and totalCaloriesAvailable >= outboundCaloriesThreshold
                and totalHydrationAvailable >= outboundHydrationThreshold then
                Internal.startScavengeOutbound(worker, currentHour)
                presenceState = Internal.getScavengePresenceState(worker)
            end

            if presenceState == Config.PresenceStates.AwayToSite or presenceState == Config.PresenceStates.AwayToHome then
                Internal.progressScavengeTravel(worker, currentHour, deltaHours)
                presenceState = Internal.getScavengePresenceState(worker)
            end

            if presenceState == Config.PresenceStates.Scavenging and worker.jobEnabled and toolsReady and hasCalories and hasHydration then
                local effectiveWorkPerHour = math.max(0.01, tonumber(scavengeBaseWorkPerHour) or 1) * math.max(0.01, tonumber(speedMultiplier) or 1)
                worker.state = Config.States.Working
                worker.workProgress = Internal.clampHours(worker.workProgress) + (workableHours * effectiveWorkPerHour)
                while worker.workProgress >= cycleHours do
                    worker.workProgress = worker.workProgress - cycleHours

                    local scavengeRun = Output.GenerateScavengeRun and Output.GenerateScavengeRun(worker) or { entries = {} }
                    for _, entry in ipairs(scavengeRun.entries or {}) do
                        Registry.AddHaulEntry(worker, entry)
                    end
                    Internal.logJobCycleOutcome(worker, currentHour, scavengeRun.totalQuantity, Internal.getScavengeLocationLabel(worker, scavengeRun), scavengeRun.entries)

                    if Internal.shouldReturnForFullHaul(worker, scavengeLoadout) then
                        Internal.beginScavengeReturnHome(worker, currentHour, Config.ReturnReasons.FullHaul)
                        break
                    end
                end
            end

            presenceState = Internal.getScavengePresenceState(worker)
            worker.dumpCooldownHours = math.max(0, tonumber(worker.travelHoursRemaining) or 0)

            if hp <= 0 then
                Internal.markWorkerDead(worker, currentHour, normalizedJobType, presenceState, hasCalories, hasHydration)
            elseif not hasHydration then
                worker.state = Config.States.Dehydrated
            elseif not hasCalories then
                worker.state = Config.States.Starving
            elseif presenceState == Config.PresenceStates.Home and (tonumber(worker.haulCount) or 0) > 0 then
                worker.state = Config.States.StorageFull
            elseif presenceState == Config.PresenceStates.Home
                and worker.jobEnabled
                and worker.assignedSiteID
                and not Internal.hasWarehouseCapacityForScavenge(worker) then
                worker.state = Config.States.StorageFull
            elseif presenceState == Config.PresenceStates.Home
                and worker.jobEnabled
                and worker.assignedSiteID
                and (totalCaloriesAvailable < outboundCaloriesThreshold
                    or totalHydrationAvailable < outboundHydrationThreshold) then
                worker.state = Config.States.WarehouseShortage
            elseif presenceState == Config.PresenceStates.Scavenging and worker.jobEnabled and toolsReady then
                worker.state = Config.States.Working
            elseif presenceState == Config.PresenceStates.Home and worker.jobEnabled and not worker.assignedSiteID then
                worker.state = Config.States.MissingSite
            elseif presenceState == Config.PresenceStates.Home and worker.jobEnabled and not toolsReady then
                worker.state = Config.States.MissingTool
            else
                worker.state = Config.States.Idle
            end
        end
    elseif hp <= 0 then
        Internal.markWorkerDead(worker, currentHour, normalizedJobType, Config.PresenceStates.Home, hasCalories, hasHydration)
    elseif not worker.jobEnabled then
        worker.state = Config.States.Idle
    elseif not toolsReady then
        worker.state = Config.States.MissingTool
    elseif not hasHydration then
        worker.state = Config.States.Dehydrated
    elseif not hasCalories then
        worker.state = Config.States.Starving
    else
        worker.state = Config.States.Working
        worker.workProgress = Internal.clampHours(worker.workProgress) + (workableHours * speedMultiplier)
        while worker.workProgress >= cycleHours do
            worker.workProgress = worker.workProgress - cycleHours
            local entries = Output.GenerateForJob(profile, worker)
            local totalQuantity = 0
            local warehouseBlocked = 0
            for _, entry in ipairs(entries) do
                local movedQty, leftoverQty = Warehouse.DepositHaulEntry(worker.ownerUsername, entry)
                totalQuantity = totalQuantity + movedQty
                warehouseBlocked = warehouseBlocked + leftoverQty
                if leftoverQty > 0 then
                    Registry.AddOutputEntry(worker, {
                        fullType = entry.fullType,
                        qty = leftoverQty
                    })
                end
            end
            Internal.logJobCycleOutcome(worker, currentHour, totalQuantity, Interaction.GetPlaceLabel(worker), entries)
            if warehouseBlocked > 0 then
                Internal.appendWorkerLog(
                    worker,
                    "Warehouse is full. " .. tostring(warehouseBlocked) .. " produced item" .. (warehouseBlocked == 1 and "" or "s") .. " could not be stored.",
                    currentHour,
                    "warehouse"
                )
                worker.state = Config.States.StorageFull
                break
            end
        end
    end

    if deltaHours > 0 then
        worker.lastSimHour = currentHour
    end
    Registry.RecalculateWorker(worker)
end

function Sim.ProcessAllWorkers(currentHour)
    currentHour = currentHour or (Config.GetCurrentWorldHours and Config.GetCurrentWorldHours()) or Config.GetCurrentHour()
    local data = Registry.GetData()
    for _, worker in pairs(data.Workers or {}) do
        if Internal.freezeWorkerForOfflineOwner(worker, currentHour) then
            Registry.RecalculateWorker(worker)
        else
            Sim.ProcessWorker(worker, currentHour)
        end
    end
    Registry.Save()
end

function Sim.OnTick()
    Sim.tickCounter = Sim.tickCounter + 1
    if Sim.tickCounter < Config.SIM_TICK_RATE then
        return
    end

    Sim.tickCounter = 0
    local currentHour = (Config.GetCurrentWorldHours and Config.GetCurrentWorldHours()) or Config.GetCurrentHour()
    local stepHours = math.max(0.05, tonumber(Config.SIM_TIME_STEP_HOURS) or 0.25)
    if Sim.lastProcessedHour >= 0 and (currentHour - Sim.lastProcessedHour) < stepHours then
        return
    end

    Sim.lastProcessedHour = currentHour
    Sim.ProcessAllWorkers(currentHour)
end
