-- ==============================================================================
-- DTNPC_MobilityCommon.lua
-- Entry point for shared NPC mobility common modules.
-- ==============================================================================

DTNPCMobility = DTNPCMobility or {}

local Mobility = DTNPCMobility
local Constants = Mobility.Constants or {}
local Internal = Mobility.Internal or {}

Mobility.Constants = Constants
Mobility.Internal = Internal

if Mobility.CommonEntryLoaded then
    return
end

Mobility.CommonEntryLoaded = true

require "DT/V2/NPC/Sys/Mobility/MobilityCommon/DTNPC_MobilityCommon_Constants"
require "DT/V2/NPC/Sys/Mobility/MobilityCommon/DTNPC_MobilityCommon_Utils"
require "DT/V2/NPC/Sys/Mobility/MobilityCommon/DTNPC_MobilityCommon_Progress"
require "DT/V2/NPC/Sys/Mobility/MobilityCommon/DTNPC_MobilityCommon_SpecialAction"
