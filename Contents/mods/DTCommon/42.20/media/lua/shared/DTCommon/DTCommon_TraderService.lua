DTCommon = DTCommon or {}

local Service = DTCommon.TraderService or {}
DTCommon.TraderService = Service

local Inventory = require "PsychopatzCore/Inventory/PsychopatzInventory"
require "PsychopatzCore/Economy/PsychopatzCurrency"
local Storage = DTCommon.Storage
local Stock = DTCommon.TraderStock
local Support = DTCommon.TraderSupport

local MAX_ROWS = 32
local MAX_ITEMS_PER_ROW = 100
local MAX_REQUESTS = 128

Service.RequestCache = Service.RequestCache or {}
Service.RequestOrder = Service.RequestOrder or {}

local function number(value, fallback)
    value = tonumber(value)
    return value ~= nil and value or fallback
end

local function integer(value, fallback)
    value = tonumber(value)
    if not value then return fallback end
    return math.floor(value)
end

local function bounded(value, maximum)
    if Support and type(Support.Bounded) == "function" then
        return Support.Bounded(value, maximum)
    end
    value = tostring(value or "")
    return #value > maximum and string.sub(value, 1, maximum) or value
end

local function positive(value, maximum)
    value = tonumber(value)
    if not value or value ~= value or value < 1 then return nil end
    value = math.floor(value)
    return value <= maximum and value or nil
end

local function failure(traderID, operation, reason, extra)
    local result = {
        accepted = false,
        traderID = traderID,
        operation = operation,
        reason = reason or "trade_rejected",
    }
    for key, value in pairs(type(extra) == "table" and extra or {}) do
        result[key] = value
    end
    return result
end

local function authority()
    return Storage and type(Storage.IsAuthority) == "function"
        and Storage.IsAuthority() == true
end

local function playerKey(player)
    local value
    if player and type(player.getOnlineID) == "function" then
        value = player:getOnlineID()
        if value ~= nil then return "online:" .. tostring(value) end
    end
    if player and type(player.getUsername) == "function" then
        value = player:getUsername()
        if value ~= nil and tostring(value) ~= "" then
            return "user:" .. tostring(value)
        end
    end
    return "object:" .. tostring(player)
end

local function claimRequest(player, traderID, requestID)
    local key = playerKey(player) .. "\031" .. tostring(traderID)
        .. "\031" .. tostring(requestID)
    if Service.RequestCache[key] then return nil, "duplicate_request" end
    Service.RequestCache[key] = true
    Service.RequestOrder[#Service.RequestOrder + 1] = key
    while #Service.RequestOrder > MAX_REQUESTS do
        local oldest = table.remove(Service.RequestOrder, 1)
        Service.RequestCache[oldest] = nil
    end
    return key
end

local function currencyCount(physical)
    if physical and type(physical.countCurrency) == "function" then
        return math.max(0, integer(physical:countCurrency(), 0))
    end
    if physical and type(physical.count) == "function" then
        return math.max(0, integer(
            physical:count(DTCommon.MONEY_FULL_TYPE),
            0
        ))
    end
    return 0
end

local function removeCurrency(physical, amount)
    local ok
    local reason
    local details
    if physical and type(physical.removeCurrency) == "function" then
        ok, reason, details = physical:removeCurrency(amount)
        if not ok then return false, reason end
        details = details or (type(reason) == "table" and reason or nil)
        if type(details) ~= "table" then
            return false, "currency_rollback_unavailable"
        end
        return true, details
    end
    if not physical or type(physical.remove) ~= "function" then
        return false, "currency_service_unavailable"
    end
    ok, details = physical:remove(DTCommon.MONEY_FULL_TYPE, amount)
    if not ok then return false, details end
    return true, details
end

local function restoreCurrency(physical, details)
    if not details then return true end
    if not physical or type(physical.restoreRemoved) ~= "function" then
        return false
    end
    local ok, restored = pcall(physical.restoreRemoved, physical, details)
    return ok and restored == true
end

local function removeAdded(physical, added)
    if not added then return true end
    if type(physical.removeAdded) ~= "function" then return false end
    local ok, removed = pcall(physical.removeAdded, physical, added)
    return ok and removed == true
end

local function rollbackHandles(handles)
    local complete = true
    for index = #(handles or {}), 1, -1 do
        local handle = handles[index]
        if not handle or type(handle.rollback) ~= "function" then
            complete = false
        else
            local ok, rolledBack = pcall(handle.rollback, handle)
            if not ok or rolledBack ~= true then complete = false end
        end
    end
    return complete
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
    return number(usedWeight, store.getWeight and store:getWeight() or 0),
        number(maxWeight, number(store.maxWeight, 0))
end

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

local function safeCall(object, method, fallback, ...)
    local fn = object and object[method]
    local ok
    local value
    if type(fn) ~= "function" then return fallback end
    ok, value = pcall(fn, object, ...)
    return ok and value ~= nil and value or fallback
end

local function listContains(list, wanted)
    local size
    if not list then return false end
    if type(list) == "table" and type(list.size) ~= "function" then
        for index = 1, #list do
            if list[index] == wanted then return true end
        end
        return false
    end
    if type(list.size) ~= "function" or type(list.get) ~= "function" then
        return false
    end
    size = tonumber(safeCall(list, "size", 0)) or 0
    for index = 0, size - 1 do
        if safeCall(list, "get", nil, index) == wanted then return true end
    end
    return false
end

local function containerHasItems(item)
    local container = safeCall(item, "getItemContainer", nil)
        or safeCall(item, "getInventory", nil)
    local items = safeCall(container, "getItems", nil)
    if type(items) == "table" and type(items.size) ~= "function" then
        return #items > 0
    end
    return items and type(items.size) == "function"
        and (tonumber(safeCall(items, "size", 0)) or 0) > 0 or false
end

local function interactionLocked(item)
    local fullType = tostring(safeCall(item, "getFullType", "") or "")
    local modData
    if fullType == "Base.IDcard" then return true end
    if safeCall(item, "isInteractionLocked", false) == true
        or safeCall(item, "getInteractionLocked", false) == true
    then
        return true
    end
    modData = safeCall(item, "getModData", nil)
    return type(modData) == "table"
        and (modData.interactionLocked == true
            or modData.PNCInteractionLocked == true
            or modData.identityNPCId ~= nil
            or modData.identityNPCName ~= nil)
end

local function equipped(player, item)
    if safeCall(item, "isEquipped", false) == true then return true end
    if player and type(player.isEquipped) == "function" then
        local ok, value = pcall(player.isEquipped, player, item)
        if ok and value == true then return true end
    end
    if safeCall(player, "getPrimaryHandItem", nil) == item
        or safeCall(player, "getSecondaryHandItem", nil) == item
    then
        return true
    end
    if listContains(safeCall(player, "getWornItems", nil), item)
        or listContains(safeCall(player, "getAttachedItems", nil), item)
    then
        return true
    end
    return false
end

local function itemProtectionReason(player, item)
    if not item then return "item_missing" end
    if safeCall(item, "isFavorite", false) == true then return "favorite" end
    if equipped(player, item) then return "equipped" end
    if interactionLocked(item) then return "item_off_limits" end
    if containerHasItems(item) then return "container_not_empty" end
    return nil
end

local function liveNPC(npcID)
    local registry = PNC and PNC.Registry or nil
    local body
    if not registry or type(registry.Get) ~= "function" then return nil end
    body = type(registry.GetLiveZombie) == "function"
        and registry.GetLiveZombie(npcID) or nil
    return body or registry.Get(npcID)
end

local function coordinate(object, method)
    local value = safeCall(object, method, nil)
    return value ~= nil and tonumber(value) or nil
end

local function nearby(player, npcID)
    local body = liveNPC(npcID)
    local px = coordinate(player, "getX")
    local py = coordinate(player, "getY")
    local nx = coordinate(body, "getX") or number(body and body.x, nil)
    local ny = coordinate(body, "getY") or number(body and body.y, nil)
    if not px or not py or not nx or not ny then return false end
    return (px - nx) * (px - nx) + (py - ny) * (py - ny) <= 36
end

-- `a` is a server-created capability for an abstract/radio trader.  A local
-- settlement has a=0 and must prove a live trader body is nearby; a guessed
-- trader ID cannot open that path remotely.
local function validateAccess(player, record)
    local status = tostring(record and record.s or DTCommon.STATUS_READY)
    if status ~= tostring(DTCommon.STATUS_READY) then
        return false, "trader_unavailable"
    end
    if tonumber(record and record.a) == 1 then return true end
    local npcID = record and (record.p or record.l)
    if npcID and nearby(player, npcID) then return true end
    return false, "access_denied"
end

local function itemID(item)
    return tostring(safeCall(item, "getID", "") or "")
end

local function fullType(item)
    return tostring(safeCall(item, "getFullType", "") or "")
end

local function itemQuantity(item)
    return math.max(1, integer(safeCall(item, "getCount", 1), 1))
end

local function normalizedRows(rows)
    local output = {}
    if type(rows) ~= "table" then return output, nil end
    if #rows > MAX_ROWS then return nil, "too_many_rows" end
    for index = 1, #rows do
        local source = type(rows[index]) == "table" and rows[index] or nil
        local rowFullType = source and bounded(source.fullType, 160) or ""
        local rowQuantity = source and positive(source.quantity, 100) or nil
        if not source or rowFullType == "" then
            return nil, "item_required"
        end
        if not rowQuantity then return nil, "quantity_invalid" end
        output[#output + 1] = {
            fullType = rowFullType,
            quantity = rowQuantity,
            itemIDs = type(source.itemIDs) == "table"
                and source.itemIDs or {},
            itemIDQuantities = type(source.itemIDQuantities) == "table"
                and source.itemIDQuantities or {},
        }
    end
    return output, nil
end

local function selectedItem(physical, wantedID, wantedFullType)
    local matches
    if not physical or type(physical.query) ~= "function" then return nil end
    matches = physical:query({ predicate = function(item)
        return itemID(item) == wantedID and fullType(item) == wantedFullType
    end })
    if #matches ~= 1 then return nil end
    return matches[1]
end

local function prepareSellRows(physical, player, rows)
    local selections = {}
    local seenIDs = {}
    local total = 0
    for rowIndex = 1, #rows do
        local row = rows[rowIndex]
        local ids = row.itemIDs
        local quantities = row.itemIDQuantities
        if #ids < 1 or #ids > MAX_ITEMS_PER_ROW then
            return nil, nil, "item_identity_required"
        end
        if row.quantity ~= #ids then
            return nil, nil, "quantity_identity_mismatch"
        end
        for idIndex = 1, #ids do
            local wantedID = bounded(ids[idIndex], 128)
            local requested = quantities[idIndex] ~= nil
                and positive(quantities[idIndex], 1) or 1
            if wantedID == "" then return nil, nil, "item_identity_required" end
            if requested ~= 1 then
                return nil, nil, "partial_stack_unsupported"
            end
            if seenIDs[wantedID] then
                return nil, nil, "duplicate_item_identity"
            end
            seenIDs[wantedID] = true
            local item = selectedItem(physical, wantedID, row.fullType)
            if not item then return nil, nil, "item_unavailable" end
            if itemQuantity(item) ~= 1 then
                return nil, nil, "partial_stack_unsupported"
            end
            local protected = itemProtectionReason(player, item)
            if protected then return nil, nil, protected end
            local quote = Stock.Quote(row.fullType, DTCommon.OP_SELL, item)
            if not quote.ok then return nil, nil, quote.reason end
            selections[#selections + 1] = {
                item = item,
                itemID = wantedID,
                fullType = row.fullType,
                unitPrice = quote.unitPrice,
                rowIndex = rowIndex,
            }
            total = total + quote.unitPrice
        end
    end
    return selections, total, nil
end

local function prepareBuyRows(stock, rows)
    local selections = {}
    local seenTypes = {}
    local total = 0
    for rowIndex = 1, #rows do
        local row = rows[rowIndex]
        if seenTypes[row.fullType] then
            return nil, nil, "duplicate_stock_identity"
        end
        seenTypes[row.fullType] = true
        if stock:count(row.fullType) < row.quantity then
            return nil, nil, "insufficient_stock"
        end
        local quote = Stock.Quote(row.fullType, DTCommon.OP_BUY)
        if not quote.ok then return nil, nil, quote.reason end
        selections[#selections + 1] = {
            fullType = row.fullType,
            quantity = row.quantity,
            unitPrice = quote.unitPrice,
        }
        total = total + quote.unitPrice * row.quantity
    end
    return selections, total, nil
end

local function selectionQuery(selection)
    local ids = {}
    for index = 1, #selection do ids[selection[index].itemID] = true end
    return { predicate = function(item)
        return ids[itemID(item)] == true
    end }
end

local function transferSell(physical, stock, selection)
    return Inventory.transfer(
        physical,
        stock,
        selectionQuery(selection),
        #selection,
        { reversible = true }
    )
end

local function transferBuy(stock, physical, selection)
    return Inventory.transfer(
        stock,
        physical,
        selection.fullType,
        selection.quantity,
        { reversible = true }
    )
end

function Service.Snapshot(traderID, player)
    local record = Service.GetRecord(traderID)
    local store
    local loadReason
    local items
    local reason
    local usedWeight
    local maxWeight
    local snapshot
    if not record then return nil, "trader_not_found" end
    if player then
        local accessOK, accessReason = validateAccess(player, record)
        if not accessOK then return nil, accessReason end
    end
    store, loadReason = Storage.LoadInventory(record)
    if not store then return nil, loadReason end
    items, reason = Stock.SnapshotItems(record, store)
    if reason then return nil, reason end
    usedWeight, maxWeight = applyCaravanCapacity(record, store)
    snapshot = Service.Get(traderID)
    if not snapshot then return nil, "trader_not_found" end
    applyCanonicalDisplayName(record, snapshot)
    snapshot.items = items or {}
    snapshot.sellRows = {}
    if player and type(player.getInventory) == "function" then
        local physical = Inventory.wrapPhysicalInventory(player:getInventory(), {
            recursive = true,
        })
        if physical then
            snapshot.sellRows = Stock.SnapshotSellRows(physical) or {}
        end
    end
    snapshot.quoteRevision = snapshot.stockVersion
    snapshot.usedWeight = usedWeight
    snapshot.maxWeight = maxWeight
    return snapshot
end

local function requestVersion(request, record)
    local observed = tonumber(request.observedStockVersion)
    local observedQuote = tonumber(request.observedQuoteRevision)
    if not observed or observed ~= math.floor(observed) then
        return false, "stock_version_required"
    end
    if observed ~= integer(record.v, 0) then return false, "stale_stock" end
    if observedQuote ~= nil and observedQuote ~= math.floor(observedQuote) then
        return false, "quote_revision_invalid"
    end
    if observedQuote ~= nil and observedQuote ~= integer(record.v, 0) then
        return false, "stale_quote"
    end
    return true
end

local function restoreAll(physical, currencyDetails, addedCurrency,
    buyTransfers, sellTransfers)
    local complete = true
    if not removeAdded(physical, addedCurrency) then complete = false end
    if not rollbackHandles(buyTransfers) then complete = false end
    if not restoreCurrency(physical, currencyDetails) then complete = false end
    if not rollbackHandles(sellTransfers) then complete = false end
    return complete
end

-- Compatibility wrapper for the old one-row endpoint. All settlement now
-- flows through ExecuteTradeBasket so quote, access, rollback, and replay
-- rules cannot diverge between single and mixed baskets.
function Service.ExecuteTrade(player, request)
    request = type(request) == "table" and request or {}
    local operation = string.upper(bounded(request.operation, 16))
    local row = {
        fullType = request.fullType,
        quantity = request.quantity,
        itemIDs = request.itemIDs,
        itemIDQuantities = request.itemIDQuantities,
    }
    local basket = {}
    for key, value in pairs(request) do basket[key] = value end
    basket.buyRows = operation == DTCommon.OP_BUY and { row } or {}
    basket.sellRows = operation == DTCommon.OP_SELL and { row } or {}
    return Service.ExecuteTradeBasket(player, basket)
end

function Service.ExecuteTradeBasket(player, request)
    local traderID
    local requestID
    local record
    local buyRows
    local sellRows
    local stock
    local physical
    local buySelections
    local sellSelections
    local buyTotal
    local sellTotal
    local netTotal
    local sellTransfers = {}
    local buyTransfers = {}
    local currencyDetails
    local addedCurrency
    local previousBudget
    local previousVersion
    local previousInventory
    local saved
    local saveReason
    local accessOK
    local reason
    local result

    if not authority() then
        return failure(nil, "BASKET", "server_authority_required")
    end
    request = type(request) == "table" and request or {}
    traderID = bounded(request.traderID, 128)
    requestID = bounded(request.requestID, 128)
    if traderID == "" then return failure(traderID, "BASKET", "trader_required") end
    if requestID == "" then
        return failure(traderID, "BASKET", "request_id_required")
    end
    record = Service.GetRecord(traderID)
    if not record then return failure(traderID, "BASKET", "trader_not_found") end
    accessOK, reason = validateAccess(player, record)
    if not accessOK then return failure(traderID, "BASKET", reason) end
    local versionOK, versionReason = requestVersion(request, record)
    if not versionOK then return failure(traderID, "BASKET", versionReason) end
    local claim, claimReason = claimRequest(player, traderID, requestID)
    if not claim then return failure(traderID, "BASKET", claimReason) end

    buyRows, reason = normalizedRows(request.buyRows)
    if not buyRows then return failure(traderID, "BASKET", reason) end
    sellRows, reason = normalizedRows(request.sellRows)
    if not sellRows then return failure(traderID, "BASKET", reason) end
    if #buyRows < 1 and #sellRows < 1 then
        return failure(traderID, "BASKET", "empty_trade")
    end

    stock, reason = Storage.LoadInventory(record)
    if not stock then return failure(traderID, "BASKET", reason) end
    applyCaravanCapacity(record, stock)
    if not player or type(player.getInventory) ~= "function" then
        return failure(traderID, "BASKET", "player_inventory_unavailable")
    end
    physical = Inventory.wrapPhysicalInventory(player:getInventory(), {
        recursive = true,
        syncOnMutation = true,
    })
    if not physical then return failure(traderID, "BASKET", "inventory_unavailable") end

    buySelections, buyTotal, reason = prepareBuyRows(stock, buyRows)
    if not buySelections then return failure(traderID, "BASKET", reason) end
    sellSelections, sellTotal, reason = prepareSellRows(
        physical, player, sellRows)
    if not sellSelections then return failure(traderID, "BASKET", reason) end
    netTotal = buyTotal - sellTotal
    if netTotal > 0 and currencyCount(physical) < netTotal then
        return failure(traderID, "BASKET", "insufficient_money")
    end
    if netTotal < 0
        and integer(record.b, 0) < math.abs(netTotal)
    then
        return failure(traderID, "BASKET", "trader_budget_exhausted")
    end

    for rowIndex = 1, #sellRows do
        local selection = {}
        for index = 1, #sellSelections do
            if sellSelections[index].rowIndex == rowIndex then
                selection[#selection + 1] = sellSelections[index]
            end
        end
        local moved, handle = transferSell(physical, stock, selection)
        if not moved or not handle then
            local rolled = rollbackHandles(sellTransfers)
            return failure(traderID, "BASKET", rolled
                and "transfer_failed" or "rollback_failed")
        end
        sellTransfers[#sellTransfers + 1] = handle
    end

    if netTotal > 0 then
        local removed, details = removeCurrency(physical, netTotal)
        if not removed then
            local rolled = rollbackHandles(sellTransfers)
            return failure(traderID, "BASKET", rolled and details or "rollback_failed")
        end
        currencyDetails = details
    end

    for index = 1, #buySelections do
        local moved, handle = transferBuy(
            stock,
            physical,
            buySelections[index]
        )
        if not moved or not handle then
            local rolled = restoreAll(
                physical,
                currencyDetails,
                addedCurrency,
                buyTransfers,
                sellTransfers
            )
            return failure(traderID, "BASKET", rolled
                and "transfer_failed" or "rollback_failed")
        end
        buyTransfers[#buyTransfers + 1] = handle
    end

    if netTotal < 0 then
        local moneyRecord
        moneyRecord, reason = Stock.EncodeItem(DTCommon.MONEY_FULL_TYPE, 1)
        if not moneyRecord then
            local rolled = restoreAll(
                physical, currencyDetails, addedCurrency,
                buyTransfers, sellTransfers
            )
            return failure(traderID, "BASKET", rolled and reason or "rollback_failed")
        end
        local added
        local addReason
        added, addReason = physical:add(moneyRecord, math.abs(netTotal))
        if not added then
            local rolled = restoreAll(
                physical, currencyDetails, addedCurrency,
                buyTransfers, sellTransfers
            )
            return failure(traderID, "BASKET", rolled
                and addReason or "rollback_failed")
        end
        addedCurrency = addReason
    end

    previousBudget = integer(record.b, 0)
    previousVersion = integer(record.v, 0)
    previousInventory = record.i
    record.b = math.max(0, previousBudget + netTotal)
    record.v = previousVersion + 1
    saved, saveReason = Storage.SaveInventory(record, stock)
    if not saved then
        local rolled = restoreAll(
            physical, currencyDetails, addedCurrency,
            buyTransfers, sellTransfers
        )
        record.b = previousBudget
        record.v = previousVersion
        record.i = previousInventory
        return failure(traderID, "BASKET", rolled and saveReason or "rollback_failed")
    end

    Stock.SaveAndTransmit()
    local snapshot, snapshotReason = Service.Snapshot(traderID, player)
    result = {
        accepted = true,
        traderID = traderID,
        operation = "BASKET",
        requestID = requestID,
        buyRows = buyRows,
        sellRows = sellRows,
        buyTotal = buyTotal,
        sellTotal = sellTotal,
        totalValue = netTotal,
        stockVersion = record.v,
        snapshot = snapshot,
        reason = snapshotReason,
    }
    return result
end

return Service
