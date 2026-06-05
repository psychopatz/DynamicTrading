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
    local reviveInfo = DTNPCHealth and DTNPCHealth.CanPlayerRevive and ({ DTNPCHealth.CanPlayerRevive(player, npcData, {
        ignoreItems = true,
    }) }) or nil
    local reviveData = reviveInfo and reviveInfo[2] or nil
    local requiresItems = reviveData and reviveData.requiresItems == true
    local requiredCount = DTNPCHealth and DTNPCHealth.GetReviveRequirement and DTNPCHealth.GetReviveRequirement(npcData) or nil
    local healLabel = requiresItems
        and EscortUI.T("DTNPC_UI_HealUpNeedSupplies", nil, "Heal Up (Need supplies)")
        or EscortUI.T("DTNPC_UI_HelpUp", nil, "Help Up")
    if requiresItems and requiredCount and requiredCount > 0 then
        healLabel = EscortUI.T("DTNPC_UI_HealUpCountOfRequired", {
            count = tostring(bandageCount),
            required = tostring(requiredCount),
        }, "Heal Up ({count}/{required})")
    elseif requiresItems and bandageCount > 0 then
        healLabel = EscortUI.T("DTNPC_UI_HealUpCount", {
            count = tostring(bandageCount),
        }, "Heal Up ({count})")
    end

    ui:speak(overrideSpeech or EscortUI.T("DTNPC_Dialogue_EscortIntro", nil, "We're moving. Keep me alive and get me back to base."))
    local options = {
        {
            text = EscortUI.T("DTNPC_UI_Status", nil, "Status"),
            message = "",
            onSelect = function(innerUI)
                EscortUI.ShowEscortConversation(
                    innerUI,
                    npc,
                    player,
                    EscortUI.GetNPCData(npc) or npcData,
                    EscortUI.GetIncidentContext(player, EscortUI.GetNPCData(npc) or npcData),
                    summary or EscortUI.T("DTNPC_Dialogue_EscortSummary", nil, "Keep the trader alive and moving.")
                )
            end,
        },
        {
            text = EscortUI.T("DTNPC_UI_FollowNear", nil, "Follow Near"),
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
                    EscortUI.T("DTNPC_Dialogue_EscortFollowNear", nil, "Stay close. I'll follow your lead.")
                )
            end,
        },
        {
            text = EscortUI.T("DTNPC_UI_FollowFar", nil, "Follow Far"),
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
                    EscortUI.T("DTNPC_Dialogue_EscortFollowFar", nil, "Give me more room. I'll trail you from farther back.")
                )
            end,
        },
        {
            text = EscortUI.T("DTNPC_UI_HoldPosition", nil, "Stay"),
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
                    EscortUI.T("DTNPC_Dialogue_EscortStay", nil, "I'll hold here until you move me again.")
                )
            end,
        },
        {
            text = healLabel,
            message = "",
            onSelect = function(innerUI)
                if requiresItems and bandageCount <= 0 then
                    innerUI:speak(EscortUI.T("DTNPC_Dialogue_EscortNeedSupplies", nil, "Bring bandages or ripped sheets first."))
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
                    requiresItems
                        and EscortUI.T("DTNPC_Dialogue_EscortPatchWithSupplies", nil, "Hold still. Use the bandage and keep moving.")
                        or EscortUI.T("DTNPC_Dialogue_EscortPatchWithoutSupplies", nil, "Hold still. I'll get you moving again.")
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
