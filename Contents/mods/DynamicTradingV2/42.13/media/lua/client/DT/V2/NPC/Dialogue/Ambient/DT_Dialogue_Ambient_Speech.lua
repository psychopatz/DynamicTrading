-- ==============================================================================
-- DT_Dialogue_Ambient_Speech.lua
-- Speech scheduling and dialogue payload generation.
-- ==============================================================================

DTNPCClient = DTNPCClient or {}
DTNPCClient.DialogueAmbient = DTNPCClient.DialogueAmbient or DTNPCClient.AmbientDialogue or {}
DTNPCClient.AmbientDialogue = DTNPCClient.DialogueAmbient

local Ambient = DTNPCClient.DialogueAmbient
local Config = DTNPCClient.DialogueAmbientConfig or DTNPCClient.AmbientDialogueConfig

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
    if DynamicTrading and DynamicTrading.DialogueAmbient and DynamicTrading.DialogueAmbient.GetEntry then
        dialogueEntry = DynamicTrading.DialogueAmbient.GetEntry(
            {
                archetype = npcData and (npcData.archetypeID or npcData.occupation) or "General",
                name = npcData and npcData.name or "Trader"
            },
            npcData and npcData.status or "Default",
            npcData and npcData.state or "Default",
            {
                traderName = npcData and npcData.name or "Trader"
            }
        )
    end
    if not dialogueEntry then
        return nil
    end

    local text = dialogueEntry.dialogue
    if not text or text == "" or text == "..." then
        return nil
    end

    local color = Config.GetSentimentColor(dialogueEntry.sentiment)
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
