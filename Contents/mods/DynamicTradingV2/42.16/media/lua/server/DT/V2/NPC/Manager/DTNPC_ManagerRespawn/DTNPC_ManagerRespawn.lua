-- ==============================================================================
-- DTNPC_ManagerRespawn.lua
-- Main entry point for the Respawn system.
-- Loads all respawn-related modules in proper order.
-- ==============================================================================

-- GUARD: Ensure DTNPCManager table exists
DTNPCManager = DTNPCManager or {}

-- GUARD: Prevent Remote MP Clients from running this, but allow SP and Host
if isClient() and not isServer() then return end

DynamicTrading.Log("DTV2", "Init", "NPC", "Loading optimization modules...")

-- Load spatial hash and distance frequency modules
require "DT/V2/NPC/Manager/DTNPC_SpatialHash/DTNPC_SpatialHash"
DynamicTrading.Log("DTV2", "Init", "NPC", "DTNPC_SpatialHash loaded: " .. tostring(DTNPC_SpatialHash ~= nil))

require "DT/V2/NPC/Manager/DTNPC_DistanceFrequency"
DynamicTrading.Log("DTV2", "Init", "NPC", "DTNPC_DistanceFrequency loaded: " .. tostring(DTNPC_DistanceFrequency ~= nil))

-- Guard: Create fallback tables with stub functions if modules didn't load
if not DTNPC_SpatialHash then
    DynamicTrading.Log("DTV2", "Init", "NPC", "WARNING: DTNPC_SpatialHash is nil, creating fallback")
    DTNPC_SpatialHash = {
        Grid = {},
        NPCToCell = {},
        IsInitialized = false,
        RebuildFromRoster = function() DynamicTrading.Log("DTV2", "Error", "NPC", "Fallback RebuildFromRoster called") end,
        InsertNPC = function() end,
        RemoveNPC = function() end,
        GetNPCsInRadius = function() return {} end,
        GetNearestNPCs = function() return {} end,
        CleanupEmptyCells = function() end,
        Clear = function() end,
        GetGridStats = function() return {} end,
        ClearDirtyFlags = function() end,
        GetDirtyCells = function() return {} end
    }
end

if not DTNPC_DistanceFrequency then
    DynamicTrading.Log("DTV2", "Init", "NPC", "WARNING: DTNPC_DistanceFrequency is nil, creating fallback")
    DTNPC_DistanceFrequency = {
        NPCTimers = {},
        GetTierForDistance = function() return 4 end,
        GetUpdateFrequencyForDistance = function() return 6 end,
        InitializeNPC = function() end,
        ShouldUpdateNPC = function() return true end,
        UpdateNPC = function() end,
        RemoveNPC = function() end,
        Clear = function() end,
        GetUpdateStats = function() return {} end
    }
end

DynamicTrading.Log("DTV2", "Init", "NPC", "Module loading complete")
DynamicTrading.Log("DTV2", "Init", "NPC", "Loading respawn modules...")

-- Load all respawn modules in alphabetical order (PZ requirement)
-- Debug module must load first as other modules depend on it
require "DT/V2/NPC/Manager/DTNPC_ManagerRespawn/DTNPC_ManagerRespawn_Debug"
require "DT/V2/NPC/Manager/DTNPC_ManagerRespawn/DTNPC_ManagerRespawn_BanditRoam"
require "DT/V2/NPC/Manager/DTNPC_ManagerRespawn/DTNPC_ManagerRespawn_Commands"
require "DT/V2/NPC/Manager/DTNPC_ManagerRespawn/DTNPC_ManagerRespawn_SpawnLogic"
require "DT/V2/NPC/Manager/DTNPC_ManagerRespawn/DTNPC_ManagerRespawn_TradeCycles"
require "DT/V2/NPC/Manager/DTNPC_ManagerRespawn/DTNPC_ManagerRespawn_Transitions"

DynamicTrading.Log("DTV2", "Init", "NPC", "All modules loaded successfully")
