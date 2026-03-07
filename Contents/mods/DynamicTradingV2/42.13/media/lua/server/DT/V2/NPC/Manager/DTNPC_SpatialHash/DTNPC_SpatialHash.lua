-- ==============================================================================
-- DTNPC_SpatialHash.lua
-- Entrypoint for the DTNPC spatial-hash module system.
-- Keeps public API stable while loading feature-focused module files.
-- ==============================================================================

DTNPC_SpatialHash = DTNPC_SpatialHash or {}

-- Configuration
DTNPC_SpatialHash.CELL_SIZE = DTNPC_SpatialHash.CELL_SIZE or 100
DTNPC_SpatialHash.CLEANUP_INTERVAL = DTNPC_SpatialHash.CLEANUP_INTERVAL or 300
DTNPC_SpatialHash.MAX_NPC_LIMIT = DTNPC_SpatialHash.MAX_NPC_LIMIT or 120

-- Shared state
DTNPC_SpatialHash.Grid = DTNPC_SpatialHash.Grid or {}
DTNPC_SpatialHash.NPCToCell = DTNPC_SpatialHash.NPCToCell or {}
DTNPC_SpatialHash.DirtyFlags = DTNPC_SpatialHash.DirtyFlags or {}
DTNPC_SpatialHash.NextCleanup = DTNPC_SpatialHash.NextCleanup or 0
DTNPC_SpatialHash.IsInitialized = DTNPC_SpatialHash.IsInitialized or false
DTNPC_SpatialHash._internal = DTNPC_SpatialHash._internal or {}

-- Load modules in dependency order.
require "DT/V2/NPC/Manager/DTNPC_SpatialHash/DTNPC_SpatialHash_Helpers"
require "DT/V2/NPC/Manager/DTNPC_SpatialHash/DTNPC_SpatialHash_Mutations"
require "DT/V2/NPC/Manager/DTNPC_SpatialHash/DTNPC_SpatialHash_Queries"
require "DT/V2/NPC/Manager/DTNPC_SpatialHash/DTNPC_SpatialHash_Maintenance"
require "DT/V2/NPC/Manager/DTNPC_SpatialHash/DTNPC_SpatialHash_Lifecycle"
require "DT/V2/NPC/Manager/DTNPC_SpatialHash/DTNPC_SpatialHash_Debug"
