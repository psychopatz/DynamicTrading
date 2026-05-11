-- ==============================================================================
-- DTNPC_MobilityCommon_SpecialAction.lua
-- Special action and blocked-counter helpers.
-- ==============================================================================

DTNPCMobility = DTNPCMobility or {}

local Mobility = DTNPCMobility
local Constants = Mobility.Constants or {}
local Internal = Mobility.Internal or {}

Mobility.Constants = Constants
Mobility.Internal = Internal

function Mobility.ClearSpecialAction(npcData, expectedKind)
    if type(npcData) ~= "table" then
        return false
    end

    if expectedKind and npcData._dtSpecialAction ~= expectedKind then
        return false
    end

    npcData._dtSpecialAction = nil
    npcData._dtSpecialActionUntil = nil
    npcData._dtSpecialActionMode = nil
    return true
end

function Mobility.StartSpecialAction(npcData, kind, durationMs, options)
    if type(npcData) ~= "table" or not kind or kind == "" then
        return 0
    end

    options = type(options) == "table" and options or {}

    local currentTime = Internal.getTimeMs()
    local untilTime = currentTime + math.max(0, math.floor(tonumber(durationMs) or 0))
    npcData._dtSpecialAction = tostring(kind)
    npcData._dtSpecialActionUntil = untilTime
    npcData._dtSpecialActionMode = options.mode or nil
    npcData._dtSpecialActionSeq = (tonumber(npcData._dtSpecialActionSeq) or 0) + 1
    Internal.resetMovementProgress(npcData)
    if kind == "fence" then
        npcData._dtFenceActionSeq = (tonumber(npcData._dtFenceActionSeq) or 0) + 1
        npcData._dtFenceCooldownUntil = untilTime + math.max(180, tonumber(options.cooldownMs) or 320)
    end
    return untilTime
end

function Mobility.GetSpecialActionState(npcData)
    if type(npcData) ~= "table" then
        return nil, 0, nil
    end

    local kind = npcData._dtSpecialAction
    local untilTime = tonumber(npcData._dtSpecialActionUntil) or 0
    local currentTime = Internal.getTimeMs()
    if not kind or kind == "" or untilTime <= 0 then
        return nil, 0, nil
    end

    if currentTime >= (untilTime + Constants.SPECIAL_ACTION_GRACE_MS) then
        Mobility.ClearSpecialAction(npcData)
        return nil, 0, nil
    end

    return tostring(kind), untilTime, npcData._dtSpecialActionMode
end

function Mobility.IsSpecialActionActive(npcData, expectedKind)
    local kind, untilTime, mode = Mobility.GetSpecialActionState(npcData)
    if not kind then
        return false, nil, 0
    end
    if expectedKind and kind ~= expectedKind then
        return false, mode, untilTime
    end
    return true, mode, untilTime
end

function Internal.clearBlockedCounter(npcData, key)
    if type(npcData) == "table" and key then
        npcData[key] = 0
    end
end

function Internal.incrementBlockedCounter(npcData, key)
    if type(npcData) ~= "table" or not key then
        return 0
    end

    npcData[key] = (tonumber(npcData[key]) or 0) + 1
    return npcData[key]
end
