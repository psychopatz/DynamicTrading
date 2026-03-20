DT_SupplyWindow = DT_SupplyWindow or {}
DT_SupplyWindow.Internal = DT_SupplyWindow.Internal or {}

local Internal = DT_SupplyWindow.Internal

local function onServerCommand(module, command, args)
    if module ~= Internal.getCommandModule() then
        return
    end
    if not DT_SupplyWindow.instance or not DT_SupplyWindow.instance:getIsVisible() then
        return
    end
    if command == "SyncWorkerDetails" or command == "SyncPlayerWorkers" then
        DT_SupplyWindow.instance:startInventoryScan()
    end
end

if not DT_SupplyWindow.EventsAdded then
    Events.OnServerCommand.Add(onServerCommand)
    DT_SupplyWindow.EventsAdded = true
end
