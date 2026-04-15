-- ==============================================================================
-- DTNPC_ProtectNotice_logic.lua
-- Notice, fallback, and debug reporting logic for DTNPCProtect.
-- ==============================================================================

DTNPCProtect = DTNPCProtect or {}
DTNPCProtect.Internal = DTNPCProtect.Internal or {}

local Internal = DTNPCProtect.Internal
local nowMillis = Internal.nowMillis
local syncProtectNotice = Internal.syncProtectNotice
local protectLog = Internal.protectLog
local buildProtectDebugSummary = Internal.buildProtectDebugSummary

local function isProtectDebugEnabled(options)
    if options and options.issue == true then
        if DTNPCProtect.CONFIG.CombatIssueLogging == true then
            return true
        end
    end

    if DTNPCProtect.CONFIG.DebugLogging == true then
        return true
    end

    local sandbox = SandboxVars and SandboxVars.DynamicTrading or nil
    if sandbox then
        if sandbox.NPCProtectDebug ~= nil then
            return sandbox.NPCProtectDebug == true
        end
        if sandbox.NPCDebug ~= nil then
            return sandbox.NPCDebug == true
        end
    end

    return false
end

function DTNPCProtect.PushCompanionNotice(zombie, npcData, text, sentiment)
    DTNPCProtect.EnsureDataDefaults(npcData)
    if not npcData or not text or text == "" then
        return false
    end

    npcData.protectNoticeSerial = (tonumber(npcData.protectNoticeSerial) or 0) + 1
    npcData.protectNoticeText = text
    npcData.protectNoticeSentiment = sentiment or "neutral"
    npcData.protectNoticeDialogueStatus = nil
    npcData.protectNoticeDialogueState = nil

    syncProtectNotice(zombie, npcData)

    return true
end

function DTNPCProtect.PushCompanionAmbientCue(zombie, npcData, dialogueStatus, dialogueState)
    DTNPCProtect.EnsureDataDefaults(npcData)
    if not npcData or not dialogueStatus or dialogueStatus == "" or not dialogueState or dialogueState == "" then
        return false
    end

    npcData.protectNoticeSerial = (tonumber(npcData.protectNoticeSerial) or 0) + 1
    npcData.protectNoticeText = nil
    npcData.protectNoticeSentiment = "neutral"
    npcData.protectNoticeDialogueStatus = dialogueStatus
    npcData.protectNoticeDialogueState = dialogueState

    syncProtectNotice(zombie, npcData)

    return true
end

function DTNPCProtect.BuildFallbackNotice(requestedState, resolvedState)
    if resolvedState == "ProtectMelee" and requestedState == "ProtectRanged" then
        return "No firearm ready. Switching to melee.", "warning"
    end
    if resolvedState == "ProtectRanged" and requestedState == "ProtectMelee" then
        return "No melee weapon ready. Switching to ranged.", "warning"
    end
    if requestedState == "ProtectAuto" then
        return "Can't cover you, I got no available weapons.", "warning"
    end
    if requestedState == "ProtectRanged" then
        return "Can't cover you. No usable firearm.", "warning"
    end
    if requestedState == "ProtectMelee" then
        return "Can't protect up close. No melee weapon.", "warning"
    end
    return nil, nil
end

function DTNPCProtect.PushFallbackNotice(npcData, text, sentiment)
    DTNPCProtect.EnsureDataDefaults(npcData)
    if not text or text == "" then
        return false
    end

    local currentTime = nowMillis()
    local lastTime = tonumber(npcData.combatFallbackAnnouncedAt) or 0
    if currentTime > 0 and lastTime > 0 and (currentTime - lastTime) < DTNPCProtect.CONFIG.NoticeCooldownMs then
        return false
    end

    npcData.combatFallbackAnnouncedAt = currentTime
    npcData.protectNoticeSerial = (tonumber(npcData.protectNoticeSerial) or 0) + 1
    npcData.protectNoticeText = text
    npcData.protectNoticeSentiment = sentiment or "neutral"
    npcData.protectNoticeDialogueStatus = nil
    npcData.protectNoticeDialogueState = nil
    return true
end

function DTNPCProtect.LogProtectDebug(npcData, label, detail, options)
    options = type(options) == "table" and options or {}
    if not isProtectDebugEnabled(options) then
        return false
    end

    if npcData then
        local key = tostring(label or "debug")
        local currentTime = nowMillis()
        local cooldown = math.max(0, tonumber(options.cooldownMs) or tonumber(DTNPCProtect.CONFIG.DebugCooldownMs) or 15000)
        npcData._protectDebugLogTimes = type(npcData._protectDebugLogTimes) == "table" and npcData._protectDebugLogTimes or {}

        local lastTime = tonumber(npcData._protectDebugLogTimes[key]) or 0
        if currentTime > 0 and lastTime > 0 and cooldown > 0 and (currentTime - lastTime) < cooldown then
            return false
        end
        npcData._protectDebugLogTimes[key] = currentTime
    end

    local prefix = tostring(npcData and (npcData.name or npcData.uuid) or "Unknown NPC")
    local suffix = tostring(label or "debug")
    local extra = detail and (" | " .. tostring(detail)) or ""
    protectLog(prefix .. " | " .. suffix .. extra .. " | " .. buildProtectDebugSummary(npcData))
    return true
end

function DTNPCProtect.ReportCombatIssue(zombie, npcData, issueKey, text, sentiment, detail, cooldownMs)
    if not npcData then
        return false
    end

    DTNPCProtect.EnsureDataDefaults(npcData)

    local key = tostring(issueKey or "generic")
    local currentTime = nowMillis()
    local cooldown = math.max(0, tonumber(cooldownMs) or tonumber(DTNPCProtect.CONFIG.DiagnosticCooldownMs) or 4000)
    npcData._protectDiagnosticTimes = type(npcData._protectDiagnosticTimes) == "table" and npcData._protectDiagnosticTimes or {}

    local lastTime = tonumber(npcData._protectDiagnosticTimes[key]) or 0
    if currentTime > 0 and lastTime > 0 and (currentTime - lastTime) < cooldown then
        return false
    end
    npcData._protectDiagnosticTimes[key] = currentTime

    if text and text ~= "" then
        npcData.protectNoticeSerial = (tonumber(npcData.protectNoticeSerial) or 0) + 1
        npcData.protectNoticeText = text
        npcData.protectNoticeSentiment = sentiment or "warning"
        npcData.protectNoticeDialogueStatus = nil
        npcData.protectNoticeDialogueState = nil
        syncProtectNotice(zombie, npcData)
    end

    DTNPCProtect.LogProtectDebug(npcData, key, detail or text, {
        issue = true,
        cooldownMs = cooldown,
    })
    return true
end
