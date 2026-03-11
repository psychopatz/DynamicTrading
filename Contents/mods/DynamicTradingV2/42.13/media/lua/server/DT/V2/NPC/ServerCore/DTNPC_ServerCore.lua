-- ==============================================================================
-- DTNPC_ServerCore.lua (Core Bootstrap)
-- Server-side Logic: Spawning, Commands, Summoning, and Multiplayer Sync.
-- Declares the global DTNPCServerCore table and requires all sub-modules.
-- ==============================================================================

DTNPCServerCore = DTNPCServerCore or {}

-- Required external dependencies
require "DT/V2/NPC/Sys/DTNPC_Generator"

-- GUARD: Prevent Remote MP Clients from running this, but allow SP and Host
if isClient() and not isServer() then return end

-- ==============================================================================
-- LOAD SUB-MODULES (Order matters for dependencies)
-- ==============================================================================

-- 1. Utilities - Helper functions needed by other modules
require "DT/V2/NPC/ServerCore/DTNPC_ServerCore_Utilities"

-- 2. Sync - Synchronization functions needed by spawn/respawn/summon
require "DT/V2/NPC/ServerCore/DTNPC_ServerCore_Sync"

-- 3. Spawn - Core spawning functionality
require "DT/V2/NPC/ServerCore/DTNPC_ServerCore_Spawn"

-- 4. Respawn - Respawning logic (depends on spawn patterns)
require "DT/V2/NPC/ServerCore/DTNPC_ServerCore_Respawn"

-- 5. Summon - Summoning/teleporting (depends on respawn)
require "DT/V2/NPC/ServerCore/DTNPC_ServerCore_Summon"

-- 6. Commands - Client command handler (needs all of the above)
require "DT/V2/NPC/ServerCore/DTNPC_ServerCore_Commands"

DynamicTrading.Log("DTV2", "NPC", "Init", "ServerCore initialized successfully")
