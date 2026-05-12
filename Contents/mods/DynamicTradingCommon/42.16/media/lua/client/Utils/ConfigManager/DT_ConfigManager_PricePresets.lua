local internal = DT_ConfigManagerInternal

function DT_ConfigManager.setLastPricePresetName(name)
    DT_ConfigManager.settings.lastPricePresetName = tostring(name or "default")
    DT_ConfigManager.save()
end

function DT_ConfigManager.getLastPricePresetName()
    return tostring(DT_ConfigManager.settings.lastPricePresetName or "default")
end

function DT_ConfigManager.setKnownPricePresets(values)
    if type(values) == "table" then
        DT_ConfigManager.settings.knownPricePresets = table.concat(values, "|")
    else
        DT_ConfigManager.settings.knownPricePresets = tostring(values or "default")
    end
    DT_ConfigManager.save()
end

function DT_ConfigManager.getKnownPricePresets()
    return internal.splitPipeList(DT_ConfigManager.settings.knownPricePresets or "default")
end

function DT_ConfigManager.addKnownPricePreset(name)
    local normalized = tostring(name or "")
    if normalized == "" then
        return
    end

    local values = DT_ConfigManager.getKnownPricePresets()
    for _, existing in ipairs(values) do
        if existing == normalized then
            DT_ConfigManager.settings.knownPricePresets = table.concat(values, "|")
            DT_ConfigManager.save()
            return
        end
    end

    values[#values + 1] = normalized
    table.sort(values, function(left, right)
        return string.lower(left) < string.lower(right)
    end)

    DT_ConfigManager.settings.knownPricePresets = table.concat(values, "|")
    DT_ConfigManager.save()
end

function DT_ConfigManager.setPriceEditorSelection(tag)
    DT_ConfigManager.settings.priceSelectedTag = tostring(tag or "")
    DT_ConfigManager.save()
end

function DT_ConfigManager.getPriceEditorSelection()
    return tostring(DT_ConfigManager.settings.priceSelectedTag or "")
end

function DT_ConfigManager.setPriceCollapsedTags(tags)
    if type(tags) == "table" then
        local values = {}
        for _, tag in ipairs(tags) do
            values[#values + 1] = tostring(tag)
        end
        DT_ConfigManager.settings.priceCollapsedTags = table.concat(values, "|")
    else
        DT_ConfigManager.settings.priceCollapsedTags = tostring(tags or "")
    end
    DT_ConfigManager.save()
end

function DT_ConfigManager.getPriceCollapsedTags()
    return internal.splitPipeList(DT_ConfigManager.settings.priceCollapsedTags or "")
end
