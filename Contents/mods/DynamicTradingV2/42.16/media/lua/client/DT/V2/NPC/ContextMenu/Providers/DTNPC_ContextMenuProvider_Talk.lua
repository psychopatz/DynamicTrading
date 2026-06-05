-- ==============================================================================
-- DTNPC_ContextMenuProvider_Talk.lua
-- Base talk action for production NPC context menus.
-- ==============================================================================

DTNPCContextMenu = DTNPCContextMenu or {}

local function addTalkOption(context, ui, npc, player, npcData)
    if not context or not npc or not player then
        return
    end

    local name = npcData and npcData.name or "Survivor"
    local talkLabel = DTNPCJobUI and DTNPCJobUI.GetTalkLabel
        and DTNPCJobUI.GetTalkLabel(ui, npc, player, npcData, name)
        or ("Talk to " .. tostring(name))

    local option = context:addOption(talkLabel, npc, function(targetNPC)
        if DTNPC_TraderDialogue_Hub and DTNPC_TraderDialogue_Hub.Init then
            DTNPC_TraderDialogue_Hub.Init(nil, targetNPC, player)
        else
            DynamicTrading.Log("DTV2", "NPC", "Error", "DTNPC_TraderDialogue_Hub not found")
        end
    end)

    if option then
        option.iconTexture = getTexture("media/ui/emotes/insult.png")
    end
end

DTNPCContextMenu.RegisterProvider({
    id = "talk",
    priority = 100,
    addOptions = addTalkOption,
})
