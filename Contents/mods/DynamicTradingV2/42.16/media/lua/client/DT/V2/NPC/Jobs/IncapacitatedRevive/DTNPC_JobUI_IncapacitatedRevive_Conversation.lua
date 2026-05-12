-- ==============================================================================
-- DTNPC_JobUI_IncapacitatedRevive_Conversation.lua
-- Conversation flow for incapacitated revive interactions.
-- ==============================================================================

DTNPC_JobUI_IncapacitatedRevive = DTNPC_JobUI_IncapacitatedRevive or {}

local ReviveUI = DTNPC_JobUI_IncapacitatedRevive
local modules = ReviveUI.Modules or {}

ReviveUI.Modules = modules

if modules.Conversation then
    return
end

modules.Conversation = true

local function buildLeaveOptions()
    return {
        {
            text = "Leave",
            message = "",
            onSelect = function(innerUI)
                innerUI:speak("Stay alive.")
                innerUI:updateOptions({})
            end,
        },
    }
end

function ReviveUI.ShowReviveConversation(ui, npc, playerObj, npcData, overrideSpeech)
    npcData = ReviveUI.GetNPCData(npc) or npcData
    if not npcData then
        return
    end

    local requiredCount = tonumber(ReviveUI.GetRequiredCount(npcData)) or 1
    local plea = "Please... if you've got bandages or rags, help me."
    if requiredCount > 1 then
        plea = "Please... I need " .. tostring(requiredCount) .. " bandages or rags, or I'm done for."
    end

    ui:speak(overrideSpeech or plea)
    ui:updateOptions({
        {
            text = "What do you need?",
            message = "",
            onSelect = function(innerUI)
                local liveNPCData = ReviveUI.GetNPCData(npc) or npcData
                local required = tonumber(ReviveUI.GetRequiredCount(liveNPCData)) or requiredCount or 1
                innerUI:speak("Bandages or ripped sheets. Use the context menu and make it quick. I need " .. tostring(required) .. ".")
                innerUI:updateOptions(buildLeaveOptions())
            end,
        },
        {
            text = "Leave",
            message = "",
            onSelect = function(innerUI)
                innerUI:speak("Then move. I need to work.")
                innerUI:updateOptions({})
            end,
        },
    })
end

function ReviveUI.ShowReviveResultConversation(ui, npc, playerObj, npcData, result)
    local thankYouLine = nil
    if DTNPC_WaveHiInteraction and DTNPC_WaveHiInteraction.BuildPlanForEmote then
        local plan = DTNPC_WaveHiInteraction.BuildPlanForEmote("thankyou", playerObj, npc, npcData)
        thankYouLine = plan and plan.introGreeting and plan.introGreeting.text or plan and plan.npcLine or nil
    end

    ui:speak(thankYouLine or "Thank you. I can make it home from here.")
    ui:updateOptions({
        {
            text = "Leave",
            message = "",
            onSelect = function(innerUI)
                innerUI:speak((result and result.message) or "They head home slowly.")
                innerUI:updateOptions({})
            end,
        },
    })
end
