-- ==============================================================================
-- DTNPC_ProtectShared_CombatState.lua
-- Shared combat-state helpers for DTNPC protect modules.
-- ==============================================================================

DTNPCProtect = DTNPCProtect or {}
DTNPCProtect.Internal = DTNPCProtect.Internal or {}

local Internal = DTNPCProtect.Internal
local nowMillis = Internal.nowMillis

local function getVariableBooleanSafe(zombie, name)
    if not zombie or not name then
        return false
    end

    if zombie.getVariableBoolean then
        local ok, result = pcall(zombie.getVariableBoolean, zombie, name)
        if ok then
            return result == true
        end
    end

    local value = zombie.getVariableString and zombie:getVariableString(name) or ""
    value = string.lower(tostring(value or ""))
    return value == "true" or value == "1"
end

local function getActionStateNameSafe(zombie)
    if not zombie or not zombie.getActionStateName then
        return ""
    end

    local ok, result = pcall(zombie.getActionStateName, zombie)
    if ok then
        return string.lower(tostring(result or ""))
    end

    return ""
end

local function isInvalidCombatActionState(actionState)
    if actionState == "" then
        return false
    end

    return string.find(actionState, "fall", 1, true) ~= nil
        or string.find(actionState, "stagger", 1, true) ~= nil
        or string.find(actionState, "stumble", 1, true) ~= nil
        or string.find(actionState, "bumped", 1, true) ~= nil
        or string.find(actionState, "knock", 1, true) ~= nil
        or string.find(actionState, "hitreaction", 1, true) ~= nil
        or string.find(actionState, "hit reaction", 1, true) ~= nil
end

local function resetCombatActionVariables(zombie)
    if not zombie then
        return
    end

    -- Do not write bAttack/bAttacking/Attack/Lunge here. In B42 these animation
    -- variables are callback/read-only slots and setting them floods the console.
    if zombie.setBumpDone then
        pcall(zombie.setBumpDone, zombie, true)
    end
end

function DTNPCProtect.IsCombatCapable(zombie, npcData, options)
    options = type(options) == "table" and options or {}

    if not zombie or not npcData or zombie:isDead() then
        return false, "invalid"
    end
    if npcData.incapState == "Active" or npcData.state == "Incapacitated" then
        return false, "incapacitated"
    end

    if getVariableBooleanSafe(zombie, "bCrawling")
        or getVariableBooleanSafe(zombie, "bBecomeCrawler")
        or getVariableBooleanSafe(zombie, "FallOnFront")
        or getVariableBooleanSafe(zombie, "bKnockedDown") then
        return false, "downed"
    end

    local actionState = getActionStateNameSafe(zombie)
    if isInvalidCombatActionState(actionState) then
        return false, "recovering_action"
    end

    if options.requireStanding ~= false then
        local methods = { "isOnFloor", "isFallOnFront", "isCrawling", "isKnockedDown" }
        for i = 1, #methods do
            local method = zombie[methods[i]]
            if type(method) == "function" then
                local ok, result = pcall(method, zombie)
                if ok and result == true then
                    return false, "downed"
                end
            end
        end
    end

    return true, nil
end

function DTNPCProtect.StopCombatActions(zombie, npcData, reason)
    if npcData then
        npcData.attackTimer = 0
        npcData.reactionTimer = 0
        npcData.isMovingState = false
        npcData.combatBlockedReason = reason
        npcData._dtReloadUntil = nil
        if DTNPCMobility and DTNPCMobility.ClearSpecialAction then
            DTNPCMobility.ClearSpecialAction(npcData)
        else
            npcData._dtSpecialAction = nil
            npcData._dtSpecialActionUntil = nil
            npcData._dtSpecialActionMode = nil
        end
    end

    resetCombatActionVariables(zombie)
    if zombie then
        if zombie.setTarget then
            zombie:setTarget(nil)
        end
        if zombie.setAttackedBy then
            zombie:setAttackedBy(nil)
        end
    end
    if DTNPCMobility and DTNPCMobility.Stop then
        DTNPCMobility.Stop(zombie)
    end
end

function DTNPCProtect.CanApplyPlayerHitReaction(npcData, target)
    if not npcData or not target or not instanceof or not instanceof(target, "IsoPlayer") then
        return true
    end

    local currentTime = nowMillis()
    local cooldownMs = tonumber(DTNPCProtect.CONFIG.PlayerHitReactionCooldownMs) or 1600
    local lastAt = tonumber(npcData.lastPlayerHitReactionAt) or 0
    if currentTime > 0 and lastAt > 0 and (currentTime - lastAt) < cooldownMs then
        return false
    end

    npcData.lastPlayerHitReactionAt = currentTime
    return true
end

function DTNPCProtect.IsHostileChasePaused(npcData)
    if not npcData then
        return false
    end

    local pauseUntil = tonumber(npcData.hostileChaseCooldownUntil) or 0
    if pauseUntil <= 0 then
        return false
    end

    local currentTime = nowMillis()
    return currentTime > 0 and currentTime < pauseUntil
end
