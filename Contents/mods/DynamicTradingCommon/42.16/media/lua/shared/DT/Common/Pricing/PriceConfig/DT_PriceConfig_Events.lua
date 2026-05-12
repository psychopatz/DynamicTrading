local PriceConfig = DynamicTrading.PriceConfig

local function onReceiveGlobalModData(key, data)
    if key ~= PriceConfig.MOD_DATA_KEY or type(data) ~= "table" then
        return
    end

    PriceConfig.HandleSyncPayload(data)
end

local function onServerCommand(module, command, args)
    if module ~= "DynamicTrading" then
        return
    end

    if command == "SyncPriceConfig" and type(args) == "table" then
        PriceConfig.HandleSyncPayload(args)
    elseif command == "PriceConfigActionResult" then
        if LuaEventManager and LuaEventManager.OnDynamicTradingPriceConfigActionResult then
            triggerEvent("OnDynamicTradingPriceConfigActionResult", args or {})
        end
    end
end

Events.OnReceiveGlobalModData.Add(onReceiveGlobalModData)
Events.OnServerCommand.Add(onServerCommand)
Events.OnInitGlobalModData.Add(PriceConfig.Init)
