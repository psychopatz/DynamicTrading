-- =============================================================================
-- DT_AudioManager
-- Centralized Audio Handler for Dynamic Trading
-- =============================================================================

require "Utils/DT_ConfigManager"

DT_AudioManager = {}

local CategoryMap = {
    DT_RadioRandom = "Radio",
    DT_RadioStatic = "Radio",
    DT_CasinoRandom = "Wallet",
    DT_CasinoLose = "Wallet",
    DT_Cashier = "Trade"
}

--- Returns the category volume multiplier for a given sound
local function GetCategoryMultiplier(soundName)
    -- Safe retrieval of Master Volume
    local masterRaw = DT_ConfigManager.getVolume("Master")
    local master = tonumber(masterRaw)
    
    if not master then
        print("[DT_AudioManager] ERROR: Master volume is nil/invalid (" .. tostring(masterRaw) .. "). Defaulting to 1.0")
        master = 1.0
    end
    
    -- Check exact match
    local cat = CategoryMap[soundName]
    
    -- Heuristic check if not found
    if not cat then
        if string.find(soundName, "Radio") then cat = "Radio"
        elseif string.find(soundName, "Casino") then cat = "Wallet"
        elseif string.find(soundName, "Cashier") then cat = "Trade"
        else cat = "Master" 
        end
    end
    
    if cat == "Master" then return master end
    
    local subRaw = DT_ConfigManager.getVolume(cat)
    local subVol = tonumber(subRaw)
    
    if not subVol then
        print("[DT_AudioManager] ERROR: Category volume for " .. tostring(cat) .. " is nil/invalid (" .. tostring(subRaw) .. "). Defaulting to 1.0")
        subVol = 1.0
    end
    
    return master * subVol
end

--- Plays a sound with volume adjusted by user config
-- @param soundName (string) The name of the sound to play
-- @param isLoop (boolean) Whether the sound should loop (default false)
-- @param baseVolume (number) The base volume of the sound (default 1.0)
-- @return The java sound object or nil
function DT_AudioManager.PlaySound(soundName, isLoop, baseVolume)
    if not DT_ConfigManager.shouldPlaySound() then return end
    
    isLoop = isLoop or false
    baseVolume = baseVolume or 1.0
    
    -- Calculate final volume
    local multiplier = GetCategoryMultiplier(soundName)
    local finalVolume = baseVolume * multiplier
    
    -- Round to 4 decimal places for consistency
    finalVolume = math.floor(finalVolume * 10000 + 0.5) / 10000
    
    print("[DT_AudioManager] PlaySound: " .. soundName .. " | Base: " .. baseVolume .. " | Mult: " .. multiplier .. " | Final: " .. finalVolume)
    
    -- Prevent playing absolute silence, but allow very low volumes
    if finalVolume <= 0.0001 then return end
    
    local sound = getSoundManager():PlaySound(soundName, isLoop, finalVolume)
    return sound
end

--- Plays a UI sound (fire and forget)
-- @param soundName (string)
-- @param baseVolume (number)
function DT_AudioManager.PlayUISound(soundName, baseVolume)
    return DT_AudioManager.PlaySound(soundName, false, baseVolume)
end
