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
    volMaster = 1.0,
    volRadio = 1.0,
    volWallet = 1.0,
    volTrade = 1.0
}

-- This table holds the *active* settings
DT_ConfigManager.settings = {}

-- COPY defaults to active settings initially
for k, v in pairs(DT_ConfigManager.defaultSettings) do
    DT_ConfigManager.settings[k] = v
end

-- =============================================================================
-- CORE LOGIC: SAVE & LOAD
-- =============================================================================

--- Saves the current settings to the text file on the disk
function DT_ConfigManager.save()
    local fileWriter = getFileWriter(DT_ConfigManager.fileName, true, false)
    
    if fileWriter then
        print("[DT_ConfigManager] Saving config to " .. DT_ConfigManager.fileName)
        fileWriter:write("enableSound=" .. tostring(DT_ConfigManager.settings.enableSound) .. "\r\n")
        fileWriter:write("volMaster=" .. tostring(DT_ConfigManager.settings.volMaster) .. "\r\n")
        fileWriter:write("volRadio=" .. tostring(DT_ConfigManager.settings.volRadio) .. "\r\n")
        fileWriter:write("volWallet=" .. tostring(DT_ConfigManager.settings.volWallet) .. "\r\n")
        fileWriter:write("volTrade=" .. tostring(DT_ConfigManager.settings.volTrade) .. "\r\n")
        fileWriter:close()
    else
        print("[DT_ConfigManager] ERROR: Could not create file writer.")
    end
end

--- Loads settings from the text file on the disk
function DT_ConfigManager.load()
    local fileReader = getFileReader(DT_ConfigManager.fileName, false)
    
    if not fileReader then
        print("[DT_ConfigManager] No config file found. Using defaults.")
        DT_ConfigManager.save() -- Create the file for next time
        return
    end

    print("[DT_ConfigManager] Loading config...")
    
    local line = fileReader:readLine()
    while line do
        if string.find(line, "enableSound=") then
            DT_ConfigManager.settings.enableSound = (string.sub(line, 13) == "true")
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

        line = fileReader:readLine()
    end
    
    fileReader:close()
    print("[DT_ConfigManager] Loaded.")
end

-- =============================================================================
-- PUBLIC HELPERS (Call these from other scripts)
-- =============================================================================

function DT_ConfigManager.toggleSound()
    DT_ConfigManager.settings.enableSound = not DT_ConfigManager.settings.enableSound
    DT_ConfigManager.save()
    return DT_ConfigManager.settings.enableSound
end

function DT_ConfigManager.setVolume(category, level)
    if level < 0 then level = 0 end
    if level > 1 then level = 1 end
    
    if category == "Master" then DT_ConfigManager.settings.volMaster = level
    elseif category == "Radio" then DT_ConfigManager.settings.volRadio = level
    elseif category == "Wallet" then DT_ConfigManager.settings.volWallet = level
    elseif category == "Trade" then DT_ConfigManager.settings.volTrade = level
    end
    
    DT_ConfigManager.save()
end

function DT_ConfigManager.shouldPlaySound()
    return DT_ConfigManager.settings.enableSound
end

function DT_ConfigManager.getVolume(category)
    if category == "Master" then return DT_ConfigManager.settings.volMaster or 1.0
    elseif category == "Radio" then return DT_ConfigManager.settings.volRadio or 1.0
    elseif category == "Wallet" then return DT_ConfigManager.settings.volWallet or 1.0
    elseif category == "Trade" then return DT_ConfigManager.settings.volTrade or 1.0
    end
    return 1.0
end


-- =============================================================================
-- INITIALIZATION
-- =============================================================================

-- Load settings as soon as the game boots up
Events.OnGameBoot.Add(DT_ConfigManager.load)
print("[DynamicTrading] Registered config manager.")