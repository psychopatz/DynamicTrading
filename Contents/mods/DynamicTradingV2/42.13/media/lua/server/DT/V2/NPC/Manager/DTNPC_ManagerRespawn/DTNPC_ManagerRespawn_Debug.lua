-- ==============================================================================
-- DTNPC_ManagerRespawn_Debug.lua
-- Debug telemetry and logging utilities for the respawn system.
-- ==============================================================================

-- GUARD: Ensure DTNPCManager table exists
DTNPCManager = DTNPCManager or {}
DTNPCManager.RespawnDebug = DTNPCManager.RespawnDebug or {}

-- GUARD: Prevent Remote MP Clients from running this, but allow SP and Host
if isClient() and not isServer() then return end

-- Debug telemetry for respawn flow.
-- Logs are throttled by key so you see process state without per-tick spam.
local RESP_DEBUG = {
    enabled = true,
    intervalHours = 1 / 120, -- ~30s in-game time
    lastByKey = {}
}

function DTNPCManager.RespawnDebug.Log(key, message, force)
    if not RESP_DEBUG.enabled then return end

    local now = getGameTime():getWorldAgeHours()
    local last = RESP_DEBUG.lastByKey[key] or -math.huge
    if force or (now - last) >= RESP_DEBUG.intervalHours then
        DynamicTrading.Log("DTV2", "NPC", "Debug", "" .. message)
        RESP_DEBUG.lastByKey[key] = now
    end
end

function DTNPCManager.RespawnDebug.SetEnabled(enabled)
    RESP_DEBUG.enabled = enabled
end

function DTNPCManager.RespawnDebug.SetInterval(hours)
    RESP_DEBUG.intervalHours = hours
end

function DTNPCManager.RespawnDebug.ClearHistory()
    RESP_DEBUG.lastByKey = {}
end

DynamicTrading.Log("DTV2", "Init", "NPC", "Loaded successfully")
