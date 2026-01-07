local function OnDataSync(key, data)
    if key == "DynamicTrading_Engine_v1.1" then
        if DynamicTradingUI.instance and DynamicTradingUI.instance:isVisible() then
            DynamicTradingUI.instance:populateList()
        end
    end
end
Events.OnReceiveGlobalModData.Add(OnDataSync)

local function OnServerCommand(module, command, args)
    if module == "DynamicTrading" and command == "TransactionResult" then
        if DynamicTradingUI.instance and DynamicTradingUI.instance:isVisible() then
            if args.msg then
                DynamicTradingUI.instance:logLocal(args.msg, not args.success)
            end
            if args.success then
                getSpecificPlayer(0):playSound("Transaction")
                DynamicTradingUI.instance:populateList()
            end
        end
    end
end
Events.OnServerCommand.Add(OnServerCommand)