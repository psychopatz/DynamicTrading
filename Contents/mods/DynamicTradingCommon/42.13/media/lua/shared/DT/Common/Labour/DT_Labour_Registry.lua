require "DT/Common/Labour/DT_Labour_Config"
require "DT/Common/Labour/DT_Labour_Nutrition"

DT_Labour = DT_Labour or {}
DT_Labour.Registry = DT_Labour.Registry or {}

local Config = DT_Labour.Config
local Nutrition = DT_Labour.Nutrition
local Registry = DT_Labour.Registry

local function ensureArray(value)
    return type(value) == "table" and value or {}
end

local function copyShallow(source)
    local copy = {}
    for key, value in pairs(source or {}) do
        copy[key] = value
    end
    return copy
end

local function buildStarterNutritionLedger(template)
    local existing = copyShallow(template and template.nutritionLedger or nil)
    if #existing > 0 then
        return existing
    end

    local templateCalories = tonumber(template and template.caloriesCached) or 0
    local templateHydration = tonumber(template and template.hydrationCached) or 0
    if templateCalories > 0 or templateHydration > 0 then
        return existing
    end

    local starterCalories = Config.RandomRangeInclusive(
        Config.RECRUIT_START_CALORIES_MIN,
        Config.RECRUIT_START_CALORIES_MAX
    )
    local starterHydration = Config.RandomRangeInclusive(
        Config.RECRUIT_START_HYDRATION_MIN,
        Config.RECRUIT_START_HYDRATION_MAX
    )

    existing[#existing + 1] = Nutrition.BuildStarterReserveEntry(starterCalories, starterHydration)
    return existing
end

function Registry.Init()
    if not ModData.exists(Config.MOD_DATA_KEY) then
        ModData.add(Config.MOD_DATA_KEY, {
            Workers = {},
            Owners = {},
            Sites = {},
            Counters = { worker = 0, site = 0 }
        })
    end

    local data = ModData.get(Config.MOD_DATA_KEY)
    data.Workers = data.Workers or {}
    data.Owners = data.Owners or {}
    data.Sites = data.Sites or {}
    data.Counters = data.Counters or { worker = 0, site = 0 }
end

Events.OnInitGlobalModData.Add(Registry.Init)

function Registry.GetData()
    if not ModData.exists(Config.MOD_DATA_KEY) then
        Registry.Init()
    end
    return ModData.get(Config.MOD_DATA_KEY)
end

function Registry.Save()
    if GlobalModData and GlobalModData.save then
        GlobalModData.save()
    end
end

function Registry.NextID(kind)
    local data = Registry.GetData()
    local key = kind == "site" and "site" or "worker"
    data.Counters[key] = (data.Counters[key] or 0) + 1
    return data.Counters[key]
end

function Registry.EnsureOwner(ownerUsername)
    local owner = Config.GetOwnerUsername(ownerUsername)
    local data = Registry.GetData()
    if not data.Owners[owner] then
        data.Owners[owner] = { workerIDs = {}, recruitAttempts = {} }
    end
    data.Owners[owner].workerIDs = data.Owners[owner].workerIDs or {}
    data.Owners[owner].recruitAttempts = data.Owners[owner].recruitAttempts or {}
    return data.Owners[owner]
end

function Registry.RecalculateWorker(worker)
    if not worker then return end

    worker.nutritionLedger = ensureArray(worker.nutritionLedger)
    worker.toolLedger = ensureArray(worker.toolLedger)
    worker.outputLedger = ensureArray(worker.outputLedger)
    worker.moneyStored = math.max(0, math.floor(tonumber(worker.moneyStored) or 0))
    worker.jobType = Config.NormalizeJobType(worker.jobType or worker.profession)
    worker.archetypeID = Config.NormalizeArchetypeID(worker.archetypeID or worker.profession)
    worker.profession = worker.profession or worker.jobType
    if (tonumber(worker.dailyHydrationNeed) or 0) > 0 and (tonumber(worker.dailyHydrationNeed) or 0) < 25 then
        worker.dailyHydrationNeed = (tonumber(worker.dailyHydrationNeed) or 0) * (Config.HYDRATION_POINTS_PER_THIRST or 1000)
    end

    local calories = 0
    local hydration = 0
    local outputCount = 0
    local tags = {}

    for i = #worker.nutritionLedger, 1, -1 do
        local entry = worker.nutritionLedger[i]
        local entryCalories = tonumber(entry and entry.caloriesRemaining) or 0
        local entryHydration = tonumber(entry and entry.hydrationRemaining) or 0
        if entryHydration > 0 and entryHydration < 25 then
            entryHydration = entryHydration * (Config.HYDRATION_POINTS_PER_THIRST or 1000)
            entry.hydrationRemaining = entryHydration
        end

        if entryCalories <= 0 and entryHydration <= 0 then
            table.remove(worker.nutritionLedger, i)
        else
            calories = calories + entryCalories
            hydration = hydration + entryHydration
        end
    end

    for i = #worker.toolLedger, 1, -1 do
        local entry = worker.toolLedger[i]
        if not entry or not entry.fullType then
            table.remove(worker.toolLedger, i)
        else
            for _, tag in ipairs(entry.tags or {}) do
                tags[tag] = true
            end
        end
    end

    for _, entry in ipairs(worker.outputLedger) do
        outputCount = outputCount + (tonumber(entry.qty) or 0)
    end

    worker.caloriesCached = calories
    worker.hydrationCached = hydration
    worker.outputCount = outputCount
    worker.assignedToolTags = tags
end

function Registry.WorkerHasRequiredTools(worker)
    local profile = Config.GetJobProfile(worker and worker.jobType)
    Registry.RecalculateWorker(worker)
    local tagMap = worker and worker.assignedToolTags or {}

    for _, requiredTag in ipairs(profile.requiredToolTags or {}) do
        local matched = false
        for itemTag, enabled in pairs(tagMap or {}) do
            if enabled and Config.TagMatches(itemTag, requiredTag) then
                matched = true
                break
            end
        end
        if not matched then
            return false
        end
    end

    return true
end

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
        workProgress = tonumber(template.workProgress) or 0,
        caloriesCached = tonumber(template.caloriesCached) or 0,
        hydrationCached = tonumber(template.hydrationCached) or 0,
        dailyCaloriesNeed = tonumber(template.dailyCaloriesNeed) or profile.dailyCaloriesNeed,
        dailyHydrationNeed = tonumber(template.dailyHydrationNeed) or profile.dailyHydrationNeed,
        starvationHours = tonumber(template.starvationHours) or 0,
        dehydrationHours = tonumber(template.dehydrationHours) or 0,
        nutritionLedger = buildStarterNutritionLedger(template),
        toolLedger = copyShallow(template.toolLedger),
        outputLedger = copyShallow(template.outputLedger),
        moneyStored = math.max(0, math.floor(tonumber(template.moneyStored) or 0)),
        statusFlags = copyShallow(template.statusFlags),
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

function Registry.GetRecruitAttempt(ownerUsername, sourceNPCID)
    if not sourceNPCID then return nil end
    local ownerData = Registry.EnsureOwner(ownerUsername)
    return ownerData.recruitAttempts[tostring(sourceNPCID)]
end

function Registry.SetRecruitAttempt(ownerUsername, sourceNPCID, attemptData)
    if not sourceNPCID then return nil end
    local ownerData = Registry.EnsureOwner(ownerUsername)
    local key = tostring(sourceNPCID)
    if attemptData == nil then
        ownerData.recruitAttempts[key] = nil
        return nil
    end

    ownerData.recruitAttempts[key] = copyShallow(attemptData)
    return ownerData.recruitAttempts[key]
end

function Registry.FindWorkerBySourceID(ownerUsername, sourceNPCID)
    if not sourceNPCID then return nil end

    local owner = Config.GetOwnerUsername(ownerUsername)
    for _, worker in ipairs(Registry.GetWorkersForOwner(owner)) do
        if worker.sourceNPCID and tostring(worker.sourceNPCID) == tostring(sourceNPCID) then
            return worker
        end
    end

    return nil
end

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
        workX = worker.workX,
        workY = worker.workY,
        workZ = worker.workZ or 0,
        assignedSiteID = worker.assignedSiteID,
        toolState = worker.toolState,
        siteState = worker.siteState,
        caloriesCached = worker.caloriesCached or 0,
        hydrationCached = worker.hydrationCached or 0,
        outputCount = worker.outputCount or 0,
        moneyStored = worker.moneyStored or 0,
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

function Registry.AddNutritionEntry(worker, entry)
    if not worker or not entry then return end
    worker.nutritionLedger = worker.nutritionLedger or {}
    worker.nutritionLedger[#worker.nutritionLedger + 1] = entry
    Registry.RecalculateWorker(worker)
end

function Registry.AddToolEntry(worker, entry)
    if not worker or not entry then return end
    worker.toolLedger = worker.toolLedger or {}
    worker.toolLedger[#worker.toolLedger + 1] = entry
    Registry.RecalculateWorker(worker)
end

function Registry.AddOutputEntry(worker, entry)
    if not worker or not entry or not entry.fullType then return end
    worker.outputLedger = worker.outputLedger or {}

    for _, existing in ipairs(worker.outputLedger) do
        if existing.fullType == entry.fullType then
            existing.qty = (existing.qty or 0) + (entry.qty or 1)
            Registry.RecalculateWorker(worker)
            return
        end
    end

    worker.outputLedger[#worker.outputLedger + 1] = {
        fullType = entry.fullType,
        qty = entry.qty or 1
    }
    Registry.RecalculateWorker(worker)
end

function Registry.AddMoney(worker, amount)
    if not worker then return end
    worker.moneyStored = math.max(0, math.floor(tonumber(worker.moneyStored) or 0) + math.floor(tonumber(amount) or 0))
    Registry.RecalculateWorker(worker)
end

function Registry.CollectOutput(worker)
    local output = worker and worker.outputLedger or {}
    worker.outputLedger = {}
    Registry.RecalculateWorker(worker)
    return output
end

function Registry.SetWorkerState(worker, state)
    if worker then
        worker.state = state
    end
end

function Registry.SetWorkerJobEnabled(worker, enabled)
    if worker then
        worker.jobEnabled = enabled == true
    end
end

function Registry.SetWorkerJobType(worker, jobType)
    if not worker then return end
    worker.jobType = Config.NormalizeJobType(jobType)
    worker.profession = worker.jobType
    worker.workProgress = 0
end

function Registry.UpsertSite(site)
    local data = Registry.GetData()
    if not site.siteID then
        site.siteID = "site_" .. tostring(Registry.NextID("site"))
    end
    data.Sites[site.siteID] = site
    return site
end

function Registry.GetSite(siteID)
    local data = Registry.GetData()
    return siteID and data.Sites[siteID] or nil
end

function Registry.AssignSiteToWorker(worker, site)
    if not worker or not site then return end
    Registry.UpsertSite(site)
    worker.assignedSiteID = site.siteID
    worker.workX = site.x
    worker.workY = site.y
    worker.workZ = site.z or 0
    worker.radius = site.radius or Config.DEFAULT_SITE_RADIUS
    worker.siteType = site.siteType
end

function Registry.ClearWorkerSite(worker)
    if not worker then return end
    worker.assignedSiteID = nil
    worker.workX = nil
    worker.workY = nil
    worker.workZ = nil
    worker.siteState = "Deferred"
end

return Registry
