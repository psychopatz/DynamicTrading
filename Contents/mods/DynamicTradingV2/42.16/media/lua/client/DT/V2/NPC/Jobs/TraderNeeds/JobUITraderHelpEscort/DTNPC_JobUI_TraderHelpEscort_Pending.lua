-- ==============================================================================
-- DTNPC_JobUI_TraderHelpEscort_Pending.lua
-- Pending offer and unavailable conversation flow.
-- ==============================================================================

DTNPC_JobUI_TraderHelpEscort = DTNPC_JobUI_TraderHelpEscort or {}

local EscortUI = DTNPC_JobUI_TraderHelpEscort
local modules = EscortUI.Modules or {}
local Helpers = EscortUI.Helpers or {}

EscortUI.Modules = modules
EscortUI.Helpers = Helpers

if modules.Pending then
    return
end

modules.Pending = true

function EscortUI.ShowUnavailable(ui, message)
    EscortUI.activeConversation = nil
    ui:speak(message or EscortUI.T("DTNPC_Dialogue_EscortUnavailable", nil, "This rescue call is no longer available."))

    local options = {}
    local footerAction = Helpers.buildExitFooterAction()
    local _, navBlock = Helpers.attachNavigationBlock(options, footerAction, {
        resetHistory = true,
        debugLabel = "EscortUnavailable",
        requireExplicitNavigation = true,
    })
    ui:updateOptions(options, navBlock)
end

function EscortUI.ShowPendingConversation(ui, npc, player, npcData, context)
    EscortUI.RememberConversation(ui, npc, player, npcData, context)

    local offer = EscortUI.GetOffer(player, context) or {}
    local incident = context and context.incident or nil
    if not incident then
        EscortUI.ShowUnavailable(ui, offer.unavailable or EscortUI.T("DTNPC_Dialogue_EscortUnavailableGone", nil, "This rescue call is gone."))
        return
    end

    ui:speak(offer.offer or EscortUI.T("DTNPC_Dialogue_EscortOffer", nil, "I need an escort back to base."))
    local options = {
        {
            text = (offer.choiceLabels and offer.choiceLabels.accept) or EscortUI.T("DTNPC_UI_Accept", nil, "Accept"),
            message = "",
            onSelect = function(innerUI)
                EscortUI.pendingRequest = {
                    ui = innerUI,
                    npc = npc,
                    player = player,
                    incidentId = context.incidentId,
                    traderId = context.traderId,
                }
                innerUI:speak(EscortUI.T("DTNPC_Dialogue_EscortAccept", nil, "Stay with me. I'm ready when you are."))

                local waitingOptions = {
                    {
                        text = EscortUI.T("DTNPC_UI_Working", nil, "Working..."),
                        message = "",
                        onSelect = function() end,
                    },
                }
                local footerAction = Helpers.buildExitFooterAction()
                local _, navBlock = Helpers.attachNavigationBlock(waitingOptions, footerAction, {
                    resetHistory = true,
                    debugLabel = "EscortAcceptWaiting",
                    requireExplicitNavigation = true,
                })
                innerUI:updateOptions(waitingOptions, navBlock)

                sendClientCommand(player, "DynamicObjectives", "AcceptObjectiveHookIncident", {
                    hookId = EscortUI.HOOK_ID,
                    incidentId = context.incidentId,
                    traderId = context.traderId,
                })
            end,
        },
        {
            text = (offer.choiceLabels and offer.choiceLabels.details) or EscortUI.T("DTNPC_UI_Details", nil, "Details"),
            message = "",
            onSelect = function(innerUI)
                innerUI:speak(offer.details or EscortUI.T("DTNPC_Dialogue_EscortDetails", nil, "Guide the trader home and keep them alive."))

                local detailOptions = {}
                local footerAction = Helpers.buildBackFooterAction({
                    onSelect = function(backUI)
                        EscortUI.ShowPendingConversation(backUI, npc, player, EscortUI.GetNPCData(npc) or npcData, context)
                    end
                })
                local _, navBlock = Helpers.attachNavigationBlock(detailOptions, footerAction, {
                    debugLabel = "EscortPendingDetails",
                    requireExplicitNavigation = true,
                })
                innerUI:updateOptions(detailOptions, navBlock)
            end,
        },
        {
            text = (offer.choiceLabels and offer.choiceLabels.decline) or EscortUI.T("DTNPC_UI_Decline", nil, "Decline"),
            message = "",
            onSelect = function(innerUI)
                innerUI:speak(offer.decline or EscortUI.T("DTNPC_Dialogue_EscortDecline", nil, "Then I keep hiding in here."))

                local doneOptions = {}
                local footerAction = Helpers.buildExitFooterAction()
                local _, navBlock = Helpers.attachNavigationBlock(doneOptions, footerAction, {
                    resetHistory = true,
                    debugLabel = "EscortDeclined",
                    requireExplicitNavigation = true,
                })
                innerUI:updateOptions(doneOptions, navBlock)
            end,
        },
    }
    local footerAction = Helpers.buildLeaveFooterAction()
    local _, navBlock = Helpers.attachNavigationBlock(options, footerAction, {
        resetHistory = true,
        debugLabel = "EscortPendingRoot",
        requireExplicitNavigation = true,
    })
    ui:updateOptions(options, navBlock)
end
