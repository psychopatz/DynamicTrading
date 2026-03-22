require "DT/Common/Labour/LabourConfig/DT_LabourConfig"
require "DT/Common/Labour/LabourRegistry/DT_LabourRegistry"
require "DT/Common/Labour/DT_Labour_Sites"
require "DT/Common/Labour/LabourNutrition/DT_LabourNutrition"
require "DT/Common/Labour/DT_Labour_Output"
require "DT/Common/Labour/DT_Labour_Presentation"
require "DT/Common/Labour/DT_Labour_Interaction"

DT_Labour = DT_Labour or {}
DT_Labour.Sim = DT_Labour.Sim or {}

local Config = DT_Labour.Config
local Registry = DT_Labour.Registry
local Sites = DT_Labour.Sites
local Nutrition = DT_Labour.Nutrition
local Output = DT_Labour.Output
local Presentation = DT_Labour.Presentation
local Interaction = DT_Labour.Interaction
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

local function formatNaturalList(values)
    local count = #(values or {})
    if count <= 0 then
        return ""
    end
    if count == 1 then
        return tostring(values[1])
    end
    if count == 2 then
        return tostring(values[1]) .. " and " .. tostring(values[2])
    end
    return tostring(values[1]) .. ", " .. tostring(values[2]) .. ", and " .. tostring(count - 2) .. " more"
end

local function buildFoundItemsClause(entries)
    local names = {}
    local hiddenCount = 0

    for _, entry in ipairs(entries or {}) do
        if entry and entry.fullType then
            local qty = math.max(1, tonumber(entry.qty) or 1)
            local itemName = getOutputDisplayName(entry.fullType)
            local displayName = qty > 1 and (itemName .. " x" .. tostring(qty)) or itemName
            if #names < 2 then
                names[#names + 1] = displayName
            else
                hiddenCount = hiddenCount + 1
            end
        end
    end

    if #names <= 0 then
        return ""
    end

    local text = formatNaturalList(names)
    if hiddenCount > 0 then
        if #names == 1 then
            text = text .. " and " .. tostring(hiddenCount) .. " more"
        else
            text = text .. ", and " .. tostring(hiddenCount) .. " more"
        end
    end

    return text
end

local function getScavengeToolSummary(worker)
    local names = {}
    local seen = {}
    for _, entry in ipairs(worker and worker.toolLedger or {}) do
        local name = tostring(entry and entry.displayName or entry and entry.fullType or "")
        if name ~= "" and not seen[name] then
            seen[name] = true
            names[#names + 1] = name
        end
    end

    if #names <= 0 then
        return "bare hands"
    end

    return formatNaturalList(names)
end

local function getScavengeLocationLabel(worker, run)
    local livePlace = Interaction and Interaction.GetPlaceLabel and Interaction.GetPlaceLabel(worker) or nil
    if livePlace and tostring(livePlace) ~= "" then
        return tostring(livePlace)
    end

    local siteProfile = run and run.siteProfile or nil
    local displayName = siteProfile and siteProfile.displayName or worker and worker.scavengeSiteProfileLabel or worker and worker.scavengeSiteRoomName or nil
    if displayName and tostring(displayName) ~= "" then
        return tostring(displayName)
    end
    return "the outskirts"
end

local function getOutcomeTokens(worker, count, placeLabel)
    local safeCount = math.max(0, tonumber(count) or 0)
    return {
        count = tostring(safeCount),
        item_word = safeCount == 1 and "item" or "items",
        place = tostring(placeLabel or Interaction.GetPlaceLabel(worker) or "Work Site")
    }
end

local function logJobCycleOutcome(worker, currentHour, count, placeLabel, entries)
    if not worker then
        return
    end

    local jobType = Config.NormalizeJobType(worker.jobType)
    local totalCount = math.max(0, tonumber(count) or 0)
    local outcomeKey = totalCount > 0 and "Recovered" or "Empty"
    local message = Interaction.BuildOutcomeMessage(worker, jobType, outcomeKey, getOutcomeTokens(worker, totalCount, placeLabel))
    local foundItems = buildFoundItemsClause(entries)

    if message and message ~= "" then
        if foundItems ~= "" and totalCount > 0 then
            message = message .. " Found: " .. foundItems .. "."
        end
        appendWorkerLog(worker, message, currentHour, "output")
    end
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

local function getScavengePresenceState(worker)
    local presenceState = worker and worker.presenceState or nil
    local states = Config.PresenceStates or {}
    if presenceState == states.AwayToSite
        or presenceState == states.Scavenging
        or presenceState == states.AwayToHome then
        return presenceState
    end
    return states.Home
end

local function getScavengeTravelHours()
    return math.max(
        0,
        tonumber(Config.GetScavengeTravelHours and Config.GetScavengeTravelHours())
            or tonumber(Config.DEFAULT_SCAVENGE_TRAVEL_HOURS)
            or 0
    )
end

local function ensureWorkerHome(worker)
    if not worker then
        return
    end

    if worker.homeX == nil or worker.homeY == nil then
        if worker.workX ~= nil and worker.workY ~= nil then
            worker.homeX = math.floor(tonumber(worker.workX) or 0)
            worker.homeY = math.floor(tonumber(worker.workY) or 0)
            worker.homeZ = math.floor(tonumber(worker.workZ) or 0)
        end
    end
end

local function getAvailableProvisionTotals(worker)
    local activeCalories, activeHydration = Nutrition.GetOnBodyTotals(worker)
    return math.max(0, tonumber(activeCalories) or 0) + math.max(0, tonumber(worker and worker.storedCalories) or 0),
        math.max(0, tonumber(activeHydration) or 0) + math.max(0, tonumber(worker and worker.storedHydration) or 0)
end

local function getRequiredTravelReserve(worker, profile, multiplier)
    local factor = math.max(0, tonumber(multiplier) or 1)
    local travelHours = getScavengeTravelHours()
    return math.max(0, tonumber(Config.GetEffectiveHourlyCaloriesNeed(worker, profile)) or 0) * travelHours * factor,
        math.max(0, tonumber(Config.GetEffectiveHourlyHydrationNeed(worker, profile)) or 0) * travelHours * factor
end

local function getReturnHomeMessage(reason)
    return Interaction.BuildReturnReasonMessage(reason)
end

local function getDeathFlavorText(worker, normalizedJobType, presenceState, hasCalories, hasHydration)
    local isScavenge = normalizedJobType == Config.JobTypes.Scavenge
    local away = presenceState == Config.PresenceStates.AwayToSite
        or presenceState == Config.PresenceStates.Scavenging
        or presenceState == Config.PresenceStates.AwayToHome

    if not hasCalories and not hasHydration then
        if isScavenge and away then
            return "Never made it back from the run. Hunger and thirst finally took them."
        end
        return "Succumbed to starvation and dehydration."
    end

    if not hasHydration then
        if isScavenge and away then
            return "Collapsed on the road, dried out and delirious."
        end
        return "Collapsed from severe dehydration."
    end

    if not hasCalories then
        if isScavenge and away then
            return "Ran themselves hollow on the job and never made it home."
        end
        return "Succumbed to starvation."
    end

    if isScavenge and away then
        return "Never made it back from the run. Their injuries finally caught up."
    end

    return "Succumbed to their injuries."
end

local function markWorkerDead(worker, currentHour, normalizedJobType, presenceState, hasCalories, hasHydration)
    if not worker then
        return
    end

    local deathCause = tostring(worker.deathCause or "")
    if deathCause == "" then
        deathCause = getDeathFlavorText(worker, normalizedJobType, presenceState, hasCalories, hasHydration)
        worker.deathCause = deathCause
        appendWorkerLog(worker, deathCause, currentHour, "death")
    end

    worker.state = Config.States.Dead
    worker.jobEnabled = false
    worker.presenceState = Config.PresenceStates.Home
    worker.travelHoursRemaining = 0
    worker.returnReason = nil
end

local function startScavengeOutbound(worker, currentHour)
    if not worker then
        return
    end

    worker.presenceState = Config.PresenceStates.AwayToSite
    worker.travelHoursRemaining = getScavengeTravelHours()
    worker.returnReason = nil
    appendWorkerLog(
        worker,
        Interaction.BuildOutcomeMessage(worker, Config.JobTypes.Scavenge, "TravelStarted", {
            place = Interaction.GetPlaceLabel(worker)
        }) or ("Set out for " .. getScavengeLocationLabel(worker) .. "."),
        currentHour,
        "travel"
    )
end

local function beginScavengeReturnHome(worker, currentHour, reason, travelHours)
    if not worker then
        return false
    end

    local presenceState = getScavengePresenceState(worker)
    if presenceState == Config.PresenceStates.Home or presenceState == Config.PresenceStates.AwayToHome then
        return false
    end

    worker.jobEnabled = false
    worker.presenceState = Config.PresenceStates.AwayToHome
    worker.travelHoursRemaining = math.max(0, tonumber(travelHours) or getScavengeTravelHours())
    worker.returnReason = reason or Config.ReturnReasons.Manual
    appendWorkerLog(worker, getReturnHomeMessage(worker.returnReason), currentHour, "travel")
    return true
end

local function completeScavengeReturnHome(worker, currentHour)
    if not worker then
        return
    end

    worker.presenceState = Config.PresenceStates.Home
    worker.travelHoursRemaining = 0
    worker.dumpCooldownHours = 0

    local movedStacks, movedCount, movedRawWeight = Registry.DumpCarriedHaul(worker)
    if movedStacks > 0 then
        worker.dumpTrips = math.max(0, tonumber(worker.dumpTrips) or 0) + 1
        appendWorkerLog(
            worker,
            Interaction.BuildOutcomeMessage(worker, Config.JobTypes.Scavenge, "ReturnedHomeWithItems", {
                count = tostring(movedCount),
                item_word = movedCount == 1 and "item" or "items",
                place = Interaction.GetPlaceLabel(worker)
            }) or ("Returned home and stowed " .. tostring(movedCount) .. " items."),
            currentHour,
            "haul"
        )
        return
    end

    appendWorkerLog(
        worker,
        Interaction.BuildOutcomeMessage(worker, Config.JobTypes.Scavenge, "ReturnedHome", {
            place = Interaction.GetPlaceLabel(worker)
        }) or "Returned home.",
        currentHour,
        "travel"
    )
end

local function progressScavengeTravel(worker, currentHour, deltaHours)
    if not worker or deltaHours <= 0 then
        return
    end

    local presenceState = getScavengePresenceState(worker)
    if presenceState ~= Config.PresenceStates.AwayToSite and presenceState ~= Config.PresenceStates.AwayToHome then
        return
    end

    worker.travelHoursRemaining = math.max(0, clampHours(worker.travelHoursRemaining) - deltaHours)
    if worker.travelHoursRemaining > 0 then
        return
    end

    if presenceState == Config.PresenceStates.AwayToSite then
        worker.presenceState = Config.PresenceStates.Scavenging
        appendWorkerLog(
            worker,
            Interaction.BuildOutcomeMessage(worker, Config.JobTypes.Scavenge, "ArrivedAtSite", {
                place = Interaction.GetPlaceLabel(worker)
            }) or ("Arrived at " .. getScavengeLocationLabel(worker) .. "."),
            currentHour,
            "travel"
        )
        return
    end

    completeScavengeReturnHome(worker, currentHour)
end

local function shouldReturnForFullHaul(worker, loadout)
    if not worker then
        return false
    end

    local haulMetrics = Registry.GetHaulMetrics and Registry.GetHaulMetrics(worker) or nil
    local effectiveCarryLimit = tonumber(loadout and loadout.effectiveCarryLimit)
        or tonumber((haulMetrics and haulMetrics.effectiveCarryLimit))
        or tonumber(worker.effectiveCarryLimit)
        or (Config.GetWorkerBaseCarryWeight and Config.GetWorkerBaseCarryWeight(worker))
        or (Config.GetDefaultWorkerCarryWeight and Config.GetDefaultWorkerCarryWeight())
        or tonumber(Config.DEFAULT_WORKER_CARRY_WEIGHT)
        or 8
    return haulMetrics ~= nil and (tonumber(haulMetrics.effectiveWeight) or 0) >= effectiveCarryLimit
end

function Sim.ProcessWorker(worker, currentHour)
    if not worker then return end

    Registry.RecalculateWorker(worker)

    local profile = Config.GetJobProfile(worker.jobType)
    local speedMultiplier = Config.GetJobSpeedMultiplier(worker.archetypeID, worker.jobType)
    local normalizedJobType = Config.NormalizeJobType(worker.jobType)
    local scavengeLoadout = nil
    local cycleHours = Config.GetEffectiveCycleHours and Config.GetEffectiveCycleHours(worker, profile) or (profile.cycleHours or 24)
    local baseWorkSpeedMultiplier = Config.GetBaseWorkSpeedMultiplier and Config.GetBaseWorkSpeedMultiplier(worker, profile) or 1.0
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

    speedMultiplier = speedMultiplier * (tonumber(baseWorkSpeedMultiplier) or 1)
    worker.workCycleHours = cycleHours
    worker.baseWorkSpeedMultiplier = baseWorkSpeedMultiplier

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
    if normalizedJobType == Config.JobTypes.Scavenge then
        ensureWorkerHome(worker)
        worker.presenceState = getScavengePresenceState(worker)
        if worker.presenceState == Config.PresenceStates.Home and worker.haulLedger and #worker.haulLedger > 0 then
            completeScavengeReturnHome(worker, currentHour)
        end
        worker.dumpCooldownHours = math.max(0, tonumber(worker.travelHoursRemaining) or 0)
    end

    local dailyCaloriesNeed = Config.GetEffectiveDailyCaloriesNeed(worker, profile)
    local dailyHydrationNeed = Config.GetEffectiveDailyHydrationNeed(worker, profile)
    local canWork = worker.jobEnabled and toolsReady
    if normalizedJobType == Config.JobTypes.Scavenge then
        canWork = canWork and worker.presenceState == Config.PresenceStates.Scavenging
    end
    local workableHours, hasCalories, hasHydration, hp = processNutrition(
        worker,
        currentHour,
        dailyCaloriesNeed,
        dailyHydrationNeed,
        canWork
    )

    worker.starvationHours = 0
    worker.dehydrationHours = 0

    if normalizedJobType == Config.JobTypes.Scavenge then
        local totalCaloriesAvailable, totalHydrationAvailable = getAvailableProvisionTotals(worker)
        local returnCaloriesThreshold, returnHydrationThreshold = getRequiredTravelReserve(worker, profile, 1)
        local outboundCaloriesThreshold, outboundHydrationThreshold = getRequiredTravelReserve(worker, profile, 2)
        local presenceState = getScavengePresenceState(worker)

        if hp <= 0 then
            markWorkerDead(worker, currentHour, normalizedJobType, presenceState, hasCalories, hasHydration)
        else
            if not worker.assignedSiteID and presenceState ~= Config.PresenceStates.Home then
                beginScavengeReturnHome(worker, currentHour, Config.ReturnReasons.MissingSite, worker.travelHoursRemaining)
                presenceState = getScavengePresenceState(worker)
            elseif not toolsReady and presenceState ~= Config.PresenceStates.Home then
                beginScavengeReturnHome(worker, currentHour, Config.ReturnReasons.MissingTool, worker.travelHoursRemaining)
                presenceState = getScavengePresenceState(worker)
            end

            if presenceState ~= Config.PresenceStates.Home and presenceState ~= Config.PresenceStates.AwayToHome then
                if totalHydrationAvailable < returnHydrationThreshold then
                    beginScavengeReturnHome(worker, currentHour, Config.ReturnReasons.LowDrink)
                    presenceState = getScavengePresenceState(worker)
                elseif totalCaloriesAvailable < returnCaloriesThreshold then
                    beginScavengeReturnHome(worker, currentHour, Config.ReturnReasons.LowFood)
                    presenceState = getScavengePresenceState(worker)
                end
            end

            if not worker.jobEnabled and presenceState ~= Config.PresenceStates.Home and presenceState ~= Config.PresenceStates.AwayToHome then
                beginScavengeReturnHome(
                    worker,
                    currentHour,
                    Config.ReturnReasons.Manual,
                    presenceState == Config.PresenceStates.AwayToSite and worker.travelHoursRemaining or nil
                )
                presenceState = getScavengePresenceState(worker)
            end

            if worker.jobEnabled
                and presenceState == Config.PresenceStates.Home
                and worker.assignedSiteID
                and toolsReady
                and hasCalories
                and hasHydration
                and totalCaloriesAvailable >= outboundCaloriesThreshold
                and totalHydrationAvailable >= outboundHydrationThreshold then
                startScavengeOutbound(worker, currentHour)
                presenceState = getScavengePresenceState(worker)
            end

            if presenceState == Config.PresenceStates.AwayToSite or presenceState == Config.PresenceStates.AwayToHome then
                progressScavengeTravel(worker, currentHour, deltaHours)
                presenceState = getScavengePresenceState(worker)
            end

            if presenceState == Config.PresenceStates.Scavenging and worker.jobEnabled and toolsReady and hasCalories and hasHydration then
                worker.state = Config.States.Working
                worker.workProgress = clampHours(worker.workProgress) + (workableHours * speedMultiplier)
                while worker.workProgress >= cycleHours do
                    worker.workProgress = worker.workProgress - cycleHours

                    local scavengeRun = Output.GenerateScavengeRun and Output.GenerateScavengeRun(worker) or { entries = {} }
                    for _, entry in ipairs(scavengeRun.entries or {}) do
                        Registry.AddHaulEntry(worker, entry)
                    end
                    logJobCycleOutcome(worker, currentHour, scavengeRun.totalQuantity, getScavengeLocationLabel(worker, scavengeRun), scavengeRun.entries)

                    if shouldReturnForFullHaul(worker, scavengeLoadout) then
                        beginScavengeReturnHome(worker, currentHour, Config.ReturnReasons.FullHaul)
                        break
                    end
                end
            end

            presenceState = getScavengePresenceState(worker)
            worker.dumpCooldownHours = math.max(0, tonumber(worker.travelHoursRemaining) or 0)

            if hp <= 0 then
                markWorkerDead(worker, currentHour, normalizedJobType, presenceState, hasCalories, hasHydration)
            elseif not hasHydration then
                worker.state = Config.States.Dehydrated
            elseif not hasCalories then
                worker.state = Config.States.Starving
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
        markWorkerDead(worker, currentHour, normalizedJobType, Config.PresenceStates.Home, hasCalories, hasHydration)
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
        while worker.workProgress >= cycleHours do
            worker.workProgress = worker.workProgress - cycleHours
            local entries = Output.GenerateForJob(profile, worker)
            local totalQuantity = 0
            for _, entry in ipairs(entries) do
                Registry.AddOutputEntry(worker, entry)
                totalQuantity = totalQuantity + math.max(1, tonumber(entry.qty) or 1)
            end
            logJobCycleOutcome(worker, currentHour, totalQuantity, Interaction.GetPlaceLabel(worker), entries)
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
