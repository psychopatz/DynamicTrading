-- ==============================================================================
-- DTNPC_ContextMenu_DebugActions.lua
-- Debug-only actions for the NPC context menu.
-- ==============================================================================

if not isDebugEnabled() then return end

DTNPCMenu = DTNPCMenu or {}
DTNPCMenu.ContextMenu = DTNPCMenu.ContextMenu or {}

local Menu = DTNPCMenu.ContextMenu

if Menu.DebugActionsLoaded then
    return
end

Menu.DebugActionsLoaded = true

function Menu.OnForceAmbientDialogue(player, npc)
    if not npc or not player then return end

    if DTNPCClient and DTNPCClient.ForceAmbientDialogueForNPC then
        local ok = DTNPCClient.ForceAmbientDialogueForNPC(npc, player:getPlayerNum())
        player:Say(ok and "Forced ambient dialogue." or "Ambient force failed. Check logs.")
    else
        player:Say("Ambient dialogue tester not available.")
    end
end

function Menu.OnDebugAmbientDialogue(player, npc)
    if not npc or not player then return end

    if DTNPCClient and DTNPCClient.DebugPrintAmbientDialogue then
        local ok = DTNPCClient.DebugPrintAmbientDialogue(npc)
        player:Say(ok and "Ambient dialogue info printed." or "Ambient dialogue lookup failed. Check logs.")
    else
        player:Say("Ambient dialogue debug not available.")
    end
end

function Menu.OnInspectNPCData(npc)
    if not npc then return end

    DTNPC_Debugger.OnOpenWindow()

    local debugger = DTNPC_Debugger.instance
    if not debugger then return end

    local id = npc:getPersistentOutfitID()
    if not id then return end

    local lists = {
        {
            list = debugger.activeNearbyPanel and debugger.activeNearbyPanel.npcList,
            panel = debugger.activeNearbyPanel
        },
        {
            list = debugger.databasePanel and debugger.databasePanel.npcList,
            panel = debugger.databasePanel
        },
        {
            list = debugger.npcList,
            panel = nil
        }
    }

    for _, entry in ipairs(lists) do
        local list = entry.list
        if list and list.items then
            for i, listEntry in ipairs(list.items) do
                if listEntry.item and listEntry.item.id == id then
                    list.selected = i

                    if entry.panel then
                        debugger:onSelectNPC(listEntry.item, entry.panel)
                    else
                        debugger:onSelectNPC(listEntry.item)
                    end

                    return
                end
            end
        end
    end
end
