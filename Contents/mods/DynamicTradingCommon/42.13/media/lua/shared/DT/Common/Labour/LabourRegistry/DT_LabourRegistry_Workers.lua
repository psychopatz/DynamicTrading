DT_Labour = DT_Labour or {}
DT_Labour.Registry = DT_Labour.Registry or {}
DT_Labour.Registry.Internal = DT_Labour.Registry.Internal or {}

local Config = DT_Labour.Config
local Registry = DT_Labour.Registry
local Internal = Registry.Internal

function Registry.CreateWorker(ownerUsername, template)
    template = template or {}
    local owner = Config.GetOwnerUsername(ownerUsername)
    local ownerData = Registry.EnsureOwner(owner)
    local archetypeID = Config.NormalizeArchetypeID(template.archetypeID or template.profession)
    local jobType = Config.NormalizeJobType(template.jobType or template.profession or Config.GetDefaultJobForArchetype(archetypeID))
    local profile = Config.GetJobProfile(jobType)
    local data = Registry.GetData()
    local workerID = template.workerID or ("worker_" .. tostring(Registry.NextID("worker")))
    local currentHour = Config.GetCurrentHour()

    local worker = {
        ownerUsername = owner,
        workerID = workerID,
        name = template.name or (jobType .. " Worker " .. tostring(data.Counters.worker)),
        profession = template.profession or jobType,
        jobType = jobType,
        archetypeID = archetypeID,
        state = template.state or Config.States.Idle,
        assignedSiteID = template.assignedSiteID,
        workX = template.workX,
        workY = template.workY,
        workZ = template.workZ or 0,
        radius = template.radius or Config.DEFAULT_SITE_RADIUS,
        toolState = template.toolState or "Missing",
        siteState = template.siteState or "Deferred",
        jobEnabled = template.jobEnabled ~= false,
        lastSimHour = template.lastSimHour or currentHour,
        lastNutritionCheckpoint = tonumber(template.lastNutritionCheckpoint) or Config.GetMealCheckpointCountAtHour(template.lastSimHour or currentHour),
        workProgress = tonumber(template.workProgress) or 0,
        caloriesCached = tonumber(template.caloriesCached) or 0,
        hydrationCached = tonumber(template.hydrationCached) or 0,
        dailyCaloriesNeed = tonumber(template.dailyCaloriesNeed) or profile.dailyCaloriesNeed,
        dailyHydrationNeed = tonumber(template.dailyHydrationNeed) or profile.dailyHydrationNeed,
        maxHp = math.max(1, tonumber(template.maxHp) or tonumber(template.healthMax) or Config.DEFAULT_WORKER_MAX_HP or 100),
        hp = tonumber(template.hp) or tonumber(template.health),
        starvationHours = tonumber(template.starvationHours) or 0,
        dehydrationHours = tonumber(template.dehydrationHours) or 0,
        nutritionLedger = Internal.BuildStarterNutritionLedger(template),
        toolLedger = Internal.CopyShallow(template.toolLedger),
        outputLedger = Internal.CopyShallow(template.outputLedger),
        moneyStored = math.max(0, math.floor(tonumber(template.moneyStored) or 0)),
        statusFlags = Internal.CopyShallow(template.statusFlags),
        isFemale = template.isFemale,
        identitySeed = template.identitySeed,
        visualID = template.visualID,
        sourceNPCID = template.sourceNPCID,
        sourceNPCType = template.sourceNPCType
    }

    if worker.isFemale == nil then
        worker.isFemale = ZombRand(2) == 0
    end
    if not worker.identitySeed then
        worker.identitySeed = ZombRand(1000) + 1
    end
    if not worker.visualID then
        worker.visualID = ZombRand(1000000)
    end
    if worker.hp == nil then
        worker.hp = worker.maxHp
    end

    Registry.RecalculateWorker(worker)
    data.Workers[workerID] = worker

    local exists = false
    for _, existingID in ipairs(ownerData.workerIDs) do
        if existingID == workerID then
            exists = true
            break
        end
    end
    if not exists then
        table.insert(ownerData.workerIDs, workerID)
    end

    Registry.Save()
    return worker
end

function Registry.GetWorker(workerID)
    local data = Registry.GetData()
    local worker = data.Workers[workerID]
    if worker then
        Registry.RecalculateWorker(worker)
    end
    return worker
end

function Registry.GetWorkerForOwner(ownerUsername, workerID)
    local worker = Registry.GetWorker(workerID)
    if not worker then return nil end
    if worker.ownerUsername ~= Config.GetOwnerUsername(ownerUsername) then
        return nil
    end
    return worker
end

function Registry.GetWorkersForOwner(ownerUsername)
    local owner = Config.GetOwnerUsername(ownerUsername)
    local ownerData = Registry.EnsureOwner(owner)
    local workers = {}

    for _, workerID in ipairs(ownerData.workerIDs or {}) do
        local worker = Registry.GetWorker(workerID)
        if worker then
            workers[#workers + 1] = worker
        end
    end

    table.sort(workers, function(a, b)
        return tostring(a.name or a.workerID) < tostring(b.name or b.workerID)
    end)

    return workers
end

return Registry
