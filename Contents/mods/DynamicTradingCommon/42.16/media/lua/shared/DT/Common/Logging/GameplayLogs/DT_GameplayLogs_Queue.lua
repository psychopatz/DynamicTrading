return function(context)
    local Logs = context.Logs
    local pendingLogs = context.pendingLogs

    function Logs.Queue(channelType, targetID, eventType, dataArray)
        if not channelType or not targetID or not context.validateEventType(eventType, "Queue") then
            return false
        end

        pendingLogs[channelType] = pendingLogs[channelType] or {}
        pendingLogs[channelType][targetID] = pendingLogs[channelType][targetID] or {}

        table.insert(pendingLogs[channelType][targetID], {
            t = context.getTimestamp(),
            e = eventType,
            d = dataArray
        })

        return true
    end

    function Logs.FlushChannel(channelType)
        if not channelType or not pendingLogs[channelType] then
            return
        end

        local hasChanges = false
        local modDataKey = Logs.GetStorageKey(channelType)
        local logData = ModData.getOrCreate(modDataKey)
        local maxCount = context.getMaxEvents()

        for targetID, pendingBatch in pairs(pendingLogs[channelType]) do
            if #pendingBatch > 0 then
                hasChanges = true
                local list, assignCombined = context.getChannelTargetList(logData, targetID)
                local keepCount = math.max(0, maxCount - #pendingBatch)
                local combined = {}

                for i = #pendingBatch, 1, -1 do
                    table.insert(combined, pendingBatch[i])
                end

                for i = 1, math.min(#list, keepCount) do
                    table.insert(combined, list[i])
                end

                assignCombined(combined)
            end
        end

        if hasChanges then
            ModData.transmit(modDataKey)
            if not isClient() then
                context.notifyLogUpdated(modDataKey)
            end
            pendingLogs[channelType] = {}
        end
    end

    function Logs.FlushAll()
        for channelType, _ in pairs(pendingLogs) do
            Logs.FlushChannel(channelType)
        end
    end

    function Logs.QueueAndFlush(channelType, targetID, eventType, dataArray)
        if not Logs.Queue(channelType, targetID, eventType, dataArray) then
            return false
        end

        Logs.FlushChannel(channelType)
        return true
    end
end
