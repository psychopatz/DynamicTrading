DT_SupplyWindow = DT_SupplyWindow or {}
DT_SupplyWindow.Internal = DT_SupplyWindow.Internal or {}

local Internal = DT_SupplyWindow.Internal

function Internal.getCommandModule()
    local config = Internal.Config
    if type(config) == "table" and config.COMMAND_MODULE and config.COMMAND_MODULE ~= "" then
        return config.COMMAND_MODULE
    end
    return "DynamicTrading_V2"
end

function Internal.getLocalPlayer()
    local config = Internal.Config
    if config.GetPlayerObject then
        return config.GetPlayerObject()
    end
    if getSpecificPlayer then
        return getSpecificPlayer(0)
    end
    return getPlayer and getPlayer() or nil
end

function Internal.resolveWorkerDetail(workerID)
    if not workerID then
        return nil
    end

    if isClient() and not isServer() then
        local cache = DT_MainWindow and DT_MainWindow.cachedDetails or nil
        return cache and cache[workerID] or nil
    end

    if DT_Labour and DT_Labour.Registry and DT_Labour.Registry.GetWorkerDetailsForOwner then
        local owner = nil
        local player = Internal.getLocalPlayer()
        if Internal.Config and Internal.Config.GetOwnerUsername then
            owner = Internal.Config.GetOwnerUsername(player)
        end
        return DT_Labour.Registry.GetWorkerDetailsForOwner(owner or "local", workerID)
    end

    return nil
end

