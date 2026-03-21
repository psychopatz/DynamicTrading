DT_Labour = DT_Labour or {}
DT_Labour.Registry = DT_Labour.Registry or {}
DT_Labour.Registry.Internal = DT_Labour.Registry.Internal or {}

local Config = DT_Labour.Config
local Registry = DT_Labour.Registry

function Registry.GetWorkerSummary(worker)
    Registry.RecalculateWorker(worker)
    return {
        ownerUsername = worker.ownerUsername,
        workerID = worker.workerID,
        name = worker.name,
        profession = worker.profession,
        jobType = worker.jobType,
        archetypeID = Config.NormalizeArchetypeID(worker.archetypeID or worker.profession),
        state = worker.state,
        jobEnabled = worker.jobEnabled,
        presenceState = worker.presenceState,
        travelHoursRemaining = worker.travelHoursRemaining,
        returnReason = worker.returnReason,
        homeX = worker.homeX,
        homeY = worker.homeY,
        homeZ = worker.homeZ or 0,
        workX = worker.workX,
        workY = worker.workY,
        workZ = worker.workZ or 0,
        assignedSiteID = worker.assignedSiteID,
        toolState = worker.toolState,
        siteState = worker.siteState,
        deathCause = worker.deathCause,
        caloriesCached = worker.caloriesCached or 0,
        hydrationCached = worker.hydrationCached or 0,
        caloriesOverflow = worker.caloriesOverflow or 0,
        hydrationOverflow = worker.hydrationOverflow or 0,
        currentCaloriesBuffer = worker.currentCaloriesBuffer or worker.caloriesCached or 0,
        currentHydrationBuffer = worker.currentHydrationBuffer or worker.hydrationCached or 0,
        carryoverCalories = worker.carryoverCalories or worker.caloriesOverflow or 0,
        carryoverHydration = worker.carryoverHydration or worker.hydrationOverflow or 0,
        bufferCaloriesTotal = worker.bufferCaloriesTotal or worker.reserveCaloriesTotal or (worker.caloriesCached or 0),
        bufferHydrationTotal = worker.bufferHydrationTotal or worker.reserveHydrationTotal or (worker.hydrationCached or 0),
        provisionCaloriesReserve = worker.provisionCaloriesReserve or worker.storedCalories or 0,
        provisionHydrationReserve = worker.provisionHydrationReserve or worker.storedHydration or 0,
        combinedCaloriesTotal = worker.combinedCaloriesTotal or worker.totalCaloriesAvailable or (worker.caloriesCached or 0),
        combinedHydrationTotal = worker.combinedHydrationTotal or worker.totalHydrationAvailable or (worker.hydrationCached or 0),
        reserveCaloriesTotal = worker.reserveCaloriesTotal or (worker.caloriesCached or 0),
        reserveHydrationTotal = worker.reserveHydrationTotal or (worker.hydrationCached or 0),
        storedCalories = worker.storedCalories or 0,
        storedHydration = worker.storedHydration or 0,
        totalCaloriesAvailable = worker.totalCaloriesAvailable or (worker.caloriesCached or 0),
        totalHydrationAvailable = worker.totalHydrationAvailable or (worker.hydrationCached or 0),
        hp = worker.hp or worker.maxHp or 0,
        maxHp = worker.maxHp or Config.DEFAULT_WORKER_MAX_HP or 100,
        outputCount = worker.outputCount or 0,
        moneyStored = worker.moneyStored or 0,
        scavengeTier = worker.scavengeTier,
        scavengeTierLabel = worker.scavengeTierLabel,
        scavengePoolRolls = worker.scavengePoolRolls,
        scavengeFailureWeight = worker.scavengeFailureWeight,
        scavengeSearchSpeedMultiplier = worker.scavengeSearchSpeedMultiplier,
        scavengeCapabilities = worker.scavengeCapabilities,
        scavengeSiteProfileID = worker.scavengeSiteProfileID,
        scavengeSiteProfileLabel = worker.scavengeSiteProfileLabel,
        scavengeSiteRoomName = worker.scavengeSiteRoomName,
        scavengeSiteZoneType = worker.scavengeSiteZoneType,
        haulCount = worker.haulCount,
        haulRawWeight = worker.haulRawWeight,
        haulEffectiveWeight = worker.haulEffectiveWeight,
        baseCarryWeight = worker.baseCarryWeight,
        effectiveCarryLimit = worker.effectiveCarryLimit,
        maxCarryWeight = worker.maxCarryWeight,
        rawCarryAllowance = worker.rawCarryAllowance,
        carryContainerCount = worker.carryContainerCount,
        dumpCooldownHours = worker.dumpCooldownHours,
        dumpTrips = worker.dumpTrips,
        outputWeight = worker.outputWeight,
        isFemale = worker.isFemale,
        identitySeed = worker.identitySeed
    }
end

function Registry.GetWorkerSummariesForOwner(ownerUsername)
    local summaries = {}
    for _, worker in ipairs(Registry.GetWorkersForOwner(ownerUsername)) do
        summaries[#summaries + 1] = Registry.GetWorkerSummary(worker)
    end
    return summaries
end

function Registry.GetWorkerDetailsForOwner(ownerUsername, workerID)
    local worker = Registry.GetWorkerForOwner(ownerUsername, workerID)
    if not worker then return nil end
    Registry.RecalculateWorker(worker)
    return worker
end

return Registry
