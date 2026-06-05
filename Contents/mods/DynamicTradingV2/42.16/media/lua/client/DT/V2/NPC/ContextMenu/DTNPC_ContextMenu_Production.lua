-- ==============================================================================
-- DTNPC_ContextMenu_Production.lua
-- Production world-context hook for NPC interactions.
-- ==============================================================================

DTNPCContextMenu = DTNPCContextMenu or {}
DTNPCContextMenu.Internal = DTNPCContextMenu.Internal or {}

local Internal = DTNPCContextMenu.Internal

if Internal.ProductionLoaded then
    return
end

Internal.ProductionLoaded = true

local function onFillWorldObjectContextMenu(playerNum, context, worldObjects, test)
    if test and ISWorldObjectContextMenu and ISWorldObjectContextMenu.Test then
        return true
    end

    local player = getSpecificPlayer(playerNum)
    if not player or not context then
        return
    end

    local npcList = DTNPCContextMenu.CollectNearbyNPCs(player, worldObjects, 3.0)
    for index = 1, #npcList do
        local npc = npcList[index]
        local npcData = DTNPCContextMenu.GetNPCData(npc)
        if npcData then
            DTNPCContextMenu.AddProviderOptions(context, nil, npc, player, npcData)
        end
    end
end

Events.OnFillWorldObjectContextMenu.Add(onFillWorldObjectContextMenu)
