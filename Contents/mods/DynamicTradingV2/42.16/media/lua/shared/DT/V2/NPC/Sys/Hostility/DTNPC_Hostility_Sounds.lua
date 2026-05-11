-- ==============================================================================
-- DTNPC_Hostility_Sounds.lua
-- Unique vocal effects for NPCs based on identity and gender.
-- ==============================================================================

DTNPCHostility = DTNPCHostility or {}

local Hostility = DTNPCHostility
local Internal = Hostility.Internal or {}

Hostility.Internal = Internal

--- Plays a unique hurt sound for an NPC based on their identity seed and gender.
--- Uses pitch variation to ensure many unique "voices" from vanilla assets.
function Hostility.PlayHurtSound(zombie, npcData)
    if not zombie or not npcData or zombie:isDead() then
        return
    end

    local seed = tonumber(npcData.identitySeed) or 1
    local isFemale = npcData.isFemale == true
    
    local sex = isFemale and "Female" or "Male"
    local soundName = sex .. "BeingHit"
    
    local emitter = zombie:getEmitter()
    if emitter then
        local soundID = emitter:playSound(soundName)
        
        -- Apply unique pitch based on identitySeed to create unique "voices"
        -- Variation range: 0.85 to 1.15 (30% difference)
        local pitch = 0.85 + (seed % 31) * 0.01
        
        if soundID and soundID ~= 0 and emitter.setPitch then
            emitter:setPitch(soundID, pitch)
        end
    end
end
