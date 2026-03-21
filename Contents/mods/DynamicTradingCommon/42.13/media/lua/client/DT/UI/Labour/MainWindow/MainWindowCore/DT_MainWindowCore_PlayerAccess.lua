DT_MainWindow = DT_MainWindow or {}
DT_MainWindow.Internal = DT_MainWindow.Internal or {}

local Internal = DT_MainWindow.Internal

function Internal.getPlayerWealth(player)
    if DT_MainWindow.MoneyProvider and DT_MainWindow.MoneyProvider.getPlayerWealth then
        return DT_MainWindow.MoneyProvider:getPlayerWealth(player)
    end
    return 0
end

function Internal.getOwnerUsername()
    local config = Internal.Config
    local player = config.GetPlayerObject and config.GetPlayerObject() or nil
    if config.GetOwnerUsername then
        return config.GetOwnerUsername(player)
    end
    return "local"
end

function Internal.appendHeldItem(targetList, seenIDs, itemObj)
    if not itemObj or not itemObj.getID then
        return
    end

    local itemID = itemObj:getID()
    if itemID == nil or seenIDs[itemID] then
        return
    end

    seenIDs[itemID] = true
    targetList[#targetList + 1] = itemObj
end

function Internal.getHeldItems()
    local config = Internal.Config
    local player = config.GetPlayerObject and config.GetPlayerObject() or nil
    if not player then
        return {}
    end

    local items = {}
    local seenIDs = {}
    Internal.appendHeldItem(items, seenIDs, player.getPrimaryHandItem and player:getPrimaryHandItem() or nil)
    Internal.appendHeldItem(items, seenIDs, player.getSecondaryHandItem and player:getSecondaryHandItem() or nil)
    return items
end

