local Stub = {}

local function copy(value)
    if type(value) ~= "table" then return value end
    local output = {}
    for key, child in pairs(value) do
        output[key] = copy(child)
    end
    return output
end

local function normalizeRow(fullType, row)
    row = copy(type(row) == "table" and row or {})
    row.fullType = row.fullType or fullType
    row.moduleName = row.moduleName
        or tostring(row.fullType):match("^([^%.]+)")
        or "Base"
    row.sourceModId = row.sourceModId
        or (row.moduleName == "Base" and "Vanilla" or row.moduleName)
    row.category = row.category or "Misc"
    row.primary = row.primary or row.category
    row.availability = row.availability or {
        status = "obtainable",
        obtainable = true,
    }
    if row.availability.obtainable == nil then
        row.availability.obtainable =
            tostring(row.availability.status or "") == "obtainable"
            or tostring(row.availability.status or "") == "cached"
    end
    return row
end

function Stub.New(rows, options)
    rows = type(rows) == "table" and rows or {}
    options = type(options) == "table" and options or {}
    local normalized = {}
    for fullType, row in pairs(rows) do
        normalized[fullType] = normalizeRow(fullType, row)
    end

    local api = {}
    api._rows = normalized
    api._queryCalls = 0
    api._exactCalls = 0
    api._allKnownCalls = 0
    api._catalogRevision = tonumber(options.catalogRevision) or 1
    api._pricingRevision = tonumber(options.pricingRevision) or 1

    function api.IsCatalogReady()
        return options.ready ~= false
    end

    function api.GetCatalogRevision()
        return api._catalogRevision
    end

    function api.GetPricingRevision()
        return api._pricingRevision
    end

    function api.GetCatalogItem(fullType)
        api._exactCalls = api._exactCalls + 1
        return copy(normalized[tostring(fullType or "")])
    end

    function api.QueryItems(query)
        api._queryCalls = api._queryCalls + 1
        query = type(query) == "table" and query or {}
        local keys = {}
        for fullType, row in pairs(normalized) do
            local categoryOK = not query.category
                or tostring(row.category) == tostring(query.category)
            local obtainableOK = not query.obtainableOnly
                or (row.availability
                    and row.availability.obtainable == true)
            local moddedOK = not query.moddedOnly
                or tostring(row.sourceModId or "") ~= "Vanilla"
            if categoryOK and obtainableOK and moddedOK then
                keys[#keys + 1] = fullType
            end
        end
        table.sort(keys)
        local output = {}
        local offset = math.max(0, math.floor(
            tonumber(query.offset) or 0
        ))
        local limit = math.max(1, math.floor(
            tonumber(query.limit) or 32
        ))
        for index = offset + 1, math.min(#keys, offset + limit) do
            output[#output + 1] = copy(normalized[keys[index]])
        end
        return output, nil, {
            revision = api._catalogRevision,
            total = #keys,
            offset = offset,
            limit = limit,
            nextOffset = offset + limit < #keys
                and offset + limit or nil,
        }
    end

    function api.GetPriceDetails(fullType, ...)
        if type(options.getPriceDetails) == "function" then
            return options.getPriceDetails(fullType, ...)
        end
        local row = normalized[tostring(fullType or "")]
        if not row then return nil end
        return { price = tonumber(row.price) or 100 }
    end

    function api.GetPriceDetailsForInstance(fullType, item, ...)
        if type(options.getPriceDetailsForInstance) == "function" then
            return options.getPriceDetailsForInstance(
                fullType, item, ...
            )
        end
        return api.GetPriceDetails(fullType, ...)
    end

    function api.GetAllKnownItems()
        api._allKnownCalls = api._allKnownCalls + 1
        error("DynamicTrading test called forbidden GetAllKnownItems()")
    end

    return api
end

return Stub
