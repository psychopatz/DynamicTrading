DT_MainWindow = DT_MainWindow or {}
DT_MainWindow.Internal = DT_MainWindow.Internal or {}

local Internal = DT_MainWindow.Internal

local function onServerCommand(module, command, args)
    if module ~= "DynamicTrading_V2" then
        return
    end

    if command == "SyncPlayerWorkers" then
        DT_MainWindow.cachedWorkers = args and args.workers or {}
        if DT_MainWindow.instance and DT_MainWindow.instance:getIsVisible() then
            DT_MainWindow.instance:populateWorkerList(DT_MainWindow.cachedWorkers)
            if (tonumber(DT_MainWindow.instance.syncStatusMutedFrames) or 0) <= 0 then
                DT_MainWindow.instance:updateStatus("Worker list synced.")
            end
        end
    elseif command == "SyncWorkerDetails" then
        if args and args.worker and args.worker.workerID then
            DT_MainWindow.cachedDetails = DT_MainWindow.cachedDetails or {}
            DT_MainWindow.cachedDetails[args.worker.workerID] = args.worker
            if DT_MainWindow.instance
                and DT_MainWindow.instance:getIsVisible()
                and DT_MainWindow.instance.selectedWorkerSummary
                and DT_MainWindow.instance.selectedWorkerSummary.workerID == args.worker.workerID then
                DT_MainWindow.instance:updateWorkerDetail(args.worker)
                if (tonumber(DT_MainWindow.instance.syncStatusMutedFrames) or 0) <= 0 then
                    DT_MainWindow.instance:updateStatus("Worker details synced.")
                end
            end
        end
    elseif command == "LabourNotice" then
        if DT_MainWindow.instance and DT_MainWindow.instance:getIsVisible() then
            DT_MainWindow.instance:updateStatus(args and args.message or "Labour update received.")
        end
    end
end

if not DT_MainWindow.EventsAdded then
    Events.OnServerCommand.Add(onServerCommand)
    Events.OnReceiveGlobalModData.Add(function(key, data)
        if not DT_MainWindow.instance or not DT_MainWindow.instance:getIsVisible() then
            return
        end

        if key == (Internal.Config.MOD_DATA_KEY or "DynamicTrading_Labour") then
            DT_MainWindow.instance:populateWorkerList(Internal.resolveWorkerSummaries())
            if (tonumber(DT_MainWindow.instance.syncStatusMutedFrames) or 0) <= 0 then
                DT_MainWindow.instance:updateStatus("Labour data refreshed from ModData.")
            end
        end
    end)
    DT_MainWindow.EventsAdded = true
end
