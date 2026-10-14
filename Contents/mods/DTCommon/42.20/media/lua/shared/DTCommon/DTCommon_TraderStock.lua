DTCommon = DTCommon or {}
DTCommon.TraderStock = DTCommon.TraderStock or {}

local Stock = DTCommon.TraderStock
local Inventory = require "PsychopatzCore/Inventory/PsychopatzInventory"
local Storage = DTCommon.Storage
local Support = DTCommon.TraderSupport
local INITIAL_STOCK_LIMIT = 8

local function unavailable(fullType, reason)
    return {
        ok = false,
        status = "UNAVAILABLE",
        reason = reason,
        fullType = fullType,
    }
end

local function finitePositive(value)
    value = tonumber(value)
    if not value or value ~= value or value == math.huge
        or value == -math.huge or value <= 0
    then
        return nil
    end
    return math.floor(value)
end

local function isCurrency(fullType)
    return tostring(fullType or "") == tostring(DTCommon.MONEY_FULL_TYPE)
        or tostring(fullType or "") == "Base.MoneyBundle"
end

local function itemValue(item, method, fallback)
    local fn = item and item[method]
    local ok
    local value
    if type(fn) ~= "function" then return fallback end
    ok, value = pcall(fn, item)
    if not ok or value == nil then return fallback end
    return value
end

-- The only price boundary used by DynamicTrading.  MarketSense owns both the
-- definition classification and concrete-instance valuation; DTCommon only
-- validates the returned primitive and applies its trade margin below.
function Stock.Price(fullType, inventoryItem)
    local api = rawget(_G, "MarketSense")
    local details
    local ok
    local price
    fullType = tostring(fullType or "")
    if fullType == "" then return unavailable(fullType, "item_required") end
    if isCurrency(fullType) then
        return unavailable(fullType, "currency_not_tradeable")
    end
    if type(api) ~= "table" then
        return unavailable(fullType, "marketsense_unavailable")
    end
    if inventoryItem ~= nil then
        if type(api.GetPriceDetailsForInstance) ~= "function" then
            return unavailable(fullType, "instance_price_api_unavailable")
        end
        ok, details = pcall(
            api.GetPriceDetailsForInstance,
            fullType,
            inventoryItem,
            false
        )
    else
        if type(api.GetPriceDetails) ~= "function" then
            return unavailable(fullType, "definition_price_api_unavailable")
        end
        ok, details = pcall(api.GetPriceDetails, fullType, false)
    end
    if not ok or type(details) ~= "table" then
        return unavailable(fullType, "price_details_unavailable")
    end
    price = finitePositive(details.price)
    if not price or price < 1 then
        return unavailable(fullType, "price_unavailable")
    end
    return {
        ok = true,
        status = "OK",
        fullType = fullType,
        intrinsicPrice = price,
        source = inventoryItem ~= nil and "instance" or "definition",
    }
end

function Stock.Quote(fullType, operation, inventoryItem)
    local price = Stock.Price(fullType, inventoryItem)
    local unitPrice
    operation = string.upper(tostring(operation or DTCommon.OP_BUY))
    if not price.ok then return price end
    if operation == DTCommon.OP_SELL then
        unitPrice = math.floor(price.intrinsicPrice * 0.5)
        -- This floor applies only after a valid positive MarketSense price.
        unitPrice = math.max(1, unitPrice)
    elseif operation == DTCommon.OP_BUY then
        unitPrice = price.intrinsicPrice
    else
        return unavailable(price.fullType, "operation_not_supported")
    end
    price.operation = operation
    price.unitPrice = unitPrice
    return price
end

-- Compatibility helper for the old stock callers.  It deliberately returns
-- nil on an unavailable price; callers must carry the reason instead of
-- inventing a generic fallback amount.
function Stock.MarketPrice(fullType, inventoryItem)
    local quote = Stock.Quote(fullType, DTCommon.OP_BUY, inventoryItem)
    if not quote.ok then return nil, quote.reason end
    return quote.unitPrice
end

function Stock.EncodeItem(fullType, quantity)
    local item
    if InventoryItemFactory
        and type(InventoryItemFactory.CreateItem) == "function"
    then
        item = InventoryItemFactory.CreateItem(fullType)
    end
    if not item and type(instanceItem) == "function" then
        item = instanceItem(fullType)
    end
    if not item then return nil, "item_type_unavailable" end
    return Inventory.encodeItem(item, quantity)
end

local function seedQuantity(value)
    if Support and type(Support.PositiveInteger) == "function" then
        return Support.PositiveInteger(value, 1, 1000)
    end
    value = tonumber(value)
    if not value or value < 1 then return 1 end
    return math.min(1000, math.floor(value))
end

local function moduleName(fullType)
    local separator = string.find(tostring(fullType or ""), ".", 1, true)
    return separator and string.sub(fullType, 1, separator - 1) or ""
end

local function hasEntries(value)
    if type(value) ~= "table" then return false end
    for _ in pairs(value) do return true end
    return false
end

local function seedCandidates()
    local api = rawget(_G, "MarketSense")
    local known
    local defaults = {}
    local candidates = {}
    local ok
    local value
    if type(api) ~= "table"
        or type(api.GetAllKnownItems) ~= "function"
        or type(api.GetItemAvailability) ~= "function"
    then
        return candidates
    end
    if type(api.EnsureRuntimeRegistryLoaded) == "function" then
        pcall(api.EnsureRuntimeRegistryLoaded, false)
    end
    ok, known = pcall(api.GetAllKnownItems)
    if not ok or type(known) ~= "table" then return candidates end
    -- A fresh server can expose lazy definition pricing before the persisted
    -- known-item registry has been built.  Rebuild once at trader creation,
    -- never from a snapshot/window refresh, so the seed remains catalog-backed.
    if not hasEntries(known)
        and type(api.EnsureRuntimeRegistryLoaded) == "function"
    then
        pcall(api.EnsureRuntimeRegistryLoaded, true)
        ok, known = pcall(api.GetAllKnownItems)
        if not ok or type(known) ~= "table" then return candidates end
    end
    for _, value in ipairs(DTCommon.DEFAULT_STOCK or {}) do
        if type(value) == "table" and value.fullType then
            defaults[tostring(value.fullType)] = seedQuantity(value.quantity)
        end
    end
    for key, entry in pairs(known) do
        local fullType = type(entry) == "table"
            and (entry.fullType or entry.item or key) or key
        fullType = tostring(fullType or "")
        if fullType ~= "" and not isCurrency(fullType) then
            local available
            local availableOK
            local detailsQuote
            availableOK, available = pcall(api.GetItemAvailability, fullType)
            if availableOK and type(available) == "table"
                and available.status == "obtainable"
            then
                detailsQuote = Stock.Price(fullType)
                if detailsQuote.ok then
                    candidates[#candidates + 1] = {
                        fullType = fullType,
                        quantity = defaults[fullType] or 1,
                        workshop = moduleName(fullType) ~= "Base",
                        fixture = defaults[fullType] ~= nil,
                    }
                end
            end
        end
    end
    table.sort(candidates, function(left, right)
        return left.fullType < right.fullType
    end)
    return candidates
end

function Stock.New()
    local store = Inventory.createVirtualInventory({
        authority = "server",
        maxWeight = 500,
    })
    local candidates = seedCandidates()
    local selected = {}
    local selectedByType = {}
    local function addCandidate(candidate)
        if #selected >= INITIAL_STOCK_LIMIT
            or selectedByType[candidate.fullType]
        then
            return
        end
        selected[#selected + 1] = candidate
        selectedByType[candidate.fullType] = true
    end
    local index
    local candidate
    local record
    -- Keep configured fixture types when they are valid MarketSense catalog
    -- entries, but never let them bypass availability or quote validation.
    for index = 1, #candidates do
        candidate = candidates[index]
        if candidate.fixture then addCandidate(candidate) end
    end
    -- Prefer at least one non-Base installed item when the catalog provides
    -- one, so a fresh trader does not require manual Workshop registration.
    for index = 1, #candidates do
        candidate = candidates[index]
        if candidate.workshop then addCandidate(candidate) end
    end
    for index = 1, #candidates do addCandidate(candidates[index]) end
    for index = 1, #selected do
        candidate = selected[index]
        record = Stock.EncodeItem(candidate.fullType, seedQuantity(candidate.quantity))
        if record then store:add(record) end
    end
    return store
end

function Stock.SaveAndTransmit()
    Storage.Touch()
    Storage.Transmit()
end

function Stock.SnapshotItems(record, existingStore)
    local store = existingStore
    local reason
    if not store then store, reason = Storage.LoadInventory(record) end
    if not store then return {}, reason end
    local items = {}
    local iterator = store:iterate()
    local itemRecord = iterator()
    while itemRecord do
        local fullType = Inventory.getItemFullType(itemRecord[1])
        if fullType then
            local buyQuote = Stock.Quote(fullType, DTCommon.OP_BUY)
            local sellQuote = Stock.Quote(fullType, DTCommon.OP_SELL)
            if buyQuote.ok and sellQuote.ok then
                items[#items + 1] = {
                    fullType = tostring(fullType),
                    quantity = math.max(1, math.floor(tonumber(itemRecord[2]) or 1)),
                    unitPrice = buyQuote.unitPrice,
                    sellPrice = sellQuote.unitPrice,
                }
            end
        end
        itemRecord = iterator()
    end
    return items
end

-- Build player-side sell rows independently from trader stock membership.  The
-- wire projection contains only primitive identity and quote data; concrete
-- InventoryItem objects never cross the client boundary.
function Stock.SnapshotSellRows(physical)
    local rows = {}
    local byKey = {}
    local iterator
    local item
    if not physical or type(physical.iterate) ~= "function" then
        return rows, "inventory_unavailable"
    end
    iterator = physical:iterate()
    item = iterator()
    while item do
        local fullType = tostring(itemValue(item, "getFullType", "") or "")
        local itemID = tostring(itemValue(item, "getID", "") or "")
        if fullType ~= "" and itemID ~= "" and not isCurrency(fullType) then
            local quote = Stock.Quote(fullType, DTCommon.OP_SELL, item)
            if quote.ok then
                local quantity = math.max(1, math.floor(
                    tonumber(itemValue(item, "getCount", 1)) or 1))
                local key = fullType .. "\031" .. tostring(quote.unitPrice)
                local row = byKey[key]
                if not row then
                    row = {
                        fullType = fullType,
                        itemIDs = {},
                        itemIDQuantities = {},
                        quantity = 0,
                        unitPrice = quote.unitPrice,
                    }
                    byKey[key] = row
                    rows[#rows + 1] = row
                end
                row.itemIDs[#row.itemIDs + 1] = itemID
                row.itemIDQuantities[#row.itemIDQuantities + 1] = quantity
                row.quantity = row.quantity + quantity
            end
        end
        item = iterator()
    end
    return rows
end

return Stock
