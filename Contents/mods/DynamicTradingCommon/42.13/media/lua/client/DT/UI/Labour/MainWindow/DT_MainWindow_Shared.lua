DT_MainWindow = DT_MainWindow or {}
DT_MainWindow.Internal = DT_MainWindow.Internal or {}

local Internal = DT_MainWindow.Internal

Internal.Config = DT_Labour.Config
Internal.MoneyProvider = DT_MainWindow.MoneyProvider or {}
DynamicTrading.TradingProvider.AttachCore(Internal.MoneyProvider)
DT_MainWindow.MoneyProvider = Internal.MoneyProvider

function Internal.formatReserveValue(value)
    return string.format("%.0f", tonumber(value) or 0)
end

function Internal.getReserveDaysLeft(storedAmount, dailyNeed)
    local perDay = tonumber(dailyNeed) or 0
    if perDay <= 0 then
        return "n/a"
    end

    local days = (tonumber(storedAmount) or 0) / perDay
    return string.format("%.2f", math.max(0, days))
end

function Internal.formatWorkerListSubtitle(worker)
    local archetype = tostring(worker.archetypeID or "General")
    local jobType = tostring(worker.jobType or worker.profession or "Scavenge")
    local state = tostring(worker.state or "Idle")
    return archetype .. " -> " .. jobType .. " | " .. state
end

function Internal.buildToolInputText(worker)
    local parts = {}
    for _, entry in ipairs(worker.toolLedger or {}) do
        parts[#parts + 1] = tostring(entry.displayName or entry.fullType or "Unknown Tool")
    end

    if #parts == 0 then
        return "None assigned yet."
    end

    return table.concat(parts, ", ")
end

function Internal.buildSupplyInputText(worker)
    local parts = {}
    for _, entry in ipairs(worker.nutritionLedger or {}) do
        local name = tostring(entry.displayName or entry.fullType or "Supply")
        local calories = Internal.formatReserveValue(entry.caloriesRemaining)
        local hydration = Internal.formatReserveValue(entry.hydrationRemaining)
        parts[#parts + 1] = name .. " [" .. calories .. " cal, " .. hydration .. " hyd]"
    end

    if #parts == 0 then
        return "None stored yet."
    end

    return table.concat(parts, ", ")
end

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

function Internal.resolveWorkerSummaries()
    if isClient() and not isServer() then
        return DT_MainWindow.cachedWorkers or {}
    end

    if DT_Labour and DT_Labour.Registry and DT_Labour.Registry.GetWorkerSummariesForOwner then
        return DT_Labour.Registry.GetWorkerSummariesForOwner(Internal.getOwnerUsername())
    end

    return {}
end

function Internal.resolveWorkerDetail(workerID)
    if not workerID then
        return nil
    end

    if isClient() and not isServer() then
        local cache = DT_MainWindow.cachedDetails or {}
        return cache[workerID]
    end

    if DT_Labour and DT_Labour.Registry and DT_Labour.Registry.GetWorkerDetailsForOwner then
        return DT_Labour.Registry.GetWorkerDetailsForOwner(Internal.getOwnerUsername(), workerID)
    end

    return nil
end

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

    if DT_Labour and DT_Labour.Network and DT_Labour.Network.HandleCommand then
        DT_Labour.Network.HandleCommand(player, command, args or {})
        return true
    end

    return false
end
