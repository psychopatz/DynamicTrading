-- ==============================================================================
-- media/lua/server/DT_FactionLocationManager.lua
-- Logic: Managing the assignment of physical bases to Factions.
-- Build 42 Compatible.
-- ==============================================================================

require "DT/Common/GeolocatorSystem/DT_GeolocatorSystem"


DT_FactionLocationManager = {}

local function buildTakenLocationIndex()
    local takenLocations = {}
    local factionData = ModData.get("DynamicTrading_Factions") or {}

    for _, data in pairs(factionData) do
        if data.homeCoords and data.homeCoords.name then
            takenLocations[data.homeCoords.name] = true
        end
    end

    return takenLocations
end

-- ==========================================================
-- 1. HELPER: GET ALL REGISTERED LOCATIONS
-- ==========================================================
-- This function gathers every location from every town file (Rosewood, Muldraugh, etc.)
function DT_FactionLocationManager.GetAllPotentialBases(targetTown, takenLocations)
    if DT_GeolocatorSystem and DT_GeolocatorSystem.GetAvailableFactionBases then
        return DT_GeolocatorSystem.GetAvailableFactionBases(targetTown, takenLocations or {})
    end

    DynamicTrading.Log("DTCommons", "Error", "Faction", "GeolocatorSystem is unavailable. No dynamic faction bases could be resolved.")
    return {}
end

-- ==========================================================
-- 2. LOGIC: CLAIM A HOME FOR A FACTION
-- ==========================================================
function DT_FactionLocationManager.AssignHome(factionID, targetTown)
    -- FAILSAFE: If the faction is the "Independent" faction, they are nomads.
    -- They get no home coordinates.
    if factionID == "Independent" or factionID == "Factionless" then
        DynamicTrading.Log("DTCommons", "Faction", "Logic", "Faction [" .. factionID .. "] is nomadic. Skipping home assignment.")
        return nil
    end

    local takenLocations = buildTakenLocationIndex()
    local available = DT_FactionLocationManager.GetAllPotentialBases(targetTown, takenLocations)

    if #available == 0 then
        available = DT_FactionLocationManager.GetAllPotentialBases(nil, takenLocations)
    end

    if #available == 0 then
        local townLog = targetTown and (" in " .. targetTown) or ""
        DynamicTrading.Log("DTCommons", "Faction", "Warn", "All geolocated faction bases" .. townLog .. " are occupied! Faction [" .. factionID .. "] is now nomadic.")
        return nil
    end

    -- Pick a random available spot
    local choice = available[ZombRand(#available) + 1]
    
    DynamicTrading.Log("DTCommons", "Faction", "Logic", "Faction [" .. factionID .. "] has claimed " .. choice.name .. " in " .. choice.town)
    
    return {
        name = choice.name,
        x = choice.coords.x,
        y = choice.coords.y,
        z = choice.coords.z,
        town = choice.town
    }
end

-- ==========================================================
-- 3. UTILITY: FIND FACTION BY LOCATION
-- ========================== ================================
-- Useful if you want to know "Who lives here?" when a player enters a zone.
function DT_FactionLocationManager.GetOwnerOfLocation(locationName)
    local factionData = ModData.get("DynamicTrading_Factions") or {}
    for id, data in pairs(factionData) do
        if data.homeCoords and data.homeCoords.name == locationName then
            return id
        end
    end
    return nil
end

DynamicTrading.Log("DTCommons", "Init", "Faction", "Faction Location Manager Initialized")