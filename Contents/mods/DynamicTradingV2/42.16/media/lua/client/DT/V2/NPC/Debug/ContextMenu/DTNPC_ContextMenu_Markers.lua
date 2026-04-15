-- ==============================================================================
-- DTNPC_ContextMenu_Markers.lua
-- Marker-related actions for the debug NPC context menu.
-- ==============================================================================

if not isDebugEnabled() then return end

DTNPCMenu = DTNPCMenu or {}
DTNPCMenu.ContextMenu = DTNPCMenu.ContextMenu or {}

local Menu = DTNPCMenu.ContextMenu

if Menu.MarkersLoaded then
    return
end

Menu.MarkersLoaded = true

local function ensureMarkerHandler(player)
    if EventMarkerHandler then
        return true
    end

    if player then
        player:Say("EventMarkerHandler not available!")
    end

    return false
end

function Menu.OnMarkNPC(player, npc)
    if not npc or not player then return end
    if not ensureMarkerHandler(player) then return end

    local npcData = Menu.GetNPCData(npc)
    if not npcData then
        player:Say("Cannot mark: No NPC data")
        return
    end

    local id = npc:getPersistentOutfitID()
    local x = npc:getX()
    local y = npc:getY()
    local color, icon = Menu.GetMarkerVisuals(npcData)
    local description = Menu.BuildMarkerDescription(player, npcData, x, y)

    EventMarkerHandler.set("npc_" .. id, icon, 1800, x, y, color, description)
    player:Say("Marked NPC: " .. npcData.name)
end

function Menu.OnMarkAllNPCs(player)
    if not ensureMarkerHandler(player) then return end

    local count = 0

    if DTNPCClient and DTNPCClient.NPCCache then
        for id, entry in pairs(DTNPCClient.NPCCache) do
            local npcData = entry.npcData
            if npcData and npcData.lastX and npcData.lastY then
                local color, icon = Menu.GetMarkerVisuals(npcData)
                local description = Menu.BuildMarkerDescription(player, npcData, npcData.lastX, npcData.lastY)

                EventMarkerHandler.set(
                    "npc_" .. id,
                    icon,
                    1800,
                    npcData.lastX,
                    npcData.lastY,
                    color,
                    description
                )

                count = count + 1
            end
        end
    end

    player:Say("Marked " .. count .. " NPCs")
end

function Menu.OnClearNPCMarkers(player)
    if not ensureMarkerHandler(player) then return end

    local count = 0

    for markerId, _ in pairs(EventMarkerHandler.markers) do
        if string.sub(markerId, 1, 4) == "npc_" then
            EventMarkerHandler.remove(markerId)
            count = count + 1
        end
    end

    player:Say("Cleared " .. count .. " NPC markers")
end
