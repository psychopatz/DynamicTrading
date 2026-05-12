-- ==============================================================================
-- DTNPC_Hostility_Sounds.lua
-- Unique vocal effects for NPCs based on identity and gender.
-- ==============================================================================

require "DT/Common/Dialogue/DT_Dialogue_Vocals"

DTNPCHostility = DTNPCHostility or {}

local Hostility = DTNPCHostility
local Internal = Hostility.Internal or {}

Hostility.Internal = Internal

--- Plays a unique vocal sound for an NPC based on their identity seed and gender.
--- @param zombie IsoZombie
--- @param npcData table
--- @param cueType string # "Hurt", "Incap", "Death", "Effort", "Chat", "Sigh", "Ambient", "State"
--- @param options table|nil
function Hostility.PlayVocal(zombie, npcData, cueType, options)
    local soundSystem = DynamicTrading
        and DynamicTrading.Dialogue
        and DynamicTrading.Dialogue.Vocals

    if soundSystem and soundSystem.PlayVocal then
        return soundSystem.PlayVocal(zombie, npcData, cueType, options)
    end

    return nil
end

-- Backward compatibility for existing calls
function Hostility.PlayHurtSound(zombie, npcData, type)
    Hostility.PlayVocal(zombie, npcData, type)
end

function Hostility.PlayDeathSound(zombie, npcData)
    Hostility.PlayVocal(zombie, npcData, "Death")
end

--- A modular method to display ambient text and play a randomized vocal SFX.
--- @param zombie IsoZombie
--- @param npcData table
--- @param text string|nil # If nil, only the vocal plays.
--- @param vocalType string|nil # The category (Chat, Sigh, etc.). If nil, only text displays.
--- @param sentiment string|nil # For text notice (e.g., "neutral", "warning").
function Hostility.Say(zombie, npcData, text, vocalType, sentiment)
    if not zombie or not npcData then return end

    -- 1. Display Text (if provided)
    if text and text ~= "" then
        if DTNPCProtect and DTNPCProtect.PushCompanionNotice then
            DTNPCProtect.PushCompanionNotice(zombie, npcData, text, sentiment or "neutral", vocalType)
            return
        end
    end

    -- 2. Play Vocal (if provided)
    if vocalType then
        Hostility.PlayVocal(zombie, npcData, vocalType)
    end
end
