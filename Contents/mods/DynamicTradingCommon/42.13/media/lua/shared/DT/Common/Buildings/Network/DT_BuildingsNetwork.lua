require "DT/Common/Buildings/DT_Buildings"

DT_Labour = DT_Labour or {}
DT_Labour.Network = DT_Labour.Network or {}

local LabourConfig = DT_Labour.Config
local Network = DT_Labour.Network
local Buildings = DT_Buildings
local Shared = (Network.Workers or {}).Shared or {}
local Internal = Network.Internal or {}

Network.Handlers = Network.Handlers or {}

local function syncBuildingsSnapshot(player, ownerUsername)
    local owner = LabourConfig.GetOwnerUsername(ownerUsername or player)
    Internal.sendResponse(player, LabourConfig.COMMAND_MODULE, "SyncBuildingsSnapshot", {
        snapshot = Buildings.BuildOwnerSnapshot(owner)
    })
end

local function syncProjectPreview(player, ownerUsername, buildingType, mode, plotX, plotY, buildingID)
    local owner = LabourConfig.GetOwnerUsername(ownerUsername or player)
    Internal.sendResponse(player, LabourConfig.COMMAND_MODULE, "SyncBuildingProjectPreview", {
        preview = Buildings.BuildProjectPreview(owner, buildingType, mode, plotX, plotY, buildingID),
        buildingType = buildingType,
        mode = mode,
        plotX = plotX,
        plotY = plotY,
        buildingID = buildingID
    })
end

local function syncWorkerList(player)
    if Internal.syncWorkerList then
        Internal.syncWorkerList(player)
    end
end

Network.Handlers.RequestOwnerBuildings = function(player, args)
    syncBuildingsSnapshot(player, player)
end

Network.Handlers.RequestBuildingProjectPreview = function(player, args)
    if not args or not args.buildingType then
        return
    end
    syncProjectPreview(player, player, args.buildingType, args.mode, args.plotX, args.plotY, args.buildingID)
end

Network.Handlers.StartBuildingProject = function(player, args)
    if not args or not args.workerID or not args.buildingType then
        return
    end

    local owner = LabourConfig.GetOwnerUsername(player)
    local ok, reason, project = Buildings.StartProject(
        owner,
        args.workerID,
        args.buildingType,
        args.mode,
        args.plotX,
        args.plotY,
        args.buildingID
    )
    local registry = DT_Labour and DT_Labour.Registry or nil
    local worker = registry and registry.GetWorkerForOwner and registry.GetWorkerForOwner(owner, args.workerID) or nil

    if not ok then
        if Internal.syncNotice then
            Internal.syncNotice(player, reason or "Unable to start building project.", "error", true)
        end
        if worker and Shared.saveAndRefreshBasic then
            Shared.saveAndRefreshBasic(player, worker, false)
        end
        syncBuildingsSnapshot(player, owner)
        return
    end

    if worker and Shared.saveAndRefreshProcessed then
        Shared.saveAndRefreshProcessed(player, worker, false)
    elseif worker and Shared.saveAndRefreshBasic then
        Shared.saveAndRefreshBasic(player, worker, false)
    end
    if Internal.syncOwnedFactionStatus then
        Internal.syncOwnedFactionStatus(player)
    end
    if Internal.syncNotice then
        Internal.syncNotice(
            player,
            "Started " .. tostring(project.buildingType or "building") .. " level " .. tostring(project.targetLevel or 1) .. ".",
            "info",
            false
        )
    end
    syncBuildingsSnapshot(player, owner)
end

Network.Handlers.DestroyBuilding = function(player, args)
    if not args or args.plotX == nil or args.plotY == nil then
        return
    end

    local owner = LabourConfig.GetOwnerUsername(player)
    local ok, reason, building = Buildings.DestroyBuilding(owner, args.plotX, args.plotY, args.buildingID)

    if not ok then
        if Internal.syncNotice then
            Internal.syncNotice(player, reason or "Unable to destroy building.", "error", true)
        end
        syncBuildingsSnapshot(player, owner)
        return
    end

    syncWorkerList(player)
    if Internal.syncOwnedFactionStatus then
        Internal.syncOwnedFactionStatus(player)
    end
    if Internal.syncNotice then
        Internal.syncNotice(
            player,
            "Destroyed " .. tostring(building and (building.buildingType or building.displayName) or "building") .. ".",
            "info",
            false
        )
    end
    syncBuildingsSnapshot(player, owner)
end

return Network
