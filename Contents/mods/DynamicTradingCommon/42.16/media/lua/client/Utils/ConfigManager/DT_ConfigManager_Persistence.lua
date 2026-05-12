local internal = DT_ConfigManagerInternal

local function writeLine(fileWriter, key, value)
    fileWriter:write(key .. "=" .. tostring(value) .. "\r\n")
end

local function parseWindowState(line)
    local payload = internal.readPrefixedValue(line, "window_")
    if not payload then
        return
    end

    local separatorIndex = string.find(payload, "=")
    if not separatorIndex then
        return
    end

    local winID = string.sub(payload, 1, separatorIndex - 1)
    local csvValue = string.sub(payload, separatorIndex + 1)
    local parts = {}

    for value in string.gmatch(csvValue, "([^,]+)") do
        parts[#parts + 1] = tonumber(value)
    end

    if #parts == 4 then
        internal.ensureWindows()[winID] = {
            x = parts[1],
            y = parts[2],
            w = parts[3],
            h = parts[4]
        }
    end
end

function DT_ConfigManager.save()
    local fileWriter = getFileWriter(DT_ConfigManager.fileName, true, false)

    if not fileWriter then
        DynamicTrading.Log("DTCommons", "Error", "Config", "Could not create file writer for " .. DT_ConfigManager.fileName)
        return
    end

    writeLine(fileWriter, "enableSound", DT_ConfigManager.settings.enableSound)
    writeLine(fileWriter, "showSidebar", DT_ConfigManager.settings.showSidebar)
    writeLine(fileWriter, "debugLogs", DT_ConfigManager.settings.debugLogs)
    writeLine(fileWriter, "use3DPortraits", DT_ConfigManager.settings.use3DPortraits)
    writeLine(fileWriter, "conversationOverlayOpacity", DT_ConfigManager.settings.conversationOverlayOpacity)
    writeLine(fileWriter, "disableConversationTransparency", DT_ConfigManager.settings.disableConversationTransparency)
    writeLine(fileWriter, "volMaster", DT_ConfigManager.settings.volMaster)
    writeLine(fileWriter, "volRadio", DT_ConfigManager.settings.volRadio)
    writeLine(fileWriter, "volWallet", DT_ConfigManager.settings.volWallet)
    writeLine(fileWriter, "volTrade", DT_ConfigManager.settings.volTrade)
    writeLine(fileWriter, "volGeneral", DT_ConfigManager.settings.volGeneral)
    writeLine(fileWriter, "lastManualId", DT_ConfigManager.settings.lastManualId or "")
    writeLine(fileWriter, "lastManualPageId", DT_ConfigManager.settings.lastManualPageId or "")
    writeLine(fileWriter, "lastManualSectionId", DT_ConfigManager.settings.lastManualSectionId or "")
    writeLine(fileWriter, "lastPricePresetName", DT_ConfigManager.settings.lastPricePresetName or "default")
    writeLine(fileWriter, "knownPricePresets", DT_ConfigManager.settings.knownPricePresets or "default")
    writeLine(fileWriter, "priceSelectedTag", DT_ConfigManager.settings.priceSelectedTag or "")
    writeLine(fileWriter, "priceCollapsedTags", DT_ConfigManager.settings.priceCollapsedTags or "")

    for winID, data in pairs(internal.ensureWindows()) do
        if data then
            fileWriter:write(string.format("window_%s=%d,%d,%d,%d\r\n", winID, data.x, data.y, data.w, data.h))
        end
    end

    fileWriter:close()
end

function DT_ConfigManager.load()
    local fileReader = getFileReader(DT_ConfigManager.fileName, false)

    if not fileReader then
        DynamicTrading.Log("DTCommons", "Config", "Init", "No config file found. Using defaults.")
        DT_ConfigManager.save()
        return
    end

    DynamicTrading.Log("DTCommons", "Config", "Init", "Loading config...")
    internal.resetSettings()

    local line = fileReader:readLine()
    while line do
        local value = internal.readPrefixedValue(line, "enableSound=")
        if value ~= nil then
            DT_ConfigManager.settings.enableSound = (value == "true")
        end

        value = internal.readPrefixedValue(line, "showSidebar=")
        if value ~= nil then
            DT_ConfigManager.settings.showSidebar = (value == "true")
        end

        value = internal.readPrefixedValue(line, "debugLogs=")
        if value ~= nil then
            DT_ConfigManager.settings.debugLogs = (value == "true")
        end

        value = internal.readPrefixedValue(line, "use3DPortraits=")
        if value ~= nil then
            DT_ConfigManager.settings.use3DPortraits = (value == "true")
        end

        value = internal.readPrefixedValue(line, "conversationOverlayOpacity=")
        if value ~= nil then
            DT_ConfigManager.settings.conversationOverlayOpacity = internal.clampUnit(
                value,
                DT_ConfigManager.defaultSettings.conversationOverlayOpacity
            )
        end

        value = internal.readPrefixedValue(line, "disableConversationTransparency=")
        if value ~= nil then
            DT_ConfigManager.settings.disableConversationTransparency = (value == "true")
        end

        value = internal.readPrefixedValue(line, "volMaster=")
        if value ~= nil and tonumber(value) ~= nil then
            DT_ConfigManager.settings.volMaster = tonumber(value)
        end

        value = internal.readPrefixedValue(line, "volRadio=")
        if value ~= nil and tonumber(value) ~= nil then
            DT_ConfigManager.settings.volRadio = tonumber(value)
        end

        value = internal.readPrefixedValue(line, "volWallet=")
        if value ~= nil and tonumber(value) ~= nil then
            DT_ConfigManager.settings.volWallet = tonumber(value)
        end

        value = internal.readPrefixedValue(line, "volTrade=")
        if value ~= nil and tonumber(value) ~= nil then
            DT_ConfigManager.settings.volTrade = tonumber(value)
        end

        value = internal.readPrefixedValue(line, "volGeneral=")
        if value ~= nil and tonumber(value) ~= nil then
            DT_ConfigManager.settings.volGeneral = tonumber(value)
        end

        value = internal.readPrefixedValue(line, "lastManualId=")
        if value ~= nil then
            DT_ConfigManager.settings.lastManualId = value
        end

        value = internal.readPrefixedValue(line, "lastManualPageId=")
        if value ~= nil then
            DT_ConfigManager.settings.lastManualPageId = value
        end

        value = internal.readPrefixedValue(line, "lastManualSectionId=")
        if value ~= nil then
            DT_ConfigManager.settings.lastManualSectionId = value
        end

        value = internal.readPrefixedValue(line, "lastPricePresetName=")
        if value ~= nil then
            DT_ConfigManager.settings.lastPricePresetName = value
        end

        value = internal.readPrefixedValue(line, "knownPricePresets=")
        if value ~= nil then
            DT_ConfigManager.settings.knownPricePresets = value
        end

        value = internal.readPrefixedValue(line, "priceSelectedTag=")
        if value ~= nil then
            DT_ConfigManager.settings.priceSelectedTag = value
        end

        value = internal.readPrefixedValue(line, "priceCollapsedTags=")
        if value ~= nil then
            DT_ConfigManager.settings.priceCollapsedTags = value
        end

        parseWindowState(line)
        line = fileReader:readLine()
    end

    fileReader:close()
    DynamicTrading.Debug = DT_ConfigManager.settings.debugLogs == true
    DynamicTrading.Log("DTCommons", "Config", "Init", "Config Loaded successfully")
end
