-- ==============================================================================
-- DTNPC_Stamina.lua
-- Entry point for shared stamina modules.
-- ==============================================================================

DTNPCStamina = DTNPCStamina or {}
DTNPCStamina.Internal = DTNPCStamina.Internal or {}

local Stamina = DTNPCStamina

if Stamina.EntryLoaded then
    return
end

Stamina.EntryLoaded = true

require "DT/Common/FlavorText/DT_FlavorText"
require "DT/Common/FlavorText/DT_FlavorText_Stamina"

require "DT/V2/NPC/Sys/Stamina/DTNPC_Stamina_Shared"
require "DT/V2/NPC/Sys/Stamina/DTNPC_Stamina_Profiles"
require "DT/V2/NPC/Sys/Stamina/DTNPC_Stamina_Cues"
require "DT/V2/NPC/Sys/Stamina/DTNPC_Stamina_Movement"
require "DT/V2/NPC/Sys/Stamina/DTNPC_Stamina_Passive"
require "DT/V2/NPC/Sys/Stamina/DTNPC_Stamina_MeleeFatigue"
