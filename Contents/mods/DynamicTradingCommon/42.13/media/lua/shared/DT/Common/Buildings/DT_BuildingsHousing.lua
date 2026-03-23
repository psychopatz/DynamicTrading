DT_Buildings = DT_Buildings or {}
DT_Buildings.Internal = DT_Buildings.Internal or {}

local Buildings = DT_Buildings
local Config = Buildings.Config
local Internal = Buildings.Internal

local function getRegistry()
    return DT_Labour and DT_Labour.Registry or nil
end

local function isLivingWorker(worker)
    local deadState = DT_Labour
        and DT_Labour.Config
        and DT_Labour.Config.States
        and DT_Labour.Config.States.Dead
        or "Dead"
    return worker and tostring(worker.state or "") ~= tostring(deadState)
end

local function getLivingWorkers(ownerUsername)
    local registry = getRegistry()
    local workers = registry and registry.GetWorkersForOwnerRaw and registry.GetWorkersForOwnerRaw(ownerUsername)
        or registry and registry.GetWorkersForOwner and registry.GetWorkersForOwner(ownerUsername)
        or {}
    local living = {}
    for _, worker in ipairs(workers or {}) do
        if isLivingWorker(worker) then
            living[#living + 1] = worker
        end
    end

    table.sort(living, function(a, b)
        return tostring(a.workerID or "") < tostring(b.workerID or "")
    end)
    return living
end

local function getBarracksInstances(ownerUsername)
    local instances = {}
    for _, instance in ipairs(Buildings.GetBuildingsForOwner(ownerUsername)) do
        if tostring(instance.buildingType or "") == "Barracks" and tonumber(instance.level) and tonumber(instance.level) > 0 then
            instances[#instances + 1] = instance
        end
    end

    table.sort(instances, function(a, b)
        if tonumber(a.level) == tonumber(b.level) then
            return tostring(a.buildingID or "") < tostring(b.buildingID or "")
        end
        return tonumber(a.level) > tonumber(b.level)
    end)
    return instances
end

function Buildings.BuildHousingAssignment(ownerUsername)
    local workers = getLivingWorkers(ownerUsername)
    local barracksInstances = getBarracksInstances(ownerUsername)
    local assignments = {}
    local housedCount = 0
    local capacity = 0
    local buildingSummaries = {}
    local workerIndex = 1

    for _, instance in ipairs(barracksInstances) do
        local level = math.max(0, math.floor(tonumber(instance.level) or 0))
        local slots = Config.GetBarracksSlotsForLevel(level)
        local recoveryMultiplier = Config.GetBarracksRecoveryMultiplier(level)
        capacity = capacity + slots

        local summary = {
            buildingID = instance.buildingID,
            buildingType = instance.buildingType,
            level = level,
            slots = slots,
            occupied = 0,
            recoveryMultiplier = recoveryMultiplier
        }

        for slotIndex = 1, slots do
            local worker = workers[workerIndex]
            if not worker then
                break
            end

            assignments[worker.workerID] = {
                housingState = "Housed",
                buildingID = instance.buildingID,
                buildingType = instance.buildingType,
                buildingLevel = level,
                recoveryMultiplier = recoveryMultiplier,
                slotIndex = slotIndex
            }
            housedCount = housedCount + 1
            summary.occupied = summary.occupied + 1
            workerIndex = workerIndex + 1
        end

        buildingSummaries[#buildingSummaries + 1] = summary
    end

    for index = workerIndex, #workers do
        local worker = workers[index]
        assignments[worker.workerID] = {
            housingState = "Unhoused",
            buildingID = nil,
            buildingType = nil,
            buildingLevel = 0,
            recoveryMultiplier = Config.GetUnhousedRecoveryMultiplier(),
            slotIndex = nil
        }
    end

    return {
        assignments = assignments,
        buildings = buildingSummaries,
        capacity = capacity,
        housedCount = housedCount,
        unhousedCount = math.max(0, #workers - housedCount),
        livingWorkers = #workers
    }
end

function Buildings.GetWorkerHousing(ownerUsername, workerID)
    local summary = Buildings.BuildHousingAssignment(ownerUsername)
    return summary.assignments[tostring(workerID or "")] or {
        housingState = "Unhoused",
        buildingID = nil,
        buildingType = nil,
        buildingLevel = 0,
        recoveryMultiplier = Config.GetUnhousedRecoveryMultiplier(),
        slotIndex = nil
    }
end

return Buildings
