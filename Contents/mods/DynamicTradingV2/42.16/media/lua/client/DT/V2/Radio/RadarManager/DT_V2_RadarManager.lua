-- ==============================================================================
-- DT_V2_RadarManager.lua
-- Entry point for the V2 radar manager modules.
-- Loads radar manager modules in explicit dependency order.
-- ==============================================================================

DT_V2_RadarManager = DT_V2_RadarManager or {}

local RadarManager = DT_V2_RadarManager

if RadarManager.EntryLoaded then
    return
end

RadarManager.EntryLoaded = true
RadarManager.Modules = RadarManager.Modules or {}

require "DT/Common/UI/RadioScanner/DT_RadioScannerLocationHandler"

require "DT/V2/Radio/RadarManager/DT_V2_RadarManager_Core"
require "DT/V2/Radio/RadarManager/DT_V2_RadarManager_Sync"
require "DT/V2/Radio/RadarManager/DT_V2_RadarManager_Accessors"
require "DT/V2/Radio/RadarManager/DT_V2_RadarManager_Coords"
require "DT/V2/Radio/RadarManager/DT_V2_RadarManager_Device"
require "DT/V2/Radio/RadarManager/DT_V2_RadarManager_State"
require "DT/V2/Radio/RadarManager/DT_V2_RadarManager_Cleanup"
require "DT/V2/Radio/RadarManager/DT_V2_RadarManager_Scan"
require "DT/V2/Radio/RadarManager/DT_V2_RadarManager_Events"

DynamicTrading.Log("DTV2", "Init", "Radio", "RadarManager modules loaded successfully")
