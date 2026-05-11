-- ==============================================================================
-- DTNPC_Hostility_Sounds.lua
-- Unique vocal effects for NPCs based on identity and gender.
-- ==============================================================================

DTNPCHostility = DTNPCHostility or {}

local Hostility = DTNPCHostility
local Internal = Hostility.Internal or {}

Hostility.Internal = Internal

--- Plays a unique hurt sound for an NPC based on their identity seed and gender.
--- Uses pitch variation and voice sets to ensure many unique "voices" from vanilla assets.
--- @param zombie IsoZombie
--- @param npcData table
--- @param type string # "Hurt", "Incap", or "Death"
function Hostility.PlayHurtSound(zombie, npcData, type)
    if not zombie or not npcData then
        return
    end

    local seed = tonumber(npcData.identitySeed) or 1
    local isFemale = npcData.isFemale == true
    local sex = isFemale and "Female" or "Male"
    type = type or "Hurt"
    
    -- Select Voice Set based on identity (Consistently unique for this NPC)
    local voiceSet = "V" .. (1 + (seed % 4))
    
    -- Select Sound Script Template
    local soundName = "DTNPC_" .. sex .. "_" .. voiceSet .. "_" .. type

    -- Add variety for Hurt sounds (Pick a random hit type each time)
    if type == "Hurt" then
        local hitPool = {"Blunt", "Scratch", "Lacerate"}
        local hitType = hitPool[1 + ZombRand(#hitPool)]
        soundName = soundName .. "_" .. hitType
    end

    local emitter = zombie:getEmitter()
    if emitter then
        local soundID = emitter:playSound(soundName)
        
        -- Apply granular pitch variation on top of the voice set baseline
        -- Variation range: 0.95 to 1.05 (Subtle enough to not break the voice set)
        local microPitch = 0.95 + (seed % 11) * 0.01
        
        if soundID and soundID ~= 0 and emitter.setPitch then
            emitter:setPitch(soundID, microPitch)
        end
    end
end

--- Specialized helper for death vocalizations.
function Hostility.PlayDeathSound(zombie, npcData)
    Hostility.PlayHurtSound(zombie, npcData, "Death")
end
