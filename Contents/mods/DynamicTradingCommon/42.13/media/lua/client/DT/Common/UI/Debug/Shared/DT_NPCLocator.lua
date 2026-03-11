-- ==============================================================================
-- DT_NPCLocator.lua
-- Reusable NPC Location Marker Utility
-- Integrates with EventMarkerHandler to mark NPC positions on map
-- ==============================================================================

DT_NPCLocator = DT_NPCLocator or {}

-- ==========================================================
-- NPC POSITION RESOLVER
-- ==========================================================
local function resolveNPCPosition(soul)
    if not soul then return nil, nil end
    
    local status = soul.status or "Resting"
    local targetX, targetY
    
    if status == "Resting" or status == "Away" then
        targetX = soul.homeCoords and soul.homeCoords.x
        targetY = soul.homeCoords and soul.homeCoords.y
    elseif status == "Trading" then
        targetX = soul.lastX
        targetY = soul.lastY
    elseif status == "Working" then
        targetX = soul.workCoords and soul.workCoords.x
        targetY = soul.workCoords and soul.workCoords.y
    end
    
    return targetX, targetY, status
end

-- ==========================================================
-- MARKER CREATION
-- ==========================================================
function DT_NPCLocator.locateNPC(uuid, soul, options)
    if not soul then
        DynamicTrading.Log("DTCommons", "Debug", "NPC", "ERROR: No soul data provided for UUID: " .. tostring(uuid))
        return false
    end
    
    local targetX, targetY, status = resolveNPCPosition(soul)
    
    if not targetX or not targetY then
        local player = getPlayer()
        if player then
            player:Say("No coordinates found for NPC: " .. (soul.name or "Unknown"))
        end
        DynamicTrading.Log("DTCommons", "Debug", "NPC", "No coordinates for NPC: " .. (soul.name or "Unknown"))
        return false
    end
    
    -- Check if EventMarkerHandler is available
    if not EventMarkerHandler then
        DynamicTrading.Log("DTCommons", "Debug", "NPC","ERROR: EventMarkerHandler not available!")
        local player = getPlayer()
        if player then
            player:Say("EventMarkerHandler not loaded!")
        end
        return false
    end
    
    -- Apply options or use defaults
    local markerID = options and options.markerID or ("locate_" .. uuid)
    local icon = options and options.icon or "friend.png"
    local duration = options and options.duration or 600 -- 10 minutes default
    local color = options and options.color or {r=0, g=1, b=1}
    local description = options and options.description or ("Target: " .. (soul.name or "Unknown") .. " (" .. status .. ")")
    
    -- Set the marker
    EventMarkerHandler.set(
        markerID,
        icon,
        duration,
        targetX,
        targetY,
        color,
        description
    )
    
    -- Feedback
    local player = getPlayer()
    if player then
        player:Say("Marked NPC location on map: " .. (soul.name or "Unknown"))
    end
    
    DynamicTrading.Log("DTCommons", "Debug", "NPC", "Marked NPC: " .. (soul.name or "Unknown") .. " at " .. targetX .. "," .. targetY)
    return true
end

-- ==========================================================
-- BATCH LOCATION
-- ==========================================================
function DT_NPCLocator.locateFactionNPCs(factionRoster, factionName)
    if not factionRoster or #factionRoster == 0 then
        DynamicTrading.Log("DTCommons", "Debug", "NPC", "No NPCs in faction roster")
        return 0
    end
    
    local count = 0
    for i, data in ipairs(factionRoster) do
        if data.soul and data.uuid then
            local success = DT_NPCLocator.locateNPC(data.uuid, data.soul, {
                markerID = "faction_" .. factionName .. "_" .. i,
                color = {r=0, g=0.8, b=1}
            })
            if success then count = count + 1 end
        end
    end
    
    return count
end

-- ==========================================================
-- MARKER REMOVAL
-- ==========================================================
function DT_NPCLocator.removeMarker(markerID)
    if EventMarkerHandler and EventMarkerHandler.remove then
        EventMarkerHandler.remove(markerID)
        return true
    end
    return false
end

function DT_NPCLocator.removeAllNPCMarkers()
    if not EventMarkerHandler or not EventMarkerHandler.markers then return 0 end
    
    local count = 0
    for markerID, _ in pairs(EventMarkerHandler.markers) do
        if string.match(markerID, "^locate_") or string.match(markerID, "^faction_") then
            EventMarkerHandler.remove(markerID)
            count = count + 1
        end
    end
    
    return count
end

DynamicTrading.Log("DTCommons", "Debug", "NPC", "NPC Locator Utility Loaded")
