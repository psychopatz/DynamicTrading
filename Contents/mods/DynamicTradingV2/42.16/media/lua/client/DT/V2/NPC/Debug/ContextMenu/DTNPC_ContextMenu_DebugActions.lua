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

local function formatBandageTime(timeValue)
    local numeric = math.max(0, tonumber(timeValue) or 0)
    if numeric <= 0 then
        return "0"
    end

    return tostring(math.floor(numeric))
end

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

function Menu.OnForceBandage(player, npc)
    if not npc or not player then return end

    local npcData = Menu.GetNPCData(npc)
    if not npcData or not npcData.uuid then
        player:Say("Bandage test unavailable for this NPC.")
        return
    end

    sendClientCommand(player, "DTNPC", "DebugForceBandage", {
        uuid = npcData.uuid,
    })

    player:Say("Force bandage: " .. tostring(npcData.name or npcData.uuid))
end

function Menu.OnForceCorpseCleanup(player, npc)
    if not npc or not player then return end

    local npcData = Menu.GetNPCData(npc)
    if not npcData or not npcData.uuid then
        player:Say("Corpse cleanup test unavailable for this NPC.")
        return
    end

    sendClientCommand(player, "DTNPC", "DebugForceCorpseCleanup", {
        uuid = npcData.uuid,
    })

    player:Say("Force corpse cleanup: " .. tostring(npcData.name or npcData.uuid))
end

function Menu.OnDebugBandageInfo(player, npc)
    if not npc or not player then return end

    local npcData = Menu.GetNPCData(npc)
    if not npcData or not DTNPCHealth or not DTNPCHealth.GetBandageDebugInfo then
        player:Say("Bandage debug unavailable.")
        return
    end

    local info = DTNPCHealth.GetBandageDebugInfo(npc, npcData)
    if not info then
        player:Say("Bandage debug unavailable.")
        return
    end

    DynamicTrading.Log(
        "DTV2",
        "NPC",
        "Debug",
        "BandageInfo name=" .. tostring(npcData.name or npcData.uuid or "Unknown")
            .. " uuid=" .. tostring(npcData.uuid)
            .. " state=" .. tostring(info.state)
            .. " status=" .. tostring(info.status)
            .. " active=" .. tostring(info.activeBandage)
            .. " dirty=" .. tostring(info.bandageDirty)
            .. " tier=" .. tostring(info.bandageTier)
            .. " tierLabel=" .. tostring(info.bandageTierLabel)
            .. " healRemaining=" .. tostring(string.format("%.2f", info.bandageHealRemaining or 0))
            .. "/" .. tostring(string.format("%.2f", info.bandageHealPool or 0))
            .. " visible=" .. tostring(info.visible)
            .. " supply=" .. tostring(info.hasSupply)
            .. " unlimited=" .. tostring(info.bandageUnlimited)
            .. " charges=" .. tostring(info.bandageCharges)
            .. " hp=" .. tostring(string.format("%.2f", info.current)) .. "/" .. tostring(string.format("%.2f", info.max))
            .. " ratio=" .. tostring(string.format("%.3f", info.ratio or 0))
            .. " threshold=" .. tostring(string.format("%.3f", info.threshold or 0))
            .. " retryAt=" .. formatBandageTime(info.retryAt)
            .. " actionUntil=" .. formatBandageTime(info.actionUntil)
    )

    player:Say("Bandage info printed.")
end

function Menu.OnOpenLootVisionInspector(player, npc)
    if not player then return end

    local npcData = npc and Menu.GetNPCData and Menu.GetNPCData(npc) or nil
    require "DT/V2/NPC/Debug/DTNPC_LootVisionWindow"
    if DTNPC_LootVisionWindow and DTNPC_LootVisionWindow.Open then
        DTNPC_LootVisionWindow.Open(player:getPlayerNum(), npcData)
    else
        player:Say("Loot vision inspector unavailable.")
    end
end
