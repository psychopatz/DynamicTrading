require "DT/Common/Labour/DT_Labour_Config"
require "DT/Common/Labour/LabourRegistry/DT_LabourRegistry"
require "DT/Common/Labour/DT_Labour_Sites"
require "DT/Common/Labour/DT_Labour_Nutrition"
require "DT/Common/Labour/DT_Labour_Output"
require "DT/Common/Labour/DT_Labour_Presentation"

DT_Labour = DT_Labour or {}
DT_Labour.Sim = DT_Labour.Sim or {}

local Config = DT_Labour.Config
local Registry = DT_Labour.Registry
local Sites = DT_Labour.Sites
local Nutrition = DT_Labour.Nutrition
local Output = DT_Labour.Output
local Presentation = DT_Labour.Presentation
local Sim = DT_Labour.Sim

if isClient() and not isServer() then
    return Sim
end

Sim.tickCounter = Sim.tickCounter or 0
Sim.lastProcessedHour = Sim.lastProcessedHour or -1

local function clampHours(value)
    return math.max(0, tonumber(value) or 0)
end

local function clampCheckpoint(value, fallback)
    local safeValue = math.floor(tonumber(value) or tonumber(fallback) or 0)
    return math.max(0, safeValue)
end

local function clampHp(value, maxHp)
    local safeMax = math.max(1, tonumber(maxHp) or Config.DEFAULT_WORKER_MAX_HP or 100)
    return math.max(0, math.min(safeMax, tonumber(value) or safeMax))
end

local function freezeWorkerForOfflineOwner(worker, currentHour)
    if not worker then
        return false
    end

    if not Config.IsOwnerOnline or Config.IsOwnerOnline(worker.ownerUsername) then
        return false
    end

    worker.lastSimHour = tonumber(currentHour) or tonumber(worker.lastSimHour) or 0
    worker.lastNutritionCheckpoint = Config.GetMealCheckpointCountAtHour(worker.lastSimHour)
    if Presentation and Presentation.RemoveProjection then
        Presentation.RemoveProjection(worker)
    end
    return true
end

local function appendWorkerLog(worker, message, worldHour, category)
    local registryInternal = DT_Labour and DT_Labour.Registry and DT_Labour.Registry.Internal or nil
    if registryInternal and registryInternal.AppendActivityLog then
        registryInternal.AppendActivityLog(worker, message, worldHour, category)
    end
end

local function getOutputDisplayName(fullType)
    local registryInternal = DT_Labour and DT_Labour.Registry and DT_Labour.Registry.Internal or nil
    if registryInternal and registryInternal.GetDisplayNameForFullType then
        return registryInternal.GetDisplayNameForFullType(fullType)
    end
    return tostring(fullType or "Unknown Item")
end

local function logOutputEntry(worker, entry, currentHour)
    if not worker or not entry or not entry.fullType then
        return
    end

    local qty = math.max(1, tonumber(entry.qty) or 1)
    local itemName = getOutputDisplayName(entry.fullType)
    local jobType = Config.NormalizeJobType(worker.jobType)
    local message = "Produced " .. itemName .. " x" .. tostring(qty) .. "."

    if jobType == Config.JobTypes.Scavenge then
        message = "Found " .. itemName .. " x" .. tostring(qty) .. " while scavenging."
    elseif jobType == Config.JobTypes.Farm then
        message = "Harvested " .. itemName .. " x" .. tostring(qty) .. "."
    elseif jobType == Config.JobTypes.Fish then
        message = "Caught " .. itemName .. " x" .. tostring(qty) .. "."
    end

    appendWorkerLog(worker, message, currentHour, "output")
end

local function getHourlyNeed(dailyNeed)
    local hoursPerDay = tonumber(Config.HOURS_PER_DAY) or 24
    if hoursPerDay <= 0 then
        return 0
    end
    return math.max(0, tonumber(dailyNeed) or 0) / hoursPerDay
end

local function refillReserveToDailyTargets(worker, dailyCaloriesNeed, dailyHydrationNeed)
    Nutrition.RefillReserveToTargets(
        worker,
        math.max(0, tonumber(dailyCaloriesNeed) or 0),
        math.max(0, tonumber(dailyHydrationNeed) or 0),
        math.max(0, tonumber(dailyCaloriesNeed) or 0),
        math.max(0, tonumber(dailyHydrationNeed) or 0)
    )
end

local function getSupportedHours(reserveAmount, hourlyNeed, intervalHours)
    if intervalHours <= 0 then
        return 0
    end
    if hourlyNeed <= 0 then
        return intervalHours
    end
    return math.min(intervalHours, math.max(0, (tonumber(reserveAmount) or 0) / hourlyNeed))
end

local function maybeRefillReserve(worker, currentHour, checkpointCount, dailyCaloriesNeed, dailyHydrationNeed, forceMealRefill)
    if not worker then
        return
    end

    if forceMealRefill then
        refillReserveToDailyTargets(worker, dailyCaloriesNeed, dailyHydrationNeed)
        return
    end

    local nextCheckpointHour = Config.GetMealCheckpointHourByCount((tonumber(checkpointCount) or 0) + 1)
    local safeNextHour = tonumber(nextCheckpointHour) or 0
    local safeCurrentHour = tonumber(currentHour) or 0
    local hoursUntilNextMeal = math.max(0, safeNextHour - safeCurrentHour)
    local caloriesThreshold = getHourlyNeed(dailyCaloriesNeed) * hoursUntilNextMeal
    local hydrationThreshold = getHourlyNeed(dailyHydrationNeed) * hoursUntilNextMeal
    local activeCalories, activeHydration = Nutrition.GetOnBodyTotals(worker)

    if activeCalories <= (caloriesThreshold + 0.0001) or activeHydration <= (hydrationThreshold + 0.0001) then
        refillReserveToDailyTargets(worker, dailyCaloriesNeed, dailyHydrationNeed)
    end
end

local function applyInterval(worker, workableHours, hp, maxHp, intervalHours, caloriesPerHour, hydrationPerHour, canWork)
    if intervalHours <= 0 then
        return workableHours, hp
    end

    local activeCalories, activeHydration = Nutrition.GetOnBodyTotals(worker)
    local fullyFedHours = math.min(
        intervalHours,
        getSupportedHours(activeCalories, caloriesPerHour, intervalHours),
        getSupportedHours(activeHydration, hydrationPerHour, intervalHours)
    )
    local deprivedHours = math.max(0, intervalHours - fullyFedHours)

    Nutrition.ConsumeReserveAmounts(
        worker,
        math.max(0, tonumber(caloriesPerHour) or 0) * intervalHours,
        math.max(0, tonumber(hydrationPerHour) or 0) * intervalHours,
        math.max(0, tonumber(caloriesPerHour) or 0) * (tonumber(Config.HOURS_PER_DAY) or 24),
        math.max(0, tonumber(hydrationPerHour) or 0) * (tonumber(Config.HOURS_PER_DAY) or 24)
    )

    if canWork and fullyFedHours > 0 then
        workableHours = workableHours + fullyFedHours
    end

    if fullyFedHours > 0 then
        hp = clampHp(hp + (fullyFedHours * (Config.WORKER_HP_REGEN_PER_HOUR or 1)), maxHp)
    end
    if deprivedHours > 0 then
        hp = clampHp(hp - (deprivedHours * (Config.WORKER_HP_LOSS_PER_HOUR or 1)), maxHp)
    end

    return workableHours, hp
end

local function processNutrition(worker, currentHour, dailyCaloriesNeed, dailyHydrationNeed, canWork)
    local lastHour = tonumber(worker.lastSimHour) or tonumber(currentHour) or 0
    local currentCheckpoint = Config.GetMealCheckpointCountAtHour(currentHour)
    local previousCheckpoint = clampCheckpoint(
        worker.lastNutritionCheckpoint,
        Config.GetMealCheckpointCountAtHour(lastHour)
    )

    if previousCheckpoint > currentCheckpoint then
        previousCheckpoint = currentCheckpoint
    end

    local caloriesPerHour = getHourlyNeed(dailyCaloriesNeed)
    local hydrationPerHour = getHourlyNeed(dailyHydrationNeed)
    maybeRefillReserve(worker, lastHour, previousCheckpoint, dailyCaloriesNeed, dailyHydrationNeed, false)
    local reserveCalories, reserveHydration = Nutrition.GetOnBodyTotals(worker)
    local hasCalories = reserveCalories > 0
    local hasHydration = reserveHydration > 0
    local maxHp = math.max(1, tonumber(worker.maxHp) or Config.DEFAULT_WORKER_MAX_HP or 100)
    local hp = clampHp(worker.hp, maxHp)
    local workableHours = 0
    local segmentStart = lastHour

    for checkpoint = previousCheckpoint + 1, currentCheckpoint do
        local checkpointHour = Config.GetMealCheckpointHourByCount(checkpoint)
        local intervalHours = math.max(0, math.min(currentHour, checkpointHour) - segmentStart)
        workableHours, hp = applyInterval(
            worker,
            workableHours,
            hp,
            maxHp,
            intervalHours,
            caloriesPerHour,
            hydrationPerHour,
            canWork
        )
        segmentStart = math.max(segmentStart, checkpointHour)

        maybeRefillReserve(worker, checkpointHour, checkpoint, dailyCaloriesNeed, dailyHydrationNeed, true)
        reserveCalories, reserveHydration = Nutrition.GetOnBodyTotals(worker)
        hasCalories = reserveCalories > 0
        hasHydration = reserveHydration > 0
    end

    local tailHours = math.max(0, currentHour - segmentStart)
    workableHours, hp = applyInterval(
        worker,
        workableHours,
        hp,
        maxHp,
        tailHours,
        caloriesPerHour,
        hydrationPerHour,
        canWork
    )
    maybeRefillReserve(worker, currentHour, currentCheckpoint, dailyCaloriesNeed, dailyHydrationNeed, false)

    reserveCalories, reserveHydration = Nutrition.GetOnBodyTotals(worker)
    hasCalories = reserveCalories > 0
    hasHydration = reserveHydration > 0

    worker.lastNutritionCheckpoint = currentCheckpoint
    worker.hp = hp

    return workableHours, hasCalories, hasHydration, hp
end

local function applyDumpTravel(worker, workableHours)
    local pendingDumpHours = math.max(0, tonumber(worker and worker.dumpCooldownHours) or 0)
    if pendingDumpHours <= 0 or workableHours <= 0 then
        return workableHours, 0
    end

    local spentHours = math.min(workableHours, pendingDumpHours)
    worker.dumpCooldownHours = math.max(0, pendingDumpHours - spentHours)
    return math.max(0, workableHours - spentHours), spentHours
end

local function queueImmediateDumpTravel(worker, dumpHours, speedMultiplier)
    local remainingDumpHours = math.max(0, tonumber(dumpHours) or 0)
    if not worker or remainingDumpHours <= 0 then
        return 0, 0
    end

    local safeSpeedMultiplier = math.max(0.001, tonumber(speedMultiplier) or 1)
    local availableProgress = clampHours(worker.workProgress)
    local availableHours = availableProgress / safeSpeedMultiplier
    local spentHours = math.min(availableHours, remainingDumpHours)

    if spentHours > 0 then
        worker.workProgress = math.max(0, availableProgress - (spentHours * safeSpeedMultiplier))
        remainingDumpHours = math.max(0, remainingDumpHours - spentHours)
    end

    if remainingDumpHours > 0 then
        worker.dumpCooldownHours = math.max(0, tonumber(worker.dumpCooldownHours) or 0) + remainingDumpHours
    end

    return spentHours, remainingDumpHours
end

local function maybeDumpScavengeHaul(worker, currentHour, loadout)
    if not worker or Config.NormalizeJobType(worker.jobType) ~= Config.JobTypes.Scavenge then
        return 0
    end

    local haulMetrics = Registry.GetHaulMetrics and Registry.GetHaulMetrics(worker) or nil
    local maxCarryWeight = tonumber(loadout and loadout.maxCarryWeight)
        or tonumber(worker.maxCarryWeight)
        or (Config.GetWorkerBaseCarryWeight and Config.GetWorkerBaseCarryWeight(worker))
        or tonumber(Config.DEFAULT_WORKER_CARRY_WEIGHT)
        or 8
    if not haulMetrics or (tonumber(haulMetrics.effectiveWeight) or 0) < maxCarryWeight then
        return 0
    end

    local movedStacks, movedCount, movedRawWeight = Registry.DumpCarriedHaul(worker)
    if movedStacks <= 0 then
        return 0
    end

    worker.dumpTrips = math.max(0, tonumber(worker.dumpTrips) or 0) + 1
    local dumpHours = math.max(0, tonumber(Config.DEFAULT_SCAVENGE_DUMP_HOURS) or 1)

    appendWorkerLog(
        worker,
        "Returned to base and dumped haul: "
            .. tostring(movedCount)
            .. " items, "
            .. string.format("%.2f", movedRawWeight)
            .. " weight.",
        currentHour,
        "haul"
    )
    return dumpHours
end

function Sim.ProcessWorker(worker, currentHour)
    if not worker then return end

    Registry.RecalculateWorker(worker)

    local profile = Config.GetJobProfile(worker.jobType)
    local speedMultiplier = Config.GetJobSpeedMultiplier(worker.archetypeID, worker.jobType)
    local normalizedJobType = Config.NormalizeJobType(worker.jobType)
    local scavengeLoadout = nil
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

    if normalizedJobType == Config.JobTypes.Scavenge and worker.jobEnabled == false and worker.haulLedger and #worker.haulLedger > 0 then
        local movedStacks, movedCount, movedRawWeight = Registry.DumpCarriedHaul(worker)
        if movedStacks > 0 then
            appendWorkerLog(
                worker,
                "Stopped scavenging and unloaded haul: "
                    .. tostring(movedCount)
                    .. " items, "
                    .. string.format("%.2f", movedRawWeight)
                    .. " weight.",
                currentHour,
                "haul"
            )
        end
    end

    worker.siteState = worker.siteState or "Deferred"
    worker.toolState = toolsReady and "Ready" or "Missing"

    local dailyCaloriesNeed = Config.GetEffectiveDailyCaloriesNeed(worker, profile)
    local dailyHydrationNeed = Config.GetEffectiveDailyHydrationNeed(worker, profile)
    local canWork = worker.jobEnabled and toolsReady
    local workableHours, hasCalories, hasHydration, hp = processNutrition(
        worker,
        currentHour,
        dailyCaloriesNeed,
        dailyHydrationNeed,
        canWork
    )
    if normalizedJobType == Config.JobTypes.Scavenge then
        workableHours = select(1, applyDumpTravel(worker, workableHours))
    end

    worker.starvationHours = 0
    worker.dehydrationHours = 0

    if hp <= 0 then
        worker.state = Config.States.Dead
        worker.jobEnabled = false
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
        worker.workProgress = clampHours(worker.workProgress) + (workableHours * speedMultiplier)
        while worker.workProgress >= (profile.cycleHours or 24) do
            worker.workProgress = worker.workProgress - (profile.cycleHours or 24)
            for _, entry in ipairs(Output.GenerateForJob(profile, worker)) do
                if normalizedJobType == Config.JobTypes.Scavenge then
                    Registry.AddHaulEntry(worker, entry)
                else
                    Registry.AddOutputEntry(worker, entry)
                end
                logOutputEntry(worker, entry, currentHour)
            end

            if normalizedJobType == Config.JobTypes.Scavenge then
                local dumpHours = maybeDumpScavengeHaul(worker, currentHour, scavengeLoadout)
                if dumpHours > 0 then
                    queueImmediateDumpTravel(worker, dumpHours, speedMultiplier)
                end
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
        if freezeWorkerForOfflineOwner(worker, currentHour) then
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

Events.OnTick.Add(Sim.OnTick)

return Sim
