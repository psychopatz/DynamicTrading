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

local function syncProjectPreview(player, ownerUsername, buildingType, mode)
    local owner = LabourConfig.GetOwnerUsername(ownerUsername or player)
    Internal.sendResponse(player, LabourConfig.COMMAND_MODULE, "SyncBuildingProjectPreview", {
        preview = Buildings.BuildProjectPreview(owner, buildingType, mode),
        buildingType = buildingType,
        mode = mode
    })
end

Network.Handlers.RequestOwnerBuildings = function(player, args)
    syncBuildingsSnapshot(player, player)
end

Network.Handlers.RequestBuildingProjectPreview = function(player, args)
    if not args or not args.buildingType then
        return
    end
    syncProjectPreview(player, player, args.buildingType, args.mode)
end

Network.Handlers.StartBuildingProject = function(player, args)
    if not args or not args.workerID or not args.buildingType then
        return
    end

    local owner = LabourConfig.GetOwnerUsername(player)
    local ok, reason, project = Buildings.StartProject(owner, args.workerID, args.buildingType, args.mode)
    local registry = DT_Labour and DT_Labour.Registry or nil
    local worker = registry and registry.GetWorkerForOwner and registry.GetWorkerForOwner(owner, args.workerID) or nil

    if not ok then
        if Internal.syncNotice then
            Internal.syncNotice(player, reason or "Unable to start building project.", "error", true)
        end
        if worker then
            Shared.saveAndRefreshBasic(player, worker, false)
        end
        syncBuildingsSnapshot(player, owner)
        return
    end

    if worker then
        Shared.saveAndRefreshProcessed(player, worker, false)
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

return Network
