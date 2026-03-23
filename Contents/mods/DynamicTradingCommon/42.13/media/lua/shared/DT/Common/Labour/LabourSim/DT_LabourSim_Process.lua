local Config = DT_Labour.Config
local Registry = DT_Labour.Registry
local Sites = DT_Labour.Sites
local Interaction = DT_Labour.Interaction
local Warehouse = DT_Labour.Warehouse
local Output = DT_Labour.Output
local Sim = DT_Labour.Sim
local Internal = Sim.Internal
local Tiredness = DT_Labour.Tiredness
local Skills = DT_Labour.Skills

local function buildXPAmount(totalQuantity)
    return math.max(10, 20 + math.min(20, math.floor(tonumber(totalQuantity) or 0) * 3))
end

local function grantWorkerJobXP(worker, currentHour, skillEffects, totalQuantity)
    if not Skills or not Skills.GrantXP or not skillEffects or not skillEffects.skillID then
        return
    end

    local result = Skills.GrantXP(worker, skillEffects.skillID, buildXPAmount(totalQuantity))
    if not result or (tonumber(result.granted) or 0) <= 0 then
        return
    end

    local message = "Earned " .. tostring(math.floor((tonumber(result.granted) or 0) + 0.5)) .. " " .. tostring(skillEffects.skillLabel or skillEffects.skillID or "Skill") .. " XP."

    if (tonumber(result.leveledUp) or 0) > 0 then
        message = message .. " " .. tostring(skillEffects.skillLabel or skillEffects.skillID or "Skill")
            .. " increased to level "
            .. tostring(result.newLevel)
            .. "."
    end

    Internal.appendWorkerLog(
        worker,
        message,
        currentHour,
        "skills"
    )
end

function Sim.ProcessWorker(worker, currentHour)
    if not worker then return end

    Registry.RecalculateWorker(worker)

    local profile = Config.GetJobProfile(worker.jobType)
    local normalizedJobType = Config.NormalizeJobType(worker.jobType)
    local isBuilderJob = normalizedJobType == (Config.JobTypes and Config.JobTypes.Builder)
    local scavengeLoadout = nil
    local cycleHours = Config.GetEffectiveWorkTarget and Config.GetEffectiveWorkTarget(worker, profile)
        or (Config.GetEffectiveCycleHours and Config.GetEffectiveCycleHours(worker, profile))
        or (profile.cycleHours or 24)
    local baseWorkSpeedMultiplier = Config.GetBaseWorkSpeedMultiplier and Config.GetBaseWorkSpeedMultiplier(worker, profile) or 1.0
    local scavengeBaseWorkPerHour = Config.GetScavengeBaseWorkPerHour and Config.GetScavengeBaseWorkPerHour() or 1.0
    local lastHour = tonumber(worker.lastSimHour) or tonumber(currentHour) or 0
    local deltaHours = math.max(0, currentHour - lastHour)
    local lowTirednessReason = (Config.ReturnReasons and Config.ReturnReasons.LowTiredness) or "LowTiredness"

    if worker.state == Config.States.Dead then
        worker.jobEnabled = false
        worker.lastNutritionCheckpoint = Config.GetMealCheckpointCountAtHour(currentHour)
        if deltaHours > 0 then
            worker.lastSimHour = currentHour
        end
        Registry.RecalculateWorker(worker)
        return
    end

    if Tiredness and Tiredness.IsDepleted and Tiredness.IsDepleted(worker) and not Tiredness.IsForcedRest(worker) then
        Tiredness.SetForcedRest(worker, true, lowTirednessReason)
    end

    Sites.RefreshWorkerSite(worker)
    local jobSkillEffects = Skills and Skills.GetWorkerJobEffects and Skills.GetWorkerJobEffects(worker, profile) or {
        speedMultiplier = 1,
        yieldMultiplier = 1,
        botchChanceMultiplier = 1,
        level = 0
    }
    local speedMultiplier = math.max(0.01, tonumber(jobSkillEffects.speedMultiplier) or 1) * (tonumber(baseWorkSpeedMultiplier) or 1)
    worker.workTarget = cycleHours
    worker.workCycleHours = cycleHours
    worker.baseWorkSpeedMultiplier = baseWorkSpeedMultiplier
    worker.jobSkillID = jobSkillEffects.skillID
    worker.jobSkillLabel = jobSkillEffects.skillLabel
    worker.jobSkillLevel = jobSkillEffects.level
    worker.jobSkillSpeedMultiplier = jobSkillEffects.speedMultiplier
    worker.jobSkillYieldMultiplier = jobSkillEffects.yieldMultiplier
    worker.jobSkillBotchMultiplier = jobSkillEffects.botchChanceMultiplier
    if isBuilderJob and DT_Buildings and DT_Buildings.GetProjectForWorker then
        local builderProject = DT_Buildings.GetProjectForWorker(worker)
        if builderProject then
            cycleHours = math.max(1, tonumber(builderProject.requiredWorkPoints) or cycleHours)
            worker.workTarget = cycleHours
            worker.workCycleHours = cycleHours
        end
    end

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

    local forcedRest = Tiredness and Tiredness.IsForcedRest and Tiredness.IsForcedRest(worker) or false
    local canWork = worker.jobEnabled and toolsReady and not forcedRest
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
        local didScavengeWork = false

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
                elseif forcedRest then
                    Internal.beginScavengeReturnHome(worker, currentHour, lowTirednessReason)
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
                and not forcedRest
                and totalCaloriesAvailable >= outboundCaloriesThreshold
                and totalHydrationAvailable >= outboundHydrationThreshold then
                Internal.startScavengeOutbound(worker, currentHour)
                presenceState = Internal.getScavengePresenceState(worker)
            end

            if presenceState == Config.PresenceStates.AwayToSite or presenceState == Config.PresenceStates.AwayToHome then
                Internal.progressScavengeTravel(worker, currentHour, deltaHours)
                presenceState = Internal.getScavengePresenceState(worker)
            end

            if presenceState == Config.PresenceStates.Scavenging and worker.jobEnabled and toolsReady and hasCalories and hasHydration and not forcedRest then
                local effectiveWorkPerHour = math.max(0.01, tonumber(scavengeBaseWorkPerHour) or 1) * math.max(0.01, tonumber(speedMultiplier) or 1)
                worker.state = Config.States.Working
                worker.workProgress = Internal.clampHours(worker.workProgress) + (workableHours * effectiveWorkPerHour)
                didScavengeWork = workableHours > 0
                while worker.workProgress >= cycleHours do
                    worker.workProgress = worker.workProgress - cycleHours

                    local scavengeRun = Output.GenerateScavengeRun and Output.GenerateScavengeRun(worker) or { entries = {} }
                    worker.scavengeBonusRareRolls = scavengeRun.bonusRareRolls or 0
                    worker.scavengeRareFinds = scavengeRun.rareFinds or 0
                    worker.scavengeBotchedRolls = scavengeRun.botchedRolls or 0
                    worker.scavengeQualityCounts = scavengeRun.qualityCounts or nil
                    for _, entry in ipairs(scavengeRun.entries or {}) do
                        Registry.AddHaulEntry(worker, entry)
                    end
                    Internal.logJobCycleOutcome(worker, currentHour, scavengeRun.totalQuantity, Internal.getScavengeLocationLabel(worker, scavengeRun), scavengeRun.entries)
                    if scavengeRun.success then
                        grantWorkerJobXP(worker, currentHour, scavengeRun.skillEffects or jobSkillEffects, scavengeRun.totalQuantity)
                    end

                    if Internal.shouldReturnForFullHaul(worker, scavengeLoadout) then
                        Internal.beginScavengeReturnHome(worker, currentHour, Config.ReturnReasons.FullHaul)
                        break
                    end
                end
            end

            presenceState = Internal.getScavengePresenceState(worker)
            worker.dumpCooldownHours = math.max(0, tonumber(worker.travelHoursRemaining) or 0)
            if Tiredness and deltaHours > 0 then
                if didScavengeWork and workableHours > 0 then
                    Tiredness.ApplyWorkDrain(worker, workableHours, profile)
                elseif presenceState == Config.PresenceStates.Home then
                    Tiredness.ApplyHomeRecovery(worker, deltaHours, profile)
                elseif presenceState == Config.PresenceStates.AwayToSite or presenceState == Config.PresenceStates.AwayToHome then
                    Tiredness.ApplyTravelDrain(worker, deltaHours, profile)
                end

                forcedRest = Tiredness.IsForcedRest(worker)
                if forcedRest then
                    Tiredness.CompleteForcedRest(worker, currentHour, "Fully rested again.")
                elseif Tiredness.IsDepleted(worker) then
                    forcedRest = true
                    Tiredness.BeginForcedRest(worker, currentHour, lowTirednessReason, presenceState == Config.PresenceStates.Home and "Too tired to keep working. Resting at home." or nil)
                    if presenceState ~= Config.PresenceStates.Home and presenceState ~= Config.PresenceStates.AwayToHome then
                        Internal.beginScavengeReturnHome(worker, currentHour, lowTirednessReason)
                    end
                end
                presenceState = Internal.getScavengePresenceState(worker)
                forcedRest = Tiredness.IsForcedRest(worker)
            end

            if hp <= 0 then
                Internal.markWorkerDead(worker, currentHour, normalizedJobType, presenceState, hasCalories, hasHydration)
            elseif not hasHydration then
                worker.state = Config.States.Dehydrated
            elseif not hasCalories then
                worker.state = Config.States.Starving
            elseif forcedRest and presenceState == Config.PresenceStates.Home then
                worker.state = Config.States.Resting
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
            elseif presenceState == Config.PresenceStates.Scavenging and worker.jobEnabled and toolsReady and not forcedRest then
                worker.state = Config.States.Working
            elseif presenceState == Config.PresenceStates.Home and worker.jobEnabled and not worker.assignedSiteID then
                worker.state = Config.States.MissingSite
            elseif presenceState == Config.PresenceStates.Home and worker.jobEnabled and not toolsReady then
                worker.state = Config.States.MissingTool
            else
                worker.state = Config.States.Idle
            end
        end
    elseif isBuilderJob then
        worker.scavengeBonusRareRolls = nil
        worker.scavengeRareFinds = nil
        worker.scavengeBotchedRolls = nil
        worker.scavengeQualityCounts = nil

        local projectState = DT_Buildings and DT_Buildings.GetProjectDisplayState and DT_Buildings.GetProjectDisplayState(worker.ownerUsername, worker.workerID) or {
            hasProject = false,
            label = "No Project"
        }
        local didWorkThisTick = false
        local buildResult = nil

        if hp <= 0 then
            Internal.markWorkerDead(worker, currentHour, normalizedJobType, Config.PresenceStates.Home, hasCalories, hasHydration)
        elseif worker.jobEnabled and toolsReady and hasHydration and hasCalories and not forcedRest and projectState.hasProject then
            worker.state = Config.States.Working
            buildResult = DT_Buildings
                and DT_Buildings.ProcessWorkerProject
                and DT_Buildings.ProcessWorkerProject(worker, currentHour, workableHours, speedMultiplier)
                or nil
            didWorkThisTick = buildResult and buildResult.didWork == true or false
            if buildResult and buildResult.completed and buildResult.project then
                local xpResult = buildResult.xpResult or nil
                local xpText = ""
                if xpResult and (tonumber(xpResult.granted) or 0) > 0 then
                    xpText = " Earned "
                        .. tostring(math.floor((tonumber(xpResult.granted) or 0) + 0.5))
                        .. " Construction XP."
                    if (tonumber(xpResult.leveledUp) or 0) > 0 then
                        xpText = xpText
                            .. " Construction increased to level "
                            .. tostring(xpResult.newLevel or 0)
                            .. "."
                    end
                end
                Internal.appendWorkerLog(
                    worker,
                    tostring(buildResult.project.buildingType or "Building")
                        .. " reached level "
                        .. tostring(buildResult.project.targetLevel or 1)
                        .. "."
                        .. xpText,
                    currentHour,
                    "buildings"
                )
            end
        end

        if Tiredness and deltaHours > 0 and hp > 0 then
            if didWorkThisTick and workableHours > 0 then
                Tiredness.ApplyWorkDrain(worker, workableHours, profile)
            else
                Tiredness.ApplyHomeRecovery(worker, deltaHours, profile)
            end

            forcedRest = Tiredness.IsForcedRest(worker)
            if forcedRest then
                Tiredness.CompleteForcedRest(worker, currentHour, "Fully rested again.")
            elseif Tiredness.IsDepleted(worker) then
                forcedRest = true
                Tiredness.BeginForcedRest(worker, currentHour, lowTirednessReason, "Too tired to keep building. Resting at home.")
            end
            forcedRest = Tiredness.IsForcedRest(worker)
        end

        if hp <= 0 then
            Internal.markWorkerDead(worker, currentHour, normalizedJobType, Config.PresenceStates.Home, hasCalories, hasHydration)
        elseif not worker.jobEnabled then
            worker.state = Config.States.Idle
        elseif not toolsReady then
            worker.state = Config.States.MissingTool
        elseif not hasHydration then
            worker.state = Config.States.Dehydrated
        elseif not hasCalories then
            worker.state = Config.States.Starving
        elseif forcedRest then
            worker.state = Config.States.Resting
        elseif projectState.hasProject then
            worker.state = Config.States.Working
        else
            worker.state = Config.States.Idle
        end
    else
        worker.scavengeBonusRareRolls = nil
        worker.scavengeRareFinds = nil
        worker.scavengeBotchedRolls = nil
        worker.scavengeQualityCounts = nil
        local didWorkThisTick = false
        if hp <= 0 then
            Internal.markWorkerDead(worker, currentHour, normalizedJobType, Config.PresenceStates.Home, hasCalories, hasHydration)
        elseif worker.jobEnabled and toolsReady and hasHydration and hasCalories and not forcedRest then
            worker.state = Config.States.Working
            worker.workProgress = Internal.clampHours(worker.workProgress) + (workableHours * speedMultiplier)
            didWorkThisTick = workableHours > 0
            while worker.workProgress >= cycleHours do
                worker.workProgress = worker.workProgress - cycleHours
                local jobResult = Output.GenerateForJob(profile, worker)
                local warehouseBlocked = 0
                for _, entry in ipairs(jobResult.entries or {}) do
                    local movedQty, leftoverQty = Warehouse.DepositHaulEntry(worker.ownerUsername, entry)
                    warehouseBlocked = warehouseBlocked + leftoverQty
                    if leftoverQty > 0 then
                        Registry.AddOutputEntry(worker, {
                            fullType = entry.fullType,
                            qty = leftoverQty
                        })
                    end
                end
                Internal.logJobCycleOutcome(worker, currentHour, jobResult.totalQuantity, Interaction.GetPlaceLabel(worker), jobResult.entries)
                if jobResult.success then
                    grantWorkerJobXP(worker, currentHour, jobResult.skillEffects or jobSkillEffects, jobResult.totalQuantity)
                elseif jobResult.failed and jobResult.failureReason then
                    Internal.appendWorkerLog(worker, tostring(jobResult.failureReason), currentHour, "output")
                end
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

        if Tiredness and deltaHours > 0 and hp > 0 then
            if didWorkThisTick and workableHours > 0 then
                Tiredness.ApplyWorkDrain(worker, workableHours, profile)
            else
                Tiredness.ApplyHomeRecovery(worker, deltaHours, profile)
            end

            forcedRest = Tiredness.IsForcedRest(worker)
            if forcedRest then
                Tiredness.CompleteForcedRest(worker, currentHour, "Fully rested again.")
            elseif Tiredness.IsDepleted(worker) then
                forcedRest = true
                Tiredness.BeginForcedRest(worker, currentHour, lowTirednessReason, "Too tired to keep working. Resting at home.")
            end
            forcedRest = Tiredness.IsForcedRest(worker)
        end

        if hp <= 0 then
            Internal.markWorkerDead(worker, currentHour, normalizedJobType, Config.PresenceStates.Home, hasCalories, hasHydration)
        elseif not worker.jobEnabled then
            worker.state = Config.States.Idle
        elseif not toolsReady then
            worker.state = Config.States.MissingTool
        elseif not hasHydration then
            worker.state = Config.States.Dehydrated
        elseif not hasCalories then
            worker.state = Config.States.Starving
        elseif forcedRest then
            worker.state = Config.States.Resting
        elseif worker.state ~= Config.States.StorageFull then
            worker.state = Config.States.Working
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
