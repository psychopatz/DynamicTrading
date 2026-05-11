-- ==============================================================================
-- DTNPC_ProtectLoadout.lua
-- Entry point for split DTNPC protect loadout modules.
-- ==============================================================================

DTNPCProtect = DTNPCProtect or {}
DTNPCProtect.Internal = DTNPCProtect.Internal or {}

if DTNPCProtect.LoadoutEntryLoaded then
    return
end

DTNPCProtect.LoadoutEntryLoaded = true

require "DT/V2/NPC/Sys/Protect/ProtectLoadout/DTNPC_ProtectLoadout_Classification"
require "DT/V2/NPC/Sys/Protect/ProtectLoadout/DTNPC_ProtectLoadout_Seeded"
require "DT/V2/NPC/Sys/Protect/ProtectLoadout/DTNPC_ProtectLoadout_Core"
require "DT/V2/NPC/Sys/Protect/ProtectLoadout/DTNPC_ProtectLoadout_Validation"
