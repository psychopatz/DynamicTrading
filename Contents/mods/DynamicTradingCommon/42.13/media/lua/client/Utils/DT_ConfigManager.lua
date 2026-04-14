-- =============================================================================
-- DT_ConfigManager
-- Handles persistent Client-side configuration (Volume, Toggles)
-- Saves to: C:\Users\<You>\Zomboid\Lua\DynamicTrading_Config.txt
-- =============================================================================

DT_ConfigManager = {}

-- The name of the file on your hard drive
DT_ConfigManager.fileName = "DynamicTrading_Config.txt"

-- Default settings if no file is found
DT_ConfigManager.defaultSettings = {
    enableSound = true,
    showSidebar = true,
    debugLogs = false,
    use3DPortraits = true,
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

-- This table holds the *active* settings
DT_ConfigManager.settings = {}

-- COPY defaults to active settings initially
for k, v in pairs(DT_ConfigManager.defaultSettings) do
    DT_ConfigManager.settings[k] = v
end

-- Ensure windows table exists
if not DT_ConfigManager.settings.windows then
    DT_ConfigManager.settings.windows = {}
end

-- =============================================================================
-- CORE LOGIC: SAVE & LOAD
-- =============================================================================

--- Saves the current settings to the text file on the disk
function DT_ConfigManager.save()
    local fileWriter = getFileWriter(DT_ConfigManager.fileName, true, false)
    
    if fileWriter then
        -- print("[DT_ConfigManager] Saving config to " .. DT_ConfigManager.fileName)
        fileWriter:write("enableSound=" .. tostring(DT_ConfigManager.settings.enableSound) .. "\r\n")
        fileWriter:write("showSidebar=" .. tostring(DT_ConfigManager.settings.showSidebar) .. "\r\n")
        fileWriter:write("debugLogs=" .. tostring(DT_ConfigManager.settings.debugLogs) .. "\r\n")
        fileWriter:write("use3DPortraits=" .. tostring(DT_ConfigManager.settings.use3DPortraits) .. "\r\n")
        fileWriter:write("volMaster=" .. tostring(DT_ConfigManager.settings.volMaster) .. "\r\n")
        fileWriter:write("volRadio=" .. tostring(DT_ConfigManager.settings.volRadio) .. "\r\n")
        fileWriter:write("volWallet=" .. tostring(DT_ConfigManager.settings.volWallet) .. "\r\n")
        fileWriter:write("volTrade=" .. tostring(DT_ConfigManager.settings.volTrade) .. "\r\n")
        fileWriter:write("volGeneral=" .. tostring(DT_ConfigManager.settings.volGeneral) .. "\r\n")
        fileWriter:write("lastManualId=" .. tostring(DT_ConfigManager.settings.lastManualId or "") .. "\r\n")
        fileWriter:write("lastManualPageId=" .. tostring(DT_ConfigManager.settings.lastManualPageId or "") .. "\r\n")
        fileWriter:write("lastManualSectionId=" .. tostring(DT_ConfigManager.settings.lastManualSectionId or "") .. "\r\n")

        fileWriter:write("lastPricePresetName=" .. tostring(DT_ConfigManager.settings.lastPricePresetName or "default") .. "\r\n")
        fileWriter:write("knownPricePresets=" .. tostring(DT_ConfigManager.settings.knownPricePresets or "default") .. "\r\n")
        fileWriter:write("priceSelectedTag=" .. tostring(DT_ConfigManager.settings.priceSelectedTag or "") .. "\r\n")
        fileWriter:write("priceCollapsedTags=" .. tostring(DT_ConfigManager.settings.priceCollapsedTags or "") .. "\r\n")
        
        -- Save Window States
        if DT_ConfigManager.settings.windows then
            for winID, data in pairs(DT_ConfigManager.settings.windows) do
                if data then
                    local line = string.format("window_%s=%d,%d,%d,%d", winID, data.x, data.y, data.w, data.h)
                    fileWriter:write(line .. "\r\n")
                end
            end
        end
        
        fileWriter:close()
    else
        DynamicTrading.Log("DTCommons", "Error", "Config", "Could not create file writer for " .. DT_ConfigManager.fileName)
    end
end

--- Loads settings from the text file on the disk
function DT_ConfigManager.load()
    local fileReader = getFileReader(DT_ConfigManager.fileName, false)
    
    if not fileReader then
        DynamicTrading.Log("DTCommons", "Config", "Init", "No config file found. Using defaults.")
        DT_ConfigManager.save() -- Create the file for next time
        return
    end

    DynamicTrading.Log("DTCommons", "Config", "Init", "Loading config...")
    
    -- Reset windows table on load to avoid stale data if we were to re-read
    DT_ConfigManager.settings.windows = {} 
    
    local line = fileReader:readLine()
    while line do
        if string.find(line, "enableSound=") then
            DT_ConfigManager.settings.enableSound = (string.sub(line, 13) == "true")
        end
        if string.find(line, "showSidebar=") then
            DT_ConfigManager.settings.showSidebar = (string.sub(line, 13) == "true")
        end
        if string.find(line, "debugLogs=") then
            DT_ConfigManager.settings.debugLogs = (string.sub(line, 11) == "true")
        end
        if string.find(line, "use3DPortraits=") then
            DT_ConfigManager.settings.use3DPortraits = (string.sub(line, 16) == "true")
        end
        if string.find(line, "volMaster=") then
            local n = tonumber(string.sub(line, 11))
            if n then DT_ConfigManager.settings.volMaster = n end
        end
        if string.find(line, "volRadio=") then
            local n = tonumber(string.sub(line, 10))
            if n then DT_ConfigManager.settings.volRadio = n end
        end
        if string.find(line, "volWallet=") then
            local n = tonumber(string.sub(line, 11))
            if n then DT_ConfigManager.settings.volWallet = n end
        end
        if string.find(line, "volTrade=") then
            local n = tonumber(string.sub(line, 10))
            if n then DT_ConfigManager.settings.volTrade = n end
        end
        if string.find(line, "volGeneral=") then
            local n = tonumber(string.sub(line, 12))
            if n then DT_ConfigManager.settings.volGeneral = n end
        end
        if string.find(line, "lastManualId=") then
            DT_ConfigManager.settings.lastManualId = string.sub(line, 14)
        end
        if string.find(line, "lastManualPageId=") then
            DT_ConfigManager.settings.lastManualPageId = string.sub(line, 18)
        end
        if string.find(line, "lastManualSectionId=") then
            DT_ConfigManager.settings.lastManualSectionId = string.sub(line, 21)
        end

        if string.find(line, "lastPricePresetName=") then
            DT_ConfigManager.settings.lastPricePresetName = string.sub(line, 20)
        end
        if string.find(line, "knownPricePresets=") then
            DT_ConfigManager.settings.knownPricePresets = string.sub(line, 18)
        end
        if string.find(line, "priceSelectedTag=") then
            DT_ConfigManager.settings.priceSelectedTag = string.sub(line, 18)
        end
        if string.find(line, "priceCollapsedTags=") then
            DT_ConfigManager.settings.priceCollapsedTags = string.sub(line, 19)
        end
        
        -- Window State Parsing: window_ID=x,y,w,h
        if string.find(line, "window_") then
            local s, e = string.find(line, "=")
            if s then
                local key = string.sub(line, 1, s-1) -- e.g. "window_TradingWindow"
                local val = string.sub(line, s+1)    -- e.g. "100,100,500,600"
                
                local winID = string.sub(key, 8) -- strip "window_"
                
                -- Parse CSV
                local parts = {}
                for p in string.gmatch(val, "([^,]+)") do
                    table.insert(parts, tonumber(p))
                end
                
                if #parts == 4 then
                    DT_ConfigManager.settings.windows[winID] = {
                        x = parts[1],
                        y = parts[2],
                        w = parts[3],
                        h = parts[4]
                    }
                end
            end
        end

        line = fileReader:readLine()
    end
    
    fileReader:close()
    DynamicTrading.Debug = DT_ConfigManager.settings.debugLogs == true
    DynamicTrading.Log("DTCommons", "Config", "Init", "Config Loaded successfully")
end

-- =============================================================================
-- PUBLIC HELPERS (Call these from other scripts)
-- =============================================================================

function DT_ConfigManager.toggleSound()
    DT_ConfigManager.settings.enableSound = not DT_ConfigManager.settings.enableSound
    DT_ConfigManager.save()
    return DT_ConfigManager.settings.enableSound
end

function DT_ConfigManager.setShowSidebar(isVisible)
    DT_ConfigManager.settings.showSidebar = isVisible
    DT_ConfigManager.save()
end

function DT_ConfigManager.setDebugLogs(enabled)
    DT_ConfigManager.settings.debugLogs = enabled == true
    DynamicTrading.Debug = DT_ConfigManager.settings.debugLogs
    DT_ConfigManager.save()
end

function DT_ConfigManager.setVolume(category, level)
    if level < 0 then level = 0 end
    if level > 1 then level = 1 end
    
    if category == "Master" then DT_ConfigManager.settings.volMaster = level
    elseif category == "Radio" then DT_ConfigManager.settings.volRadio = level
    elseif category == "Wallet" then DT_ConfigManager.settings.volWallet = level
    elseif category == "Trade" then DT_ConfigManager.settings.volTrade = level
    elseif category == "General" then DT_ConfigManager.settings.volGeneral = level
    end
    
    DT_ConfigManager.save()
end

function DT_ConfigManager.shouldPlaySound()
    return DT_ConfigManager.settings.enableSound
end

function DT_ConfigManager.getVolume(category)
    if category == "Master" then return DT_ConfigManager.settings.volMaster or 1.0
    elseif category == "Radio" then return DT_ConfigManager.settings.volRadio or 1.0
    elseif category == "Wallet" then return DT_ConfigManager.settings.volWallet or 0.5
    elseif category == "Trade" then return DT_ConfigManager.settings.volTrade or 0.5
    elseif category == "General" then return DT_ConfigManager.settings.volGeneral or 0.5
    end
    return 1.0
end

-- =============================================================================
-- WINDOW STATE HELPERS
-- =============================================================================

function DT_ConfigManager.setWindowState(winID, x, y, w, h)
    if not DT_ConfigManager.settings.windows then
        DT_ConfigManager.settings.windows = {}
    end
    
    DT_ConfigManager.settings.windows[winID] = { x=x, y=y, w=w, h=h }
    DT_ConfigManager.save()
end

function DT_ConfigManager.getWindowState(winID)
    if not DT_ConfigManager.settings.windows then return nil end
    return DT_ConfigManager.settings.windows[winID]
end

function DT_ConfigManager.setLastManualLocation(manualId, pageId, sectionId)
    DT_ConfigManager.settings.lastManualId = tostring(manualId or "")
    DT_ConfigManager.settings.lastManualPageId = tostring(pageId or "")
    DT_ConfigManager.settings.lastManualSectionId = tostring(sectionId or "")
    DT_ConfigManager.save()
end

function DT_ConfigManager.getLastManualLocation()
    return {
        manualId = DT_ConfigManager.settings.lastManualId or "",
        pageId = DT_ConfigManager.settings.lastManualPageId or "",
        sectionId = DT_ConfigManager.settings.lastManualSectionId or "",
    }
end

-- =============================================================================
-- MODDATA-BASED MANUAL STATE (per-save, resets on new game)
-- =============================================================================

local DT_MANUAL_MODDATA_KEY = "DT_ManualState"

function DT_ConfigManager.getManualModData()
    local player = getSpecificPlayer and getSpecificPlayer(0) or nil
    if not player then return nil end
    local modData = player:getModData()
    if not modData[DT_MANUAL_MODDATA_KEY] then
        modData[DT_MANUAL_MODDATA_KEY] = {}
    end
    return modData[DT_MANUAL_MODDATA_KEY]
end

function DT_ConfigManager.setLastSeenReleaseVersion(version)
    local md = DT_ConfigManager.getManualModData()
    if md then md.lastSeenReleaseVersion = tostring(version or "") end
end

function DT_ConfigManager.getLastSeenReleaseVersion()
    local md = DT_ConfigManager.getManualModData()
    return md and tostring(md.lastSeenReleaseVersion or "") or ""
end

function DT_ConfigManager.setLastSeenWhatsNewCount(count)
    local md = DT_ConfigManager.getManualModData()
    if md then md.lastSeenWhatsNewCount = tonumber(count or 0) or 0 end
end

function DT_ConfigManager.getLastSeenWhatsNewCount()
    local md = DT_ConfigManager.getManualModData()
    return md and tonumber(md.lastSeenWhatsNewCount or 0) or 0
end

function DT_ConfigManager.setLastAutoOpenedReleaseVersion(version)
    local md = DT_ConfigManager.getManualModData()
    if md then md.lastAutoOpenedReleaseVersion = tostring(version or "") end
end

function DT_ConfigManager.getLastAutoOpenedReleaseVersion()
    local md = DT_ConfigManager.getManualModData()
    return md and tostring(md.lastAutoOpenedReleaseVersion or "") or ""
end

function DT_ConfigManager.setDisabledAutoOpenReleaseVersion(version)
    local md = DT_ConfigManager.getManualModData()
    if md then md.disabledAutoOpenReleaseVersion = tostring(version or "") end
end

function DT_ConfigManager.getDisabledAutoOpenReleaseVersion()
    local md = DT_ConfigManager.getManualModData()
    return md and tostring(md.disabledAutoOpenReleaseVersion or "") or ""
end

function DT_ConfigManager.setDismissedSupportBannerVersion(version)
    local md = DT_ConfigManager.getManualModData()
    if md then md.dismissedSupportBannerVersion = tostring(version or "") end
end

function DT_ConfigManager.getDismissedSupportBannerVersion()
    local md = DT_ConfigManager.getManualModData()
    return md and tostring(md.dismissedSupportBannerVersion or "") or ""
end

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
    local raw = tostring(DT_ConfigManager.settings.knownPricePresets or "default")
    local values = {}
    if raw == "" then
        return values
    end

    for value in string.gmatch(raw, "([^|]+)") do
        values[#values + 1] = value
    end

    return values
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
    local raw = tostring(DT_ConfigManager.settings.priceCollapsedTags or "")
    local tags = {}
    if raw == "" then
        return tags
    end

    for tag in string.gmatch(raw, "([^|]+)") do
        tags[#tags + 1] = tag
    end

    return tags
end


-- =============================================================================
-- INITIALIZATION
-- =============================================================================

-- Load settings as soon as the game boots up
Events.OnGameBoot.Add(DT_ConfigManager.load)
DynamicTrading.Log("DTCommons", "Init", "Config", "Registered config manager")
