-- ==============================================================================
-- DT_Dialogue_Ambient_Debug.lua
-- Debug and forced ambient dialogue helpers.
-- ==============================================================================

DTNPCClient = DTNPCClient or {}
DTNPCClient.DialogueAmbient = DTNPCClient.DialogueAmbient or DTNPCClient.AmbientDialogue or {}
DTNPCClient.AmbientDialogue = DTNPCClient.DialogueAmbient

local Ambient = DTNPCClient.DialogueAmbient
local DialogueVocals = DynamicTrading
    and DynamicTrading.Dialogue
    and DynamicTrading.Dialogue.Vocals

local function queueSpeechData(manager, zombie, npcData, speechData)
    if not manager or not zombie or not npcData or not speechData then
        return false
    end

    speechData.zombie = zombie
    manager.speechList[npcData.uuid or tostring(zombie:getPersistentOutfitID())] = speechData
    if speechData.audio and DialogueVocals and DialogueVocals.PlaySpeechAudio then
        DialogueVocals.PlaySpeechAudio(zombie, npcData, speechData.audio)
    end
    if DTNPCClient.TrackNPCForAmbientDialogue then
        DTNPCClient.TrackNPCForAmbientDialogue(zombie, npcData, npcData.uuid, zombie:getPersistentOutfitID())
    end
    return true
end

function Ambient.GetAmbientDebugInfo(npcData)
    local archetype = npcData and (npcData.archetypeID or npcData.occupation) or "General"
    local status = npcData and npcData.status or "Default"
    local state = npcData and npcData.state or "Default"
    local dialogueDB = DynamicTrading and DynamicTrading.Dialogue and DynamicTrading.Dialogue.Archetypes or nil
    local archetypeTable = dialogueDB and dialogueDB[archetype] or nil
    local generalTable = dialogueDB and dialogueDB.General or nil
    local entry = nil

    if DynamicTrading and DynamicTrading.DialogueAmbient and DynamicTrading.DialogueAmbient.GetEntry then
        entry = DynamicTrading.DialogueAmbient.GetEntry(
            {
                archetype = archetype,
                name = npcData and npcData.name or "Trader"
            },
            status,
            state,
            {
                traderName = npcData and npcData.name or "Trader"
            }
        )
    end

    return {
        archetype = archetype,
        status = status,
        state = state,
        hasArchetype = archetypeTable ~= nil,
        hasArchetypeAmbient = archetypeTable and archetypeTable.Ambient ~= nil or false,
        hasGeneralAmbient = generalTable and generalTable.Ambient ~= nil or false,
        entry = entry,
    }
end

function DTNPCClient.DebugPrintAmbientDialogue(zombie)
    local npcData = Ambient.GetNPCData(zombie)
    if not npcData then
        DynamicTrading.Log("DTV2", "NPC", "Ambient", "DEBUG Ambient: no npcData on target zombie")
        return false
    end

    local info = Ambient.GetAmbientDebugInfo(npcData)
    DynamicTrading.Log("DTV2", "NPC", "Ambient", "DEBUG Ambient NPC: " .. tostring(npcData.name or "Unknown"))
    DynamicTrading.Log("DTV2", "NPC", "Ambient", "  UUID: " .. tostring(npcData.uuid))
    DynamicTrading.Log("DTV2", "NPC", "Ambient", "  Archetype: " .. tostring(info.archetype))
    DynamicTrading.Log("DTV2", "NPC", "Ambient", "  Status: " .. tostring(info.status))
    DynamicTrading.Log("DTV2", "NPC", "Ambient", "  State: " .. tostring(info.state))
    DynamicTrading.Log("DTV2", "NPC", "Ambient", "  Has Archetype Table: " .. tostring(info.hasArchetype))
    DynamicTrading.Log("DTV2", "NPC", "Ambient", "  Has Archetype Ambient: " .. tostring(info.hasArchetypeAmbient))
    DynamicTrading.Log("DTV2", "NPC", "Ambient", "  Has General Ambient: " .. tostring(info.hasGeneralAmbient))

    if info.entry then
        DynamicTrading.Log("DTV2", "NPC", "Ambient", "  Picked Sentiment: " .. tostring(info.entry.sentiment))
        DynamicTrading.Log("DTV2", "NPC", "Ambient", "  Picked Dialogue: " .. tostring(info.entry.dialogue))
        return true
    end

    DynamicTrading.Log("DTV2", "NPC", "Ambient", "  Picked Dialogue: nil")
    return false
end

function DTNPCClient.ForceAmbientDialogueForNPC(zombie, playerIndex)
    if not zombie then
        return false
    end

    local npcData = Ambient.GetNPCData(zombie)
    if not npcData then
        DynamicTrading.Log("DTV2", "NPC", "Ambient", "Force Ambient failed: no npcData on target zombie")
        return false
    end

    local manager = DTNPCClient.DialogueAmbientManagers and DTNPCClient.DialogueAmbientManagers[playerIndex or 0]
    if not manager then
        DynamicTrading.Log(
            "DTV2",
            "NPC",
            "Ambient",
            "Force Ambient failed: no dialogue manager for player index " .. tostring(playerIndex or 0)
        )
        return false
    end

    local speechData = Ambient.BuildSpeechData(npcData, zombie, getTimeInMillis())
    if not speechData then
        DynamicTrading.Log("DTV2", "NPC", "Ambient", "Force Ambient failed: no speech data generated")
        DTNPCClient.DebugPrintAmbientDialogue(zombie)
        return false
    end

    queueSpeechData(manager, zombie, npcData, speechData)

    DynamicTrading.Log(
        "DTV2",
        "NPC",
        "Ambient",
        "Force Ambient queued for " .. tostring(npcData.name or "Unknown") .. ": " .. tostring(speechData.text)
    )
    return true
end

function DTNPCClient.QueueAmbientSpeechForNPC(zombie, text, sentiment, playerIndex)
    local speechText = tostring(text or "")
    if not zombie or speechText == "" then
        return false
    end

    local npcData = Ambient.GetNPCData and Ambient.GetNPCData(zombie) or nil
    local manager = DTNPCClient.DialogueAmbientManagers and DTNPCClient.DialogueAmbientManagers[playerIndex or 0] or nil
    if not npcData or not manager or not Ambient.BuildCustomSpeechData then
        return false
    end

    local speechData = Ambient.BuildCustomSpeechData(speechText, sentiment or "neutral", zombie, getTimeInMillis(), npcData)
    return queueSpeechData(manager, zombie, npcData, speechData)
end
