DT_LabourSupplyWindow = DT_LabourSupplyWindow or {}
DT_LabourSupplyWindow.Internal = DT_LabourSupplyWindow.Internal or {}

local Internal = DT_LabourSupplyWindow.Internal

local function onServerCommand(module, command, args)
    if module ~= Internal.getCommandModule() then
        return
    end
    if not DT_LabourSupplyWindow.instance or not DT_LabourSupplyWindow.instance:getIsVisible() then
        return
    end
    if command == "SyncWorkerDetails" or command == "SyncPlayerWorkers" then
        DT_LabourSupplyWindow.instance:startInventoryScan()
    end
end

if not DT_LabourSupplyWindow.EventsAdded then
    Events.OnServerCommand.Add(onServerCommand)
    DT_LabourSupplyWindow.EventsAdded = true
end
