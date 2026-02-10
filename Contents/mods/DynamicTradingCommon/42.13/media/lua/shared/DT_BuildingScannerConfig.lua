-- =============================================================================
-- FILE: media/lua/shared/DT_Config.lua
-- AUTHOR: Dynamic Trading Mod Team
-- PURPOSE: Central configuration with county and town mapping
-- VERSION: 2.0 - Enhanced with County Support
-- =============================================================================

-- Create the global table if it doesn't exist yet
DTM = DTM or {}

-- Initialize the Config table
DTM.Config = {}

-- =============================================================================
-- SYSTEM SETTINGS
-- =============================================================================

-- If true, the mod will print detailed logs to the console.
DTM.Config.Debug = true

-- =============================================================================
-- BUILDING DETECTION SETTINGS
-- =============================================================================

-- The minimum total area (Width * Height) a building must have to be valid.
DTM.Config.MinBuildingArea = 60

-- The minimum length of the shortest side.
DTM.Config.MinBuildingDimension = 5

-- Max Distance (in squares) to search around a player.
DTM.Config.SearchRadius = 50

-- =============================================================================
-- NPC SPAWN PREFERENCES
-- =============================================================================

DTM.Config.PreferredRooms = {
    "livingroom",
    "kitchen",
    "foyer",
    "hall",
    "retail",
    "grocery",
    "office",
    "diner",
    "restaurant",
    "storefront"
}

DTM.Config.BlacklistedRooms = {
    "bathroom",
    "closet",
    "storage",
    "cell",
    "garage",
    "shed",
    "basement"
}

-- =============================================================================
-- KENTUCKY COUNTY & TOWN MAPPING
-- =============================================================================

-- Define counties with their coordinate bounds and towns
DTM.Counties = {
    {
        name = "Louisville",
        bounds = {minX = 12000, maxX = 14500, minY = 1000, maxY = 4000},
        towns = {"Louisville"}
    },
    {
        name = "Muldraugh",
        bounds = {minX = 10500, maxX = 13000, minY = 6600, maxY = 9500},
        towns = {"Muldraugh"}
    },
    {
        name = "Riverside",
        bounds = {minX = 6000, maxX = 7500, minY = 5000, maxY = 6500},
        towns = {"Riverside"}
    },
    {
        name = "West Point",
        bounds = {minX = 11000, maxX = 12500, minY = 4000, maxY = 5500},
        towns = {"West Point"}
    },
    {
        name = "Rosewood",
        bounds = {minX = 7500, maxX = 8500, minY = 11000, maxY = 12000},
        towns = {"Rosewood"}
    },
    {
        name = "March Ridge",
        bounds = {minX = 9500, maxX = 11000, minY = 11500, maxY = 13000},
        towns = {"March Ridge"}
    }
}

-- Specific town coordinates (more precise)
DTM.Towns = {
    {name = "Muldraugh", minX = 10500, maxX = 13000, minY = 6600, maxY = 9500},
    {name = "Rosewood", minX = 7500, maxX = 8500, minY = 11000, maxY = 12000},
    {name = "Riverside", minX = 6000, maxX = 7500, minY = 5000, maxY = 6500},
    {name = "West Point", minX = 11000, maxX = 12500, minY = 4000, maxY = 5500},
    {name = "Louisville", minX = 12000, maxX = 14500, minY = 1000, maxY = 4000},
    {name = "March Ridge", minX = 9500, maxX = 11000, minY = 11500, maxY = 13000}
}

-- =============================================================================
-- UTILITY: COUNTY DETECTION
-- =============================================================================

function DTM.GetCountyName(x, y)
    -- Check each defined county
    for _, county in ipairs(DTM.Counties) do
        if x >= county.bounds.minX and x <= county.bounds.maxX and
           y >= county.bounds.minY and y <= county.bounds.maxY then
            return county.name
        end
    end
    
    -- Fallback for areas outside known counties
    return "Unknown County"
end

-- =============================================================================
-- UTILITY: TOWN DETECTION (Enhanced)
-- =============================================================================

function DTM.GetTownName(x, y)
    -- 1. Check defined town boundaries first (most precise)
    for _, town in ipairs(DTM.Towns) do
        if x >= town.minX and x <= town.maxX and
           y >= town.minY and y <= town.maxY then
            return town.name
        end
    end

    -- 2. Fallback: Try Engine MetaGrid (Search for TownZone)
    local metaGrid = getWorld():getMetaGrid()
    if metaGrid then
        local zones = metaGrid:getZonesAt(x, y, 0)
        if zones then
            for i = 0, zones:size() - 1 do
                local z = zones:get(i)
                if z:getType() == "TownZone" then
                    return z:getName() or "Nearby Town"
                end
            end
        end
    end

    return "Wilderness"
end

-- =============================================================================
-- UTILITY: DETAILED BUILDING INFO
-- =============================================================================

function DTM.GetBuildingDetails(def)
    if not def then return {} end
    
    local details = {}
    details.roomCount = 0
    details.uniqueRooms = {}
    details.isAlarmed = def:isAlarmed()
    details.visited = def:isHasBeenVisited()
    details.id = def:getID()
    details.primaryRoom = "Building"

    local roomList = def:getRooms()
    if roomList then
        details.roomCount = roomList:size()
        local counts = {}
        local roomNames = {}
        
        for i = 0, roomList:size() - 1 do
            local r = roomList:get(i)
            local rName = r:getName() or "unknown"
            counts[rName] = (counts[rName] or 0) + 1
            if not roomNames[rName] then
                table.insert(details.uniqueRooms, rName)
                roomNames[rName] = true
            end
        end
        
        -- Determine primary room (most common or most important)
        local maxCount = 0
        for name, count in pairs(counts) do
            if count > maxCount then
                maxCount = count
                details.primaryRoom = name
            end
        end
        
        -- Prefer certain room types if present
        for _, preferredRoom in ipairs(DTM.Config.PreferredRooms) do
            if counts[preferredRoom] and counts[preferredRoom] > 0 then
                details.primaryRoom = preferredRoom
                break
            end
        end
    end

    return details
end

-- =============================================================================
-- SHARED BUILDING SCANNER
-- =============================================================================

function DTM.ScanForBuildings()
    print("[DTM] STARTING DETAILED BUILDING SCAN WITH COUNTY MAPPING...")
    local metaGrid = getWorld():getMetaGrid()
    if not metaGrid then return {} end

    local buildings = metaGrid:getBuildings()
    local potentialTradingPosts = {}
    local minArea = DTM.Config.MinBuildingArea
    
    for i = 0, buildings:size() - 1 do
        local def = buildings:get(i)
        local w, h = def:getW(), def:getH()
        local area = w * h

        if area >= minArea then
            local x, y = def:getX(), def:getY()
            local cx, cy = math.floor(x + (w/2)), math.floor(y + (h/2))
            local bDetails = DTM.GetBuildingDetails(def)
            local town = DTM.GetTownName(cx, cy)
            local county = DTM.GetCountyName(cx, cy)

            table.insert(potentialTradingPosts, {
                x = x, y = y, w = w, h = h,
                cx = cx, cy = cy,
                area = area, 
                name = bDetails.primaryRoom or "Building", 
                town = town,
                county = county,
                details = bDetails
            })
        end
    end
    
    print("[DTM] SCAN COMPLETE. Found " .. #potentialTradingPosts .. " buildings across multiple counties.")
    return potentialTradingPosts
end

-- =============================================================================
-- UTILITY: ZONE AREA HELPER (Build 42 Compatible)
-- =============================================================================

function DTM.GetZoneArea(z)
    if not z then return 0 end
    
    -- Try various ways to get dimensions based on Build 42 versions
    local w = 0
    local h = 0
    
    if z.getW and z.getH then
        w = z:getW()
        h = z:getH()
    elseif z.getWidth and z.getHeight then
        w = z:getWidth()
        h = z:getHeight()
    elseif z.w and z.h then
        w = z.w
        h = z.h
    end
    
    return w * h
end

-- =============================================================================
-- SHARED WILDERNESS SCANNER
-- =============================================================================

function DTM.ScanForWilderness()
    print("[DTM] SCANNING FOR WILDERNESS (GRID SAMPLING)...")
    local metaGrid = getWorld():getMetaGrid()
    if not metaGrid then return {} end

    local wildernessPoints = {}
    local zonesFound = 0
    
    -- Grid Sampling settings
    local minX, maxX = 3000, 15000
    local minY, maxY = 3000, 15000
    local step = 300 -- Check every 300 tiles

    for x = minX, maxX, step do
        for y = minY, maxY, step do
            local zones = metaGrid:getZonesAt(x, y, 0)
            if zones then
                for i = 0, zones:size() - 1 do
                    local z = zones:get(i)
                    local type = z:getType()
                    
                    if type == "Forest" or type == "DeepForest" or type == "Meadow" or 
                       type == "Vegetation" or type == "Farm" then
                        
                        local town = DTM.GetTownName(x, y)
                        local county = DTM.GetCountyName(x, y)
                        
                        -- Only add if truly wilderness
                        if town == "Wilderness" then
                            table.insert(wildernessPoints, {
                                x = x, y = y, 
                                cx = x, cy = y,
                                name = type,
                                town = "Wilderness",
                                county = county,
                                area = DTM.GetZoneArea(z),
                                details = {
                                    roomCount = 0, 
                                    uniqueRooms = {type}, 
                                    isAlarmed = false, 
                                    visited = false, 
                                    id = -1
                                }
                            })
                            zonesFound = zonesFound + 1
                            break
                        end
                    end
                end
            end
        end
    end
    
    print("[DTM] WILDERNESS SCAN COMPLETE. Found " .. zonesFound .. " natural locations.")
    return wildernessPoints
end

-- =============================================================================
-- SHARED ROAD SCANNER
-- =============================================================================

function DTM.ScanForRoads()
    print("[DTM] SCANNING FOR ROADS (GRID SAMPLING)...")
    local metaGrid = getWorld():getMetaGrid()
    if not metaGrid then return {} end

    local roadPoints = {}
    local zonesFound = 0
    local uniqueZoneTypes = {}
    
    local minX, maxX = 3000, 15000 
    local minY, maxY = 3000, 15000
    local step = 50 -- Small step to catch thin roads
    
    -- Zone types to look for
    local roadTypes = {
        ["Road"] = true,
        ["Street"] = true, 
        ["Highway"] = true,
        ["Path"] = true,
        ["Trail"] = true,
        ["ZoneRoad"] = true,
        ["Paved"] = true,
        ["Driveway"] = true,
        ["Parking"] = true,
        ["Nav"] = true,
        ["ForagingNav"] = true
    }

    for x = minX, maxX, step do
        for y = minY, maxY, step do
            local zones = metaGrid:getZonesAt(x, y, 0)
            if zones then
                for i = 0, zones:size() - 1 do
                    local z = zones:get(i)
                    local type = z:getType()
                    
                    -- Debug logging for new zone types
                    if not uniqueZoneTypes[type] then
                         uniqueZoneTypes[type] = true
                         if DTM.Config.Debug then
                             print("[DTM DEBUG] Found new zone type: " .. tostring(type))
                         end
                    end
                    
                    if roadTypes[type] or string.find(string.lower(type), "road") or 
                       string.find(string.lower(type), "street") then
                         
                        local town = DTM.GetTownName(x, y)
                        local county = DTM.GetCountyName(x, y)
                        
                        table.insert(roadPoints, {
                            x = x, y = y, 
                            cx = x, cy = y,
                            name = "Road (" .. type .. ")",
                            town = town,
                            county = county,
                            area = DTM.GetZoneArea(z),
                            details = {
                                roomCount = 0, 
                                uniqueRooms = {"Road"}, 
                                isAlarmed = false, 
                                visited = false, 
                                id = -1
                            }
                        })
                        zonesFound = zonesFound + 1
                        break 
                    end
                end
            end
        end
    end
    
    print("[DTM] ROAD SCAN COMPLETE. Found " .. zonesFound .. " road locations.")
    return roadPoints
end

-- =============================================================================
-- SHARED DATA LOADING
-- =============================================================================

function DTM.LoadBuildings()
    -- If already loaded with lookup, skip
    if DTM.Buildings and DTM.BuildingLookup then return true end

    local modData = ModData.getOrCreate("DT_Buildings")
    if modData and modData.locations then
        DTM.Buildings = modData.locations
        print("[DTM] Loaded " .. #DTM.Buildings .. " buildings from ModData.")
    else
        -- Fallback for clients/new worlds: scan locally
        DTM.Buildings = DTM.ScanForBuildings()
    end

    -- Build lookup table for O(1) UI resolution
    DTM.BuildingLookup = {}
    for _, b in ipairs(DTM.Buildings) do
        DTM.BuildingLookup[b.x .. "," .. b.y] = b
    end
    
    return true
end

-- =============================================================================
-- DEBUG HELPER
-- =============================================================================

function DTM.Log(message)
    if DTM.Config.Debug then
        print("[DTM DEBUG] " .. tostring(message))
    end
end