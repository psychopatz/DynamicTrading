-- ==============================================================================
-- DTNPC_JobUI_IncapacitatedRevive_Registry.lua
-- Job UI registration for incapacitated revive interactions.
-- ==============================================================================

DTNPC_JobUI_IncapacitatedRevive = DTNPC_JobUI_IncapacitatedRevive or {}

local ReviveUI = DTNPC_JobUI_IncapacitatedRevive
local modules = ReviveUI.Modules or {}

ReviveUI.Modules = modules

if modules.Registry then
    return
end

modules.Registry = true

DTNPCJobUI.Register({
    id = "IncapacitatedRevive",
    priority = 220,
    matches = function(ui, npc, playerObj, npcData)
        npcData = npcData or ReviveUI.GetNPCData(npc)
        if not npcData or not DTNPCHealth or not DTNPCHealth.GetHealthState then
            return false
        end

        if DTNPCHealth.GetHealthState(npcData) ~= "Incapacitated" then
            return false
        end

        local canRevive, info = DTNPCHealth.CanPlayerRevive(playerObj, npcData, {
            ignoreItems = true,
        })
        return canRevive == true or (info and info.reason == "need_supplies")
    end,
    getTalkLabel = function(ui, npc, playerObj, npcData, defaultName)
        return ReviveUI.T("DTNPC_UI_HelpIncapacitatedName", {
            name = tostring(defaultName or (npcData and npcData.name) or "Survivor"),
        }, "Help Incapacitated {name}")
    end,
    generateOptions = function(ui, npc, playerObj, npcData)
        npcData = npcData or ReviveUI.GetNPCData(npc)
        if not npcData then
            return false
        end

        ReviveUI.ShowReviveConversation(ui, npc, playerObj, npcData)
        return true
    end,
    addContextMenuOptions = function(context, ui, npc, playerObj, npcData)
        if not context or not npc or not playerObj or not ReviveUI.AddContextMenuOptions then
            return false
        end

        return ReviveUI.AddContextMenuOptions(context, ui, npc, playerObj, npcData) == true
    end,
})
