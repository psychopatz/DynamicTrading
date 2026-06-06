-- ==============================================================================
-- DT_Dialogue_Ambient_Speech.lua
-- Speech scheduling and dialogue payload generation.
-- ==============================================================================

DTNPCClient = DTNPCClient or {}
DTNPCClient.DialogueAmbient = DTNPCClient.DialogueAmbient or DTNPCClient.AmbientDialogue or {}
DTNPCClient.AmbientDialogue = DTNPCClient.DialogueAmbient

require "DT/Common/FlavorText/DT_FlavorText"
require "DT/Common/FlavorText/DT_FlavorText_Bandits"
require "DT/Common/FlavorText/DT_FlavorText_Combat"
require "DT/Common/Dialogue/DT_Dialogue_Vocals"

local Ambient = DTNPCClient.DialogueAmbient
local Config = DTNPCClient.DialogueAmbientConfig or DTNPCClient.AmbientDialogueConfig
local DialogueVocals = DynamicTrading
    and DynamicTrading.Dialogue
    and DynamicTrading.Dialogue.Vocals

local function T(key, params, fallback)
    return DynamicTrading and DynamicTrading.Text and DynamicTrading.Text.Get
        and DynamicTrading.Text.Get(key, params, fallback)
        or fallback
        or tostring(key or "")
end

local function lower(value)
    return string.lower(tostring(value or ""))
end

local function isProtectAmbientState(state)
    return state == "ProtectAuto"
        or state == "ProtectRanged"
        or state == "ProtectMelee"
end

local PROTECT_NOTICE_FALLBACKS = {
    ["Companion:Attack"] = { key = "DTNPC_Ambient_Protect_Attack", fallback = "On it." },
    ["Companion:AttackRange"] = { key = "DTNPC_Ambient_Protect_AttackRange", fallback = "Covering you." },
    ["Companion:Reloading"] = { key = "DTNPC_Ambient_Protect_Reloading", fallback = "Reloading." },
    ["Companion:CrowdRefuse"] = { key = "DTNPC_Ambient_Protect_CrowdRefuse", fallback = "Too many of them. Backing off." },
    ["Companion:NoAmmo"] = { key = "DTNPC_Ambient_Protect_NoAmmo", fallback = "I'm out of ammo." },
    ["Companion:Return"] = { key = "DTNPC_Ambient_Protect_Return", fallback = "Back with you." },
    ["CorpseCleanup:Start"] = { key = "DTNPC_Ambient_CorpseCleanup_Start", fallback = "Cleaning this up." },
    ["CorpseCleanup:Finish"] = { key = "DTNPC_Ambient_CorpseCleanup_Finish", fallback = "Area's clear." },
    ["Default:Looking"] = { key = "DTNPC_Ambient_Protect_Looking", fallback = "Checking the last spot." },
    ["Default:Searching"] = { key = "DTNPC_Ambient_Protect_Searching", fallback = "Still looking." },
}

local function buildSpeechAudio(npcData, text, sentiment, status, state, entry, channel, cooldownMs)
    if not DialogueVocals or not DialogueVocals.BuildSpeechAudio then
        return nil
    end

    return DialogueVocals.BuildSpeechAudio(npcData, {
        text = text,
        sentiment = sentiment,
        status = status,
        state = state,
        entry = entry,
        hook = type(entry) == "table" and entry.vocalHook or nil,
        channel = channel or "ambient_dialogue",
        cooldownMs = cooldownMs or 1800,
    })
end

local function buildSpeechDataFromText(text, sentiment, zombie, currentTime, audio, speechKey)
    if not zombie or not text or text == "" then
        return nil
    end

    local color = Config.GetSentimentColor(sentiment)
    return {
        text = text,
        width = Ambient.textManager:MeasureStringX(Ambient.FONT_DIALOGUE, text),
        color = color,
        x = zombie:getX(),
        y = zombie:getY(),
        z = zombie:getZ(),
        timestamp = currentTime,
        expireTime = currentTime + Config.DisplayTimeMs,
        audio = audio,
        speechKey = speechKey,
    }
end

function Ambient.BuildCustomSpeechData(text, sentiment, zombie, currentTime, npcData)
    local safeText = tostring(text or "")
    local safeSentiment = sentiment or "neutral"
    local timestamp = currentTime or getTimeInMillis()
    local liveNPCData = npcData or (Ambient.GetNPCData and Ambient.GetNPCData(zombie)) or nil
    return buildSpeechDataFromText(
        safeText,
        safeSentiment,
        zombie,
        timestamp,
        buildSpeechAudio(
            liveNPCData,
            safeText,
            safeSentiment,
            liveNPCData and liveNPCData.status or nil,
            liveNPCData and liveNPCData.state or nil,
            nil,
            "ambient_dialogue",
            1200
        ),
        "custom:" .. safeSentiment .. ":" .. safeText
    )
end

function Ambient.BuildFallbackAmbientAudio(npcData)
    if not npcData or not DialogueVocals or not DialogueVocals.BuildSpeechAudio then
        return nil
    end

    local state = tostring(npcData.state or "")
    local sentiment = tostring(npcData.sentiment or "")
    local vocalType = "Chat"
    if state == "Resting" then
        vocalType = "Sigh"
    elseif state == "Guard" then
        vocalType = "Chat"
    elseif npcData.isBandit == true or tostring(npcData.factionID or "") == "Bandits" then
        vocalType = "Chat"
        sentiment = sentiment ~= "" and sentiment or "warning"
    end

    return DialogueVocals.BuildSpeechAudio(npcData, {
        sentiment = sentiment ~= "" and sentiment or nil,
        status = npcData.status,
        state = npcData.state,
        vocalType = vocalType,
        channel = "ambient_dialogue",
        cooldownMs = 2200,
        preferVariantPool = true,
    })
end

local function getRaidAmbientCategory(npcData)
    if not npcData then
        return nil
    end

    if npcData.isBandit == true or tostring(npcData.factionID or "") == "Bandits" then
        return "BanditsAmbient"
    end

    if npcData.raidHostileFaction == true and npcData.banditGroupID ~= nil then
        return "HostileRaidersAmbient"
    end

    return nil
end

local function getRaidAmbientKind(npcData)
    local state = tostring(npcData and npcData.state or "Default")
    local status = tostring(npcData and npcData.status or "Default")

    if npcData and (npcData.banditDemandResolved == true or npcData.banditLeaving == true) then
        return "Resolved", "warning"
    end
    if state == "Attack" then
        return "Attack", "angry"
    end
    if state == "AttackRange" then
        return "AttackRange", "warning"
    end
    if state == "Flee" then
        return "Flee", "warning"
    end
    if status == "Working" or state == "Guard" then
        return "Working", "warning"
    end

    return "Default", "neutral"
end

local function buildRaidAmbientSpeechData(npcData, zombie, currentTime)
    local category = getRaidAmbientCategory(npcData)
    if not category then
        return nil
    end

    local kind, sentiment = getRaidAmbientKind(npcData)
    local text = DynamicTrading
        and DynamicTrading.FlavorText
        and DynamicTrading.FlavorText.GetRandom
        and DynamicTrading.FlavorText.GetRandom(category, kind)
        or nil
    if not text or text == "" then
        return nil
    end

    return buildSpeechDataFromText(
        text,
        sentiment,
        zombie,
        currentTime,
        buildSpeechAudio(npcData, text, sentiment, npcData and npcData.status, npcData and npcData.state, nil, "ambient_dialogue", 2200),
        tostring(category) .. ":" .. tostring(kind)
    )
end

function Ambient.BuildProtectNoticeSpeechData(npcData, zombie, currentTime)
    if not npcData or not zombie then
        return nil
    end

    local text = npcData.protectNoticeText
    if text and text ~= "" then
        return buildSpeechDataFromText(
            text,
            npcData.protectNoticeSentiment,
            zombie,
            currentTime,
            buildSpeechAudio(
                npcData,
                text,
                npcData.protectNoticeSentiment,
                npcData.protectNoticeDialogueStatus,
                npcData.protectNoticeDialogueState,
                nil,
                "protect_notice",
                1200
            ),
            "protect_text:" .. tostring(text)
        )
    end

    local status = npcData.protectNoticeDialogueStatus
    local state = npcData.protectNoticeDialogueState
    if not status or status == "" or not state or state == "" then
        return nil
    end

    if DynamicTrading and DynamicTrading.DialogueAmbient and DynamicTrading.DialogueAmbient.GetEntry then
        local entry = DynamicTrading.DialogueAmbient.GetEntry(
            {
                archetype = npcData.archetypeID or npcData.occupation or "General",
                name = npcData.name or "Trader"
            },
            status,
            state,
            {
                traderName = npcData.name or "Trader"
            }
        )
        if entry and entry.dialogue and entry.dialogue ~= "" and entry.dialogue ~= "..." then
            return buildSpeechDataFromText(
                entry.dialogue,
                entry.sentiment,
                zombie,
                currentTime,
                buildSpeechAudio(npcData, entry.dialogue, entry.sentiment, status, state, entry, "protect_notice", 1200),
                "protect_entry:" .. tostring(status) .. ":" .. tostring(state)
            )
        end
    end

    local fallbackKey = tostring(status) .. ":" .. tostring(state)
    local fallbackEntry = PROTECT_NOTICE_FALLBACKS[fallbackKey]
    local fallbackText = fallbackEntry and T(fallbackEntry.key, nil, fallbackEntry.fallback) or T("DTNPC_Ambient_Protect_Searching", nil, "Staying alert.")
    return buildSpeechDataFromText(
        fallbackText,
        npcData.protectNoticeSentiment or "neutral",
        zombie,
        currentTime,
        buildSpeechAudio(
            npcData,
            fallbackText,
            npcData.protectNoticeSentiment or "neutral",
            status,
            state,
            nil,
            "protect_notice",
            1200
        ),
        "protect_fallback:" .. tostring(status) .. ":" .. tostring(state)
    )
end

function Ambient.GetRandomDelay(minMs, maxMs)
    local safeMin = math.max(0, tonumber(minMs) or 0)
    local safeMax = math.max(safeMin, tonumber(maxMs) or safeMin)
    if safeMax <= safeMin then
        return safeMin
    end

    return safeMin + ZombRand((safeMax - safeMin) + 1)
end

function Ambient.ScheduleInitialSpeak(entry, currentTime)
    entry.nextSpeakAt = currentTime + Ambient.GetRandomDelay(
        Config.InitialDelayMinMs,
        Config.InitialDelayMaxMs
    )
end

function Ambient.ScheduleRepeatSpeak(entry, currentTime)
    entry.nextSpeakAt = currentTime + Ambient.GetRandomDelay(
        Config.RepeatDelayMinMs,
        Config.RepeatDelayMaxMs
    )
end

function Ambient.BuildSpeechData(npcData, zombie, currentTime)
    local dialogueEntry = nil
    local ambientState = npcData and npcData.state or "Default"
    local ambientStatus = npcData and npcData.status or "Default"

    if ambientState == "Incapacitated" then
        -- Incapacitated pleas should override duty chatter like Trading/Working.
        ambientStatus = "Default"
    end

    -- Protect-mode companions should use protect notices and combat cues, not generic work chatter.
    if isProtectAmbientState(ambientState) then
        return nil
    end

    local raidAmbientSpeech = buildRaidAmbientSpeechData(npcData, zombie, currentTime)
    if raidAmbientSpeech then
        return raidAmbientSpeech
    end

    if DynamicTrading and DynamicTrading.DialogueAmbient and DynamicTrading.DialogueAmbient.GetEntry then
        dialogueEntry = DynamicTrading.DialogueAmbient.GetEntry(
            {
                archetype = npcData and (npcData.archetypeID or npcData.occupation) or "General",
                name = npcData and npcData.name or "Trader"
            },
            ambientStatus,
            ambientState,
            {
                traderName = npcData and npcData.name or "Trader"
            }
        )
    end
    if not dialogueEntry then
        return nil
    end

    local text = dialogueEntry.dialogue
    if not text or text == "" or text == "..." or lower(text) == "nil" then
        return nil
    end

    return buildSpeechDataFromText(
        text,
        dialogueEntry.sentiment,
        zombie,
        currentTime,
        buildSpeechAudio(npcData, text, dialogueEntry.sentiment, ambientStatus, ambientState, dialogueEntry, "ambient_dialogue", 2200),
        tostring(ambientStatus) .. ":" .. tostring(ambientState)
    )
end
