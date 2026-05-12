return function(context)
    local Logs = context.Logs
    local pendingLocalLogs = context.pendingLocalLogs

    function Logs.QueueLocal(channelType, username, eventType, dataArray)
        if not channelType or not username or not context.validateEventType(eventType, "QueueLocal") then
            return false
        end

        pendingLocalLogs[channelType] = pendingLocalLogs[channelType] or {}
        pendingLocalLogs[channelType][username] = pendingLocalLogs[channelType][username] or {}

        table.insert(pendingLocalLogs[channelType][username], {
            t = context.getTimestamp(),
            e = eventType,
            d = dataArray
        })

        return true
    end

    function Logs.FlushLocal(channelType)
        if not channelType or not pendingLocalLogs[channelType] then
            return
        end

        local hasChanges = false
        local maxCount = context.getMaxEvents()

        for username, pendingBatch in pairs(pendingLocalLogs[channelType]) do
            if #pendingBatch > 0 then
                hasChanges = true
                local modDataKey = Logs.GetLocalStorageKey(channelType, username)
                local logData = ModData.getOrCreate(modDataKey)
                local list = logData.list or {}
                local keepCount = math.max(0, maxCount - #pendingBatch)
                local combined = {}

                for i = #pendingBatch, 1, -1 do
                    table.insert(combined, pendingBatch[i])
                end

                for i = 1, math.min(#list, keepCount) do
                    table.insert(combined, list[i])
                end

                logData.list = combined

                if isServer() then
                    local playerObj = getPlayerFromUsername(username)
                    if playerObj then
                        sendServerCommand(playerObj, "DTLogs", "SyncLocal", { key = modDataKey, data = logData })
                    end
                else
                    context.notifyLogUpdated(modDataKey)
                end
            end
        end

        if hasChanges then
            pendingLocalLogs[channelType] = {}
        end
    end

    function Logs.QueueAndFlushLocal(channelType, username, eventType, dataArray)
        if not Logs.QueueLocal(channelType, username, eventType, dataArray) then
            return false
        end

        Logs.FlushLocal(channelType)
        return true
    end
end
