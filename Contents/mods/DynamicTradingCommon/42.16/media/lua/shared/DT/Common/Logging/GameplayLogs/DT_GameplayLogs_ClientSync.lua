return function(context)
    local Logs = context.Logs

    if not isClient() then
        return
    end

    local function OnReceiveGlobalModData(key, data)
        if not Logs.IsGameplayLogKey(key) or type(data) ~= "table" then
            return
        end

        ModData.add(key, data)
        context.notifyLogUpdated(key)
    end

    local function OnServerCommand(module, command, args)
        if module == "DTLogs" and command == "SyncLocal" and args and args.key and args.data then
            local logData = ModData.getOrCreate(args.key)
            logData.list = args.data.list
            context.notifyLogUpdated(args.key)
        end
    end

    Events.OnReceiveGlobalModData.Add(OnReceiveGlobalModData)
    Events.OnServerCommand.Add(OnServerCommand)
end
