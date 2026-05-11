-- ==============================================================================
-- DTNPC_MobilityPassages.lua
-- Entry point for split DTNPC mobility passage modules.
-- ==============================================================================

DTNPCMobility = DTNPCMobility or {}

local Mobility = DTNPCMobility
local Internal = Mobility.Internal or {}

Mobility.Internal = Internal

if Mobility.PassagesEntryLoaded then
    return
end

Mobility.PassagesEntryLoaded = true

require "DT/V2/NPC/Sys/Mobility/MobilityPassages/DTNPC_MobilityPassages_Shared"
require "DT/V2/NPC/Sys/Mobility/MobilityPassages/DTNPC_MobilityPassages_FenceDetection"
require "DT/V2/NPC/Sys/Mobility/MobilityPassages/DTNPC_MobilityPassages_FenceTraverse"
require "DT/V2/NPC/Sys/Mobility/MobilityPassages/DTNPC_MobilityPassages_PassageDetection"
require "DT/V2/NPC/Sys/Mobility/MobilityPassages/DTNPC_MobilityPassages_PassageInteraction"
require "DT/V2/NPC/Sys/Mobility/MobilityPassages/DTNPC_MobilityPassages_Proactive"
