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

local function normalizeMode(mode)
    return tostring(mode or "build") == "upgrade" and "upgrade" or "build"
end

local function buildBasePreview(owner, buildingType, mode, plotX, plotY, buildingID)
    local definition = Config.GetDefinition(buildingType)
    return {
        ownerUsername = owner,
        buildingType = tostring(buildingType or ""),
        displayName = tostring(definition and definition.displayName or buildingType or "Building"),
        iconPath = definition and definition.iconPath or nil,
        mode = normalizeMode(mode),
        plotX = math.floor(tonumber(plotX) or 0),
        plotY = math.floor(tonumber(plotY) or 0),
        buildingID = buildingID,
        available = false,
        canStart = false,
        reason = "Unavailable.",
        currentLevel = 0,
        targetLevel = 0,
        workPoints = 0,
        recipeAvailability = {
            hasAll = false,
            entries = {}
        },
        effects = {}
    }
end

function Buildings.ResolveProjectTarget(ownerUsername, buildingType, mode, plotX, plotY, buildingID)
    local owner = getOwnerUsername(ownerUsername)
    local normalizedBuildingType = tostring(buildingType or "")
    local normalizedMode = normalizeMode(mode)
    local definition = Config.GetDefinition(normalizedBuildingType)
    if not definition then
        return nil, "Unknown building."
    end

    local x = math.floor(tonumber(plotX) or 0)
    local y = math.floor(tonumber(plotY) or 0)
    local plot, state, instance, activeProject = Buildings.GetPlotWithState(owner, x, y)

    if normalizedMode == "upgrade" then
        if not instance then
            return nil, "There is no building to upgrade on that plot."
        end
        if tostring(instance.buildingType or "") ~= normalizedBuildingType then
            return nil, "That plot contains a different building."
        end
        if buildingID and tostring(instance.buildingID or "") ~= tostring(buildingID) then
            return nil, "That building no longer matches the selected plot."
        end
        if activeProject then
            return nil, "That plot already has an active project."
        end

        local nextLevel = math.max(1, math.floor(tonumber(instance.level) or 0) + 1)
        local nextLevelDefinition = Config.GetLevelDefinition(normalizedBuildingType, nextLevel)
        if not nextLevelDefinition or nextLevelDefinition.enabled ~= true then
            return nil, "That building cannot be upgraded further."
        end

        return {
            ownerUsername = owner,
            instance = instance,
            plot = plot,
            currentLevel = math.max(0, math.floor(tonumber(instance.level) or 0)),
            targetLevel = nextLevel,
            mode = "upgrade",
            plotX = x,
            plotY = y
        }, nil
    end

    if activeProject then
        return nil, "That plot already has an active project."
    end
    if state ~= Buildings.MapConstants.PlotStates.Empty then
        return nil, "That plot is not empty."
    end
    if plot.unlocked ~= true then
        return nil, "That plot is locked."
    end

    if normalizedBuildingType == "Headquarters" then
        if plot.kind ~= Buildings.MapConstants.PlotKinds.HQOnly or x ~= 0 or y ~= 0 then
            return nil, "Headquarters can only be built on the center plot."
        end
        if Buildings.OwnerHasHeadquarters(owner) then
            return nil, "Headquarters is already built."
        end
    else
        if plot.kind ~= Buildings.MapConstants.PlotKinds.Standard then
            return nil, "Only Headquarters can be built on this plot."
        end
        if normalizedBuildingType ~= "Barracks" then
            return nil, "That building is only a placeholder right now."
        end
    end

    local levelDefinition = Config.GetLevelDefinition(normalizedBuildingType, 1)
    if not levelDefinition or levelDefinition.enabled ~= true then
        return nil, "That building is not available yet."
    end

    return {
        ownerUsername = owner,
        instance = nil,
        plot = plot,
        currentLevel = 0,
        targetLevel = 1,
        mode = "build",
        plotX = x,
        plotY = y
    }, nil
end

function Buildings.GetWorkerProject(ownerUsername, workerID)
    for _, project in pairs(Buildings.GetProjectsForOwner(ownerUsername)) do
        if project.status == "Active" and tostring(project.assignedBuilderID or "") == tostring(workerID or "") then
            return project
        end
    end
    return nil
end

function Buildings.GetProjectForWorker(worker)
    if not worker or not worker.workerID then
        return nil
    end
    return Buildings.GetWorkerProject(worker.ownerUsername, worker.workerID)
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
    local levelDefinition = Config.GetLevelDefinition(buildingType, targetLevel)
    return buildRecipeAvailability(ownerUsername, levelDefinition and levelDefinition.recipe or {})
end

function Buildings.BuildProjectPreview(ownerUsername, buildingType, mode, plotX, plotY, buildingID)
    local owner = getOwnerUsername(ownerUsername)
    local preview = buildBasePreview(owner, buildingType, mode, plotX, plotY, buildingID)
    local target, targetReason = Buildings.ResolveProjectTarget(owner, buildingType, mode, plotX, plotY, buildingID)
    if not target then
        preview.reason = targetReason or preview.reason
        return preview
    end

    local levelDefinition = Config.GetLevelDefinition(buildingType, target.targetLevel)
    if not levelDefinition or levelDefinition.enabled ~= true then
        preview.reason = "That level is not available yet."
        return preview
    end

    preview.available = true
    preview.currentLevel = math.max(0, math.floor(tonumber(target.currentLevel) or 0))
    preview.targetLevel = math.max(1, math.floor(tonumber(target.targetLevel) or 1))
    preview.buildingID = target.instance and target.instance.buildingID or preview.buildingID
    preview.workPoints = math.max(1, math.floor(tonumber(levelDefinition.workPoints) or 1))
    preview.recipeAvailability = buildRecipeAvailability(owner, levelDefinition.recipe)
    preview.effects = Internal.CopyDeep(levelDefinition.effects or {})
    preview.canStart = preview.recipeAvailability.hasAll == true
    preview.reason = preview.canStart and nil or "Missing required materials."
    return preview
end

function Buildings.BuildPlotBuildOptions(ownerUsername, plotX, plotY)
    local options = {}
    for _, definition in ipairs(Config.GetDefinitionList and Config.GetDefinitionList() or {}) do
        local preview = Buildings.BuildProjectPreview(ownerUsername, definition.buildingType, "build", plotX, plotY, nil)
        local description = "Placeholder building."
        local effectLines = {}

        if definition.buildingType == "Headquarters" then
            description = "Establishes the settlement core. Upgrading Headquarters unlocks new outer plots around your base."
            if preview.targetLevel and preview.targetLevel > 1 then
                effectLines[#effectLines + 1] = "Unlocks the next Headquarters border expansion."
            else
                effectLines[#effectLines + 1] = "Required to begin settlement expansion."
            end
        elseif definition.buildingType == "Barracks" then
            description = "Provides housing for your workers and improves recovery for the occupants living inside."
            if preview.effects and preview.effects.housingSlots then
                effectLines[#effectLines + 1] = "Housing Slots: " .. tostring(preview.effects.housingSlots)
            end
            if preview.effects and preview.effects.recoveryMultiplier then
                effectLines[#effectLines + 1] = "Recovery Multiplier: x" .. tostring(preview.effects.recoveryMultiplier)
            end
        else
            description = "Planned for a future update. This building is shown as a placeholder for expansion."
            effectLines[#effectLines + 1] = "Currently unavailable in this build."
        end

        options[#options + 1] = {
            buildingType = definition.buildingType,
            displayName = definition.displayName,
            iconPath = definition.iconPath,
            enabled = preview.available == true,
            disabledReason = preview.available == true and nil or preview.reason,
            preview = preview,
            description = description,
            effectLines = effectLines
        }
    end
    return options
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
    if Buildings.GetWorkerProject(worker.ownerUsername, worker.workerID) then
        return false, "That builder already has an active project."
    end
    local registry = getRegistry()
    if registry and registry.WorkerHasRequiredTools and not registry.WorkerHasRequiredTools(worker) then
        return false, "That builder is missing required tools."
    end
    return true, nil
end

function Buildings.CanDestroyBuilding(ownerUsername, plotX, plotY, buildingID)
    local owner = getOwnerUsername(ownerUsername)
    local x = math.floor(tonumber(plotX) or 0)
    local y = math.floor(tonumber(plotY) or 0)
    local building = Buildings.FindBuildingAtPlot(owner, x, y)
    if not building or math.floor(tonumber(building.level) or 0) <= 0 then
        return false, "There is no completed building on that plot.", nil
    end
    if buildingID and tostring(building.buildingID or "") ~= tostring(buildingID) then
        return false, "That building no longer matches the selected plot.", nil
    end
    if tostring(building.buildingType or "") == "Headquarters" then
        return false, "Headquarters cannot be destroyed.", nil
    end
    if Buildings.GetActiveProjectAtPlot(owner, x, y) then
        return false, "You cannot destroy a building while a project is active on that plot.", nil
    end
    return true, nil, building
end

Internal.BuildingsConsumeRecipe = consumeRecipe

return Buildings
