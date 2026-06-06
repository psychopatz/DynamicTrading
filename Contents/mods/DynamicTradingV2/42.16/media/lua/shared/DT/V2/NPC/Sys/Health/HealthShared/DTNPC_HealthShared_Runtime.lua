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

local function getDynamicTradingSandbox()
    return SandboxVars and SandboxVars.DynamicTrading or nil
end

internal.getDynamicTradingSandbox = getDynamicTradingSandbox

local function getBaseHPMultiplier()
    local sandbox = getDynamicTradingSandbox()
    local configured = sandbox and tonumber(sandbox.NPCBaseHealthMultiplier) or nil
    if configured and configured > 0 then
        return configured
    end

    return 1.0
end

internal.getBaseHPMultiplier = getBaseHPMultiplier

local function getNPCDamageTakenMultiplier()
    local sandbox = getDynamicTradingSandbox()
    local configured = sandbox and tonumber(sandbox.NPCDamageTakenMultiplier) or nil
    if configured and configured >= 0 then
        return configured
    end

    return 1.0
end

internal.getNPCDamageTakenMultiplier = getNPCDamageTakenMultiplier

local function getNPCDamageDealtMultiplier()
    local sandbox = getDynamicTradingSandbox()
    local configured = sandbox and tonumber(sandbox.NPCDamageDealtMultiplier) or nil
    if configured and configured >= 0 then
        return configured
    end

    return 1.0
end

internal.getNPCDamageDealtMultiplier = getNPCDamageDealtMultiplier

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

local function resolveAuthoritativeNPCContext(zombie, npcData)
    local resolvedZombie = zombie
    local resolvedData = npcData
    local uuid = nil

    if type(npcData) == "table" and npcData.uuid then
        uuid = tostring(npcData.uuid)
    elseif zombie and zombie.getModData then
        local modData = zombie:getModData()
        uuid = modData and modData.DTNPC_UUID or nil
        if not uuid and type(modData and modData.DTNPC_Data) == "table" then
            uuid = modData.DTNPC_Data.uuid
        end
    end

    if uuid and DTNPCManager and DTNPCManager.Data and DTNPCManager.Data[uuid] then
        resolvedData = DTNPCManager.Data[uuid]
    end

    if resolvedZombie and resolvedData and resolvedZombie.getModData and DTNPC and DTNPC.MarkBodyOwnership then
        DTNPC.MarkBodyOwnership(resolvedZombie, resolvedData)
    end

    return resolvedZombie, resolvedData
end

internal.resolveAuthoritativeNPCContext = resolveAuthoritativeNPCContext
