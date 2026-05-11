-- ==============================================================================
-- DTNPC_ProtectTargeting_Cues.lua
-- Flavor text and throttled notice helpers for DTNPC protect targeting.
-- ==============================================================================

DTNPCProtect = DTNPCProtect or {}
DTNPCProtect.Internal = DTNPCProtect.Internal or {}

local Internal = DTNPCProtect.Internal

local function nowMillisSafe()
    if Internal.nowMillis then
        return Internal.nowMillis()
    end
    if getTimeInMillis then
        return getTimeInMillis()
    end
    return math.floor((getGameTime():getWorldAgeHours() or 0) * 3600000)
end

local function getFlavorLine(kind)
    return DynamicTrading
        and DynamicTrading.FlavorText
        and DynamicTrading.FlavorText.GetRandom
        and DynamicTrading.FlavorText.GetRandom("CompanionCombat", kind)
        or nil
end

local function pushThrottledFlavorNotice(zombie, npcData, key, flavorKind, sentiment, cooldownMs, targetID)
    if not zombie or not npcData or not DTNPCProtect.PushCompanionNotice then
        return false
    end

    local nowMs = nowMillisSafe()
    local timeKey = key .. "At"
    local targetKey = key .. "TargetID"
    local lastAt = tonumber(npcData[timeKey]) or 0
    if targetID ~= nil and npcData[targetKey] == targetID and lastAt > 0 and (nowMs - lastAt) < cooldownMs then
        return false
    end
    if targetID == nil and lastAt > 0 and (nowMs - lastAt) < cooldownMs then
        return false
    end

    local line = getFlavorLine(flavorKind)
    if not line or line == "" then
        return false
    end

    npcData[timeKey] = nowMs
    npcData[targetKey] = targetID
    return DTNPCProtect.PushCompanionNotice(zombie, npcData, line, sentiment or "warning")
end

local function pushThrottledEncounterNotice(zombie, npcData, key, threatType, sentiment, cooldownMs, targetID)
    local flavorKind = threatType == "bandits"
        and "ProtectTargetingBanditsEngage"
        or "ProtectTargetingHostileNPCEngage"
    return pushThrottledFlavorNotice(zombie, npcData, key, flavorKind, sentiment, cooldownMs, targetID)
end

Internal.PushTargetingFlavorNotice = pushThrottledFlavorNotice
Internal.PushTargetingEncounterNotice = pushThrottledEncounterNotice
