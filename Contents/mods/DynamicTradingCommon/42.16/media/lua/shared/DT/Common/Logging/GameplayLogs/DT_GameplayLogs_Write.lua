return function(context)
    local Logs = context.Logs

    function Logs.AddEvent(channel, eventID, dataArray)
        if channel == "Factions" then
            context.warnLogIssue("Deprecated AddEvent('Factions', ...) call detected. Use AddFactionEvent(factionID, eventID, data) instead.")
            return false
        end

        return Logs.AddChannelEvent(channel, eventID, dataArray)
    end

    function Logs.AddChannelEvent(channelType, eventID, dataArray)
        if not context.validateEventType(eventID, "AddChannelEvent") then
            return false
        end

        Logs.QueueAndFlush(channelType, context.GLOBAL_TARGET_ID, eventID, dataArray)
        return true
    end

    function Logs.AddFactionEvent(factionID, eventID, dataArray)
        if not factionID or tostring(factionID) == "" then
            context.warnLogIssue("AddFactionEvent received an invalid faction ID")
            return false
        end

        if DynamicTrading.Log then
            DynamicTrading.Log("DTLogs", "Gameplay", "Write", "AddFactionEvent called | Faction: " .. tostring(factionID) .. " | Event: " .. tostring(eventID) .. " | Context: " .. (isServer() and "Server" or (isClient() and "Client" or "SinglePlayer")))
        end

        if not context.validateEventType(eventID, "AddFactionEvent") then
            return false
        end

        Logs.QueueAndFlush("Factions", tostring(factionID), eventID, dataArray)
        return true
    end

    function Logs.AddRadioEvent(eventID, dataArray)
        if DynamicTrading.Log then
            DynamicTrading.Log("DTLogs", "Gameplay", "Write", "AddRadioEvent called | Event: " .. tostring(eventID) .. " | Context: " .. (isServer() and "Server" or (isClient() and "Client" or "SinglePlayer")))
        end

        return Logs.AddChannelEvent("Radio", eventID, dataArray)
    end

    function Logs.AddPlayerRadioEvent(playerObj, eventID, dataArray)
        if not context.validateEventType(eventID, "AddPlayerRadioEvent") then
            return false
        end

        local username = playerObj and playerObj:getUsername() or nil
        if not username or username == "" then
            context.warnLogIssue("AddPlayerRadioEvent could not resolve a username")
            return false
        end

        if DynamicTrading.Log then
            DynamicTrading.Log("DTLogs", "Gameplay", "Write", "AddPlayerRadioEvent called | User: " .. tostring(username) .. " | Event: " .. tostring(eventID) .. " | Context: " .. (isServer() and "Server" or (isClient() and "Client" or "SinglePlayer")))
        end

        Logs.QueueAndFlushLocal("Radio", username, eventID, dataArray)
        return true
    end

    function Logs.AddLocalEvent(playerObj, channel, eventID, dataArray)
        if channel == "Radio" then
            return Logs.AddPlayerRadioEvent(playerObj, eventID, dataArray)
        end

        if not context.validateEventType(eventID, "AddLocalEvent") then
            return false
        end

        local username = playerObj and playerObj:getUsername() or nil
        if not username or username == "" then
            context.warnLogIssue("AddLocalEvent could not resolve a username")
            return false
        end

        Logs.QueueAndFlushLocal(channel, username, eventID, dataArray)
        return true
    end
end
