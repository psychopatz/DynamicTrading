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
    enableSound = true, -- true or false
    volume = 1.0        -- 0.0 to 1.0
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
        
        -- Write EnableSound
        -- We convert boolean true/false to string "true"/"false"
        fileWriter:write("enableSound=" .. tostring(DT_ConfigManager.settings.enableSound) .. "\r\n")
        
        -- Write Volume
        fileWriter:write("volume=" .. tostring(DT_ConfigManager.settings.volume) .. "\r\n")
        
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
        -- We parse the line looking for "key=value"
        -- This is a simple manual parser
        
        -- Check for enableSound
        if string.find(line, "enableSound=") then
            local valueStr = string.sub(line, 13) -- "enableSound=" is 12 chars, so start at 13
            if valueStr == "true" then
                DT_ConfigManager.settings.enableSound = true
            else
                DT_ConfigManager.settings.enableSound = false
            end
        end
        
        -- Check for volume
        if string.find(line, "volume=") then
            local valueStr = string.sub(line, 8) -- "volume=" is 7 chars, so start at 8
            local num = tonumber(valueStr)
            if num then
                DT_ConfigManager.settings.volume = num
            end
        end

        line = fileReader:readLine()
    end
    
    fileReader:close()
    print("[DT_ConfigManager] Config loaded. Sound: " .. tostring(DT_ConfigManager.settings.enableSound) .. ", Vol: " .. DT_ConfigManager.settings.volume)
end

-- =============================================================================
-- PUBLIC HELPERS (Call these from other scripts)
-- =============================================================================

--- Toggles sound on/off and saves
function DT_ConfigManager.toggleSound()
    DT_ConfigManager.settings.enableSound = not DT_ConfigManager.settings.enableSound
    DT_ConfigManager.save()
    return DT_ConfigManager.settings.enableSound
end

--- Sets volume (0.0 to 1.0) and saves
function DT_ConfigManager.setVolume(level)
    -- Clamp volume between 0 and 1
    if level < 0 then level = 0 end
    if level > 1 then level = 1 end
    
    DT_ConfigManager.settings.volume = level
    DT_ConfigManager.save()
end

--- Returns true if sound should play
function DT_ConfigManager.shouldPlaySound()
    return DT_ConfigManager.settings.enableSound
end

--- Returns the volume level
function DT_ConfigManager.getVolume()
    return DT_ConfigManager.settings.volume
end

-- =============================================================================
-- INITIALIZATION
-- =============================================================================

-- Load settings as soon as the game boots up
Events.OnGameBoot.Add(DT_ConfigManager.load)