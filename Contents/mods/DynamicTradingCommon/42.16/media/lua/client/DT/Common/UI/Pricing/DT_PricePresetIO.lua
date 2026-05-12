-- =============================================================================
-- DYNAMIC TRADING: PRICE PRESET IMPORT / EXPORT
-- =============================================================================

require "Utils/ConfigManager/DT_ConfigManager"

DT_PricePresetIO = DT_PricePresetIO or {}

local PRESET_PREFIX = "DynamicTrading_PricingPreset_"
local PRESET_FOLDER_HINT = "Zomboid/Lua/"

local function trim(value)
    local text = tostring(value or "")
    text = string.gsub(text, "^%s+", "")
    text = string.gsub(text, "%s+$", "")
    return text
end

local function sanitizeName(name)
    local text = trim(name)
    if text == "" then
        text = "default"
    end

    text = string.gsub(text, "[^%w%-_ ]", "_")
    text = string.gsub(text, "%s+", "_")
    if text == "" then
        text = "default"
    end

    return text
end

local function sortedKeys(map)
    local keys = {}
    for key in pairs(map or {}) do
        keys[#keys + 1] = key
    end
    table.sort(keys)
    return keys
end

function DT_PricePresetIO.getFileName(presetName)
    return PRESET_PREFIX .. sanitizeName(presetName) .. ".txt"
end

function DT_PricePresetIO.getExportPathHint(presetName)
    return PRESET_FOLDER_HINT .. DT_PricePresetIO.getFileName(presetName)
end

function DT_PricePresetIO.exportPreset(presetName, data)
    local resolvedName = sanitizeName(presetName)
    local fileName = DT_PricePresetIO.getFileName(resolvedName)
    local payload = data or (DynamicTrading.PriceConfig and DynamicTrading.PriceConfig.GetData and DynamicTrading.PriceConfig.GetData()) or nil
    if type(payload) ~= "table" then
        return false, "No price config data available."
    end

    local writer = getFileWriter(fileName, true, false)
    if not writer then
        return false, "Unable to open preset file for writing."
    end

    local tagMultipliers = payload.tagMultipliers or {}
    local itemOverrides = payload.itemOverrides or {}

    writer:write("version=" .. tostring(payload.version or 1) .. "\r\n")
    writer:write("name=" .. resolvedName .. "\r\n")
    writer:write("updatedAt=" .. tostring(payload.updatedAt or 0) .. "\r\n")

    for _, tag in ipairs(sortedKeys(tagMultipliers)) do
        writer:write("tag=" .. tostring(tag) .. "|" .. tostring(tagMultipliers[tag]) .. "\r\n")
    end

    for _, itemKey in ipairs(sortedKeys(itemOverrides)) do
        writer:write("item=" .. tostring(itemKey) .. "|" .. tostring(itemOverrides[itemKey]) .. "\r\n")
    end

    writer:close()

    if DT_ConfigManager and DT_ConfigManager.setLastPricePresetName then
        DT_ConfigManager.setLastPricePresetName(resolvedName)
    end
    if DT_ConfigManager and DT_ConfigManager.addKnownPricePreset then
        DT_ConfigManager.addKnownPricePreset(resolvedName)
    end

    return true, fileName
end

function DT_PricePresetIO.importPreset(presetName)
    local resolvedName = sanitizeName(presetName)
    local fileName = DT_PricePresetIO.getFileName(resolvedName)
    local reader = getFileReader(fileName, false)
    if not reader then
        return false, "Preset file not found: " .. fileName
    end

    local payload = {
        name = resolvedName,
        tagMultipliers = {},
        itemOverrides = {}
    }
    local warnings = {}

    local line = reader:readLine()
    while line do
        local text = trim(line)
        if text ~= "" and string.sub(text, 1, 1) ~= "#" then
            local equalsPos = string.find(text, "=", 1, true)
            if equalsPos then
                local key = string.sub(text, 1, equalsPos - 1)
                local value = string.sub(text, equalsPos + 1)

                if key == "name" then
                    payload.name = sanitizeName(value)
                elseif key == "tag" or key == "item" then
                    local splitPos = string.find(value, "|", 1, true)
                    if splitPos then
                        local left = trim(string.sub(value, 1, splitPos - 1))
                        local right = trim(string.sub(value, splitPos + 1))
                        local number = tonumber(right)

                        if left ~= "" and number ~= nil then
                            if key == "tag" then
                                payload.tagMultipliers[left] = number
                            else
                                payload.itemOverrides[left] = number
                            end
                        else
                            warnings[#warnings + 1] = "Skipped malformed preset line: " .. text
                        end
                    else
                        warnings[#warnings + 1] = "Skipped malformed preset line: " .. text
                    end
                end
            end
        end

        line = reader:readLine()
    end

    reader:close()

    if DT_ConfigManager and DT_ConfigManager.setLastPricePresetName then
        DT_ConfigManager.setLastPricePresetName(payload.name)
    end
    if DT_ConfigManager and DT_ConfigManager.addKnownPricePreset then
        DT_ConfigManager.addKnownPricePreset(payload.name)
    end

    return true, payload, warnings
end

return DT_PricePresetIO
