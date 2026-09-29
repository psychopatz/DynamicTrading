DTCommon = DTCommon or {}

local Service = DTCommon.TraderService or {}
DTCommon.TraderService = Service

local Inventory = require "PsychopatzCore/Inventory/PsychopatzInventory"
local Storage = DTCommon.Storage
local Stock = DTCommon.TraderStock
local Support = DTCommon.TraderSupport

local function authority()
    return Storage and Storage.IsAuthority and Storage.IsAuthority() == true
end

local function applyCaravanCapacity(record, store)
    local usedWeight
    local maxWeight
    local caravan = rawget(_G, "DTHoomans")
        and DTHoomans.Caravan or nil
    if caravan and type(caravan.GetCapacity) == "function" then
        usedWeight, maxWeight = caravan.GetCapacity(record)
        if tonumber(maxWeight) and tonumber(maxWeight) > 0 then
            store.maxWeight = tonumber(maxWeight)
        end
    end
    return tonumber(usedWeight) or store:getWeight(),
        tonumber(maxWeight) or tonumber(store.maxWeight) or 0
end

-- Optional canonical name provider. Project Hoomans owns NPC identity, so the
-- DTHoomans bridge - when loaded - supplies the merchant's real display name.
-- DT's own record label stays only as the degraded fallback. Mirrors
-- applyCaravanCapacity: the bridge is optional and costs nothing when absent.
local function applyCanonicalDisplayName(record, snapshot)
    local caravan = rawget(_G, "DTHoomans")
        and DTHoomans.Caravan or nil
    local name
    if not snapshot or not caravan
        or type(caravan.ResolveTraderDisplayName) ~= "function"
    then
        return
    end
    name = caravan.ResolveTraderDisplayName(record)
    if type(name) == "string" and name ~= "" then
        snapshot.displayName = name
    end
end

function Service.Snapshot(traderID)
    local record = Service.GetRecord(traderID)
    if not record then return nil, "trader_not_found" end
    local store, loadReason = Storage.LoadInventory(record)
    local usedWeight
    local maxWeight
    local items, reason = Stock.SnapshotItems(record)
    if loadReason then return nil, loadReason end
    if reason then return nil, reason end
    usedWeight, maxWeight = applyCaravanCapacity(record, store)
    local snapshot = Service.Get(traderID)
    applyCanonicalDisplayName(record, snapshot)
    snapshot.items = items
    snapshot.usedWeight = usedWeight
    snapshot.maxWeight = maxWeight
    return snapshot
end

local function failure(traderID, operation, reason)
    return {
        accepted = false,
        traderID = traderID,
        operation = operation,
        reason = reason,
    }
end

function Service.ExecuteTrade(player, request)
    if not authority() then return failure(nil, nil, "server_authority_required") end
    request = type(request) == "table" and request or {}
    local traderID = Support.Bounded(request.traderID, 128)
    local operation = string.upper(Support.Bounded(request.operation, 16))
    local fullType = Support.Bounded(request.fullType, 160)
    local quantity = Support.PositiveInteger(request.quantity, 1, 100)
    local record = Service.GetRecord(traderID)
    if not record then return failure(traderID, operation, "trader_not_found") end
    if operation ~= DTCommon.OP_BUY and operation ~= DTCommon.OP_SELL then
        return failure(traderID, operation, "operation_not_supported")
    end
    if fullType == "" then return failure(traderID, operation, "item_required") end
    local observedVersion = tonumber(request.observedStockVersion)
    if observedVersion
        and math.floor(observedVersion) ~= math.floor(tonumber(record.v) or 0)
    then
        return failure(traderID, operation, "stale_stock")
    end

    local stock, stockReason = Storage.LoadInventory(record)
    if not stock then return failure(traderID, operation, stockReason) end
    applyCaravanCapacity(record, stock)
    local price = Stock.MarketPrice(fullType)
    local total = price * quantity
    local physical
    if not player or type(player.getInventory) ~= "function" then
        return failure(traderID, operation, "player_inventory_unavailable")
    end
    physical = Inventory.wrapPhysicalInventory(player:getInventory(), {
        syncOnMutation = true,
    })
    if not physical then return failure(traderID, operation, "inventory_unavailable") end

    if operation == DTCommon.OP_BUY then
        if stock:count(fullType) < quantity then
            return failure(traderID, operation, "insufficient_stock")
        end
        if physical:count(DTCommon.MONEY_FULL_TYPE) < total then
            return failure(traderID, operation, "insufficient_money")
        end
        local removedMoney, removeReason = physical:remove(
            DTCommon.MONEY_FULL_TYPE, total)
        if not removedMoney then return failure(traderID, operation, removeReason) end
        local moved, moveReason = Inventory.transfer(
            stock, physical, fullType, quantity)
        if not moved then
            physical:restoreRemoved(removedMoney)
            return failure(traderID, operation, moveReason)
        end
        record.b = math.max(0, math.floor(tonumber(record.b) or 0)) + total
    else
        if math.floor(tonumber(record.b) or 0) < total then
            return failure(traderID, operation, "trader_budget_exhausted")
        end
        local moved, moveReason = Inventory.transfer(
            physical, stock, fullType, quantity)
        if not moved then return failure(traderID, operation, moveReason) end
        local moneyRecord, moneyReason = Stock.EncodeItem(
            DTCommon.MONEY_FULL_TYPE, 1)
        if not moneyRecord then
            Inventory.transfer(stock, physical, fullType, quantity)
            return failure(traderID, operation, moneyReason)
        end
        local added, addReason = physical:add(moneyRecord, total)
        if not added then
            Inventory.transfer(stock, physical, fullType, quantity)
            return failure(traderID, operation, addReason)
        end
        record.b = math.max(0, math.floor(tonumber(record.b) or 0)) - total
    end

    record.v = math.max(0, math.floor(tonumber(record.v) or 0)) + 1
    local saved, saveReason = Storage.SaveInventory(record, stock)
    if not saved then return failure(traderID, operation, saveReason) end
    Stock.SaveAndTransmit()
    local snapshot, snapshotReason = Service.Snapshot(traderID)
    return {
        accepted = true,
        traderID = traderID,
        operation = operation,
        fullType = fullType,
        quantity = quantity,
        totalValue = total,
        snapshot = snapshot,
        reason = snapshotReason,
    }
end

local function normalizedRows(rows)
    local output = {}
    if type(rows) ~= "table" then return output end
    for index = 1, math.min(#rows, 32) do
        local source = type(rows[index]) == "table" and rows[index] or {}
        local fullType = Support.Bounded(source.fullType, 160)
        local quantity = Support.PositiveInteger(source.quantity, 1, 100)
        if fullType ~= "" then
            output[#output + 1] = {
                fullType = fullType,
                quantity = quantity,
                itemIDs = type(source.itemIDs) == "table"
                    and source.itemIDs or {},
            }
        end
    end
    return output
end

local function rowQuery(row)
    local ids = {}
    local idCount = 0
    for index = 1, math.min(#(row.itemIDs or {}), 100) do
        local id = tostring(row.itemIDs[index])
        if not ids[id] then
            ids[id] = true
            idCount = idCount + 1
        end
    end
    if idCount < 1 then return row.fullType end
    return {
        predicate = function(item)
            local itemID = item and item.getID and item:getID() or nil
            local fullType = item and item.getFullType
                and item:getFullType() or nil
            return ids[tostring(itemID or "")] == true
                and tostring(fullType or "") == row.fullType
        end,
    }
end

local function rollbackTransfers(stock, physical, rows, direction)
    for index = #rows, 1, -1 do
        local row = rows[index]
        if direction == "to_player" then
            Inventory.transfer(stock, physical, row.fullType, row.quantity)
        else
            Inventory.transfer(physical, stock, row.fullType, row.quantity)
        end
    end
end

function Service.ExecuteTradeBasket(player, request)
    if not authority() then return failure(nil, nil, "server_authority_required") end
    request = type(request) == "table" and request or {}
    local traderID = Support.Bounded(request.traderID, 128)
    local record = Service.GetRecord(traderID)
    local buyRows = normalizedRows(request.buyRows)
    local sellRows = normalizedRows(request.sellRows)
    local observedVersion = tonumber(request.observedStockVersion)
    local stock
    local physical
    local buyTotal = 0
    local sellTotal = 0
    local movedToStock = {}
    local movedToPlayer = {}
    local removedMoney
    local moneyRecord
    local reason
    local previousBudget
    local previousVersion
    if not record then return failure(traderID, "BASKET", "trader_not_found") end
    if observedVersion
        and math.floor(observedVersion) ~= math.floor(tonumber(record.v) or 0)
    then
        return failure(traderID, "BASKET", "stale_stock")
    end
    if #buyRows < 1 and #sellRows < 1 then
        return failure(traderID, "BASKET", "empty_trade")
    end
    stock, reason = Storage.LoadInventory(record)
    if not stock then return failure(traderID, "BASKET", reason) end
    applyCaravanCapacity(record, stock)
    previousBudget = math.max(0, math.floor(tonumber(record.b) or 0))
    previousVersion = math.max(0, math.floor(tonumber(record.v) or 0))
    if not player or type(player.getInventory) ~= "function" then
        return failure(traderID, "BASKET", "player_inventory_unavailable")
    end
    physical = Inventory.wrapPhysicalInventory(player:getInventory(), {
        syncOnMutation = true,
    })
    if not physical then return failure(traderID, "BASKET", "inventory_unavailable") end

    for _, row in ipairs(buyRows) do
        if stock:count(row.fullType) < row.quantity then
            return failure(traderID, "BASKET", "insufficient_stock")
        end
        buyTotal = buyTotal + Stock.MarketPrice(row.fullType) * row.quantity
    end
    for _, row in ipairs(sellRows) do
        local query = rowQuery(row)
        if physical:count(query) < row.quantity then
            return failure(traderID, "BASKET", "item_unavailable")
        end
        sellTotal = sellTotal
            + math.max(1, math.floor(Stock.MarketPrice(row.fullType) * 0.5))
                * row.quantity
    end
    local netTotal = buyTotal - sellTotal
    if netTotal > 0 and physical:count(DTCommon.MONEY_FULL_TYPE) < netTotal then
        return failure(traderID, "BASKET", "insufficient_money")
    end
    if netTotal < 0
        and math.floor(tonumber(record.b) or 0) < math.abs(netTotal)
    then
        return failure(traderID, "BASKET", "trader_budget_exhausted")
    end

    for _, row in ipairs(sellRows) do
        local moved, moveReason = Inventory.transfer(
            physical, stock, rowQuery(row), row.quantity
        )
        if not moved then
            rollbackTransfers(stock, physical, movedToStock, "to_player")
            return failure(traderID, "BASKET", moveReason)
        end
        movedToStock[#movedToStock + 1] = row
    end
    if netTotal > 0 then
        removedMoney, reason = physical:remove(
            DTCommon.MONEY_FULL_TYPE, netTotal)
        if not removedMoney then
            rollbackTransfers(stock, physical, movedToStock, "to_player")
            return failure(traderID, "BASKET", reason)
        end
    end
    for _, row in ipairs(buyRows) do
        local moved, moveReason = Inventory.transfer(
            stock, physical, row.fullType, row.quantity
        )
        if not moved then
            rollbackTransfers(stock, physical, movedToStock, "to_player")
            rollbackTransfers(stock, physical, movedToPlayer, "to_stock")
            if removedMoney then physical:restoreRemoved(removedMoney) end
            return failure(traderID, "BASKET", moveReason)
        end
        movedToPlayer[#movedToPlayer + 1] = row
    end
    if netTotal < 0 then
        moneyRecord, reason = Stock.EncodeItem(
            DTCommon.MONEY_FULL_TYPE, 1)
        if not moneyRecord then
            rollbackTransfers(stock, physical, movedToStock, "to_player")
            rollbackTransfers(stock, physical, movedToPlayer, "to_stock")
            return failure(traderID, "BASKET", reason)
        end
        local added, addReason = physical:add(moneyRecord, math.abs(netTotal))
        if not added then
            rollbackTransfers(stock, physical, movedToStock, "to_player")
            rollbackTransfers(stock, physical, movedToPlayer, "to_stock")
            return failure(traderID, "BASKET", addReason)
        end
    end
    record.b = math.max(0, math.floor(tonumber(record.b) or 0)) + netTotal
    record.v = math.max(0, math.floor(tonumber(record.v) or 0)) + 1
    local saved, saveReason = Storage.SaveInventory(record, stock)
    if not saved then
        if netTotal < 0 then
            physical:remove(DTCommon.MONEY_FULL_TYPE, math.abs(netTotal))
        end
        rollbackTransfers(stock, physical, movedToStock, "to_player")
        rollbackTransfers(stock, physical, movedToPlayer, "to_stock")
        if removedMoney then physical:restoreRemoved(removedMoney) end
        record.b = previousBudget
        record.v = previousVersion
        return failure(traderID, "BASKET", saveReason)
    end
    Stock.SaveAndTransmit()
    local snapshot, snapshotReason = Service.Snapshot(traderID)
    return {
        accepted = true,
        traderID = traderID,
        operation = "BASKET",
        buyRows = buyRows,
        sellRows = sellRows,
        totalValue = netTotal,
        snapshot = snapshot,
        reason = snapshotReason,
    }
end

return Service
