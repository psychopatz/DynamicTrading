local Catalog = require "DT/Common/Abstract/Normalization/DT_AbstractCatalog"
local Buckets = require "DT/Common/Abstract/Normalization/DT_AbstractBuckets"

DynamicTrading = DynamicTrading or {}
DynamicTrading.Abstract = DynamicTrading.Abstract or {}
DynamicTrading.Abstract.DebugData = DynamicTrading.Abstract.DebugData or {}

local DebugData = DynamicTrading.Abstract.DebugData

local function escapeRichText(value)
    local text = tostring(value or "")
    text = text:gsub("<", "[")
    text = text:gsub(">", "]")
    return text
end

local function join(values, separator)
    local parts = {}
    for _, value in ipairs(values or {}) do
        if value ~= nil and tostring(value) ~= "" then
            parts[#parts + 1] = tostring(value)
        end
    end
    return table.concat(parts, separator or ", ")
end

local function buildAbstractText(bucketMeta, fallbackID)
    local label = bucketMeta and bucketMeta.label or tostring(fallbackID or "")
    local bucketID = tostring(fallbackID or "")
    if label == "" then
        label = bucketID
    end
    return label, bucketID
end

function DebugData.GetBucketOptions()
    return Buckets.GetFilterOptions()
end

function DebugData.GetRows(searchText, bucketFilter)
    local filtered = Catalog.FilterRecords({
        searchText = searchText,
        bucket = bucketFilter,
    })

    local rows = {}
    for _, record in ipairs(filtered or {}) do
        local bucketMeta = Buckets.Get(record.primaryBucket) or {}
        local abstractName, abstractID = buildAbstractText(bucketMeta, record.primaryBucket)
        local reasonPreview = record.reasons and record.reasons[1] or ""
        rows[#rows + 1] = {
            record = record,
            abstractName = abstractName,
            abstractID = abstractID,
            abstractDescription = bucketMeta.description or "",
            reasonPreview = tostring(reasonPreview or ""),
            listText = tostring(record.displayName or record.fullType)
                .. " -> "
                .. tostring(abstractName ~= "" and abstractName or "Unknown"),
        }
    end
    return rows
end

function DebugData.GetPageSlice(rows, pageIndex, pageSize)
    local sourceRows = rows or {}
    local size = math.max(1, tonumber(pageSize) or 100)
    local totalRows = #sourceRows
    local totalPages = math.max(1, math.ceil(totalRows / size))
    local page = math.max(1, math.min(totalPages, tonumber(pageIndex) or 1))
    local startIndex = ((page - 1) * size) + 1
    local endIndex = math.min(totalRows, startIndex + size - 1)
    local visibleRows = {}

    for index = startIndex, endIndex do
        visibleRows[#visibleRows + 1] = sourceRows[index]
    end

    return {
        rows = visibleRows,
        pageIndex = page,
        pageSize = size,
        totalRows = totalRows,
        totalPages = totalPages,
        startIndex = totalRows > 0 and startIndex or 0,
        endIndex = totalRows > 0 and endIndex or 0,
    }
end

function DebugData.GetTexture(fullType)
    return nil
end

function DebugData.BuildDetailText(record)
    if not record then
        return " <RGB:0.65,0.65,0.65> Select a normalized item to inspect its mapping. <LINE> "
    end

    local bucketMeta = Buckets.Get(record.primaryBucket) or {}
    local abstractName, abstractID = buildAbstractText(bucketMeta, record.primaryBucket)
    local meaningText = tostring(bucketMeta.description or "No abstract resource description is defined for this bucket yet.")
    local text = " <RGB:1,1,1> <SIZE:Medium> " .. escapeRichText(record.displayName or record.fullType) .. " <LINE> "
    text = text .. " <RGB:0.55,0.8,1> " .. escapeRichText(record.fullType) .. " <LINE> <LINE> "
    text = text .. " <RGB:1,1,1> Abstract Mapping <LINE> "
    text = text .. " <RGB:0.85,0.85,0.85> Abstract Name: <RGB:1,1,1> " .. escapeRichText(abstractName) .. " <LINE> "
    text = text .. " <RGB:0.85,0.85,0.85> Abstract ID: <RGB:1,1,1> " .. escapeRichText(abstractID) .. " <LINE> "
    text = text .. " <RGB:0.85,0.85,0.85> Units: <RGB:1,1,1> " .. tostring(record.normalizedUnits or 0) .. " <LINE> "
    text = text .. " <RGB:0.85,0.85,0.85> Confidence: <RGB:1,1,1> " .. tostring(record.confidence or 0) .. "% <LINE> "
    text = text .. " <RGB:0.85,0.85,0.85> Source: <RGB:1,1,1> " .. escapeRichText(record.source or "") .. " <LINE> "
    text = text .. " <RGB:0.85,0.85,0.85> Base Price: <RGB:1,1,1> " .. tostring(record.basePrice or 0) .. " <LINE> "
    text = text .. " <RGB:0.85,0.85,0.85> Module: <RGB:1,1,1> " .. escapeRichText(record.module or "") .. " <LINE> <LINE> "

    text = text .. " <RGB:1,1,1> Related Abstract Meaning <LINE> "
    text = text .. " <RGB:0.8,0.8,0.8> " .. escapeRichText(meaningText) .. " <LINE> <LINE> "

    text = text .. " <RGB:1,1,1> Why It Mapped Here <LINE> "
    text = text .. " <RGB:0.8,0.8,0.8> This item is being normalized into the abstract resource above based on DT tags, script hints, or name heuristics. <LINE> "
    for _, reason in ipairs(record.reasons or {}) do
        text = text .. " <RGB:0.8,0.8,0.8> - " .. escapeRichText(reason) .. " <LINE> "
    end
    text = text .. " <LINE> "

    local quality = join(record.qualityFlags, ", ")
    text = text .. " <RGB:1,1,1> Quality Flags <LINE> "
    text = text .. " <RGB:0.8,0.8,0.8> " .. escapeRichText(quality ~= "" and quality or "None") .. " <LINE> <LINE> "

    local secondary = join(record.secondaryBuckets, ", ")
    text = text .. " <RGB:1,1,1> Secondary Buckets <LINE> "
    text = text .. " <RGB:0.8,0.8,0.8> " .. escapeRichText(secondary ~= "" and secondary or "None") .. " <LINE> <LINE> "

    text = text .. " <RGB:1,1,1> Tags <LINE> "
    text = text .. " <RGB:0.8,0.8,0.8> " .. escapeRichText(join(record.tags, ", ") ~= "" and join(record.tags, ", ") or "None") .. " <LINE> <LINE> "

    return text
end

function DebugData.GetStatusText(searchText, bucketFilter, filteredCount, pageIndex, totalPages, startIndex, endIndex)
    local state = Catalog.GetDebugState()
    local bucketMeta = Buckets.Get(bucketFilter)
    local bucketText = bucketFilter ~= "" and (bucketMeta and bucketMeta.shortLabel or bucketFilter) or "All"
    local searchInfo = tostring(searchText or "")
    if searchInfo == "" then
        searchInfo = "None"
    end
    return "Showing " .. tostring(startIndex or 0)
        .. "-" .. tostring(endIndex or 0)
        .. " of " .. tostring(filteredCount or 0)
        .. " filtered"
        .. " | Page " .. tostring(pageIndex or 1) .. "/" .. tostring(totalPages or 1)
        .. " | Catalog " .. tostring(state.totalRecords or 0)
        .. " | Bucket: " .. bucketText
        .. " | Search: " .. searchInfo
        .. " | Cache Rev: " .. tostring(state.revision or 0)
        .. " | Builds: " .. tostring(state.buildCount or 0)
end

return DebugData
