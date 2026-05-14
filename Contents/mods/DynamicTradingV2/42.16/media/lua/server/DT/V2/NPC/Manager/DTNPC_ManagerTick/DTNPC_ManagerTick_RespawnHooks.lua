-- ==============================================================================
-- DTNPC_ManagerTick_RespawnHooks.lua
-- Lazy loading bridge for respawn-related manager hooks.
-- ==============================================================================

DTNPCManager = DTNPCManager or {}

if isClient() and not isServer() then return end

DTNPCManager.TickInternal = DTNPCManager.TickInternal or {}
DTNPCManager.TickRuntime = DTNPCManager.TickRuntime or {}

local tickInternal = DTNPCManager.TickInternal
local tickRuntime = DTNPCManager.TickRuntime

function tickInternal.EnsureRespawnHooks()
    local hasHooks = DTNPCManager
        and DTNPCManager.CheckForRespawn
        and DTNPCManager.CheckRosterSpawns
        and DTNPCManager.ProcessAwayTransitions
        and DTNPCManager.ProcessTradeCycles

    if hasHooks then
        return true
    end

    require "DT/V2/NPC/Manager/DTNPC_ManagerRespawn/DTNPC_ManagerRespawn"

    hasHooks = DTNPCManager
        and DTNPCManager.CheckForRespawn
        and DTNPCManager.CheckRosterSpawns
        and DTNPCManager.ProcessAwayTransitions
        and DTNPCManager.ProcessTradeCycles

    if not hasHooks and not tickRuntime.Flags.hasLoggedMissingRespawnHooks then
        tickRuntime.Flags.hasLoggedMissingRespawnHooks = true
        DynamicTrading.Log(
            "DTV2",
            "NPC",
            "Warn",
            "Respawn hooks are still missing after reload; skipping respawn/trade tick work"
        )
    end

    return hasHooks
end
