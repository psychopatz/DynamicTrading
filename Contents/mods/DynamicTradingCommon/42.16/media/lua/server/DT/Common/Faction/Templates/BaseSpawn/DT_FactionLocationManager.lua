-- ==============================================================================
-- media/lua/server/DT_FactionLocationManager.lua
-- Logic: Managing the assignment of physical bases to Factions.
-- Build 42 Compatible.
-- ==============================================================================

require "DT/Common/Faction/Templates/BaseSpawn/Rosewood"
require "DT/Common/Faction/Templates/BaseSpawn/Muldraugh"
require "DT/Common/Faction/Templates/BaseSpawn/WestPoint"
require "DT/Common/Faction/Templates/BaseSpawn/Riverside"
require "DT/Common/Faction/Templates/BaseSpawn/Louisville"


DT_FactionLocationManager = {}

-- ==========================================================
-- 1. HELPER: GET ALL REGISTERED LOCATIONS
-- ==========================================================
-- This function gathers every location from every town file (Rosewood, Muldraugh, etc.)
function DT_FactionLocationManager.GetAllPotentialBases()
    local allBases = {}
    
    if not DT_FactionLocations then 
        DynamicTrading.Log("DTCommons", "Error", "Faction", "No Faction Locations registered in DT_FactionLocations!")
        return allBases 
    end

    for townName, basesInTown in pairs(DT_FactionLocations) do
        for _, baseData in ipairs(basesInTown) do
            -- We inject the town name into the data for better tracking
            local entry = {
                name = baseData.name,
                coords = baseData.coords,
                town = townName
            }
            table.insert(allBases, entry)
        end
    end
    
    return allBases
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

    local allPotential = DT_FactionLocationManager.GetAllPotentialBases()
    if #allPotential == 0 then return nil end

    -- Get currently taken locations from our Faction ModData
    local takenLocations = {}
    local factionData = ModData.get("DynamicTrading_Factions") or {}
    
    for id, data in pairs(factionData) do
        if data.homeCoords and data.homeCoords.name then
            takenLocations[data.homeCoords.name] = true
        end
    end

    -- Filter out the taken ones and filter by town if targetTown is provided
    local available = {}
    for _, base in ipairs(allPotential) do
        local isCorrectTown = (not targetTown) or (base.town == targetTown)
        if isCorrectTown and not takenLocations[base.name] then
            table.insert(available, base)
        end
    end

    -- If no spots are left in this town, this faction becomes nomadic by default
    if #available == 0 then
        local townLog = targetTown and (" in " .. targetTown) or ""
        DynamicTrading.Log("DTCommons", "Faction", "Warn", "All registered faction bases" .. townLog .. " are occupied! Faction [" .. factionID .. "] is now nomadic.")
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