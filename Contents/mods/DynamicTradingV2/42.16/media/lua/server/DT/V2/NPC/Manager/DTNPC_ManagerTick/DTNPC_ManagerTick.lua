-- ==============================================================================
-- DTNPC_ManagerTick.lua
-- Main tick loop entry point: position tracking, visual fixes, and periodic broadcasts.
-- ==============================================================================

DTNPCManager = DTNPCManager or {}

if isClient() and not isServer() then return end

require "DT/Common/Faction/TradingSys/RosterLogic/TradeScheduler/DT_RosterLogic_TradeScheduler"

DynamicTrading.Log("DTV2", "NPC", "Init", "Loading optimization modules...")

require "DT/V2/NPC/Sys/Data/DTNPC_Data"
require "DT/V2/NPC/Manager/DTNPC_DistanceFrequency"
DynamicTrading.Log("DTV2", "NPC", "Init", "DTNPC_DistanceFrequency loaded: " .. tostring(DTNPC_DistanceFrequency ~= nil))

require "DT/V2/NPC/Manager/DTNPC_SpatialHash/DTNPC_SpatialHash"
DynamicTrading.Log("DTV2", "NPC", "Init", "DTNPC_SpatialHash loaded: " .. tostring(DTNPC_SpatialHash ~= nil))

require "DT/V2/NPC/Manager/DTNPC_ZombieAggro/DTNPC_ZombieAggro"
DynamicTrading.Log("DTV2", "NPC", "Init", "DTNPC_ZombieAggro loaded: " .. tostring(DTNPC_ZombieAggro ~= nil))

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

DynamicTrading.Log("DTV2", "NPC", "Init", "Module loading complete")

DTNPCManager.TickInternal = DTNPCManager.TickInternal or {}
DTNPCManager.TickRuntime = DTNPCManager.TickRuntime or {}

local tickRuntime = DTNPCManager.TickRuntime

tickRuntime.Constants = tickRuntime.Constants or {
    TICK_RATE = 20,
    POSITION_BROADCAST_RATE = 240,
    ACTIVE_RESPAWN_CHECK_RATE = 240,
    SHELL_CLEANUP_CHECK_RATE = 5,
    ROSTER_RESPAWN_CHECK_RATE = 60,
    AWAY_TRANSITION_CHECK_RATE = 60,
    RESTING_REGEN_CHECK_RATE = 120,
    TRADE_CYCLE_CHECK_RATE = 600,
}

tickRuntime.Counters = tickRuntime.Counters or {
    tickCounter = 0,
    positionBroadcastCounter = 0,
    activeRespawnCheckCounter = 0,
    shellCleanupCheckCounter = 0,
    rosterRespawnCheckCounter = 0,
    awayTransitionCheckCounter = 0,
    restingRegenCheckCounter = 0,
    tradeCycleCheckCounter = 0,
}

tickRuntime.Flags = tickRuntime.Flags or {
    hasLoggedMissingRespawnHooks = false,
    startupHintPassTicks = 0,
    eventsRegistered = false,
}

require "DT/V2/NPC/Manager/DTNPC_ManagerTick/DTNPC_ManagerTick_BodyRecovery"
require "DT/V2/NPC/Manager/DTNPC_ManagerTick/DTNPC_ManagerTick_ShellCleanup"
require "DT/V2/NPC/Manager/DTNPC_ManagerTick/DTNPC_ManagerTick_StartupHints"
require "DT/V2/NPC/Manager/DTNPC_ManagerTick/DTNPC_ManagerTick_Safety"
require "DT/V2/NPC/Manager/DTNPC_ManagerTick/DTNPC_ManagerTick_RespawnHooks"
require "DT/V2/NPC/Manager/DTNPC_ManagerTick/DTNPC_ManagerTick_RestingRegen"
require "DT/V2/NPC/Manager/DTNPC_ManagerTick/DTNPC_ManagerTick_WorldSweep"

if not tickRuntime.Flags.eventsRegistered then
    Events.OnTick.Add(DTNPCManager.OnTick)
    if Events.OnZombieUpdate and DTNPCManager.TickInternal.ApplySafetyToMarkedServerZombie then
        Events.OnZombieUpdate.Add(DTNPCManager.TickInternal.ApplySafetyToMarkedServerZombie)
    end
    tickRuntime.Flags.eventsRegistered = true
end
