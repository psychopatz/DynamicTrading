-- =============================================================================
-- DT_AudioManager (Common)
-- Centralized Audio Handler for Dynamic Trading
-- Data-agnostic: Register categories via DT_AudioManager.RegisterCategory
-- =============================================================================

require "Utils/ConfigManager/DT_ConfigManager"

DT_AudioManager = {}

-- Stores category mappings: SoundPrefix -> CategoryName
-- e.g. "DT_RadioRandom" -> "Radio"
DT_AudioManager.CategoryMap = {}

-- Stores helper data for categories (not strictly necessary but good for debugging)
DT_AudioManager.Categories = {
    Master = true -- Always exists
}

--- Registers a sound prefix to a volume category
-- @param soundPrefix (string) The prefix or full name of the sound (e.g., "DT_Radio")
-- @param category (string) The specific category name in ConfigManager (e.g., "Radio")
function DT_AudioManager.RegisterCategory(soundPrefix, category)
    DT_AudioManager.CategoryMap[soundPrefix] = category
    DT_AudioManager.Categories[category] = true
end

--- Returns the category volume multiplier for a given sound
local function GetCategoryMultiplier(soundName)
    -- Safe retrieval of Master Volume
    local masterRaw = DT_ConfigManager.getVolume("Master")
    local master = tonumber(masterRaw) or 0.6
    
    -- Check for prefix/exact match in map
    local cat = "General" -- Default to General, not Master
    
    -- Exact match in map?
    if DT_AudioManager.CategoryMap[soundName] then
        cat = DT_AudioManager.CategoryMap[soundName]
    else
        -- Check for key match in the map keys
        for prefix, category in pairs(DT_AudioManager.CategoryMap) do
            if string.find(soundName, prefix) then
                cat = category
                break
            end
        end
    end
    
    local subRaw = DT_ConfigManager.getVolume(cat)
    local subVol = tonumber(subRaw) or 0.5
    
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
