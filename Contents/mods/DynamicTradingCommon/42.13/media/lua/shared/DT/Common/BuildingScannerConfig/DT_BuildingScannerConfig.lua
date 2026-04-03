-- =============================================================================
-- FILE: media/lua/shared/DT/Common/BuildingScannerConfig/DT_BuildingScannerConfig.lua
-- AUTHOR: Dynamic Trading Mod Team
-- PURPOSE: Entry point for building scanner configuration and scanning helpers
-- VERSION: 2.0 - Enhanced with County Support
-- =============================================================================

DTM = DTM or {}
DTM.Config = {}

require "DT/Common/BuildingScannerConfig/DT_BuildingScannerConfig_Settings"
require "DT/Common/BuildingScannerConfig/DT_BuildingScannerConfig_MapData"
require "DT/Common/BuildingScannerConfig/DT_BuildingScannerConfig_LocationLogic"
require "DT/Common/BuildingScannerConfig/DT_BuildingScannerConfig_BuildingLogic"
require "DT/Common/BuildingScannerConfig/DT_BuildingScannerConfig_ZoneLogic"
require "DT/Common/BuildingScannerConfig/DT_BuildingScannerConfig_BuildingScanLogic"
require "DT/Common/BuildingScannerConfig/DT_BuildingScannerConfig_WildernessScanLogic"
require "DT/Common/BuildingScannerConfig/DT_BuildingScannerConfig_RoadScanLogic"
require "DT/Common/BuildingScannerConfig/DT_BuildingScannerConfig_LoadLogic"
require "DT/Common/BuildingScannerConfig/DT_BuildingScannerConfig_DebugLogic"
