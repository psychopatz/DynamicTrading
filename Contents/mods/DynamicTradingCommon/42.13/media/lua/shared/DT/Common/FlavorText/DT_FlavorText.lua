DynamicTrading = DynamicTrading or {}
DynamicTrading.FlavorText = DynamicTrading.FlavorText or {}
DynamicTrading.FlavorText.Tables = DynamicTrading.FlavorText.Tables or {}

local function getLanguageCode()
    if DynamicTrading.GetLanguage then
        return DynamicTrading.GetLanguage()
    end

    if Translator and Translator.getLanguage() then
        return Translator.getLanguage():toString()
    end

    return "EN"
end

local function getGlobalTableName(category, kind, lang)
    return "DT_FlavorText_" .. tostring(category) .. "_" .. tostring(kind) .. "_" .. tostring(lang)
end

local function getRawFlavorTable(category, kind, lang)
    local categoryTables = DynamicTrading.FlavorText.Tables[category]
    local kindTables = categoryTables and categoryTables[kind]
    local registered = kindTables and kindTables[lang]
    if type(registered) == "table" then
        return registered
    end

    return rawget(_G, getGlobalTableName(category, kind, lang))
end

local function formatPlaceholders(text, ...)
    local args = { ... }
    return (tostring(text):gsub("%%(%d+)", function(index)
        local value = args[tonumber(index)]
        if value == nil then
            return "%" .. index
        end
        return tostring(value)
    end))
end

function DynamicTrading.FlavorText.GetLanguage()
    return getLanguageCode()
end

function DynamicTrading.FlavorText.RegisterTable(category, kind, lang, data)
    if not category or not kind or not lang or type(data) ~= "table" then
        return
    end

    local tables = DynamicTrading.FlavorText.Tables
    tables[category] = tables[category] or {}
    tables[category][kind] = tables[category][kind] or {}
    tables[category][kind][lang] = data

    -- Preserve compatibility with any code that still expects the old global tables.
    rawset(_G, getGlobalTableName(category, kind, lang), data)
end

function DynamicTrading.FlavorText.GetTable(category, kind, lang)
    local targetLang = lang or getLanguageCode()
    local langTable = getRawFlavorTable(category, kind, targetLang)
    if langTable ~= nil then
        return langTable
    end
    if targetLang ~= "EN" then
        return getRawFlavorTable(category, kind, "EN")
    end
    return nil
end

function DynamicTrading.FlavorText.GetValue(category, kind, key, ...)
    local targetLang = getLanguageCode()
    local langTable = getRawFlavorTable(category, kind, targetLang)
    local value = langTable and langTable[key]

    if value == nil and targetLang ~= "EN" then
        local fallbackTable = getRawFlavorTable(category, kind, "EN")
        value = fallbackTable and fallbackTable[key]
    end

    if type(value) ~= "string" then
        return tostring(key or "")
    end

    if select("#", ...) > 0 then
        return formatPlaceholders(value, ...)
    end

    return value
end

function DynamicTrading.FlavorText.GetPool(category, kind, lang)
    local pool = DynamicTrading.FlavorText.GetTable(category, kind, lang)
    if type(pool) == "table" then
        return pool
    end
    return nil
end

function DynamicTrading.FlavorText.GetRandom(category, kind, lang)
    local pool = DynamicTrading.FlavorText.GetPool(category, kind, lang)
    if not pool or #pool == 0 then
        return ""
    end
    return pool[ZombRand(#pool) + 1]
end

function DynamicTrading.FlavorText.GetBySeed(category, kind, seed, lang)
    local pool = DynamicTrading.FlavorText.GetPool(category, kind, lang)
    if not pool or #pool == 0 then
        return ""
    end

    local safeSeed = tonumber(seed) or 1
    local index = ((safeSeed - 1) % #pool) + 1
    return pool[index]
end
