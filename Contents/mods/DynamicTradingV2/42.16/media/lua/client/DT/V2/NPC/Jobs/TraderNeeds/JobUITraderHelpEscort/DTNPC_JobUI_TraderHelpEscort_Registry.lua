-- ==============================================================================
-- DTNPC_JobUI_TraderHelpEscort_Registry.lua
-- Job UI registration for trader escort interactions.
-- ==============================================================================

DTNPC_JobUI_TraderHelpEscort = DTNPC_JobUI_TraderHelpEscort or {}

local EscortUI = DTNPC_JobUI_TraderHelpEscort
local modules = EscortUI.Modules or {}

EscortUI.Modules = modules

if modules.Registry then
    return
end

modules.Registry = true

DTNPCJobUI.Register({
    id = "TraderNeeds.HelpEscort",
    priority = 250,
    matches = function(ui, npc, player, npcData)
        npcData = npcData or EscortUI.GetNPCData(npc)
        if not npcData then
            return false
        end

        return tostring(npcData.doObjectiveHookId or "") == EscortUI.HOOK_ID
            or npcData.doObjectiveEscortActive == true
            or npcData.doObjectiveDistress == true
    end,
    getTalkLabel = function(ui, npc, player, npcData, defaultName)
        local name = tostring(defaultName or (npcData and npcData.name) or "Trader")
        if npcData and npcData.doObjectiveEscortActive == true then
            return "Talk to Escorted " .. name
        end
        return "Talk to Distressed " .. name
    end,
    getTraderProxyPatch = function(ui, npc, player, npcData)
        return {
            doObjectiveHookId = npcData and npcData.doObjectiveHookId or nil,
            doObjectiveIncidentId = npcData and npcData.doObjectiveIncidentId or nil,
            doObjectiveIncidentStatus = npcData and npcData.doObjectiveIncidentStatus or nil,
            doObjectiveDistress = npcData and npcData.doObjectiveDistress or nil,
            doObjectiveEscortActive = npcData and npcData.doObjectiveEscortActive or nil,
            suppressTrade = true,
        }
    end,
    generateOptions = function(ui, npc, player, npcData)
        npcData = npcData or EscortUI.GetNPCData(npc)
        if not npcData then
            return false
        end

        local context = EscortUI.GetIncidentContext(player, npcData)
        local activeQuest = EscortUI.GetActiveEscortQuest(player, context.traderId, context.incidentId)
        if npcData.doObjectiveEscortActive == true or activeQuest then
            EscortUI.ShowEscortConversation(ui, npc, player, npcData, context)
            return true
        end

        if tostring(npcData.doObjectiveIncidentStatus or "") ~= "pending" then
            EscortUI.ShowUnavailable(ui, "This distress call has already been resolved.")
            return true
        end

        EscortUI.ShowPendingConversation(ui, npc, player, npcData, context)
        return true
    end,
})
