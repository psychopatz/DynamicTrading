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
    if command == "SyncWorkerDetails" then
        local worker = args and args.worker or nil
        if worker and worker.workerID == DT_SupplyWindow.instance.workerID then
            DT_SupplyWindow.instance:setWorkerData(worker)
            if DT_SupplyWindow.instance.autoRefreshPending then
                DT_SupplyWindow.instance.autoRefreshPending = nil
            else
                DT_SupplyWindow.instance:updateStatus("Supply reserves refreshed for " .. tostring(worker.name or worker.workerID) .. ".")
            end
        elseif args and args.workerID and args.workerID == DT_SupplyWindow.instance.workerID then
            DT_SupplyWindow.instance:updateStatus("This worker record was removed.")
            DT_SupplyWindow.instance:close()
        end
    elseif command == "LabourNotice" then
        if args and args.message then
            DT_SupplyWindow.instance:updateStatus(args.message)
        end
    end
end

if not DT_SupplyWindow.EventsAdded then
    Events.OnServerCommand.Add(onServerCommand)
    DT_SupplyWindow.EventsAdded = true
end
