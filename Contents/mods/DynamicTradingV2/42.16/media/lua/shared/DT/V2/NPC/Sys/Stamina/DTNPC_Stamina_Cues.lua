-- ==============================================================================
-- DTNPC_Stamina_Cues.lua
-- Stamina cue and flavor dispatch helpers.
-- ==============================================================================

DTNPCStamina = DTNPCStamina or {}
DTNPCStamina.Internal = DTNPCStamina.Internal or {}

local Internal = DTNPCStamina.Internal
local nowMillis = Internal.nowMillis

local function getCueLine(kind)
    if DynamicTrading and DynamicTrading.FlavorText and DynamicTrading.FlavorText.GetRandom then
        local line = DynamicTrading.FlavorText.GetRandom("CompanionCombat", kind)
        if line and line ~= "" then
            return line
        end
    end

    return nil
end

local function pushCue(zombie, npcData, kind, sentiment, cooldownMs)
    if not zombie or not npcData then
        return false
    end

    local currentTime = nowMillis()
    local safeCooldown = math.max(0, tonumber(cooldownMs) or 5000)
    local cues = type(npcData._dtStaminaCueTimes) == "table" and npcData._dtStaminaCueTimes or {}
    npcData._dtStaminaCueTimes = cues

    local lastTime = tonumber(cues[kind]) or 0
    if currentTime > 0 and lastTime > 0 and (currentTime - lastTime) < safeCooldown then
        return false
    end
    cues[kind] = currentTime

    if DTNPCProtect and DTNPCProtect.PushCombatFlavorNotice then
        local pushed = DTNPCProtect.PushCombatFlavorNotice(zombie, npcData, kind, sentiment or "warning", "Companion", kind)
        if pushed == true then
            return true
        end
    end

    if DTNPCProtect and DTNPCProtect.PushCompanionNotice then
        local line = getCueLine(kind)
        if line and line ~= "" then
            return DTNPCProtect.PushCompanionNotice(zombie, npcData, line, sentiment or "warning")
        end
    end

    return false
end

Internal.getCueLine = getCueLine
Internal.pushCue = pushCue
