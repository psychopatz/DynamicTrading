DT_MainWindow = DT_MainWindow or {}
DT_MainWindow.Internal = DT_MainWindow.Internal or {}

local Internal = DT_MainWindow.Internal

function DT_MainWindow:sendLabourCommand(command, args)
    local config = Internal.Config
    local player = config.GetPlayerObject and config.GetPlayerObject() or nil
    if not player then
        return false
    end

    if isClient() and not isServer() then
        sendClientCommand(player, "DynamicTrading_V2", command, args or {})
        return true
    end

    if triggerEvent and DynamicTrading and DynamicTrading.NetworkServer and DynamicTrading.NetworkServer.HandlesSharedCommands then
        triggerEvent("OnClientCommand", "DynamicTrading_V2", command, player, args or {})
        return true
    end

    if DT_Labour and DT_Labour.Network and DT_Labour.Network.HandleCommand then
        DT_Labour.Network.HandleCommand(player, command, args or {})
        return true
    end

    return false
end
