DT_Buildings = DT_Buildings or {}
DT_Buildings.Internal = DT_Buildings.Internal or {}

local Buildings = DT_Buildings
local Config = Buildings.Config
local Internal = Buildings.Internal

local function getLabourConfig()
    return DT_Labour and DT_Labour.Config or {}
end

local function getRegistry()
    return DT_Labour and DT_Labour.Registry or nil
end

local function getWarehouse()
    return DT_Labour and DT_Labour.Warehouse or nil
end

local function getSkills()
    return DT_Labour and DT_Labour.Skills or nil
end

local function getWorkerConstructionLevel(worker)
    local skills = getSkills()
    local entry = skills and skills.GetSkillEntry and skills.GetSkillEntry(worker, "Construction") or nil
    return math.max(0, math.floor(tonumber(entry and entry.level) or 0))
end

local function getDisplayName(fullType)
    local registry = getRegistry()
    local internal = registry and registry.Internal or nil
    return internal and internal.GetDisplayNameForFullType and internal.GetDisplayNameForFullType(fullType) or tostring(fullType or "Unknown")
end

local function getBuildingDefinition(buildingType)
    return Config.GetDefinition and Config.GetDefinition(buildingType) or nil
end

local function getLevelDefinition(buildingType, level)
    return Config.GetLevelDefinition and Config.GetLevelDefinition(buildingType, level) or nil
end

local function getOwnerUsername(playerOrUsername)
    local labourConfig = getLabourConfig()
    return labourConfig.GetOwnerUsername and labourConfig.GetOwnerUsername(playerOrUsername) or tostring(playerOrUsername or "local")
end

local function buildRecipeMap(recipe)
    local required = {}
    for _, entry in ipairs(recipe or {}) do
        local fullType = tostring(entry.fullType or "")
        local count = math.max(0, math.floor(tonumber(entry.count) or 0))
        if fullType ~= "" and count > 0 then
            required[fullType] = (required[fullType] or 0) + count
        end
    end
    return required
end

local function hasRecipeEntries(required)
    for _, _ in pairs(required or {}) do
        return true
    end
    return false
end

local function getWarehouseOutputCounts(ownerUsername)
    local warehouseApi = getWarehouse()
    local warehouse = warehouseApi and warehouseApi.GetOwnerWarehouse and warehouseApi.GetOwnerWarehouse(ownerUsername) or nil
    local counts = {}
    for _, entry in ipairs(warehouse and warehouse.ledgers and warehouse.ledgers.output or {}) do
        local fullType = tostring(entry.fullType or "")
        local qty = math.max(0, math.floor(tonumber(entry.qty) or 0))
        if fullType ~= "" and qty > 0 then
            counts[fullType] = (counts[fullType] or 0) + qty
        end
    end
    return counts
end

local function buildRecipeAvailability(ownerUsername, recipe)
    local availableCounts = getWarehouseOutputCounts(ownerUsername)
    local entries = {}
    local hasAll = true

    for _, entry in ipairs(recipe or {}) do
        local fullType = tostring(entry.fullType or "")
        local required = math.max(0, math.floor(tonumber(entry.count) or 0))
        local available = availableCounts[fullType] or 0
        local recipeEntry = {
            fullType = fullType,
            displayName = getDisplayName(fullType),
            count = required,
            available = available,
            satisfied = available >= required
        }
        if recipeEntry.satisfied ~= true then
            hasAll = false
        end
        entries[#entries + 1] = recipeEntry
    end

    return {
        hasAll = hasAll,
        entries = entries
    }
end

local function consumeRecipe(ownerUsername, recipe)
    local warehouseApi = getWarehouse()
    local warehouse = warehouseApi and warehouseApi.GetOwnerWarehouse and warehouseApi.GetOwnerWarehouse(ownerUsername) or nil
    if not warehouse then
        return false
    end

    local required = buildRecipeMap(recipe)
    if not hasRecipeEntries(required) then
        return true
    end

    local outputLedger = warehouse.ledgers and warehouse.ledgers.output or {}

    for fullType, needed in pairs(required) do
        local available = 0
        for _, entry in ipairs(outputLedger) do
            if entry.fullType == fullType then
                available = available + math.max(0, math.floor(tonumber(entry.qty) or 0))
            end
        end
        if available < needed then
            return false
        end
    end

    for index = #outputLedger, 1, -1 do
        local entry = outputLedger[index]
        local fullType = tostring(entry and entry.fullType or "")
        local needed = required[fullType]
        if needed and needed > 0 and entry then
            local qty = math.max(0, math.floor(tonumber(entry.qty) or 0))
            local toTake = math.min(qty, needed)
            qty = qty - toTake
            required[fullType] = needed - toTake
            if qty <= 0 then
                table.remove(outputLedger, index)
            else
                entry.qty = qty
            end
        end
    end

    if warehouseApi and warehouseApi.Recalculate then
        warehouseApi.Recalculate(warehouse)
    end
    return true
end

local function findProjectByBuilder(ownerUsername, workerID)
    for _, project in pairs(Buildings.GetProjectsForOwner(ownerUsername)) do
        if project.status == "Active" and tostring(project.assignedBuilderID or "") == tostring(workerID or "") then
            return project
        end
    end
    return nil
end

local function findActiveProject(ownerUsername, projectID)
    local project = Buildings.GetProjectsForOwner(ownerUsername)[tostring(projectID or "")]
    if project and project.status == "Active" then
        return project
    end
    return nil
end

local function getProjectTarget(ownerUsername, buildingType, mode)
    local definition = getBuildingDefinition(buildingType)
    if not definition then
        return nil, "Unknown building."
    end
    if definition.enabled ~= true then
        return nil, "That building is not available yet."
    end

    local instances = {}
    for _, instance in ipairs(Buildings.GetBuildingsForOwner(ownerUsername)) do
        if tostring(instance.buildingType or "") == tostring(buildingType or "") then
            instances[#instances + 1] = instance
        end
    end

    table.sort(instances, function(a, b)
        if tonumber(a.level) == tonumber(b.level) then
            return tostring(a.buildingID or "") < tostring(b.buildingID or "")
        end
        return tonumber(a.level) < tonumber(b.level)
    end)

    if mode == "upgrade" then
        for _, instance in ipairs(instances) do
            local nextLevel = math.max(1, math.floor(tonumber(instance.level) or 0) + 1)
            if nextLevel <= math.max(0, math.floor(tonumber(definition.maxLevel) or 0))
                and getLevelDefinition(buildingType, nextLevel)
                and getLevelDefinition(buildingType, nextLevel).enabled == true then
                return {
                    instance = instance,
                    currentLevel = math.max(0, math.floor(tonumber(instance.level) or 0)),
                    targetLevel = nextLevel,
                    mode = "upgrade"
                }, nil
            end
        end
        return nil, "No existing building can be upgraded."
    end

    return {
        instance = nil,
        currentLevel = 0,
        targetLevel = 1,
        mode = "build"
    }, nil
end

function Buildings.GetWorkerProject(ownerUsername, workerID)
    return findProjectByBuilder(ownerUsername, workerID)
end

function Buildings.GetProjectForWorker(worker)
    if not worker or not worker.workerID then
        return nil
    end
    return findProjectByBuilder(worker.ownerUsername, worker.workerID)
end

function Buildings.GetProjectDisplayState(ownerUsername, workerID)
    local project = Buildings.GetWorkerProject(ownerUsername, workerID)
    if not project then
        return {
            hasProject = false,
            label = "No Project"
        }
    end

    return {
        hasProject = true,
        label = tostring(project.buildingType or "Project") .. " L" .. tostring(project.targetLevel or 1),
        project = project
    }
end

function Buildings.GetRecipeAvailability(ownerUsername, buildingType, targetLevel)
    local levelDefinition = getLevelDefinition(buildingType, targetLevel)
    return buildRecipeAvailability(ownerUsername, levelDefinition and levelDefinition.recipe or {})
end

function Buildings.BuildProjectPreview(ownerUsername, buildingType, mode)
    local owner = getOwnerUsername(ownerUsername)
    local preview = {
        ownerUsername = owner,
        buildingType = tostring(buildingType or ""),
        mode = tostring(mode or "build"),
        available = false,
        canStart = false,
        reason = "Unavailable.",
        currentLevel = 0,
        targetLevel = 0,
        buildingID = nil,
        workPoints = 0,
        recipeAvailability = {
            hasAll = false,
            entries = {}
        },
        effects = {}
    }

    local target, targetReason = getProjectTarget(owner, buildingType, mode)
    if not target then
        preview.reason = targetReason or preview.reason
        return preview
    end

    local levelDefinition = getLevelDefinition(buildingType, target.targetLevel)
    if not levelDefinition or levelDefinition.enabled ~= true then
        preview.reason = "That level is not available yet."
        return preview
    end

    preview.available = true
    preview.currentLevel = math.max(0, math.floor(tonumber(target.currentLevel) or 0))
    preview.targetLevel = math.max(1, math.floor(tonumber(target.targetLevel) or 1))
    preview.buildingID = target.instance and target.instance.buildingID or nil
    preview.workPoints = math.max(1, math.floor(tonumber(levelDefinition.workPoints) or 1))
    preview.recipeAvailability = buildRecipeAvailability(owner, levelDefinition.recipe)
    preview.effects = Internal.CopyDeep(levelDefinition.effects or {})
    preview.canStart = preview.recipeAvailability.hasAll == true
    preview.reason = preview.canStart and nil or "Missing required materials."

    return preview
end

function Buildings.CanWorkerBuild(worker)
    local labourConfig = getLabourConfig()
    if not worker or not worker.workerID then
        return false, "Builder not found."
    end
    if tostring(worker.state or "") == tostring(labourConfig.States and labourConfig.States.Dead or "Dead") then
        return false, "That worker is dead."
    end
    if labourConfig.NormalizeJobType and labourConfig.NormalizeJobType(worker.jobType) ~= tostring(labourConfig.JobTypes and labourConfig.JobTypes.Builder or "Builder") then
        return false, "That worker is not assigned to Builder."
    end
    if getWorkerConstructionLevel(worker) <= 0 then
        return false, "That worker has no Construction skill."
    end
    if findProjectByBuilder(worker.ownerUsername, worker.workerID) then
        return false, "That builder already has an active project."
    end
    local registry = getRegistry()
    if registry and registry.WorkerHasRequiredTools and not registry.WorkerHasRequiredTools(worker) then
        return false, "That builder is missing required tools."
    end
    return true, nil
end

function Buildings.StartProject(ownerUsername, workerID, buildingType, mode)
    local owner = getOwnerUsername(ownerUsername)
    local registry = getRegistry()
    local worker = registry and registry.GetWorkerForOwner and registry.GetWorkerForOwner(owner, workerID) or nil
    local canBuild, workerReason = Buildings.CanWorkerBuild(worker)
    if not canBuild then
        return false, workerReason, nil
    end

    local target, targetReason = getProjectTarget(owner, buildingType, mode)
    if not target then
        return false, targetReason, nil
    end

    local levelDefinition = getLevelDefinition(buildingType, target.targetLevel)
    if not levelDefinition or levelDefinition.enabled ~= true then
        return false, "That level is not available yet.", nil
    end

    local recipeAvailability = buildRecipeAvailability(owner, levelDefinition.recipe)
    if recipeAvailability.hasAll ~= true then
        return false, "Missing required materials.", nil
    end

    if not consumeRecipe(owner, levelDefinition.recipe) then
        return false, "Unable to reserve the required materials.", nil
    end

    local ownerProjects = Buildings.GetProjectsForOwner(owner)
    local project = {
        projectID = "project_" .. tostring(Buildings.NextID("project")),
        ownerUsername = owner,
        buildingType = tostring(buildingType or ""),
        buildingID = target.instance and target.instance.buildingID or nil,
        currentLevel = math.max(0, math.floor(tonumber(target.currentLevel) or 0)),
        targetLevel = math.max(1, math.floor(tonumber(target.targetLevel) or 1)),
        assignedBuilderID = worker.workerID,
        progressWorkPoints = 0,
        requiredWorkPoints = math.max(1, math.floor(tonumber(levelDefinition.workPoints) or 1)),
        recipe = Internal.CopyDeep(levelDefinition.recipe or {}),
        xpReward = math.max(0, math.floor(tonumber(levelDefinition.xpReward) or 0)),
        status = "Active",
        mode = target.mode,
        startedWorldHours = (getLabourConfig().GetCurrentWorldHours and getLabourConfig().GetCurrentWorldHours()) or 0,
        failureReason = nil
    }
    ownerProjects[project.projectID] = project
    Buildings.Save()
    return true, nil, project
end

function Buildings.CompleteProject(project)
    if not project then
        return nil
    end

    local owner = getOwnerUsername(project.ownerUsername)
    local instance = project.buildingID and Buildings.FindBuildingForOwner(owner, project.buildingID) or nil
    if not instance then
        instance = Buildings.CreateBuildingInstance(owner, project.buildingType, 0)
        project.buildingID = instance.buildingID
    end

    instance.level = math.max(0, math.floor(tonumber(project.targetLevel) or tonumber(instance.level) or 0))
    project.status = "Completed"
    Buildings.Save()
    return instance
end

function Buildings.FailProject(project, reason)
    if not project then
        return
    end
    project.status = "Failed"
    project.failureReason = tostring(reason or "Unknown")
    Buildings.Save()
end

function Buildings.ProcessWorkerProject(worker, currentHour, workableHours, speedMultiplier)
    local project = Buildings.GetProjectForWorker(worker)
    if not project or project.status ~= "Active" then
        return {
            hadProject = false,
            didWork = false,
            completed = false
        }
    end

    local progressGain = math.max(
        0,
        (math.max(0, tonumber(workableHours) or 0) * Config.GetBuilderBaseWorkPointsPerHour() * math.max(0.01, tonumber(speedMultiplier) or 1))
    )
    project.progressWorkPoints = math.max(0, tonumber(project.progressWorkPoints) or 0) + progressGain

    local result = {
        hadProject = true,
        didWork = progressGain > 0,
        completed = false,
        project = project
    }

    if project.progressWorkPoints + 0.0001 >= math.max(1, tonumber(project.requiredWorkPoints) or 1) then
        result.completed = true
        result.instance = Buildings.CompleteProject(project)

        local skills = getSkills()
        if skills and skills.GrantXP then
            result.xpResult = skills.GrantXP(worker, "Construction", project.xpReward or 0)
        end
    end

    return result
end

function Buildings.GetOwnerProjectList(ownerUsername)
    local projects = {}
    for _, project in pairs(Buildings.GetProjectsForOwner(ownerUsername)) do
        if tostring(project.status or "") == "Active" then
            projects[#projects + 1] = project
        end
    end

    table.sort(projects, function(a, b)
        return tostring(a.projectID or "") < tostring(b.projectID or "")
    end)
    return projects
end

return Buildings
