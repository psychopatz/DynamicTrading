-- ==============================================================================
-- DTNPC_MobilityMovement.lua
-- Entry point for split DTNPC mobility movement modules.
-- ==============================================================================

DTNPCMobility = DTNPCMobility or {}

local Mobility = DTNPCMobility
local Internal = Mobility.Internal or {}

Mobility.Internal = Internal

if Mobility.MovementEntryLoaded then
    return
end

Mobility.MovementEntryLoaded = true

require "DT/V2/NPC/Sys/Mobility/MobilityMovement/DTNPC_MobilityMovement_Shared"
require "DT/V2/NPC/Sys/Mobility/MobilityMovement/DTNPC_MobilityMovement_Directional"
require "DT/V2/NPC/Sys/Mobility/MobilityMovement/DTNPC_MobilityMovement_TowardTarget"
require "DT/V2/NPC/Sys/Mobility/MobilityMovement/DTNPC_MobilityMovement_AwayFromPoint"
