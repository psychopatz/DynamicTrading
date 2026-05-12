-- =============================================================================
-- FILE: media/lua/shared/DT/Common/GeolocatorSystem/DT_GeolocatorSystem.lua
-- PURPOSE: Entry point for the unified Geolocator System.
-- =============================================================================

DT_GeolocatorSystem = DT_GeolocatorSystem or {}
DT_GeolocatorSystem.Config = DT_GeolocatorSystem.Config or {}

require "DT/Common/GeolocatorSystem/DT_GeolocatorSystem_Data"
require "DT/Common/GeolocatorSystem/DT_GeolocatorSystem_Settings"
require "DT/Common/GeolocatorSystem/GeolocatorSystemRegistry/DT_GeolocatorSystemRegistry"
require "DT/Common/GeolocatorSystem/DT_GeolocatorSystem_BuildingLogic"
require "DT/Common/GeolocatorSystem/DT_GeolocatorSystem_ZoneLogic"
require "DT/Common/GeolocatorSystem/GeolocatorSystemLocation/DT_GeolocatorSystemLocation"
require "DT/Common/GeolocatorSystem/DT_GeolocatorSystem_ScanLogic"
require "DT/Common/GeolocatorSystem/DT_GeolocatorSystem_WildernessScanLogic"
require "DT/Common/GeolocatorSystem/DT_GeolocatorSystem_RoadScanLogic"
require "DT/Common/GeolocatorSystem/GeolocatorSystemLoad/DT_GeolocatorSystemLoad"
require "DT/Common/GeolocatorSystem/DT_GeolocatorSystem_DebugLogic"

DTM = DT_GeolocatorSystem
