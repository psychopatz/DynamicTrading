local System = DT_System
local Internal = System.Internal

function System.CanUseDebug(player)
    local playerObj = player or Internal.GetLocalPlayer()

    if DynamicTrading and DynamicTrading.Debug then
        return true
    end

    if isDebugEnabled and isDebugEnabled() then
        return true
    end

    if playerObj and playerObj.getAccessLevel then
        local accessLevel = playerObj:getAccessLevel()
        if accessLevel and accessLevel ~= "" and accessLevel ~= "None" then
            return true
        end
    end

    return false
end

function System.ToggleWindow()
    if DT_LabourWindow and DT_LabourWindow.ToggleWindow then
        DT_LabourWindow.ToggleWindow()
    end
end

function System.OpenWindow()
    if DT_LabourWindow and DT_LabourWindow.Open then
        DT_LabourWindow.Open()
    elseif DT_LabourWindow and DT_LabourWindow.ToggleWindow then
        DT_LabourWindow.ToggleWindow()
    end
end

function System.SendCommand(command, args)
    local player = Internal.GetLocalPlayer()
    if not player then
        return false
    end

    if isClient() and not isServer() then
        sendClientCommand(player, Internal.GetCommandModule(), command, args or {})
        return true
    end

    if DT_Labour and DT_Labour.Network and DT_Labour.Network.HandleCommand then
        DT_Labour.Network.HandleCommand(player, command, args or {})
        return true
    end

    return false
end
