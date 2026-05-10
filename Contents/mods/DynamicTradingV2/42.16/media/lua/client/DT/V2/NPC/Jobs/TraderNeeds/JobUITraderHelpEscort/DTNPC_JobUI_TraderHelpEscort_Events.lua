-- ==============================================================================
-- DTNPC_JobUI_TraderHelpEscort_Events.lua
-- Network result handlers for the escort job UI.
-- ==============================================================================

DTNPC_JobUI_TraderHelpEscort = DTNPC_JobUI_TraderHelpEscort or {}

local EscortUI = DTNPC_JobUI_TraderHelpEscort
local modules = EscortUI.Modules or {}

EscortUI.Modules = modules

if modules.Events then
    return
end

modules.Events = true

function EscortUI.OnIncidentAccepted(args)
    local pending = EscortUI.pendingRequest
    EscortUI.pendingRequest = nil
    if not pending or not pending.ui then
        return
    end

    if DTNPCClient and DTNPCClient.QueueNearbySync then
        DTNPCClient.QueueNearbySync("trader-help-escort-accepted")
    end

    EscortUI.ShowEscortConversation(
        pending.ui,
        pending.npc,
        pending.player,
        EscortUI.GetNPCData(pending.npc),
        EscortUI.GetIncidentContext(pending.player, EscortUI.GetNPCData(pending.npc)),
        (args and args.message) or "I'm with you. Get me home."
    )
end

function EscortUI.OnIncidentFailed(args)
    local pending = EscortUI.pendingRequest
    EscortUI.pendingRequest = nil
    if not pending or not pending.ui then
        return
    end

    EscortUI.ShowUnavailable(pending.ui, args and args.message or "This rescue is no longer available.")
end

function EscortUI.OnEscortActionResult(args)
    local pending = EscortUI.pendingAction
    EscortUI.pendingAction = nil

    if DTNPCClient and DTNPCClient.QueueNearbySync then
        DTNPCClient.QueueNearbySync("trader-help-escort-action")
    end
    if not pending or not pending.ui then
        return
    end

    local npcData = EscortUI.GetNPCData(pending.npc)
    local context = EscortUI.GetIncidentContext(pending.player, npcData)
    if (not context or (not context.traderId and not context.incidentId))
        and EscortUI.activeConversation
        and EscortUI.activeConversation.context
    then
        context = EscortUI.activeConversation.context
    end

    EscortUI.ShowEscortConversation(
        pending.ui,
        pending.npc,
        pending.player,
        npcData,
        context,
        args and args.message or "Escort order updated."
    )
end
