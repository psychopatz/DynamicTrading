-- ==============================================================================
-- DTNPC_ContextMenuProvider_JobUI.lua
-- Bridge to job-specific production NPC context menu extensions.
-- ==============================================================================

DTNPCContextMenu = DTNPCContextMenu or {}

local function addJobUIOptions(context, ui, npc, player, npcData)
    if DTNPCJobUI and DTNPCJobUI.AddContextMenuOptions then
        DTNPCJobUI.AddContextMenuOptions(context, ui, npc, player, npcData)
    end
end

DTNPCContextMenu.RegisterProvider({
    id = "job_ui",
    priority = 10,
    addOptions = addJobUIOptions,
})
