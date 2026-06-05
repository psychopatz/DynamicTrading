-- ==============================================================================
-- DTNPC_JobUI_TraderHelpEscort_Context.lua
-- Runtime data access and command helpers.
-- ==============================================================================

DTNPC_JobUI_TraderHelpEscort = DTNPC_JobUI_TraderHelpEscort or {}

local EscortUI = DTNPC_JobUI_TraderHelpEscort
local modules = EscortUI.Modules or {}

EscortUI.Modules = modules

if modules.Context then
    return
end

modules.Context = true

function EscortUI.GetNPCData(npc)
    return npc and DTNPC and DTNPC.GetData and DTNPC.GetData(npc) or nil
end

function EscortUI.GetIncidentContext(player, npcData)
    local incidentId = npcData and npcData.doObjectiveIncidentId or nil
    local store = DynamicObjectives
        and DynamicObjectives.Quests
        and DynamicObjectives.Quests.GetStore
        and DynamicObjectives.Quests.GetStore(player, false)
        or nil
    local hookState = store and store.hookState and store.hookState[EscortUI.HOOK_ID] or nil
    local incident = hookState and hookState.incidents and incidentId and hookState.incidents[tostring(incidentId)] or nil

    return {
        incident = incident,
        incidentId = incidentId and tostring(incidentId) or nil,
        traderId = npcData and npcData.uuid or nil,
        traderName = npcData and npcData.name or "Trader",
    }
end

function EscortUI.GetActiveEscortQuest(player, traderId, incidentId)
    local store = DynamicObjectives
        and DynamicObjectives.Quests
        and DynamicObjectives.Quests.GetStore
        and DynamicObjectives.Quests.GetStore(player, false)
        or nil
    if not store then
        return nil
    end

    for _, quest in ipairs(store.quests or {}) do
        if quest.status == "active" and tostring(quest.hookId or "") == EscortUI.HOOK_ID then
            local hookState = type(quest.hookState) == "table" and quest.hookState or nil
            if incidentId and tostring(quest.hookIncidentId or "") == tostring(incidentId) then
                return quest
            end
            if traderId and hookState and tostring(hookState.traderId or "") == tostring(traderId) then
                return quest
            end
        end
    end

    return nil
end

function EscortUI.GetOffer(player, context)
    if not DynamicObjectives or not DynamicObjectives.Quests or not DynamicObjectives.Quests.BuildObjectiveHookOffer then
        return nil
    end

    return DynamicObjectives.Quests.BuildObjectiveHookOffer(player, EscortUI.HOOK_ID, context)
end

function EscortUI.RememberConversation(ui, npc, player, npcData, context)
    EscortUI.activeConversation = {
        ui = ui,
        npc = npc,
        player = player,
        npcData = npcData,
        context = context,
    }
end

function EscortUI.CountBandages(player)
    if DTNPCHealth and DTNPCHealth.CountReviveItems then
        return tonumber(DTNPCHealth.CountReviveItems(player)) or 0
    end

    if DynamicObjectives and DynamicObjectives.MedicalItemUtils and DynamicObjectives.MedicalItemUtils.CountBandageItems then
        return tonumber(DynamicObjectives.MedicalItemUtils.CountBandageItems(player)) or 0
    end

    return 0
end

function EscortUI.SendEscortAction(player, context, action, extraArgs)
    if not player or not context or not context.traderId or not sendClientCommand then
        return false
    end

    local payload = {
        hookId = EscortUI.HOOK_ID,
        incidentId = context.incidentId,
        traderId = context.traderId,
        action = action,
    }
    extraArgs = type(extraArgs) == "table" and extraArgs or nil
    if extraArgs then
        for key, value in pairs(extraArgs) do
            payload[key] = value
        end
    end

    sendClientCommand(player, "DynamicObjectives", "EscortObjectiveAction", payload)

    return true
end
