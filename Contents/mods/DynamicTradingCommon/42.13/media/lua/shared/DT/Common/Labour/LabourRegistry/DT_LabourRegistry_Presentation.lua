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
        workX = worker.workX,
        workY = worker.workY,
        workZ = worker.workZ or 0,
        assignedSiteID = worker.assignedSiteID,
        toolState = worker.toolState,
        siteState = worker.siteState,
        caloriesCached = worker.caloriesCached or 0,
        hydrationCached = worker.hydrationCached or 0,
        hp = worker.hp or worker.maxHp or 0,
        maxHp = worker.maxHp or Config.DEFAULT_WORKER_MAX_HP or 100,
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

return Registry
