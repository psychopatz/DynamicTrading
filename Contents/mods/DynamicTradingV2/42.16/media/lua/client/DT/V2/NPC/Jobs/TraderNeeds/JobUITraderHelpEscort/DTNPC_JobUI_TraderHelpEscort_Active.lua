-- ==============================================================================
-- DTNPC_JobUI_TraderHelpEscort_Active.lua
-- Active escort conversation flow.
-- ==============================================================================

DTNPC_JobUI_TraderHelpEscort = DTNPC_JobUI_TraderHelpEscort or {}

local EscortUI = DTNPC_JobUI_TraderHelpEscort
local modules = EscortUI.Modules or {}
local Helpers = EscortUI.Helpers or {}

EscortUI.Modules = modules
EscortUI.Helpers = Helpers

if modules.Active then
    return
end

modules.Active = true

local function rememberPendingAction(ui, npc, player)
    EscortUI.pendingAction = {
        ui = ui,
        npc = npc,
        player = player,
    }
end

function EscortUI.ShowEscortConversation(ui, npc, player, npcData, context, overrideSpeech)
    npcData = EscortUI.GetNPCData(npc) or npcData

    local resolvedContext = EscortUI.GetIncidentContext(player, npcData)
    if type(resolvedContext) == "table" and (resolvedContext.traderId or resolvedContext.incidentId) then
        context = resolvedContext
    else
        context = type(context) == "table" and context or {}
    end
    context.npcData = npcData

    EscortUI.RememberConversation(ui, npc, player, npcData, context)

    local quest = EscortUI.GetActiveEscortQuest(player, context.traderId, context.incidentId)
    local summary = EscortUI.BuildEscortStatusText(player, npcData, context, quest)
    local bandageCount = EscortUI.CountBandages(player)
    local requiredCount = DTNPCHealth and DTNPCHealth.GetReviveRequirement and DTNPCHealth.GetReviveRequirement(npcData) or nil
    local healLabel = "Heal Up (Need supplies)"
    if requiredCount and requiredCount > 0 then
        healLabel = "Heal Up (" .. tostring(bandageCount) .. "/" .. tostring(requiredCount) .. ")"
    elseif bandageCount > 0 then
        healLabel = "Heal Up (" .. tostring(bandageCount) .. ")"
    end

    ui:speak(overrideSpeech or "We're moving. Keep me alive and get me back to base.")
    local options = {
        {
            text = "Status",
            message = "",
            onSelect = function(innerUI)
                EscortUI.ShowEscortConversation(
                    innerUI,
                    npc,
                    player,
                    EscortUI.GetNPCData(npc) or npcData,
                    EscortUI.GetIncidentContext(player, EscortUI.GetNPCData(npc) or npcData),
                    summary or "Keep the trader alive and moving."
                )
            end,
        },
        {
            text = "Follow Near",
            message = "",
            onSelect = function(innerUI)
                rememberPendingAction(innerUI, npc, player)
                EscortUI.SendEscortAction(player, context, "follow", {
                    followSpacingMode = "near",
                })
                EscortUI.ShowEscortConversation(
                    innerUI,
                    npc,
                    player,
                    EscortUI.GetNPCData(npc) or npcData,
                    EscortUI.GetIncidentContext(player, EscortUI.GetNPCData(npc) or npcData),
                    "Stay close. I'll follow your lead."
                )
            end,
        },
        {
            text = "Follow Far",
            message = "",
            onSelect = function(innerUI)
                rememberPendingAction(innerUI, npc, player)
                EscortUI.SendEscortAction(player, context, "follow", {
                    followSpacingMode = "far",
                })
                EscortUI.ShowEscortConversation(
                    innerUI,
                    npc,
                    player,
                    EscortUI.GetNPCData(npc) or npcData,
                    EscortUI.GetIncidentContext(player, EscortUI.GetNPCData(npc) or npcData),
                    "Give me more room. I'll trail you from farther back."
                )
            end,
        },
        {
            text = "Stay",
            message = "",
            onSelect = function(innerUI)
                rememberPendingAction(innerUI, npc, player)
                EscortUI.SendEscortAction(player, context, "stay")
                EscortUI.ShowEscortConversation(
                    innerUI,
                    npc,
                    player,
                    EscortUI.GetNPCData(npc) or npcData,
                    EscortUI.GetIncidentContext(player, EscortUI.GetNPCData(npc) or npcData),
                    "I'll hold here until you move me again."
                )
            end,
        },
        {
            text = healLabel,
            message = "",
            onSelect = function(innerUI)
                if bandageCount <= 0 then
                    innerUI:speak("Bring bandages or ripped sheets first.")
                    EscortUI.ShowEscortConversation(
                        innerUI,
                        npc,
                        player,
                        EscortUI.GetNPCData(npc) or npcData,
                        EscortUI.GetIncidentContext(player, EscortUI.GetNPCData(npc) or npcData)
                    )
                    return
                end

                rememberPendingAction(innerUI, npc, player)
                EscortUI.SendEscortAction(player, context, "patchup")
                EscortUI.ShowEscortConversation(
                    innerUI,
                    npc,
                    player,
                    EscortUI.GetNPCData(npc) or npcData,
                    EscortUI.GetIncidentContext(player, EscortUI.GetNPCData(npc) or npcData),
                    "Hold still. Use the bandage and keep moving."
                )
            end,
        },
    }
    local footerAction = Helpers.buildLeaveFooterAction()
    local _, navBlock = Helpers.attachNavigationBlock(options, footerAction, {
        resetHistory = true,
        debugLabel = "EscortActiveRoot",
        requireExplicitNavigation = true,
    })
    ui:updateOptions(options, navBlock)
end
