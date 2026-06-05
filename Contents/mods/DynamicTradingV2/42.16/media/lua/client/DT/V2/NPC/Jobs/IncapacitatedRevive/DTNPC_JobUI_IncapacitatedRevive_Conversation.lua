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
            text = ReviveUI.T("DTNPC_UI_Leave", nil, "Leave"),
            message = "",
            onSelect = function(innerUI)
                innerUI:speak(ReviveUI.T("DTNPC_Dialogue_ReviveLeaveShort", nil, "Stay alive."))
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

    local reviveInfo = ReviveUI.GetReviveInfo(playerObj, npcData, true)
    local requiresItems = reviveInfo and reviveInfo.requiresItems == true
    local requiredCount = tonumber(ReviveUI.GetRequiredCount(npcData)) or 1
    local plea = ReviveUI.T("DTNPC_Dialogue_RevivePlea", nil, "Please... help me up.")
    if requiresItems then
        plea = ReviveUI.T("DTNPC_Dialogue_RevivePleaSupplies", nil, "Please... if you've got bandages or rags, help me.")
        if requiredCount > 1 then
            plea = ReviveUI.T("DTNPC_Dialogue_RevivePleaSuppliesCount", {
                count = tostring(requiredCount),
            }, "Please... I need {count} bandages or rags, or I'm done for.")
        end
    end

    ui:speak(overrideSpeech or plea)
    ui:updateOptions({
        {
            text = ReviveUI.T("DTNPC_UI_WhatDoYouNeed", nil, "What do you need?"),
            message = "",
            onSelect = function(innerUI)
                local liveNPCData = ReviveUI.GetNPCData(npc) or npcData
                local liveInfo = ReviveUI.GetReviveInfo(playerObj, liveNPCData, true)
                local liveRequiresItems = liveInfo and liveInfo.requiresItems == true
                local required = tonumber(ReviveUI.GetRequiredCount(liveNPCData)) or requiredCount or 1
                if liveRequiresItems then
                    innerUI:speak(ReviveUI.T("DTNPC_Dialogue_ReviveNeedBandages", {
                        count = tostring(required),
                    }, "Bandages or ripped sheets. Use the context menu and make it quick. I need {count}."))
                else
                    innerUI:speak(ReviveUI.T("DTNPC_Dialogue_ReviveJustGetMeUp", nil, "Just get me back on my feet. Use the context menu and be quick."))
                end
                innerUI:updateOptions(buildLeaveOptions())
            end,
        },
        {
            text = ReviveUI.T("DTNPC_UI_Leave", nil, "Leave"),
            message = "",
            onSelect = function(innerUI)
                innerUI:speak(ReviveUI.T("DTNPC_Dialogue_ReviveLeaveNow", nil, "Then move. I need to work."))
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

    ui:speak(thankYouLine or ReviveUI.T("DTNPC_Dialogue_ReviveThankYou", nil, "Thank you. I can make it home from here."))
    ui:updateOptions({
        {
            text = ReviveUI.T("DTNPC_UI_Leave", nil, "Leave"),
            message = "",
            onSelect = function(innerUI)
                innerUI:speak((result and result.message) or ReviveUI.T("DTNPC_Dialogue_ReviveHeadHomeSlowly", nil, "They head home slowly."))
                innerUI:updateOptions({})
            end,
        },
    })
end
