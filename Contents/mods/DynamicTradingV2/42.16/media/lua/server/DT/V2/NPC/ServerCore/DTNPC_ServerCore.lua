-- ==============================================================================
-- DTNPC_ServerCore.lua (Core Bootstrap)
-- Server-side Logic: Spawning, Commands, Summoning, and Multiplayer Sync.
-- Declares the global DTNPCServerCore table and requires all sub-modules.
-- ==============================================================================

DTNPCServerCore = DTNPCServerCore or {}

-- Required external dependencies
require "DT/V2/NPC/Sys/DTNPC_Generator"
require "DT/V2/NPC/Sys/DTNPC_Protect"
require "DT/V2/NPC/Sys/Data/DTNPC_Data"
require "DT/V2/NPC/Sys/Lifecycle/DTNPC_Lifecycle"
require "DT/V2/NPC/Manager/DTNPC_DistanceFrequency"
require "DT/V2/NPC/Manager/DTNPC_SpatialHash/DTNPC_SpatialHash"

if not DTNPC_DistanceFrequency then
    DynamicTrading.Log("DTV2", "NPC", "Warn", "DTNPC_DistanceFrequency is nil, creating fallback")
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

if not DTNPC_SpatialHash then
    DynamicTrading.Log("DTV2", "NPC", "Warn", "DTNPC_SpatialHash is nil, creating fallback")
    DTNPC_SpatialHash = {
        Grid = {},
        NPCToCell = {},
        IsInitialized = false,
        RebuildFromRoster = function() end,
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

-- GUARD: Prevent Remote MP Clients from running this, but allow SP and Host
if isClient() and not isServer() then return end

-- ==============================================================================
-- LOAD SUB-MODULES (Order matters for dependencies)
-- ==============================================================================

-- 1. Utilities - Helper functions needed by other modules
require "DT/V2/NPC/ServerCore/DTNPC_ServerCore_Utilities"

-- 2. Control helpers - UUID-based state and order helpers used by commands and integrations
require "DT/V2/NPC/ServerCore/ServerCoreControl/DTNPC_ServerCoreControl"

-- 3. Sync - Synchronization functions needed by spawn/respawn/summon
require "DT/V2/NPC/ServerCore/DTNPC_ServerCore_Sync"

-- 4. Spawn - Core spawning functionality
require "DT/V2/NPC/ServerCore/DTNPC_ServerCore_Spawn"

-- 5. Respawn - Respawning logic (depends on spawn patterns)
require "DT/V2/NPC/ServerCore/DTNPC_ServerCore_Respawn"

-- 5.5 Arrival - Shared abstract-to-live activation helpers
require "DT/V2/NPC/ServerCore/ServerCoreArrival/DTNPC_ServerCoreArrival"

-- 6. Summon - Summoning/teleporting (depends on respawn/arrival)
require "DT/V2/NPC/ServerCore/DTNPC_ServerCore_Summon"

-- 6.5 Loot Search - Companion loot discovery/collection subsystem
require "DT/V2/NPC/LootSearch/DTNPC_LootSearch_Server"

-- 6.6 Bandit ambush events - ephemeral hostile NPC groups and robbery demands
require "DT/V2/NPC/Bandits/DTNPC_Bandits"

-- 7. Commands - Client command handler (needs all of the above)
require "DT/V2/NPC/ServerCore/ServerCoreCommands/DTNPC_ServerCoreCommands"

DynamicTrading.Log("DTV2", "NPC", "Init", "ServerCore initialized successfully")
