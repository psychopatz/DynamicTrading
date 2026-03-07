-- ==============================================================================
-- DTNPC_SpatialHash.lua
-- Entrypoint for the DTNPC spatial-hash module system.
-- Keeps public API stable while loading feature-focused module files.
-- ==============================================================================

DTNPC_SpatialHash = DTNPC_SpatialHash or {}

local SH = DTNPC_SpatialHash

-- Configuration
SH.CELL_SIZE = SH.CELL_SIZE or 100
SH.CLEANUP_INTERVAL = SH.CLEANUP_INTERVAL or 300
SH.MAX_NPC_LIMIT = SH.MAX_NPC_LIMIT or 120

-- Shared state
SH.Grid = SH.Grid or {}
SH.NPCToCell = SH.NPCToCell or {}
SH.DirtyFlags = SH.DirtyFlags or {}
SH.NextCleanup = SH.NextCleanup or 0
SH.IsInitialized = SH.IsInitialized or false
SH._internal = SH._internal or {}

-- Load modules in dependency order.
require "DT/V2/NPC/Manager/DTNPC_SpatialHash/DTNPC_DTNPC_SpatialHash_Helpers"
require "DT/V2/NPC/Manager/DTNPC_SpatialHash/DTNPC_DTNPC_SpatialHash_Mutations"
require "DT/V2/NPC/Manager/DTNPC_SpatialHash/DTNPC_DTNPC_SpatialHash_Queries"
require "DT/V2/NPC/Manager/DTNPC_SpatialHash/DTNPC_DTNPC_SpatialHash_Maintenance"
require "DT/V2/NPC/Manager/DTNPC_SpatialHash/DTNPC_DTNPC_SpatialHash_Lifecycle"
require "DT/V2/NPC/Manager/DTNPC_SpatialHash/DTNPC_DTNPC_SpatialHash_Debug"
