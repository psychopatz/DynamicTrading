local internal = DT_ConfigManagerInternal

DT_ConfigManager.fileName = "DynamicTrading_Config.txt"

DT_ConfigManager.defaultSettings = {
    enableSound = true,
    showSidebar = true,
    debugLogs = false,
    use3DPortraits = true,
    conversationOverlayOpacity = 1.0,
    disableConversationTransparency = false,
    volMaster = 0.6,
    volRadio = 0.6,
    volWallet = 0.5,
    volTrade = 0.5,
    volGeneral = 0.5,
    lastManualId = "",
    lastManualPageId = "",
    lastManualSectionId = "",
    lastPricePresetName = "default",
    knownPricePresets = "default",
    priceSelectedTag = "",
    priceCollapsedTags = ""
}

function internal.clampUnit(value, fallback)
    local numberValue = tonumber(value)
    if numberValue == nil then
        numberValue = tonumber(fallback) or 0
    end
    if numberValue < 0 then
        numberValue = 0
    end
    if numberValue > 1 then
        numberValue = 1
    end
    return numberValue
end

function internal.readPrefixedValue(line, prefix)
    if string.sub(line, 1, #prefix) == prefix then
        return string.sub(line, #prefix + 1)
    end
    return nil
end

function internal.resetSettings()
    DT_ConfigManager.settings = DT_ConfigManager.settings or {}
    for key, value in pairs(DT_ConfigManager.defaultSettings) do
        DT_ConfigManager.settings[key] = value
    end
    DT_ConfigManager.settings.windows = {}
end

function internal.ensureWindows()
    if not DT_ConfigManager.settings then
        DT_ConfigManager.settings = {}
    end
    if not DT_ConfigManager.settings.windows then
        DT_ConfigManager.settings.windows = {}
    end
    return DT_ConfigManager.settings.windows
end

function internal.splitPipeList(rawValue)
    local values = {}
    local raw = tostring(rawValue or "")
    if raw == "" then
        return values
    end

    for value in string.gmatch(raw, "([^|]+)") do
        values[#values + 1] = value
    end

    return values
end

internal.resetSettings()
