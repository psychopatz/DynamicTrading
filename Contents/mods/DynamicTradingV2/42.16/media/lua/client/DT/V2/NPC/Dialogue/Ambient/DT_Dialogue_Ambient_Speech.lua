-- ==============================================================================
-- DT_Dialogue_Ambient_Speech.lua
-- Speech scheduling and dialogue payload generation.
-- ==============================================================================

DTNPCClient = DTNPCClient or {}
DTNPCClient.DialogueAmbient = DTNPCClient.DialogueAmbient or DTNPCClient.AmbientDialogue or {}
DTNPCClient.AmbientDialogue = DTNPCClient.DialogueAmbient

require "DT/Common/FlavorText/DT_FlavorText"
require "DT/Common/FlavorText/DT_FlavorText_Bandits"

local Ambient = DTNPCClient.DialogueAmbient
local Config = DTNPCClient.DialogueAmbientConfig or DTNPCClient.AmbientDialogueConfig

local function lower(value)
    return string.lower(tostring(value or ""))
end

local function isProtectAmbientState(state)
    return state == "ProtectAuto"
        or state == "ProtectRanged"
        or state == "ProtectMelee"
end

local PROTECT_NOTICE_FALLBACKS = {
    ["Companion:Attack"] = "On it.",
    ["Companion:AttackRange"] = "Covering you.",
    ["Companion:NoAmmo"] = "I'm out of ammo.",
    ["Companion:Return"] = "Back with you.",
    ["Default:Looking"] = "Checking the last spot.",
    ["Default:Searching"] = "Still looking.",
}

local function buildSpeechDataFromText(text, sentiment, zombie, currentTime)
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
    }
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

    return buildSpeechDataFromText(text, sentiment, zombie, currentTime)
end

function Ambient.BuildProtectNoticeSpeechData(npcData, zombie, currentTime)
    if not npcData or not zombie then
        return nil
    end

    local text = npcData.protectNoticeText
    if text and text ~= "" then
        return buildSpeechDataFromText(text, npcData.protectNoticeSentiment, zombie, currentTime)
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
            return buildSpeechDataFromText(entry.dialogue, entry.sentiment, zombie, currentTime)
        end
    end

    local fallbackKey = tostring(status) .. ":" .. tostring(state)
    return buildSpeechDataFromText(
        PROTECT_NOTICE_FALLBACKS[fallbackKey] or "Staying alert.",
        npcData.protectNoticeSentiment or "neutral",
        zombie,
        currentTime
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

    return buildSpeechDataFromText(text, dialogueEntry.sentiment, zombie, currentTime)
end
