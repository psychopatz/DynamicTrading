DynamicTrading = DynamicTrading or {}
DynamicTrading.Abstract = DynamicTrading.Abstract or {}
DynamicTrading.Abstract.Normalization = DynamicTrading.Abstract.Normalization or {}

local Types = DynamicTrading.Abstract.Normalization.Types or {}
DynamicTrading.Abstract.Normalization.Types = Types

Types.RECORD_FIELDS = {
    "fullType",
    "displayName",
    "module",
    "basePrice",
    "tags",
    "primaryBucket",
    "secondaryBuckets",
    "normalizedUnits",
    "qualityFlags",
    "source",
    "confidence",
    "reasons",
}

Types.SOURCE = {
    explicit = "explicit_override",
    tagRule = "tag_rule",
    scriptHint = "script_hint",
    heuristic = "name_heuristic",
}

Types.CONFIDENCE = {
    explicit = 95,
    tagRule = 78,
    scriptHint = 58,
    heuristic = 38,
    fallback = 12,
}

local function deepCopyArray(values)
    local copy = {}
    for i = 1, #(values or {}) do
        copy[i] = values[i]
    end
    return copy
end

local function shallowCopyMap(source)
    local copy = {}
    for key, value in pairs(source or {}) do
        copy[key] = value
    end
    return copy
end

local function trim(value)
    local text = tostring(value or "")
    text = text:gsub("^%s+", "")
    text = text:gsub("%s+$", "")
    return text
end

local function normalizeSearchText(value)
    local text = string.lower(trim(value))
    text = text:gsub("[%s_%-]+", " ")
    return text
end

local function parseModule(fullType)
    local text = tostring(fullType or "")
    local moduleName = text:match("^([^%.]+)%.")
    return moduleName or ""
end

local function shortType(fullType)
    local text = tostring(fullType or "")
    return text:match("([^%.]+)$") or text
end

local function uniqueSortedArray(values)
    local seen = {}
    local ordered = {}
    for _, value in ipairs(values or {}) do
        local text = trim(value)
        if text ~= "" and not seen[text] then
            seen[text] = true
            ordered[#ordered + 1] = text
        end
    end
    table.sort(ordered)
    return ordered
end

Types.DeepCopyArray = deepCopyArray
Types.ShallowCopyMap = shallowCopyMap
Types.Trim = trim
Types.NormalizeSearchText = normalizeSearchText
Types.ParseModule = parseModule
Types.ShortType = shortType
Types.UniqueSortedArray = uniqueSortedArray

return Types
