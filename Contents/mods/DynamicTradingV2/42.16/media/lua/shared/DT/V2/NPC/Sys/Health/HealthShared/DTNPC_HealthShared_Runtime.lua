-- ==============================================================================
-- DTNPC_HealthShared_Runtime.lua
-- Runtime and numeric helpers for DT NPC health.
-- ==============================================================================

DTNPCHealth = DTNPCHealth or {}
DTNPCHealth.Internal = DTNPCHealth.Internal or {}

local internal = DTNPCHealth.Internal

local function isRemoteClient()
    return isClient() and not isServer()
end

internal.isRemoteClient = isRemoteClient

local function isDedicatedServer()
    return isServer() and not isClient()
end

internal.isDedicatedServer = isDedicatedServer

local function getBaseHPMultiplier()
    local sandbox = SandboxVars and SandboxVars.DynamicTrading or nil
    local configured = sandbox and tonumber(sandbox.NPCBaseHealthMultiplier) or nil
    if configured and configured > 0 then
        return configured
    end

    return 1.0
end

internal.getBaseHPMultiplier = getBaseHPMultiplier

local function nowMillis()
    if getTimeInMillis then
        local value = tonumber(getTimeInMillis())
        if value and value > 0 then
            return math.floor(value)
        end
    end

    local gt = getGameTime and getGameTime() or nil
    if gt and gt.getWorldAgeHours then
        return math.floor((tonumber(gt:getWorldAgeHours()) or 0) * 3600000)
    end

    return 0
end

internal.nowMillis = nowMillis

local function clamp(value, minValue, maxValue)
    local numeric = tonumber(value) or minValue
    if numeric < minValue then
        return minValue
    end
    if numeric > maxValue then
        return maxValue
    end
    return numeric
end

internal.clamp = clamp
